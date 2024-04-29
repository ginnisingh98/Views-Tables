--------------------------------------------------------
--  DDL for Package Body CSFW_REQ_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSFW_REQ_PUB" AS
/*$Header: csfwreqb.pls 120.2 2006/02/14 05:30:05 htank noship $*/

PROCEDURE CREATE_REQUIREMENT_HEADER
(
  p_task_id IN NUMBER
, p_location_id IN NUMBER
, p_ATTRIBUTE1 IN VARCHAR2
, p_ATTRIBUTE2 IN VARCHAR2
, p_ATTRIBUTE3 IN VARCHAR2
, p_ATTRIBUTE4 IN VARCHAR2
, p_ATTRIBUTE5 IN VARCHAR2
, p_ATTRIBUTE6 IN VARCHAR2
, p_ATTRIBUTE7 IN VARCHAR2
, p_ATTRIBUTE8 IN VARCHAR2
, p_ATTRIBUTE9 IN VARCHAR2
, p_ATTRIBUTE10 IN VARCHAR2
, p_ATTRIBUTE11 IN VARCHAR2
, p_ATTRIBUTE12 IN VARCHAR2
, p_ATTRIBUTE13 IN VARCHAR2
, p_ATTRIBUTE14 IN VARCHAR2
, p_ATTRIBUTE15 IN VARCHAR2
, p_ATTRIBUTE_CATEGORY IN VARCHAR2
, x_header_id OUT NOCOPY NUMBER
, x_error_id  OUT NOCOPY NUMBER
, x_error     OUT NOCOPY VARCHAR2
)
IS
    l_header_id   number;
    l_req_hdr_rec CSP_Requirement_headers_PVT.REQUIREMENT_HEADER_Rec_Type;
    l_Return_Status  VARCHAR2(1);
    l_Msg_Count      NUMBER;
    l_Msg_Data       VARCHAR2(2000);
    l_msg_index_out  NUMBER;
    l_data VARCHAR2(255);

 cursor c_next_header is select CSP_REQUIREMENT_HEADERS_S1.nextval from dual;

BEGIN
	open c_next_header;
	fetch c_next_header into l_header_id ;
	close c_next_header;

	l_req_hdr_rec.REQUIREMENT_HEADER_ID        := l_header_id;
	l_req_hdr_rec.OPEN_REQUIREMENT             := 'Y';
	l_req_hdr_rec.TASK_ID                      := p_task_id;
	l_req_hdr_rec.PARTS_DEFINED                := 'Y';

	IF (p_location_id <> 0) THEN
		l_req_hdr_rec.SHIP_TO_LOCATION_ID  := p_location_id;
		l_req_hdr_rec.ADDRESS_TYPE         := 'C';--Customer
	ELSE
	   l_req_hdr_rec.ADDRESS_TYPE         := 'R';  -- Resource bug # 5023696
	END IF;

	-- bug # 5023696
	l_req_hdr_rec.ORDER_TYPE_ID := 1430;

   -- set other parameters
   IF p_ATTRIBUTE1 IS NULL OR p_ATTRIBUTE1 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE1 := p_ATTRIBUTE1;
   END IF;

   IF p_ATTRIBUTE2 IS NULL OR p_ATTRIBUTE2 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE2 := p_ATTRIBUTE2;
   END IF;

   IF p_ATTRIBUTE3 IS NULL OR p_ATTRIBUTE3 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE3 := p_ATTRIBUTE3;
   END IF;

   IF p_ATTRIBUTE4 IS NULL OR p_ATTRIBUTE4 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE4 := p_ATTRIBUTE4;
   END IF;

   IF p_ATTRIBUTE5 IS NULL OR p_ATTRIBUTE5 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE5 := p_ATTRIBUTE5;
   END IF;

   IF p_ATTRIBUTE6 IS NULL OR p_ATTRIBUTE6 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE6 := p_ATTRIBUTE6;
   END IF;

   IF p_ATTRIBUTE7 IS NULL OR p_ATTRIBUTE7 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE7 := p_ATTRIBUTE7;
   END IF;

   IF p_ATTRIBUTE8 IS NULL OR p_ATTRIBUTE8 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE8 := p_ATTRIBUTE8;
   END IF;

   IF p_ATTRIBUTE9 IS NULL OR p_ATTRIBUTE9 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE9 := p_ATTRIBUTE9;
   END IF;

   IF p_ATTRIBUTE10 IS NULL OR p_ATTRIBUTE10 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE10 := p_ATTRIBUTE10;
   END IF;

   IF p_ATTRIBUTE11 IS NULL OR p_ATTRIBUTE11 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE11 := p_ATTRIBUTE11;
   END IF;

   IF p_ATTRIBUTE12 IS NULL OR p_ATTRIBUTE12 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE12 := p_ATTRIBUTE12;
   END IF;

   IF p_ATTRIBUTE13 IS NULL OR p_ATTRIBUTE13 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE13 := p_ATTRIBUTE13;
   END IF;

   IF p_ATTRIBUTE14 IS NULL OR p_ATTRIBUTE14 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE14 := p_ATTRIBUTE14;
   END IF;

   IF p_ATTRIBUTE15 IS NULL OR p_ATTRIBUTE15 <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE15 := p_ATTRIBUTE15;
   END IF;

   IF p_ATTRIBUTE_CATEGORY IS NULL OR p_ATTRIBUTE_CATEGORY <> '#%*%#'
   THEN
      l_req_hdr_rec.ATTRIBUTE_CATEGORY := p_ATTRIBUTE_CATEGORY;
   END IF;

	CSP_Requirement_headers_PVT.Create_requirement_headers(
	    P_Api_Version_Number         => 1.0 ,
	    P_Init_Msg_List              => FND_API.G_FALSE,
	    P_Commit                     => FND_API.G_TRUE,
	    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
	    P_REQUIREMENT_HEADER_Rec     => l_req_hdr_rec,
	    X_REQUIREMENT_HEADER_ID      => x_header_id ,
	    X_Return_Status              => l_Return_Status,
	    X_Msg_Count                  => l_Msg_Count ,
	    X_Msg_Data                   => l_Msg_Data
	    );

	IF l_Return_Status = FND_API.G_RET_STS_SUCCESS
          THEN
            /* API-call was successfull */
              x_error_id := 0;
              x_error := FND_API.G_RET_STS_SUCCESS;
	  commit work;
          ELSE
            FOR l_counter IN 1 .. l_msg_count
            LOOP
                      fnd_msg_pub.get
                        ( p_msg_index     => l_counter
                        , p_encoded       => FND_API.G_FALSE
                        , p_data          => l_Msg_Data
                        , p_msg_index_out => l_msg_index_out
                        );
                      --dbms_output.put_line( 'Message: '||l_data );
            END LOOP ;
            x_error_id := 1;
            x_error := l_data;
          END IF;
