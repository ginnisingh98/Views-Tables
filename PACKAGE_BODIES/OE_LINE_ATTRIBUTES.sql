--------------------------------------------------------
--  DDL for Package Body OE_LINE_ATTRIBUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_LINE_ATTRIBUTES" AS
/* $Header: OEXLATTB.pls 115.2 99/07/16 08:13:05 porting shi $ */

/*
** set_so_line_attributes is called from OrderImport to manipulate so_line_attributes
** given the records in so_line_attributes_interface.
** For op_code = INSERT/UPDATE, we only do UPDATE the records since
** insertion is already done in oeoord()
** For op_code = DELETE, we don't do any deletion since the complementing record in
** so_line_attributes is deleted from oeoord()
*/

PROCEDURE set_so_line_attributes
  (in_line_id		IN NUMBER,
   in_op_code	        IN VARCHAR2,
   in_ord_source	IN VARCHAR2,
   in_orig_sys_ref	IN VARCHAR2,
   in_orig_sys_l_ref    IN VARCHAR2,
   in_req_id	        IN NUMBER,
   out_result	        OUT NUMBER   )
  IS


	l_date			DATE;
	l_updated_by		NUMBER;
	l_login_id		NUMBER;
	l_program_application_id	NUMBER;
	l_program_id		NUMBER;
	l_request_id		NUMBER;
	l_industry_context	VARCHAR2(30);
	l_industry_attribute1	VARCHAR2(150);
	l_industry_attribute2	VARCHAR2(150);
	l_industry_attribute3	VARCHAR2(150);
	l_industry_attribute4	VARCHAR2(150);
	l_industry_attribute5	VARCHAR2(150);
	l_industry_attribute6	VARCHAR2(150);
	l_industry_attribute7	VARCHAR2(150);
	l_industry_attribute8	VARCHAR2(150);
	l_industry_attribute9	VARCHAR2(150);
	l_industry_attribute10	VARCHAR2(150);
	l_industry_attribute11	VARCHAR2(150);
	l_industry_attribute12	VARCHAR2(150);
	l_industry_attribute13	VARCHAR2(150);
	l_industry_attribute14	VARCHAR2(150);
	l_industry_attribute15	VARCHAR2(150);
	l_global_attribute_category	VARCHAR2(30);
	l_global_attribute1	VARCHAR2(150);
	l_global_attribute2	VARCHAR2(150);
	l_global_attribute3	VARCHAR2(150);
	l_global_attribute4	VARCHAR2(150);
	l_global_attribute5	VARCHAR2(150);
	l_global_attribute6	VARCHAR2(150);
	l_global_attribute7	VARCHAR2(150);
	l_global_attribute8	VARCHAR2(150);
	l_global_attribute9	VARCHAR2(150);
	l_global_attribute10	VARCHAR2(150);
	l_global_attribute11	VARCHAR2(150);
	l_global_attribute12	VARCHAR2(150);
	l_global_attribute13	VARCHAR2(150);
	l_global_attribute14	VARCHAR2(150);
	l_global_attribute15	VARCHAR2(150);
	l_global_attribute16	VARCHAR2(150);
	l_global_attribute17	VARCHAR2(150);
	l_global_attribute18	VARCHAR2(150);
	l_global_attribute19	VARCHAR2(150);
	l_global_attribute20	VARCHAR2(150);

