CREATE DATABASE Asm__4;
USE Asm__4;


CREATE TABLE Publishers (
    publisher_id INT IDENTITY(1,1) PRIMARY KEY,
    publisher_name NVARCHAR(200) NOT NULL,
    address NVARCHAR(300) NOT NULL
);

CREATE TABLE Categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(200) NOT NULL UNIQUE
);

CREATE TABLE Books (
    book_id VARCHAR(10) PRIMARY KEY,      
    title NVARCHAR(300) NOT NULL,
    author NVARCHAR(200) NOT NULL,
    summary NVARCHAR(MAX) NOT NULL,
    publish_year INT NOT NULL CHECK(publish_year > 0),
    edition INT NOT NULL CHECK(edition > 0),
    publisher_id INT NOT NULL FOREIGN KEY REFERENCES Publishers(publisher_id),
    category_id INT NOT NULL FOREIGN KEY REFERENCES Categories(category_id),
    price DECIMAL(12,4) NOT NULL CHECK(price >= 0)
);

CREATE TABLE Quantities (
    quantity_id INT IDENTITY(1,1) PRIMARY KEY,
    book_id VARCHAR(10) NOT NULL UNIQUE FOREIGN KEY REFERENCES Books(book_id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK(quantity >= 0)
);


INSERT INTO Publishers (publisher_name, address) VALUES
(N'Tri Thức', N'53 Nguyễn Du, Hai Bà Trưng, Hà Nội'),
(N'NXB Giáo Dục', N'123 Đường A, Hà Nội'),
(N'NXB Khoa Học', N'45 Đường B, Hà Nội');

INSERT INTO Categories (category_name) VALUES
(N'Khoa học xã hội'), (N'Tin học'), (N'Toán học'), (N'Văn học');

INSERT INTO Books (book_id, title, author, summary, publish_year, edition, publisher_id, category_id, price) VALUES
('B001', N'Trí tuệ Do Thái', N'Eran Katz', N'Bạn có muốn biết: Người Do Thái sáng tạo ra cái gì và nguồn gốc trí tuệ của họ...', 2010, 1, 1, 1, 79000),
('B002', N'Tin học căn bản', N'Nguyễn Văn A', N'Giới thiệu tin học...', 2015, 1, 2, 2, 120000),
('B003', N'Lập trình C# nâng cao', N'Trần B', N'Hướng dẫn C#...', 2018, 2, 2, 2, 250000),
('B004', N'Toán rời rạc', N'Lê C', N'Toán rời rạc cơ bản...', 2009, 1, 3, 3, 150000),
('B005', N'Văn học hiện đại', N'Hồ D', N'Tác phẩm tiêu biểu...', 2020, 1, 3, 4, 90000);

INSERT INTO Quantities (book_id, quantity) VALUES
('B001', 100),
('B002', 50),
('B003', 30),
('B004', 10),
('B005', 5);

-- 4) Liệt kê các cuốn sách có năm xuất bản từ 2008 đến nay
SELECT * FROM Books WHERE publish_year >= 2008;

-- 5) Liệt kê 10 cuốn sách có giá bán cao nhất
SELECT TOP 10 * FROM Books ORDER BY price DESC;

-- 6) Tìm những cuốn sách có tiêu đề chứa từ “tin học”
SELECT * FROM Books WHERE title LIKE N'%tin học%';

-- 7) Liệt kê các cuốn sách có tên bắt đầu với chữ “T” theo thứ tự giá giảm dần
SELECT * FROM Books WHERE title LIKE N'T%' ORDER BY price DESC;

-- 8) Liệt kê các cuốn sách của nhà xuất bản Tri thức
SELECT b.* FROM Books b JOIN Publishers p ON b.publisher_id = p.publisher_id WHERE p.publisher_name = N'Tri Thức';

-- 9) Lấy thông tin chi tiết về nhà xuất bản xuất bản cuốn sách “Trí tuệ Do Thái”
SELECT p.* FROM Publishers p
JOIN Books b ON p.publisher_id = b.publisher_id
WHERE b.title = N'Trí tuệ Do Thái';

