--------------------------------------------------------
--  DDL for Package Body PSP_MESSAGE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_MESSAGE_S" AS
/*$Header: PSPSTMSB.pls 115.8 2002/11/20 04:36:19 ddubey ship $*/

 l_new_line_char VARCHAR2(2000) := '
';


 FUNCTION    Get ( p_msg_index     IN NUMBER   ,
     		   p_encoded       IN VARCHAR2 := FND_API.G_TRUE )
 RETURN VARCHAR2 IS

 l_msg_buf VARCHAR2(2000) ;

 BEGIN

  l_msg_buf := FND_MSG_PUB.Get(p_msg_index,
                               p_encoded);

  return l_msg_buf ;

 END Get ;

 FUNCTION SUBSTRB_GET RETURN VARCHAR2 IS

 l_msg_buf VARCHAR2(2000) ;

 BEGIN

--  l_msg_buf := SUBSTRB(FND_MESSAGE.Get, 1, 255);
-- Modified for Rel 11

  l_msg_buf := SUBSTRB(FND_MESSAGE.Get, 1, 2000);

  return l_msg_buf ;

 END ;

 FUNCTION SUBSTRB_GET (p_msg_index	IN NUMBER,
		       p_encoded	IN VARCHAR2)
 RETURN VARCHAR2 IS

 l_msg_buf VARCHAR2(2000);

 BEGIN

/*
    l_msg_buf := substrb(FND_MSG_PUB.Get (p_msg_index 	=> p_msg_index,
           		                 p_encoded 	=> p_encoded), 1, 255);
 */
-- Modified for Rel 11
    l_msg_buf := substrb(FND_MSG_PUB.Get (p_msg_index 	=> p_msg_index,
           		                 p_encoded 	=> p_encoded), 1, 2000);

   return l_msg_buf ;

 END ;



 PROCEDURE  Print_Error ( p_mode         IN VARCHAR2,
                          p_print_header IN VARCHAR2 := FND_API.G_TRUE )
 IS

  l_msg_count   NUMBER         ;
  l_msg_data    VARCHAR2(2000) ;
  l_msg_buf     VARCHAR2(2000) ;

  BEGIN

    -- Validate the p_mode parameter.
    IF p_mode NOT IN (FND_FILE.LOG, FND_FILE.OUTPUT) THEN
      --
      Fnd_Message.Set_Name ('PSP', 'PSP_INVALID_ARGUMENT') ;
      Fnd_Message.Set_Token('ROUTINE', 'Print_Error' ) ;
      l_msg_buf := Fnd_Message.Get ;
      FND_FILE.Put_Line( FND_FILE.LOG, l_msg_buf ) ;
      RETURN ;
      --
    END IF ;


    if FND_API.to_Boolean( p_print_header ) then
        FND_MESSAGE.Set_Name('PSP', 'PSP_PROGRAM_FAILURE_HEADER');
        l_msg_buf  := substrb_get ;
        FND_FILE.Put_Line( p_mode, l_msg_buf ) ;
    end if ;

    FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                p_data  => l_msg_data   ) ;

    if l_msg_count = 0 then
   	FND_MESSAGE.Set_Name('PSP', 'PSP_SERVER_ERROR_NO_MSG');
    	l_msg_buf  := substrb_get ;
        FND_FILE.Put_Line( p_mode, l_msg_buf ) ;
    elsif l_msg_count = 1 then
	FND_MESSAGE.Set_Encoded(l_msg_data);
	l_msg_buf := substrb_get ;
        FND_FILE.Put_Line( p_mode, l_msg_buf ) ;
    elsif l_msg_count > 1 then
        for i in 1..l_msg_count loop
            if i =1 then
               l_msg_buf := substrb_get
                 		(p_msg_index 	=> FND_MSG_PUB.G_FIRST,
           		         p_encoded 	=> FND_API.G_FALSE);
            else
               l_msg_buf := substrb_get
                 		(p_msg_index 	=> FND_MSG_PUB.G_NEXT,
           		         p_encoded 	=> FND_API.G_FALSE);
	    end if;
            FND_FILE.Put_Line( p_mode, l_msg_buf ) ;
        end loop ;
    end if;

 END Print_Error ;

