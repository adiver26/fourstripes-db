CREATE database fourstripes;

\c fourstripes;

DROP TABLE IF EXISTS Users;
CREATE TABLE Users
(	Name VARCHAR(33)  NOT NULL,
	UserID INT NOT NULL, 
	Age INT NOT NULL,
	Email VARCHAR(50) NOT NULL,
	PRIMARY KEY (UserID),
	UNIQUE (Email),
	CHECK (Age>=13)
);

DROP TABLE IF EXISTS User_Details;
CREATE TABLE User_Details
(
	Phone_No VARCHAR(15) NOT NULL,
	UserID INT NOT NULL,
	Sub_Count INT DEFAULT 0,
	Register_Date TIMESTAMP NOT NULL,
	Last_Login TIMESTAMP NOT NULL,
	PRIMARY KEY(Phone_No),
	FOREIGN KEY(UserID) REFERENCES Users(UserID) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Category;
CREATE TABLE Category
(
	CategoryID INT NOT NULL,
	CategoryName VARCHAR(20) NOT NULL, 
	PRIMARY KEY(CategoryID)
);

DROP TABLE IF EXISTS Video;
CREATE TABLE Video
(	VideoID INT NOT NULL, 
	VideoTitle VARCHAR(35) NOT NULL,
	VideoSize DECIMAL, 
	UserID INT NOT NULL,
	Description VARCHAR(30), 
	CategoryID INT NOT NULL, 
	Number_of_likes INT DEFAULT 0, 
	Number_of_Dislikes INT DEFAULT 0, 
	Views INT DEFAULT 0, 
	Uploaded_Date TIMESTAMP, 
	PRIMARY KEY(VideoID), 
	FOREIGN KEY(UserID) REFERENCES Users(UserID) ON DELETE CASCADE, 
	FOREIGN KEY(CategoryID) REFERENCES Category(CategoryID),
	CHECK (VideoSize <= 500)
);

DROP TABLE IF EXISTS VideoComment;
CREATE TABLE VideoComment
(
	CommentID INT NOT NULL,
    UserID INT NOT NULL,
    VideoID INT NOT NULL,
    Comments VARCHAR(99) NOT NULL,
    CommentDate TIMESTAMP NOT NULL,
	PRIMARY KEY (CommentID),
	FOREIGN KEY (UserID) REFERENCES Users(UserID)  ON DELETE CASCADE,
	FOREIGN KEY (VideoID) REFERENCES Video(VideoID) ON DELETE CASCADE
);

DROP TABLE IF EXISTS Trending;
CREATE TABLE Trending
(
	VideoID INT NOT NULL, 
	TrendingID SERIAL NOT NULL,	 	
	PRIMARY KEY(TrendingID),
	FOREIGN KEY(VideoID) REFERENCES Video(VideoID) ON DELETE CASCADE
	

);


CREATE OR REPLACE FUNCTION function_copy() RETURNS TRIGGER AS
$BODY$
BEGIN
  IF (new.Views/(new.Number_of_likes-new.Number_of_dislikes)) > 50 THEN
    INSERT into Trending 
	values (new.VideoID,DEFAULT);

  END IF;
    RETURN new;
END;
$BODY$
language plpgsql;

CREATE TRIGGER Trends 
AFTER INSERT ON Video 
FOR EACH ROW 
EXECUTE PROCEDURE function_copy();