EXCEPTION
  WHEN OTHERS
  THEN
    x_error_id := -1;
    x_error := SQLERRM;

END CREATE_REQUIREMENT_HEADER;



PROCEDURE DELETE_REQUIREMENT_HEADER
(
  p_header_id IN NUMBER
, x_error_id  OUT NOCOPY NUMBER
, x_error     OUT NOCOPY VARCHAR2
)
IS
    l_req_hdr_rec CSP_Requirement_headers_PVT.REQUIREMENT_HEADER_Rec_Type;
    l_Return_Status  VARCHAR2(1);
    l_Msg_Count      NUMBER;
    l_Msg_Data       VARCHAR2(2000);
    l_msg_index_out  NUMBER;
    l_data VARCHAR2(255);
BEGIN

	l_req_hdr_rec.REQUIREMENT_HEADER_ID        := p_header_id;

	CSP_Requirement_headers_PVT.Delete_requirement_headers(
	P_Api_Version_Number         => 1.0,
	P_Init_Msg_List              => FND_API.G_FALSE,
	P_Commit                     => FND_API.G_TRUE,
	p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
	P_REQUIREMENT_HEADER_Rec     => l_req_hdr_rec,
	X_Return_Status              => l_Return_Status,
	X_Msg_Count                  => l_Msg_Count,
	X_Msg_Data                   => l_Msg_Data
	);

    IF l_Return_Status = FND_API.G_RET_STS_SUCCESS
          THEN
            /* API-call was successfull */
              x_error_id := 0;
              x_error := FND_API.G_RET_STS_SUCCESS;
	  commit work;
          ELSE
            FOR l_counter IN 1 .. l_msg_count
            LOOP
                      fnd_msg_pub.get
                        ( p_msg_index     => l_counter
                        , p_encoded       => FND_API.G_FALSE
                        , p_data          => l_Msg_Data
                        , p_msg_index_out => l_msg_index_out
                        );
                      --dbms_output.put_line( 'Message: '||l_data );
            END LOOP ;
            x_error_id := 1;
            x_error := l_data;
          END IF;
EXCEPTION
  WHEN OTHERS
  THEN
    x_error_id := -1;
    x_error := SQLERRM;

END DELETE_REQUIREMENT_HEADER;