BEGIN


   /* standard WHO */
   l_date := SYSDATE;
   l_updated_by := FND_GLOBAL.USER_ID;
   l_login_id := FND_GLOBAL.LOGIN_ID;

   /* standard concurrent program info */
   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
   l_program_application_id := FND_GLOBAL.PROG_APPL_ID;
   l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;


   IF ((in_op_code = 'INSERT') OR (in_op_code = 'UPDATE')) THEN

	SELECT
	  industry_context,
	  industry_attribute1,
	  industry_attribute2,
	  industry_attribute3,
	  industry_attribute4,
	  industry_attribute5,
	  industry_attribute6,
	  industry_attribute7,
	  industry_attribute8,
	  industry_attribute9,
	  industry_attribute10,
	  industry_attribute11,
	  industry_attribute12,
	  industry_attribute13,
	  industry_attribute14,
	  industry_attribute15,
	  global_attribute_category,
	  global_attribute1,
	  global_attribute2,
	  global_attribute3,
	  global_attribute4,
	  global_attribute5,
	  global_attribute6,
	  global_attribute7,
	  global_attribute8,
	  global_attribute9,
	  global_attribute10,
	  global_attribute11,
	  global_attribute12,
	  global_attribute13,
	  global_attribute14,
	  global_attribute15,
	  global_attribute16,
	  global_attribute17,
	  global_attribute18,
	  global_attribute19,
	  global_attribute20
        INTO
	  l_industry_context,
	  l_industry_attribute1,
	  l_industry_attribute2,
	  l_industry_attribute3,
	  l_industry_attribute4,
	  l_industry_attribute5,
	  l_industry_attribute6,
	  l_industry_attribute7,
	  l_industry_attribute8,
	  l_industry_attribute9,
	  l_industry_attribute10,
	  l_industry_attribute11,
	  l_industry_attribute12,
	  l_industry_attribute13,
	  l_industry_attribute14,
	  l_industry_attribute15,
	  l_global_attribute_category,
	  l_global_attribute1,
	  l_global_attribute2,
	  l_global_attribute3,
	  l_global_attribute4,
	  l_global_attribute5,
	  l_global_attribute6,
	  l_global_attribute7,
	  l_global_attribute8,
	  l_global_attribute9,
	  l_global_attribute10,
	  l_global_attribute11,
	  l_global_attribute12,
	  l_global_attribute13,
	  l_global_attribute14,
	  l_global_attribute15,
	  l_global_attribute16,
	  l_global_attribute17,
	  l_global_attribute18,
	  l_global_attribute19,
	  l_global_attribute20

	FROM   so_line_attributes_interface
	WHERE  order_source_id = in_ord_source
	AND    original_system_reference = in_orig_sys_ref
	AND    original_system_line_reference = in_orig_sys_l_ref
	AND    Nvl(error_flag,'N') <> 'Y';


      UPDATE so_line_attributes
	SET
	last_update_date = sysdate,
	last_updated_by = l_updated_by,
	last_update_login = l_login_id,
	program_application_id = l_program_application_id,
	program_id = l_program_id,
	program_update_date = l_date,
	request_id = l_request_id,
	industry_context = l_industry_context,
	industry_attribute1 = l_industry_attribute1,
	industry_attribute2 = l_industry_attribute2,
	industry_attribute3 = l_industry_attribute3,
	industry_attribute4 = l_industry_attribute4,
	industry_attribute5 = l_industry_attribute5,
	industry_attribute6 = l_industry_attribute6,
	industry_attribute7 = l_industry_attribute7,
	industry_attribute8 = l_industry_attribute8,
	industry_attribute9 = l_industry_attribute9,
	industry_attribute10 = l_industry_attribute10,
	industry_attribute11 = l_industry_attribute11,
	industry_attribute12 = l_industry_attribute12,
	industry_attribute13 = l_industry_attribute13,
	industry_attribute14 = l_industry_attribute14,
	industry_attribute15 = l_industry_attribute15,
	global_attribute_category = l_global_attribute_category,
	global_attribute1 = l_global_attribute1,
	global_attribute2 = l_global_attribute2,
	global_attribute3 = l_global_attribute3,
	global_attribute4 = l_global_attribute4,
	global_attribute5 = l_global_attribute5,
	global_attribute6 = l_global_attribute6,
	global_attribute7 = l_global_attribute7,
	global_attribute8 = l_global_attribute8,
	global_attribute9 = l_global_attribute9,
	global_attribute10 = l_global_attribute10,
	global_attribute11 = l_global_attribute11,
	global_attribute12 = l_global_attribute12,
	global_attribute13 = l_global_attribute13,
	global_attribute14 = l_global_attribute14,
	global_attribute15 = l_global_attribute15,
	global_attribute16 = l_global_attribute16,
	global_attribute17 = l_global_attribute17,
	global_attribute18 = l_global_attribute18,
	global_attribute19 = l_global_attribute19,
	global_attribute20  = l_global_attribute20
     WHERE  line_id = in_line_id;

     /* we don't do anything for DELETE */

   END IF;


   out_result := 1;

   EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   out_result := 1;

