import os
import shutil
import subprocess
import pandas as pd
from flask import Flask, request, render_template, jsonify

app = Flask(__name__)

# Rota principal
@app.route('/', methods=['GET', 'POST'])
def index():
    message = None
    tabela_html = None
    total_items = 0

    if request.method == 'POST':
        message = "Iniciando Processo..."

        repositoryUrl = request.form['repositoryUrl']
        sysFolder = request.form['sysFolder']
        testFolder = request.form['testFolder']
        nCommit = request.form['nCommit']

        PATHSYS = os.path.join(os.getcwd(), "database", sysFolder)
        PATHTEST = os.path.join(PATHSYS, testFolder)
        PATHSCRIPT = os.getcwd()
        PATHXML = os.path.join(PATHSYS, "xml")
        MINEFEATURES_DIR = os.path.join(PATHSCRIPT, "MineFeaturesLines")
        DOXYGEN_DIR = os.path.join(PATHSCRIPT, "Doxygen")

        def remove_lock_file():
            lock_file = os.path.join(PATHSYS, '.git', 'index.lock')
            if os.path.isfile(lock_file):
                os.remove(lock_file)
                print("Removed lock file: " + lock_file)

        try:
            if os.path.isdir("database"):
                os.chdir("database")
                result = subprocess.run(["git", "stash"], capture_output=True, text=True)
                if result.returncode != 0:
                    raise RuntimeError(f"Failed to stash changes: {result.stderr}")

                if os.path.isdir("clean"):
                    shutil.rmtree("clean")

                if os.path.isdir(sysFolder):
                    print("System already exists")
                    remove_lock_file()
                    message = "Sistema já existe."
                else:
                    result = subprocess.run(["git", "clone", repositoryUrl], capture_output=True, text=True)
                    if result.returncode != 0:
                        raise RuntimeError(f"Failed to clone the repository: {result.stderr}")
                    message = "Repositório clonado com sucesso."
            else:
                os.makedirs("database")
                os.chdir("database")
                result = subprocess.run(["git", "clone", repositoryUrl], capture_output=True, text=True)
                if result.returncode != 0:
                    raise RuntimeError(f"Failed to clone the repository: {result.stderr}")
                message = "Pasta criada e repositório clonado com sucesso."

            if not os.path.isdir(sysFolder):
                raise RuntimeError("Failed to clone the repository.")

            if not os.path.isdir(MINEFEATURES_DIR):
                raise RuntimeError(f"Directory {MINEFEATURES_DIR} does not exist.")

            os.chdir(MINEFEATURES_DIR)
            result = subprocess.run(["gradle", "run", f"-Pmyargs={PATHSYS},{os.path.join(PATHSCRIPT, 'result-featurelocation')},{nCommit}"], capture_output=True, text=True)
            if result.returncode != 0:
                raise RuntimeError(f"Gradle task failed: {result.stderr}")

            message = "Processo concluído com sucesso."

        except Exception as error:
            message = f"Erro: {error}"

        # Doxygen
        try:
            doxyfile_source = os.path.join(DOXYGEN_DIR, "Doxyfile")
            doxyfile_dest = os.path.join(PATHSYS, "Doxyfile")

            if not os.path.isfile(doxyfile_source):
                raise FileNotFoundError(f"Doxyfile not found at {doxyfile_source}")

            shutil.copyfile(doxyfile_source, doxyfile_dest)
            os.chdir(PATHSYS)
            subprocess.run(["doxygen", "Doxyfile"], check=True)
            message = "Doxygen process completed successfully."

        except FileNotFoundError as ex:
            message = f"Doxyfile not found: {ex}"
        except subprocess.CalledProcessError as ex:
            message = f"Error during Doxygen execution: {ex}"
        except Exception as error:
            message = f"An error occurred: {error}"

        # MineTestLines
        try:
            os.chdir(os.path.join(PATHSCRIPT, "MineTestLines"))
            subprocess.run(["python3", "MineTestLines.py", PATHTEST, PATHXML, testFolder], check=True)

            os.chdir(os.path.join(PATHSCRIPT, "MergeTestFeaturesLines"))
            subprocess.run(["python3", "MergeTestFeaturesLines.py", os.path.join(PATHSCRIPT, "MineTestLines", "result", "MineTestLines.csv"), os.path.join(PATHSCRIPT, "result-featurelocation", nCommit, "FilesFeature", "feature.csv")], check=True)

            message = "Processo de teste concluído."

        except Exception as error:
            message = f"An error occurred: {error}"

    # Parâmetros de paginação e busca
    page = request.args.get('page', 1, type=int)
    search_query = request.args.get('search', "", type=str)
    per_page = 10

    # Carregar dados da tabela para a página atual
    csv_file_path = os.path.join(os.path.dirname(__file__), 'MergeTestFeaturesLines', 'result', 'feature2test.csv')
    try:
        tabela_data, total_items = gerar_tabela(csv_file_path, page=page, per_page=per_page, search_query=search_query)

        # Converter o DataFrame em HTML
        if tabela_data is not None:
            tabela_html = tabela_data.to_html(classes='table table-striped', index=False)
        else:
            tabela_html = "Nenhum dado encontrado."

    except Exception as error:
        message = f"Erro ao gerar a tabela: {error}"

    return render_template('index.html', message=message, tabela_html=tabela_html, page=page, per_page=per_page)

