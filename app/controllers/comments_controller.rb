class CommentsController < ApplicationController
  
  def edit
    @comment = Comment.find(params[:id])
    render(:action => 'edit')
  end
  
  def update
    @comment = Comment.find(params[:id])
    c_name   = controller_name(@comment.commentable_type)
    
    if @comment.update_attributes(params[:comment])
      flash[:notice] = 'Comment was successfully updated.'
      redirect_to :controller => c_name, 
                  :action => :show,
                  :id => @comment.commentable_id
    else
      redirect_to :back 
    end
    
    def destroy
      @comment = Comment.find(params[:id])
      @comment.destroy
      flash[:notice] = 'Comment was successfully deleted'
      redirect_to :controller => controller_name(@comment.commentable_type), 
                  :action => :show,
                  :id => @comment.commentable_id
    end
  end
  
private
  def controller_name(commentable_type)
  #convert class name to controller name by pluralizing, and inserting '_' as needed
    name = commentable_type.downcase.pluralize
    case name[0,4]
      when "olig"
        c_name = name.insert(5, '_')
      when "pool"
        c_name = name.insert(4, '_')
      else
        c_name = name
    end
    return c_name
  end
  
end