END set_so_line_attributes;


/*
** set_industry_attributes is called from oeoord.lpc
** to insert(delete) a complementing null record into so_line_attributes
** whenever a line is inserted(deleted) into so_lines.
** Also called from Order User Exit to update records when in GUI mode,
** or to insert/delete records when in Character mode.
*/

PROCEDURE set_industry_attributes
  (in_op_code                   IN VARCHAR2,
   in_line_id                   IN NUMBER,
   in_industry_context          IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute1       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute2       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute3       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute4       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute5       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute6       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute7       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute8       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute9       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute10       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute11       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute12       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute13       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute14       IN VARCHAR2 DEFAULT NULL,
   in_industry_attribute15       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute_category  IN VARCHAR2 DEFAULT NULL,
   in_global_attribute1        IN VARCHAR2 DEFAULT NULL,
   in_global_attribute2        IN VARCHAR2 DEFAULT NULL,
   in_global_attribute3        IN VARCHAR2 DEFAULT NULL,
   in_global_attribute4        IN VARCHAR2 DEFAULT NULL,
   in_global_attribute5        IN VARCHAR2 DEFAULT NULL,
   in_global_attribute6        IN VARCHAR2 DEFAULT NULL,
   in_global_attribute7        IN VARCHAR2 DEFAULT NULL,
   in_global_attribute8        IN VARCHAR2 DEFAULT NULL,
   in_global_attribute9        IN VARCHAR2 DEFAULT NULL,
   in_global_attribute10       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute11       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute12       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute13       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute14       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute15       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute16       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute17       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute18       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute19       IN VARCHAR2 DEFAULT NULL,
   in_global_attribute20       IN VARCHAR2 DEFAULT NULL)

IS

   l_date			DATE;
   l_user_id		 	NUMBER;
   l_login_id			NUMBER;

   l_request_id                 NUMBER;
   l_prog_application_id        NUMBER;
   l_program_id                 NUMBER;

