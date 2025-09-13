module MyModule::DecentralizedBlog {
    use aptos_framework::signer;
    use std::string::String;
    use std::vector;

    /// Struct representing a blog post with IPFS content
    struct BlogPost has store, key {
        ipfs_hash: String,     // IPFS hash of the blog content
        title: String,         // Title of the blog post
        author: address,       // Author's address
        timestamp: u64,        // Creation timestamp
        likes: u64,           // Number of likes received
    }

    /// Struct to store all blog posts for a user
    struct UserBlog has store, key {
        posts: vector<BlogPost>,  // Vector of all blog posts
        total_posts: u64,         // Total number of posts
    }

    /// Function to create a new blog post with IPFS content
    public fun create_post(
        author: &signer, 
        ipfs_hash: String, 
        title: String, 
        timestamp: u64
    ) acquires UserBlog {
        let author_addr = signer::address_of(author);
        
        let new_post = BlogPost {
            ipfs_hash,
            title,
            author: author_addr,
            timestamp,
            likes: 0,
        };

        if (!exists<UserBlog>(author_addr)) {
            let blog = UserBlog {
                posts: vector::empty<BlogPost>(),
                total_posts: 0,
            };
            move_to(author, blog);
        };

        let user_blog = borrow_global_mut<UserBlog>(author_addr);
        vector::push_back(&mut user_blog.posts, new_post);
        user_blog.total_posts = user_blog.total_posts + 1;
    }

    /// Function to like a specific blog post
    public fun like_post(
        _liker: &signer, 
        author_addr: address, 
        post_index: u64
    ) acquires UserBlog {
        let user_blog = borrow_global_mut<UserBlog>(author_addr);
        let post = vector::borrow_mut(&mut user_blog.posts, post_index);
        post.likes = post.likes + 1;
    }
}