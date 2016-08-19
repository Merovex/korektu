class FixesController < ApplicationController
  protect_from_forgery except: :create
  before_action :set_book
  before_action :set_fix, only: [:show, :edit, :update, :destroy]

  # GET /fixes
  # GET /fixes.json
  def index
    @fixes = @book.fixes
  end

  # GET /fixes/1
  # GET /fixes/1.json
  def show
  end

  # GET /fixes/new
  def new
    @fix = @book.fixes.new
  end

  # GET /fixes/1/edit
  def edit
  end
  def create
    @fix = @book.fixes.new(fix_params)
    # raise @fix.inspect

    respond_to do |format|
      if @fix.save
        format.html { redirect_to book_fixes_path @book, notice: 'Fix was successfully created.' }
        format.json { render :show, status: :created, location: @fix }
      else
        format.html { render :new }
        format.json { render json: @fix.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /fixes/1
  # PATCH/PUT /fixes/1.json
  def update
    respond_to do |format|
      if @fix.update(fix_params)
        format.html { redirect_to @book, notice: 'Fix was successfully updated.' }
        format.json { render :show, status: :ok, location: @fix }
      else
        format.html { render :edit }
        format.json { render json: @fix.errors, status: :unprocessable_entity }
      end
    end
  end
  def destroy
    @fix.destroy
    respond_to do |format|
      format.html { redirect_to fixes_url, notice: 'Fix was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fix
      @fix = @book.fixes.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def fix_params
      # raise params.inspect
      params.require(:fix).permit(:version_id, :book_id, :kind, :fixed, :text, :email, :name, :location)
    end
end