BEGIN

   /* standard WHO */
   l_date := SYSDATE;
   l_user_id := FND_GLOBAL.USER_ID;
   l_login_id := FND_GLOBAL.LOGIN_ID;

   /* standard concurrent program info */
   l_request_id := FND_GLOBAL.CONC_REQUEST_ID;
   l_prog_application_id := FND_GLOBAL.PROG_APPL_ID;
   l_program_id := FND_GLOBAL.CONC_PROGRAM_ID;

   IF (in_op_code = 'INSERT') THEN

      INSERT INTO so_line_attributes
        (line_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date,
         request_id,
         industry_context,
         industry_attribute1,
         industry_attribute2,
         industry_attribute3,
         industry_attribute4,
         industry_attribute5,
         industry_attribute6,
         industry_attribute7,
         industry_attribute8,
         industry_attribute9,
         industry_attribute10,
         industry_attribute11,
         industry_attribute12,
         industry_attribute13,
         industry_attribute14,
         industry_attribute15,
         global_attribute_category,
         global_attribute1,
         global_attribute2,
         global_attribute3,
         global_attribute4,
         global_attribute5,
         global_attribute6,
         global_attribute7,
         global_attribute8,
         global_attribute9,
         global_attribute10,
         global_attribute11,
         global_attribute12,
         global_attribute13,
         global_attribute14,
         global_attribute15,
         global_attribute16,
         global_attribute17,
         global_attribute18,
         global_attribute19,
         global_attribute20)

      VALUES
        (in_line_id,
   	 l_date,
   	 l_user_id,
   	 l_date,
   	 l_user_id,
   	 l_login_id,
         l_prog_application_id,
         l_program_id,
         l_date,
         l_request_id,
         in_industry_context,
         in_industry_attribute1,
         in_industry_attribute2,
         in_industry_attribute3,
         in_industry_attribute4,
         in_industry_attribute5,
         in_industry_attribute6,
         in_industry_attribute7,
         in_industry_attribute8,
         in_industry_attribute9,
         in_industry_attribute10,
         in_industry_attribute11,
         in_industry_attribute12,
         in_industry_attribute13,
         in_industry_attribute14,
         in_industry_attribute15,
         in_global_attribute_category,
         in_global_attribute1,
         in_global_attribute2,
         in_global_attribute3,
         in_global_attribute4,
         in_global_attribute5,
         in_global_attribute6,
         in_global_attribute7,
         in_global_attribute8,
         in_global_attribute9,
         in_global_attribute10,
         in_global_attribute11,
         in_global_attribute12,
         in_global_attribute13,
         in_global_attribute14,
         in_global_attribute15,
         in_global_attribute16,
         in_global_attribute17,
         in_global_attribute18,
         in_global_attribute19,
         in_global_attribute20);

    ELSIF (in_op_code = 'UPDATE') THEN

    BEGIN

      UPDATE so_line_attributes
        SET
        last_update_date = l_date,
        last_updated_by = l_user_id,
        last_update_login = l_login_id,
        program_application_id = l_prog_application_id,
        program_id = l_program_id,
        program_update_date = l_date,
        request_id = l_request_id,
        industry_context = in_industry_context,
        industry_attribute1 = in_industry_attribute1,
        industry_attribute2 = in_industry_attribute2,
        industry_attribute3 = in_industry_attribute3,
        industry_attribute4 = in_industry_attribute4,
        industry_attribute5 = in_industry_attribute5,
        industry_attribute6 = in_industry_attribute6,
        industry_attribute7 = in_industry_attribute7,
        industry_attribute8 = in_industry_attribute9,
        industry_attribute9 = in_industry_attribute9,
        industry_attribute10 = in_industry_attribute10,
        industry_attribute11 = in_industry_attribute11,
        industry_attribute12 = in_industry_attribute12,
        industry_attribute13 = in_industry_attribute13,
        industry_attribute14 = in_industry_attribute14,
        industry_attribute15 = in_industry_attribute15,
        global_attribute_category = in_global_attribute_category,
        global_attribute1 = in_global_attribute1,
        global_attribute2 = in_global_attribute2,
        global_attribute3 = in_global_attribute3,
        global_attribute4 = in_global_attribute4,
        global_attribute5 = in_global_attribute5,
        global_attribute6 = in_global_attribute6,
        global_attribute7 = in_global_attribute7,
        global_attribute8 = in_global_attribute8,
        global_attribute9 = in_global_attribute9,
        global_attribute10 = in_global_attribute10,
        global_attribute11 = in_global_attribute11,
        global_attribute12 = in_global_attribute12,
        global_attribute13 = in_global_attribute13,
        global_attribute14 = in_global_attribute14,
        global_attribute15 = in_global_attribute15,
        global_attribute16 = in_global_attribute16,
        global_attribute17 = in_global_attribute17,
        global_attribute18 = in_global_attribute18,
        global_attribute19 = in_global_attribute19,
        global_attribute20 = in_global_attribute20
	WHERE line_id = in_line_id;

      /* existing order lines that were inserted PRE-ReleaseAccountingInstallation
	 would have no complementing records in so_line_attributes.
         In this case, we should insert a new record with the new information */

      IF SQL%NOTFOUND THEN -- update failed

      INSERT INTO so_line_attributes
        (line_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login,
         program_application_id,
         program_id,
         program_update_date,
         request_id,
         industry_context,
         industry_attribute1,
         industry_attribute2,
         industry_attribute3,
         industry_attribute4,
         industry_attribute5,
         industry_attribute6,
         industry_attribute7,
         industry_attribute8,
         industry_attribute9,
         industry_attribute10,
         industry_attribute11,
         industry_attribute12,
         industry_attribute13,
         industry_attribute14,
         industry_attribute15,
         global_attribute_category,
         global_attribute1,
         global_attribute2,
         global_attribute3,
         global_attribute4,
         global_attribute5,
         global_attribute6,
         global_attribute7,
         global_attribute8,
         global_attribute9,
         global_attribute10,
         global_attribute11,
         global_attribute12,
         global_attribute13,
         global_attribute14,
         global_attribute15,
         global_attribute16,
         global_attribute17,
         global_attribute18,
         global_attribute19,
         global_attribute20)

      VALUES
        (in_line_id,
   	 l_date,
   	 l_user_id,
   	 l_date,
   	 l_user_id,
   	 l_login_id,
         l_prog_application_id,
         l_program_id,
         l_date,
         l_request_id,
         in_industry_context,
         in_industry_attribute1,
         in_industry_attribute2,
         in_industry_attribute3,
         in_industry_attribute4,
         in_industry_attribute5,
         in_industry_attribute6,
         in_industry_attribute7,
         in_industry_attribute8,
         in_industry_attribute9,
         in_industry_attribute10,
         in_industry_attribute11,
         in_industry_attribute12,
         in_industry_attribute13,
         in_industry_attribute14,
         in_industry_attribute15,
         in_global_attribute_category,
         in_global_attribute1,
         in_global_attribute2,
         in_global_attribute3,
         in_global_attribute4,
         in_global_attribute5,
         in_global_attribute6,
         in_global_attribute7,
         in_global_attribute8,
         in_global_attribute9,
         in_global_attribute10,
         in_global_attribute11,
         in_global_attribute12,
         in_global_attribute13,
         in_global_attribute14,
         in_global_attribute15,
         in_global_attribute16,
         in_global_attribute17,
         in_global_attribute18,
         in_global_attribute19,
         in_global_attribute20);

      END IF; /* no record exists for update */

    END;

    ELSIF (in_op_code = 'DELETE') THEN

        DELETE
        FROM  so_line_attributes
        WHERE line_id = in_line_id;

    END if;

