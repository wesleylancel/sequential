require 'test_helper'

# Test Models:
#
#   Post        - scope: :author_id
#   Invoice     - scope: :client_id, start_at: 1000
#   Product     - scope: :category_id, skip: lambda { |p| p.price == -1 }
class HasSequentialIdTest < ActiveSupport::TestCase
  test 'basic scoped operation' do
    p = Post.create(author_id: 1)
    assert_equal 1, p.sequential_id

    p = Post.create(author_id: 1)
    assert_equal 2, p.sequential_id

    p = Post.create(author_id: 2)
    assert_equal 1, p.sequential_id
  end
  
  test 'start_at' do
    i = Invoice.create(client_id: 1)
    assert_equal 1000, i.sequential_id

    i = Invoice.create(client_id: 1)
    assert_equal 1001, i.sequential_id

    i = Invoice.create(client_id: 2)
    assert_equal 1000, i.sequential_id
  end

  test 'skip' do
    p = Product.create(category_id: 1)
    assert_equal 1, p.sequential_id

    p = Product.create(category_id: 1)
    assert_equal 2, p.sequential_id

    p = Product.create(category_id: 1, price: -1)
    assert_nil p.sequential_id
    assert_equal 2, SequentialId::Sequence.where(model: 'Product', scope: 'category_id', scope_id: 1).first.value

    p = Product.create(category_id: 2)
    assert_equal 1, p.sequential_id
  end
end
