import sys
import pandas as pd

def ler_arquivo_metabase(caminho_arquivo: str) -> pd.DataFrame:
    print(f"Lendo base Metabase: {caminho_arquivo}")
    df = pd.read_csv(
        caminho_arquivo,
        on_bad_lines="skip",
    )

    base = pd.DataFrame()

    base["Cliente"] = df["Cliente"]
    base["Ativo"] = df["Ativo"]
    base["Data de Nascimento"] = pd.to_datetime(
        df["Data de Nascimento"], errors="coerce"
    ).dt.strftime("%Y-%m-%d")
    base["Telefone"] = df["Telefone"]
    base["E-mail"] = df["E-mail"]
    base["Data da Última Compra"] = pd.to_datetime(
        df["Data da Última Compra"], errors="coerce"
    ).dt.strftime("%Y-%m-%d")
    base["Código do Vendedor"] = df["Código do Vendedor"]
    base["ID da(s) Etapa(s) em que o Cliente Comprou"] = df[
        "ID da(s) Etapa(s) em que o Cliente Comprou"
    ]
    base["Valor Total Comprado"] = df["Valor Total Comprado"]

    return base

def merge_etapas(series: pd.Series) -> str:
    etapas = []
    for valor in series.dropna().astype(str):
        for e in valor.split(","):
            e = e.strip()
            if e:
                etapas.append(e)

    visto = set()
    resultado = []
    for e in etapas:
        if e not in visto:
            visto.add(e)
            resultado.append(e)

    return ",".join(resultado)

def pedir_arquivos() -> list[str]:
    print("Digite o caminho (ou nome) de cada arquivo CSV que será lido.")
    print("Exemplos:")
    print("  janeiro a abril.csv")
    print("  /Users/fulano/Downloads/maio a agosto.csv")
    print("Quando terminar, apenas pressione Enter em branco.\n")

    arquivos = []
    while True:
        caminho = input("Arquivo CSV (ou Enter para finalizar): ").strip()
        if not caminho:
            break
        arquivos.append(caminho)

    if not arquivos:
        print("Nenhum arquivo informado. Encerrando.")
        sys.exit(1)

    return arquivos

def main():
    arquivos_metabase = pedir_arquivos()

    dataframes = [ler_arquivo_metabase(arq) for arq in arquivos_metabase]]

    df = pd.concat(dataframes, ignore_index=True)

    df["Valor Total Comprado"] = pd.to_numeric(
        df["Valor Total Comprado"], errors="coerce"
    ).fillna(0)

    group_cols = [
        "Cliente",
        "Ativo",
        "Data de Nascimento",
        "Telefone",
        "E-mail",
        "Código do Vendedor",
    ]

    agrupado = (
        df.groupby(group_cols, dropna=False)
        .agg(
            {
                "Data da Última Compra": "max",
                "Valor Total Comprado": "sum",
                "ID da(s) Etapa(s) em que o Cliente Comprou": merge_etapas,
            }
        )
        .reset_index()
    )

    agrupado = agrupado.sort_values(by=["Cliente"])

    agrupado["Valor Total Comprado"] = agrupado["Valor Total Comprado"].round(2)

    saida = "base_compradores_final.csv"
    agrupado.to_csv(
    saida,
    index=False,
    sep=";",
    decimal=",",
    float_format="%.2f",
    )
    print(f"Arquivo final salvo em: {saida}")

if __name__ == "__main__":
    main()