END set_industry_attributes;


/*
** get_industry_attributes is called from oexobj.lpc
** to get industry attributes from the database given a line_id.
** This is used to resolve locking issue.
*/

PROCEDURE get_industry_attributes
  (in_op_code                   IN VARCHAR2,
   in_line_id                   IN NUMBER,
   out_industry_context         OUT  VARCHAR2 ,
   out_industry_attribute1      OUT  VARCHAR2 ,
   out_industry_attribute2      OUT  VARCHAR2 ,
   out_industry_attribute3      OUT  VARCHAR2 ,
   out_industry_attribute4      OUT  VARCHAR2 ,
   out_industry_attribute5      OUT  VARCHAR2 ,
   out_industry_attribute6      OUT  VARCHAR2 ,
   out_industry_attribute7      OUT  VARCHAR2 ,
   out_industry_attribute8      OUT  VARCHAR2 ,
   out_industry_attribute9      OUT  VARCHAR2 ,
   out_industry_attribute10     OUT  VARCHAR2 ,
   out_industry_attribute11     OUT  VARCHAR2 ,
   out_industry_attribute12     OUT  VARCHAR2 ,
   out_industry_attribute13     OUT  VARCHAR2 ,
   out_industry_attribute14     OUT  VARCHAR2 ,
   out_industry_attribute15     OUT  VARCHAR2,
   out_global_attribute_category      OUT  VARCHAR2 ,
   out_global_attribute1              OUT  VARCHAR2 ,
   out_global_attribute2              OUT  VARCHAR2 ,
   out_global_attribute3              OUT  VARCHAR2 ,
   out_global_attribute4              OUT  VARCHAR2 ,
   out_global_attribute5              OUT  VARCHAR2 ,
   out_global_attribute6              OUT  VARCHAR2 ,
   out_global_attribute7              OUT  VARCHAR2 ,
   out_global_attribute8              OUT  VARCHAR2 ,
   out_global_attribute9              OUT  VARCHAR2 ,
   out_global_attribute10             OUT  VARCHAR2 ,
   out_global_attribute11             OUT  VARCHAR2 ,
   out_global_attribute12             OUT  VARCHAR2 ,
   out_global_attribute13             OUT  VARCHAR2 ,
   out_global_attribute14             OUT  VARCHAR2 ,
   out_global_attribute15             OUT  VARCHAR2 ,
   out_global_attribute16             OUT  VARCHAR2 ,
   out_global_attribute17             OUT  VARCHAR2 ,
   out_global_attribute18             OUT  VARCHAR2 ,
   out_global_attribute19             OUT  VARCHAR2 ,
   out_global_attribute20     OUT  VARCHAR2
   )