PROCEDURE CREATE_REQUIREMENT_LINE
(
  p_header_id   IN NUMBER
, p_inv_item_id IN NUMBER
, p_UOM         IN VARCHAR2
, p_quantity    IN NUMBER
, p_revision    IN VARCHAR2
, p_ATTRIBUTE1 IN VARCHAR2
, p_ATTRIBUTE2 IN VARCHAR2
, p_ATTRIBUTE3 IN VARCHAR2
, p_ATTRIBUTE4 IN VARCHAR2
, p_ATTRIBUTE5 IN VARCHAR2
, p_ATTRIBUTE6 IN VARCHAR2
, p_ATTRIBUTE7 IN VARCHAR2
, p_ATTRIBUTE8 IN VARCHAR2
, p_ATTRIBUTE9 IN VARCHAR2
, p_ATTRIBUTE10 IN VARCHAR2
, p_ATTRIBUTE11 IN VARCHAR2
, p_ATTRIBUTE12 IN VARCHAR2
, p_ATTRIBUTE13 IN VARCHAR2
, p_ATTRIBUTE14 IN VARCHAR2
, p_ATTRIBUTE15 IN VARCHAR2
, p_ATTRIBUTE_CATEGORY IN VARCHAR2
, x_error_id  OUT NOCOPY NUMBER
, x_error     OUT NOCOPY VARCHAR2
, x_line_id   OUT NOCOPY NUMBER
)
IS
    l_line_id    number;
    l_req_line_rec   CSP_Requirement_Lines_PVT.Requirement_Line_Rec_Type;
    l_req_table      CSP_Requirement_Lines_PVT.Requirement_Line_Tbl_Type;
    l_req_table_tmp  CSP_Requirement_Lines_PVT.Requirement_Line_Tbl_Type;
    l_Return_Status  VARCHAR2(1);
    l_Msg_Count      NUMBER;
    l_Msg_Data       VARCHAR2(2000);
    l_msg_index_out  NUMBER;
    l_data           VARCHAR2(255);

    cursor c_next_line is select CSP_REQUIREMENT_LINES_S1.nextval from dual;

BEGIN

	x_line_id := 0;
	open c_next_line;
	fetch c_next_line into l_line_id;
	close c_next_line;

	l_req_line_rec.REQUIREMENT_LINE_ID        := l_line_id ;
	l_req_line_rec.REQUIREMENT_HEADER_ID      := p_header_id;
	l_req_line_rec.INVENTORY_ITEM_ID          := p_inv_item_id;
	l_req_line_rec.UOM_CODE                   := p_UOM;
	l_req_line_rec.REQUIRED_QUANTITY          := p_quantity;

--dbms_output.put_line('1...');

     IF p_revision <> '$$#@' then
	l_req_line_rec.REVISION                   := p_revision;
--	dbms_output.put_line('2...');
   END IF;

   -- set other parameters
   IF p_ATTRIBUTE1 IS NULL OR p_ATTRIBUTE1 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE1 := p_ATTRIBUTE1;
   END IF;

   IF p_ATTRIBUTE2 IS NULL OR p_ATTRIBUTE2 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE2 := p_ATTRIBUTE2;
   END IF;

   IF p_ATTRIBUTE3 IS NULL OR p_ATTRIBUTE3 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE3 := p_ATTRIBUTE3;
   END IF;

   IF p_ATTRIBUTE4 IS NULL OR p_ATTRIBUTE4 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE4 := p_ATTRIBUTE4;
   END IF;

   IF p_ATTRIBUTE5 IS NULL OR p_ATTRIBUTE5 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE5 := p_ATTRIBUTE5;
   END IF;

   IF p_ATTRIBUTE6 IS NULL OR p_ATTRIBUTE6 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE6 := p_ATTRIBUTE6;
   END IF;

   IF p_ATTRIBUTE7 IS NULL OR p_ATTRIBUTE7 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE7 := p_ATTRIBUTE7;
   END IF;

   IF p_ATTRIBUTE8 IS NULL OR p_ATTRIBUTE8 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE8 := p_ATTRIBUTE8;
   END IF;

   IF p_ATTRIBUTE9 IS NULL OR p_ATTRIBUTE9 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE9 := p_ATTRIBUTE9;
   END IF;

   IF p_ATTRIBUTE10 IS NULL OR p_ATTRIBUTE10 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE10 := p_ATTRIBUTE10;
   END IF;

   IF p_ATTRIBUTE11 IS NULL OR p_ATTRIBUTE11 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE11 := p_ATTRIBUTE11;
   END IF;

   IF p_ATTRIBUTE12 IS NULL OR p_ATTRIBUTE12 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE12 := p_ATTRIBUTE12;
   END IF;

   IF p_ATTRIBUTE13 IS NULL OR p_ATTRIBUTE13 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE13 := p_ATTRIBUTE13;
   END IF;

   IF p_ATTRIBUTE14 IS NULL OR p_ATTRIBUTE14 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE14 := p_ATTRIBUTE14;
   END IF;

   IF p_ATTRIBUTE15 IS NULL OR p_ATTRIBUTE15 <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE15 := p_ATTRIBUTE15;
   END IF;

   IF p_ATTRIBUTE_CATEGORY IS NULL OR p_ATTRIBUTE_CATEGORY <> '#%*%#'
   THEN
      l_req_line_rec.ATTRIBUTE_CATEGORY := p_ATTRIBUTE_CATEGORY;
   END IF;