# Rota sobre
@app.route('/about')
def about():
    return render_template('about.html')

# Rota do usuário
@app.route('/user/<username>')
def user(username):
    return f'Hello, {username}!'

def gerar_tabela(csv_file_path, page=1, per_page=10, search_query=""):
    try:
        df = pd.read_csv(csv_file_path)

        # Filtrar os dados com base no critério de busca
        if search_query:
            df = df[df.apply(lambda row: row.astype(str).str.contains(search_query, case=False).any(), axis=1)]

        # Calcular índices de início e fim para paginação
        start_idx = (page - 1) * per_page
        end_idx = start_idx + per_page

        # Obter os dados para a página atual
        paginated_data = df.iloc[start_idx:end_idx]

        return paginated_data, len(df)  # Retornando também o total de itens
    except Exception as e:
        print(f"Erro ao gerar tabela: {e}")
        return None, 0  # Retorna None e 0 em caso de erro

def count_pages(total_items, per_page=10):
    total_pages = (total_items + per_page - 1) // per_page
    return total_pages

@app.route('/get_table', methods=['GET'])
def get_table():
    table_option = request.args.get('table_option', 'MergeFeatureLines')
    page = request.args.get('page', 1, type=int)
    search_query = request.args.get('search', "", type=str)
    per_page = 10

    # Determinar o caminho do arquivo CSV com base na opção de tabela selecionada
    if table_option == 'MineTestLines':
        csv_file_path = os.path.join(os.path.dirname(__file__), 'MineTestLines', 'result', 'MineTestLines.csv')
    else:
        csv_file_path = os.path.join(os.path.dirname(__file__), 'MergeTestFeaturesLines', 'result', 'feature2test.csv')

    try:
        tabela_data, total_items = gerar_tabela(csv_file_path, page=page, per_page=per_page, search_query=search_query)
        total_pages = count_pages(total_items, per_page=per_page)
    except Exception as error:
        return jsonify({'error': str(error)}), 500

    return jsonify({
        'tabela_html': tabela_data.to_html(classes='table table-striped', index=False) if tabela_data is not None else "Nenhum dado encontrado.",
        'total_pages': total_pages
    })

@app.route('/get_chart_data', methods=['GET'])
def get_chart_data():
    table_option = request.args.get('table_option', 'MergeTestFeaturesLines')
    column = request.args.get('column', default='TestFile', type=str)

    if table_option == 'MineTestLines':
        csv_file_path = os.path.join(os.path.dirname(__file__), 'MineTestLines', 'result', 'MineTestLines.csv')
    else:
        csv_file_path = os.path.join(os.path.dirname(__file__), 'MergeTestFeaturesLines', 'result', 'feature2test.csv')

    try:
        df = pd.read_csv(csv_file_path)
        top_5 = df[column].value_counts().nlargest(5)
        data = [{'label': label, 'value': value} for label, value in top_5.items()]

        return jsonify(data)
    except Exception as error:
        return jsonify({'error': str(error)}), 500

if __name__ == '__main__':
    app.run(debug=True)
