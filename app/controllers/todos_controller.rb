require 'csv'

class TodosController < ApplicationController
  before_action :set_todo, only: [:show]
  
  def index
    @todos = Todo.all
  end

  def create
    @todo = Todo.new(todo_params)
    if @todo.save
      redirect_to todos_path, notice: 'Todo was successfully created.'
    else
      render :index
    end
  end

  def show; end

  # CSVエクスポートアクションをトリガーします。
  def export
    # TodoExporterサービスを利用してCSVデータを生成し、ファイルダウンロードとして送信します。
    send_data TodoExporter.new(Todo.all).generate_csv, filename: "todos-#{Date.today}.csv"
  end

  # CSVファイルからTodosを読み込むためのインポートアクションをトリガーします。
  def import
    # ファイルがアップロードされたかどうかを確認します。
    if params[:file].present?
      begin
        # TodoImporterサービスを利用してCSVデータをインポートします。
        TodoImporter.new(params[:file].path).import_csv
        # インポートが成功したら、成功通知とともにインデックスアクションにリダイレクトします。
        redirect_to todos_path, notice: 'Todosが正常にインポートされました！'
      rescue => e
        # エラーが発生した場合、アラートとともにインデックスアクションにリダイレクトします。
        redirect_to todos_path, alert: e.message
      end
    else
      # ファイルがアップロードされていない場合、アラートとともにインデックスアクションにリダイレクトします。
      redirect_to todos_path, alert: 'CSVファイルをアップロードしてください。'
    end
  end
  
  private

  def set_todo
    @todo = Todo.find(params[:id])
  end

  def todo_params
    params.require(:todo).permit(:title)
  end
end

# TodoExporterサービスオブジェクトは、Todo項目のCSVデータ生成を処理します。
class TodoExporter
    def initialize(todos)
      @todos = todos
    end
  
    # ヘッダー付きのCSV文字列を生成し、ファイルダウンロードに使用します。
    def generate_csv
      CSV.generate(headers: true) do |csv|
        csv << ['ID', 'Title'] # CSVヘッダーを追加します。
        @todos.each do |todo|
          csv << [todo.id, todo.title] # 各TodoのデータをCSVに追加します。
        end
      end
    end
  end
  
  # TodoImporterサービスオブジェクトは、CSVファイルからTodo項目のインポートを処理します。
  class TodoImporter
    def initialize(file_path)
      @file_path = file_path
    end
  
    # CSVファイルを読み取り、各行からTodo項目を作成します。
    def import_csv
      CSV.foreach(@file_path, headers: true) do |row|
        Todo.create!(title: row['Title']) # エラーチェック付きでTodo項目を作成します。
      end
    end
  end