IS

BEGIN
    IF (in_op_code = 'SELECT') THEN

      SELECT
         industry_context,
         industry_attribute1,
         industry_attribute2,
         industry_attribute3,
         industry_attribute4,
         industry_attribute5,
         industry_attribute6,
         industry_attribute7,
         industry_attribute8,
         industry_attribute9,
         industry_attribute10,
         industry_attribute11,
         industry_attribute12,
         industry_attribute13,
         industry_attribute14,
         industry_attribute15,
         global_attribute_category,
         global_attribute1,
         global_attribute2,
         global_attribute3,
         global_attribute4,
         global_attribute5,
         global_attribute6,
         global_attribute7,
         global_attribute8,
         global_attribute9,
         global_attribute10,
         global_attribute11,
         global_attribute12,
         global_attribute13,
         global_attribute14,
         global_attribute15,
         global_attribute16,
         global_attribute17,
         global_attribute18,
         global_attribute19,
         global_attribute20

      INTO
         out_industry_context,
         out_industry_attribute1,
         out_industry_attribute2,
         out_industry_attribute3,
         out_industry_attribute4,
         out_industry_attribute5,
         out_industry_attribute6,
         out_industry_attribute7,
         out_industry_attribute8,
         out_industry_attribute9,
         out_industry_attribute10,
         out_industry_attribute11,
         out_industry_attribute12,
         out_industry_attribute13,
         out_industry_attribute14,
         out_industry_attribute15,
         out_global_attribute_category,
         out_global_attribute1,
         out_global_attribute2,
         out_global_attribute3,
         out_global_attribute4,
         out_global_attribute5,
         out_global_attribute6,
         out_global_attribute7,
         out_global_attribute8,
         out_global_attribute9,
         out_global_attribute10,
         out_global_attribute11,
         out_global_attribute12,
         out_global_attribute13,
         out_global_attribute14,
         out_global_attribute15,
         out_global_attribute16,
         out_global_attribute17,
         out_global_attribute18,
         out_global_attribute19,
         out_global_attribute20
      FROM
         so_line_attributes
      WHERE
         line_id = in_line_id;

   END IF;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
         out_industry_context := NULL ;
         out_industry_attribute1 := NULL ;
         out_industry_attribute2 := NULL ;
         out_industry_attribute3 := NULL ;
         out_industry_attribute4 := NULL ;
         out_industry_attribute5 := NULL ;
         out_industry_attribute6 := NULL ;
         out_industry_attribute7 := NULL ;
         out_industry_attribute8 := NULL ;
         out_industry_attribute9 := NULL ;
         out_industry_attribute10 := NULL ;
         out_industry_attribute11 := NULL ;
         out_industry_attribute12 := NULL ;
         out_industry_attribute13 := NULL ;
         out_industry_attribute14 := NULL ;
         out_industry_attribute15 := NULL ;
         out_global_attribute_category := NULL ;
         out_global_attribute1 := NULL ;
         out_global_attribute2 := NULL ;
         out_global_attribute3 := NULL ;
         out_global_attribute4 := NULL ;
         out_global_attribute5 := NULL ;
         out_global_attribute6 := NULL ;
         out_global_attribute7 := NULL ;
         out_global_attribute8 := NULL ;
         out_global_attribute9 := NULL ;
         out_global_attribute10 := NULL ;
         out_global_attribute11 := NULL ;
         out_global_attribute12 := NULL ;
         out_global_attribute13 := NULL ;
         out_global_attribute14 := NULL ;
         out_global_attribute15 := NULL ;
         out_global_attribute16 := NULL ;
         out_global_attribute17 := NULL ;
         out_global_attribute18 := NULL ;
         out_global_attribute19 := NULL ;
         out_global_attribute20 := NULL ;


END get_industry_attributes;

END oe_line_attributes;

/
