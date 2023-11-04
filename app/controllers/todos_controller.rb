require 'csv'

class TodosController < ApplicationController
    def index
        @todos = Todo.all
    end

    def create
        @todo = Todo.new(todo_params)
        if @todo.save
            redirect_to todos_path
        else
            render :index
        end
    end

    def show
        @todo = Todo.find(params[:id])
    end

    def export
        @todos = Todo.all
    
        csv_data = CSV.generate(headers: true) do |csv|
          csv << ['ID', 'Title'] # CSV Header
    
          @todos.each do |todo|
            csv << [todo.id, todo.title]
          end
        end
    
        send_data csv_data, filename: "todos-#{Date.today}.csv"
    end

    def import
        if params[:file].present?
          CSV.foreach(params[:file].path, headers: true) do |row|
            Todo.create(title: row['Title'])
          end
          flash[:notice] = "Todos imported successfully!"
        else
          flash[:alert] = "Please upload a CSV file."
        end
        redirect_to todos_path
    end
    
    private

    def todo_params
        params.require(:todo).permit(:title)
    end
end
