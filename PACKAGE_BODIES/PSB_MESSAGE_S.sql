--------------------------------------------------------
--  DDL for Package Body PSB_MESSAGE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_MESSAGE_S" AS
/* $Header: PSBSTMSB.pls 120.3.12010000.3 2009/04/03 10:46:24 rkotha ship $ */

 l_new_line_char VARCHAR2(2000) := FND_GLOBAL.Newline;

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

  /*Bug:5753424: Modified the number of chars from 255 to 2000
                 in SUBSTRB function */
  l_msg_buf := SUBSTRB(FND_MESSAGE.Get, 1, 2000);

  return l_msg_buf ;

 END ;

 FUNCTION SUBSTRB_GET (p_msg_index      IN NUMBER,
		       p_encoded        IN VARCHAR2)
 RETURN VARCHAR2 IS

 l_msg_buf VARCHAR2(2000);

 BEGIN

  /*Bug:5753424: Modified the number of chars from 255 to 2000
                 in SUBSTRB function */
   l_msg_buf := substrb(FND_MSG_PUB.Get (p_msg_index    => p_msg_index,
					 p_encoded      => p_encoded), 1, 2000);

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
      Fnd_Message.Set_Name ('PSB', 'PSB_INVALID_ARGUMENT') ;
      Fnd_Message.Set_Token('ROUTINE', 'Print_Error' ) ;
      l_msg_buf := Fnd_Message.Get ;
      FND_FILE.Put_Line( FND_FILE.LOG, l_msg_buf ) ;
      RETURN ;
      --
    END IF ;

    -- Get number of messages to print.
    FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count ,
                                p_data  => l_msg_data  ) ;

    -- If no messages to print, simply return (bug#3190892).
    IF l_msg_count = 0 THEN
      RETURN ;
    ELSE
      -- Print standard header is asked for.
      IF FND_API.to_Boolean( p_print_header ) THEN
        FND_MESSAGE.Set_Name('PSB', 'PSB_PROGRAM_FAILURE_HEADER');
        l_msg_buf  := substrb_get ;
        FND_FILE.Put_Line( p_mode, l_msg_buf ) ;
      END IF ;
      --

      /* No longer applicable.
      if l_msg_count = 0 then
        FND_MESSAGE.Set_Name('PSB', 'PSB_SERVER_ERROR_NO_MSG');
        l_msg_buf  := substrb_get ;
        FND_FILE.Put_Line( p_mode, l_msg_buf ) ;
      */

      IF l_msg_count = 1 then

        FND_MESSAGE.Set_Encoded(l_msg_data);
        l_msg_buf := substrb_get ;
        FND_FILE.Put_Line( p_mode, l_msg_buf ) ;

      ELSIF l_msg_count > 1 then

        -- Get all messages from the message stack.
        FOR i IN 1..l_msg_count
        LOOP
          --
          IF i = 1 THEN
            l_msg_buf := substrb_get
	                 ( p_msg_index => FND_MSG_PUB.G_FIRST,
	                   p_encoded   => FND_API.G_FALSE    ) ;
          ELSE
            l_msg_buf := substrb_get
                         ( p_msg_index    => FND_MSG_PUB.G_NEXT,
                           p_encoded      => FND_API.G_FALSE   ) ;
          END IF;
          --
          FND_FILE.Put_Line( p_mode, l_msg_buf ) ;
          --
        END LOOP ;
        -- End getting all messages from the message stack.

      END IF;

    END IF ;

 END Print_Error ;


 PROCEDURE  Insert_Error( p_source_process IN VARCHAR2,
			  p_process_id     IN NUMBER,
			  p_msg_count      IN NUMBER,
			  p_msg_data       IN VARCHAR2,
			  p_desc_sequence  IN VARCHAR2 := FND_API.G_FALSE
			)
 IS


  l_msg_count   NUMBER          := p_msg_count ;
  l_msg_data    VARCHAR2(2000)  := p_msg_data ;
  l_msg_buf     VARCHAR2(2000) ;
  l_conc_req_id NUMBER          := NVL(FND_GLOBAL.CONC_REQUEST_ID, FND_API.G_MISS_NUM);
  l_user_id     NUMBER          := FND_GLOBAL.USER_ID ;
  l_seq_number  NUMBER          := 0 ;

  BEGIN

    if FND_API.to_Boolean( p_desc_sequence ) then
	l_seq_number := l_msg_count + 1 ;
    end if;

    if l_msg_count = 1 then
	FND_MESSAGE.Set_Encoded(l_msg_data);
	l_msg_buf := FND_MESSAGE.Get;
    elsif l_msg_count = 0 then
	FND_MESSAGE.Set_Name('PSB', 'PSB_SERVER_ERROR_NO_MSG');
	l_msg_buf  := FND_MESSAGE.Get ;
    elsif l_msg_count > 1 then
	for i in 1..l_msg_count loop

	    if i =1 then
	       l_msg_buf := FND_MSG_PUB.Get
				(p_msg_index    => FND_MSG_PUB.G_FIRST,
				 p_encoded      => FND_API.G_FALSE);
	    else
	       l_msg_buf := FND_MSG_PUB.Get
				(p_msg_index    => FND_MSG_PUB.G_NEXT,
				 p_encoded      => FND_API.G_FALSE);
	    end if;

	    if FND_API.to_Boolean( p_desc_sequence ) then
	       l_seq_number := l_seq_number - 1 ;
	    else
	       l_seq_number := i ;
	    end if ;

	    insert into PSB_ERROR_MESSAGES
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
	insert into PSB_ERROR_MESSAGES
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



 PROCEDURE  Print_Success IS

  l_msg_buf     VARCHAR2(2000) ;

  BEGIN

    FND_MESSAGE.Set_Name('PSB', 'PSB_PROGRAM_SUCCESS');
    l_msg_buf  := substrb_get;
    FND_FILE.Put_Line( FND_FILE.OUTPUT, l_msg_buf );

 END Print_Success ;


 PROCEDURE  Get_Error_Message( p_print_header IN VARCHAR2 := FND_API.G_TRUE,
			       p_msg_string   OUT  NOCOPY VARCHAR2)
 IS
  --
  l_msg_count      NUMBER         ;
  l_msg_data       VARCHAR2(2000) ;
  l_msg_buf        VARCHAR2(2000) ;
  --
 BEGIN

    if FND_API.to_Boolean( p_print_header ) then
       -- Standard program failure message.
       FND_MESSAGE.Set_Name('PSB', 'PSB_PROGRAM_FAILURE_HEADER');
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
	FND_MESSAGE.Set_Name('PSB', 'PSB_SERVER_ERROR_NO_MSG');
	l_msg_buf := l_msg_buf || l_new_line_char || substrb_get ;
	--
    end if;

    p_msg_string := l_msg_buf ;

 END Get_Error_Message ;


 PROCEDURE  Get_Success_Message( p_msg_string OUT  NOCOPY VARCHAR2 )
 IS
 BEGIN
    --
    FND_MESSAGE.Set_Name('PSB', 'PSB_PROGRAM_SUCCESS');
    p_msg_string  := substrb_get ;
    --
 END ;


  FUNCTION  Get_Error_Stack ( p_msg_count NUMBER )
  RETURN VARCHAR2
  IS

    l_msg_count               NUMBER ;
    l_msg_data                VARCHAR2(2000) ;

    -- The error stack in workflow supports VARCHAR2(4000).
    -- Setting it to 3900 to leave space for function and procedure names.
    l_error_message           VARCHAR2(3900) := null ;

  BEGIN

    -- Check if messages exist or not.
    IF p_msg_count IS NULL THEN
      RETURN NULL ;
    END IF;

    -- Retrieve messages from the message stack.
    FOR i IN 1..p_msg_count
    LOOP
      FND_MSG_PUB.Get( p_msg_index     => i  ,
		       p_encoded       => FND_API.G_FALSE     ,
		       p_data          => l_msg_data          ,
		       p_msg_index_out => l_msg_count
		   );

      l_error_message := l_error_message || ' ' || l_msg_data ;

    END LOOP;

    RETURN l_error_message ;

  EXCEPTION
    WHEN value_error THEN

      -- The probability of crossing limit of 3900 char is very low. Checking
      -- for length for each message is inefficient. This code path should give
      -- faster performance.
      RETURN l_error_message ;

    WHEN others THEN
      RAISE ;
  END Get_Error_Stack ;

/* Start bug no  4030864 */

PROCEDURE BATCH_INSERT_ERROR (p_source_process IN VARCHAR2,
                          p_process_id     IN NUMBER)
IS
  l_msg_count    NUMBER;
  l_msg_data     VARCHAR2(3000);
  l_msg_buf      VARCHAR2(3000);
  l_max_seq_no   NUMBER;
  l_seq_no       NUMBER;
  l_loop_process BOOLEAN;
  l_conc_req_id  NUMBER  := NVL(FND_GLOBAL.CONC_REQUEST_ID, FND_API.G_MISS_NUM);
  l_user_id      NUMBER  := FND_GLOBAL.USER_ID ;

  -- cursor to fetch the maximum of sequence
  CURSOR l_seq_csr
  IS
  SELECT max(sequence_number) seq_no
  FROM   psb_error_messages
  WHERE  process_id = p_process_id
  AND    source_process = p_source_process;

BEGIN
  -- get the maximum sequence number
  FOR l_seq_rec IN l_seq_csr
  LOOP
    l_max_seq_no :=  NVL(l_seq_rec.seq_no,0);
  END LOOP;

  fnd_msg_pub.count_and_get(
    p_count => l_msg_count,
    p_data => l_msg_data);

  l_loop_process := FALSE;

  FOR l_count IN 1..l_msg_count
  LOOP
    l_loop_process := TRUE;
    l_seq_no := l_max_seq_no + l_count;

    if l_count =1 then
      if l_count = l_msg_count then
        fnd_message.Set_Encoded(l_msg_data);
        l_msg_buf := FND_MESSAGE.Get;
      else
        l_msg_buf := FND_MSG_PUB.Get
			 (p_msg_index    => FND_MSG_PUB.G_FIRST,
			  p_encoded      => FND_API.G_FALSE);
      end if;
    else
      l_msg_buf := FND_MSG_PUB.Get
	            (p_msg_index    => FND_MSG_PUB.G_NEXT,
		     p_encoded      => FND_API.G_FALSE);
    end if;

     insert into PSB_ERROR_MESSAGES
     (concurrent_request_id,
      process_id,
      source_process,
      sequence_number,
      description,
      creation_date,
      created_by
      )
      values
     (
      l_conc_req_id,
      p_process_id,
      p_source_process,
      l_seq_no,
      l_msg_buf,
      sysdate,
      l_user_id
      );

  END LOOP;

  IF l_loop_process = FALSE then
    FND_MESSAGE.Set_Name('PSB', 'PSB_SERVER_ERROR_NO_MSG');
    l_msg_buf  := FND_MESSAGE.Get ;

    insert into PSB_ERROR_MESSAGES
    (concurrent_request_id,
     process_id,
     source_process,
     sequence_number,
     description,
     creation_date,
     created_by)
     values
     (l_conc_req_id,
      p_process_id,
      p_source_process,
      1,
      l_msg_buf,
      sysdate,
      l_user_id);

  end if;

END;
/* End bug no  4030864 */


END PSB_MESSAGE_S;

/