/*******************************************************************
 PROCEDURE  Insert_Error( p_source_process IN VARCHAR2,
			  p_process_id	   IN NUMBER,
			  p_msg_count      IN NUMBER,
                          p_msg_data       IN VARCHAR2,
                          p_desc_sequence  IN VARCHAR2 := FND_API.G_FALSE
                        )
 IS


  l_msg_count   NUMBER          := p_msg_count ;
  l_msg_data    VARCHAR2(2000)  := p_msg_data ;
  l_msg_buf     VARCHAR2(2000) ;
  l_conc_req_id	NUMBER		:= NVL(FND_GLOBAL.CONC_REQUEST_ID, FND_API.G_MISS_NUM);
  l_user_id	NUMBER		:= FND_GLOBAL.USER_ID ;
  l_seq_number  NUMBER          := 0 ;

  BEGIN

    if FND_API.to_Boolean( p_desc_sequence ) then
        l_seq_number := l_msg_count + 1 ;
    end if;

    if l_msg_count = 1 then
	FND_MESSAGE.Set_Encoded(l_msg_data);
	l_msg_buf := FND_MESSAGE.Get;
    elsif l_msg_count = 0 then
   	FND_MESSAGE.Set_Name('PSP', 'PSP_SERVER_ERROR_NO_MSG');
    	l_msg_buf  := FND_MESSAGE.Get ;
    elsif l_msg_count > 1 then
        for i in 1..l_msg_count loop

            if i =1 then
               l_msg_buf := FND_MSG_PUB.Get
                 		(p_msg_index 	=> FND_MSG_PUB.G_FIRST,
           		         p_encoded 	=> FND_API.G_FALSE);
            else
               l_msg_buf := FND_MSG_PUB.Get
                 		(p_msg_index 	=> FND_MSG_PUB.G_NEXT,
           		         p_encoded 	=> FND_API.G_FALSE);
	    end if;

            if FND_API.to_Boolean( p_desc_sequence ) then
               l_seq_number := l_seq_number - 1 ;
            else
               l_seq_number := i ;
            end if ;

            insert into PSP_ERROR_MESSAGES
            	       (concurrent_request_id,
                	process_id,
                	source_process,
			sequence_number,
                	description,
                	creation_date,
                	created_by)
        	values (l_conc_req_id,
                	p_process_id,
                	p_source_process,
			l_seq_number,
                	l_msg_buf,
                	sysdate,
                	l_user_id);
        end loop ;
    end if;

    if l_msg_count = 0 or l_msg_count = 1 then
        insert into PSP_ERROR_MESSAGES
            	       (concurrent_request_id,
                	process_id,
                	source_process,
			sequence_number,
                	description,
                	creation_date,
                	created_by)
        	values (l_conc_req_id,
                	p_process_id,
                	p_source_process,
			1,
                	l_msg_buf,
                	sysdate,
                	l_user_id);
    end if;

 END Insert_Error ;

**************************************************************************/

 PROCEDURE  Print_Success IS

  l_msg_buf     VARCHAR2(2000) ;

  BEGIN

    FND_MESSAGE.Set_Name('PSP', 'PSP_PROGRAM_SUCCESS');
    l_msg_buf  := substrb_get;
    -- FND_FILE.Put_Line( FND_FILE.OUTPUT, l_msg_buf );
    FND_FILE.Put_Line( FND_FILE.LOG, l_msg_buf ) ;

 END Print_Success ;


 PROCEDURE  Get_Error_Message( p_print_header IN VARCHAR2 := FND_API.G_TRUE,
			       p_msg_string   OUT NOCOPY VARCHAR2)
 IS
  --
  l_msg_count      NUMBER         ;
  l_msg_data       VARCHAR2(2000) ;
  l_msg_buf        VARCHAR2(2000) ;
  --
 BEGIN

    if FND_API.to_Boolean( p_print_header ) then
       -- Standard program failure message.
       FND_MESSAGE.Set_Name('PSP', 'PSP_PROGRAM_FAILURE_HEADER');
       l_msg_buf := substrb_get;
    end if;

    -- Count total number of messages.
    FND_MSG_PUB.Count_And_Get(  p_count  => l_msg_count,
                                p_data   => l_msg_data   );

    if l_msg_count = 1 then
        --
        FND_MESSAGE.Set_Encoded(l_msg_data);
        l_msg_buf := l_msg_buf || l_new_line_char || substrb_get ;
        --
    elsif l_msg_count > 1 then
        --
        for i in 1..l_msg_count loop

            if i = 1 then
                l_msg_buf := l_msg_buf || l_new_line_char ||
                             substrb_get
                         	(  p_msg_index    => FND_MSG_PUB.G_FIRST,
                            	   p_encoded      => FND_API.G_FALSE
                         	);
	    else
                l_msg_buf := l_msg_buf || l_new_line_char ||
                             substrb_get
                         	(  p_msg_index    => FND_MSG_PUB.G_NEXT,
                            	   p_encoded      => FND_API.G_FALSE
                         	);
            end if;
        end loop ;
    elsif l_msg_count = 0 then
        --
        FND_MESSAGE.Set_Name('PSP', 'PSP_SERVER_ERROR_NO_MSG');
        l_msg_buf := l_msg_buf || l_new_line_char || substrb_get ;
        --
    end if;

    p_msg_string := l_msg_buf ;

 END Get_Error_Message ;


 PROCEDURE  Get_Success_Message( p_msg_string OUT NOCOPY VARCHAR2 )
 IS
 BEGIN
    --
    FND_MESSAGE.Set_Name('PSP', 'PSP_PROGRAM_SUCCESS');
    p_msg_string  := substrb_get ;
    --
 END ;


END PSP_MESSAGE_S;

/
