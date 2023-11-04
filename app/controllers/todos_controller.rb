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

  def export
    send_data TodoExporter.new(Todo.all).generate_csv, filename: "todos-#{Date.today}.csv"
  end

  def import
    if params[:file].present?
      begin
        TodoImporter.new(params[:file].path).import_csv
        redirect_to todos_path, notice: 'Todos imported successfully!'
      rescue => e
        redirect_to todos_path, alert: e.message
      end
    else
      redirect_to todos_path, alert: 'Please upload a CSV file.'
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

class TodoExporter
  def initialize(todos)
    @todos = todos
  end

  def generate_csv
    CSV.generate(headers: true) do |csv|
      csv << ['ID', 'Title']
      @todos.each do |todo|
        csv << [todo.id, todo.title]
      end
    end
  end
end

class TodoImporter
  def initialize(file_path)
    @file_path = file_path
  end

  def import_csv
    CSV.foreach(@file_path, headers: true) do |row|
      Todo.create!(title: row['Title'])
    end
  end
end