-- 10) Hiển thị: Mã sách, Tên sách, Năm xuất bản, Nhà xuất bản, Loại sách
SELECT b.book_id, b.title, b.publish_year, p.publisher_name, c.category_name
FROM Books b
JOIN Publishers p ON b.publisher_id = p.publisher_id
JOIN Categories c ON b.category_id = c.category_id;

-- 11) Tìm cuốn sách có giá bán đắt nhất
SELECT TOP 1 * FROM Books ORDER BY price DESC;

-- 12) Tìm cuốn sách có số lượng lớn nhất trong kho
SELECT b.*, q.quantity FROM Books b JOIN Quantities q ON b.book_id = q.book_id ORDER BY q.quantity DESC;

-- 13) Tìm các cuốn sách của tác giả “Eran Katz”
SELECT * FROM Books WHERE author = N'Eran Katz';

-- 14) Giảm giá bán 10% các cuốn sách xuất bản từ năm 2008 trở về trước
UPDATE Books SET price = price * 0.9 WHERE publish_year <= 2008;
SELECT * FROM Books;
-- 15) Thống kê số đầu sách của mỗi nhà xuất bản
SELECT p.publisher_name, COUNT(b.book_id) AS num_books
FROM Publishers p
LEFT JOIN Books b ON p.publisher_id = b.publisher_id
GROUP BY p.publisher_name;

-- 16) Thống kê số đầu sách của mỗi loại sách
SELECT c.category_name, COUNT(b.book_id) AS num_books
FROM Categories c
LEFT JOIN Books b ON c.category_id = b.category_id
GROUP BY c.category_name;

-- 17) Đặt chỉ mục (Index) cho trường tên sách
CREATE INDEX IX_Books_Title ON Books(title);

-- 18) Viết view: Mã sách, tên sách, tác giả, nhà xb, giá bán
CREATE VIEW View_Book_Info AS
SELECT b.book_id, b.title, b.author, p.publisher_name, b.price
FROM Books b
JOIN Publishers p ON b.publisher_id = p.publisher_id;


-- Thêm sách
CREATE PROCEDURE SP_Them_Sach
    @book_id VARCHAR(10),
    @title NVARCHAR(300),
    @author NVARCHAR(200),
    @summary NVARCHAR(MAX),
    @publish_year INT,
    @edition INT,
    @publisher_id INT,
    @category_id INT,
    @price DECIMAL(12,4)
AS
BEGIN
    INSERT INTO Books(book_id, title, author, summary, publish_year, edition, publisher_id, category_id, price)
    VALUES(@book_id, @title, @author, @summary, @publish_year, @edition, @publisher_id, @category_id, @price);
END;

-- Tìm sách theo từ khóa
CREATE PROCEDURE SP_Tim_Sach
    @keyword NVARCHAR(200)
AS
BEGIN
    SELECT * FROM Books
    WHERE title LIKE N'%' + @keyword + N'%' OR summary LIKE N'%' + @keyword + N'%';
END;

-- Liệt kê sách theo chuyên mục
CREATE PROCEDURE SP_Sach_ChuyenMuc
    @category_id INT
AS
BEGIN
    SELECT * FROM Books WHERE category_id = @category_id;
END;


CREATE TRIGGER TR_NoDeleteIfInStock
ON Books
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM deleted d
        JOIN Quantities q ON d.book_id = q.book_id
        WHERE q.quantity > 0
    )
    BEGIN
        RAISERROR('Cannot delete book that still has stock (quantity > 0).', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    ELSE
    BEGIN
        DELETE b FROM Books b JOIN deleted d ON b.book_id = d.book_id;
    END
END;


CREATE TRIGGER TR_NoDeleteCategoryIfBooksExist
ON Categories
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM deleted d
        JOIN Books b ON d.category_id = b.category_id
    )
    BEGIN
        RAISERROR('Cannot delete category that still has books.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    ELSE
    BEGIN
        DELETE c FROM Categories c JOIN deleted d ON c.category_id = d.category_id;
    END
END;
