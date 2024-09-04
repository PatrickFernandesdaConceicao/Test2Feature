import pandas as pd

def gerar_tabela(csv_file_path):
    try:
        df = pd.read_csv(csv_file_path)
        return df.to_html(classes='table table-striped')
    except Exception as e:
        print(f"Erro ao gerar a tabela: {e}")
        raise