l_req_table(1) := l_req_line_rec;
-- CALL API

CSP_Requirement_Lines_PVT.Create_requirement_lines(
    P_Api_Version_Number         => 1.0,
    P_Init_Msg_List              => FND_API.G_FALSE,
    P_Commit                     => FND_API.G_TRUE,
    p_validation_level           => FND_API.G_VALID_LEVEL_FULL,
    P_Requirement_Line_Tbl       => l_req_table,
    x_Requirement_Line_tbl       => l_req_table_tmp,
    X_Return_Status              => l_Return_Status,
    X_Msg_Count                  => l_Msg_Count,
    X_Msg_Data                   => l_Msg_Data
    );
    IF l_Return_Status = FND_API.G_RET_STS_SUCCESS
          THEN
            /* API-call was successfull */
              x_error_id := 0;
              x_error := FND_API.G_RET_STS_SUCCESS;
	      l_req_line_rec := l_req_table_tmp(1);
	      x_line_id := l_req_line_rec.REQUIREMENT_LINE_ID;
	  commit work;
          ELSE
            FOR l_counter IN 1 .. l_msg_count
            LOOP
                      fnd_msg_pub.get
                        ( p_msg_index     => l_counter
                        , p_encoded       => FND_API.G_FALSE
                        , p_data          => l_data
                        , p_msg_index_out => l_msg_index_out
                        );
--                      dbms_output.put_line( 'Message: '||l_data );
            END LOOP ;
            x_error_id := 1;
            x_error := l_data;
          END IF;
EXCEPTION
  WHEN OTHERS
  THEN
    x_error_id := -1;
    x_error := SQLERRM;
END CREATE_REQUIREMENT_LINE;


PROCEDURE DELETE_REQUIREMENT_LINE
(
  p_LINE_ID   IN NUMBER
, x_error_id  OUT NOCOPY NUMBER
, x_error     OUT NOCOPY VARCHAR2
)
IS
    l_req_line_rec   CSP_Requirement_Lines_PVT.Requirement_Line_Rec_Type;
    l_req_table      CSP_Requirement_Lines_PVT.Requirement_Line_Tbl_Type;
    l_Return_Status  VARCHAR2(1);
    l_Msg_Count      NUMBER;
    l_Msg_Data       VARCHAR2(2000);
    l_msg_index_out  NUMBER;
    l_data           VARCHAR2(255);

BEGIN
/*
	l_req_line_rec.REQUIREMENT_LINE_ID        := p_LINE_ID ;

l_req_table(1) := l_req_line_rec;

-- CALL API

--dbms_output.put_line( 'Calling API');
CSP_Requirement_Lines_PVT.Delete_requirement_lines(
    P_Api_Version_Number        => 1.0,
    P_Init_Msg_List             => FND_API.G_FALSE,
    P_Commit                    => FND_API.G_TRUE,
    p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
    P_Requirement_Line_Tbl      => l_req_table,
    X_Return_Status             => l_Return_Status,
    X_Msg_Count                 => l_Msg_Count,
    X_Msg_Data                  => l_data
    );


    IF l_Return_Status = FND_API.G_RET_STS_SUCCESS
          THEN
              x_error_id := 0;
              x_error := FND_API.G_RET_STS_SUCCESS;
          ELSE
            FOR l_counter IN 1 .. l_msg_count
            LOOP
                      fnd_msg_pub.get
                        ( p_msg_index     => l_counter
                        , p_encoded       => FND_API.G_FALSE
                        , p_data          => l_data
                        , p_msg_index_out => l_msg_index_out
                        );
                      --dbms_output.put_line( 'Message: '||l_data);
            END LOOP ;
            x_error_id := 1;
            x_error := l_data;
          END IF;
	  */

	  delete CSP_requirement_lines where REQUIREMENT_LINE_ID = p_LINE_ID;
	  commit work;
		x_error_id := 0;
		x_error := '';

EXCEPTION
  WHEN OTHERS
  THEN
    x_error_id := -1;
    x_error := SQLERRM;

END DELETE_REQUIREMENT_LINE;





END csfw_req_pub;

/
