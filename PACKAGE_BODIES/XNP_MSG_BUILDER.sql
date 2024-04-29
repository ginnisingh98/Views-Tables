--------------------------------------------------------
--  DDL for Package Body XNP_MSG_BUILDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_MSG_BUILDER" AS
/* $Header: XNPMBLPB.pls 120.1 2005/06/18 00:23:09 appldev  $ */

	g_message_code		VARCHAR2(40) ;
	g_excep_section		VARCHAR2(16000) ;
	g_decl_section		VARCHAR2(16000);
	g_create_body		VARCHAR2(32767);
	g_mandatory_check	BOOLEAN := FALSE ;
	g_mandatory_list	VARCHAR2(4000) ;
	g_loop_counter		NUMBER := 1 ;

	g_event_indr               XNP_MSG_TYPES_B.msg_type%TYPE ;
	g_dtd_url                  XNP_MSG_TYPES_B.dtd_url%TYPE ;
	g_msg_priority             XNP_MSG_TYPES_B.priority%TYPE ;
	g_validate_logic           XNP_MSG_TYPES_B.validate_logic%TYPE ;
	g_process_logic            XNP_MSG_TYPES_B.in_process_logic%TYPE ;
	g_out_process_logic        XNP_MSG_TYPES_B.out_process_logic%TYPE ;
	g_dflt_process_logic       XNP_MSG_TYPES_B.default_process_logic%TYPE ;
	g_queue_name               XNP_MSG_TYPES_B.queue_name%TYPE ;
        g_temp_tab                 XDP_TYPES.VARCHAR2_4000_TAB ;

	CURSOR get_msg_type_data IS
		SELECT msg_type,
		       priority,
			in_process_logic,
			out_process_logic,
			default_process_logic,
			validate_logic,
			queue_name,
			dtd_url
		FROM XNP_MSG_TYPES_B
		WHERE msg_code = g_message_code ;

	CURSOR get_compilation_errors ( l_proc_name VARCHAR2 )IS
		SELECT text FROM user_errors
		WHERE name =  UPPER( l_proc_name )  ;

	CURSOR get_parameter_data IS
		SELECT name,
                       element_datatype,
                       mandatory_flag,
		       NVL ( element_default_value, 'NP_NULL' ) element_default_value ,
                       parameter_sequence
		 FROM xnp_msg_elements
		WHERE msg_code = g_message_code
		  AND parameter_flag = 'Y'
                ORDER BY parameter_sequence ;


	g_white_space   CONSTANT  CHAR := ' ' ;

	g_new_line CONSTANT VARCHAR2(10) := convert(fnd_global.local_chr(10),
		substr(userenv('LANGUAGE'), instr(userenv('LANGUAGE'),'.') +1),
		'WE8ISO8859P1')  ;

	g_comma         CONSTANT  CHAR := ',' ;
	g_delimeter     CONSTANT  CHAR := '%' ;
	g_np_prefix     CONSTANT  VARCHAR2(10) := 'XNP$' ;

	-- forward declarations

	PROCEDURE cr_start_body(
		x_start_body OUT NOCOPY VARCHAR2
	);


	PROCEDURE cr_start_signature(
		x_start_sig OUT NOCOPY VARCHAR2
	);

	PROCEDURE cr_dflt_process_body(
		x_dflt_process OUT NOCOPY VARCHAR2
	);

	PROCEDURE cr_process_body(
		x_process_body OUT NOCOPY VARCHAR2
	);

	PROCEDURE cr_process_signature(
		x_process_sig OUT NOCOPY VARCHAR2
	);

	PROCEDURE cr_dflt_process_sig(
		x_dflt_process_sig OUT NOCOPY VARCHAR2
	);

	PROCEDURE cr_validate_signature(
		x_validate_sig OUT NOCOPY VARCHAR2
	);

	PROCEDURE compile_spec(
		p_pkg_name IN VARCHAR2
		,x_error_code OUT NOCOPY NUMBER
		,x_error_message OUT NOCOPY VARCHAR2
	);

	PROCEDURE compile_body(
		p_pkg_name IN VARCHAR2
		,x_error_code OUT NOCOPY NUMBER
		,x_error_message OUT NOCOPY VARCHAR2
	);

	PROCEDURE cr_pkg_body(
		 x_error_code    OUT NOCOPY NUMBER
		,x_error_message OUT NOCOPY VARCHAR2
		,x_package_body  OUT NOCOPY VARCHAR2
	);

	PROCEDURE cr_pkg_spec(
		 x_error_code    OUT NOCOPY NUMBER
		,x_error_message OUT NOCOPY VARCHAR2
		,x_package_spec  OUT NOCOPY VARCHAR2
	) ;

	PROCEDURE cr_publish_body(
		x_publish_body OUT NOCOPY VARCHAR2
	);

	PROCEDURE cr_create_body(
		x_create_body OUT NOCOPY VARCHAR2
	);

	PROCEDURE cr_publish_signature(
		x_publish_sig OUT NOCOPY VARCHAR2
	);

	PROCEDURE cr_create_signature(
		x_create_sig OUT NOCOPY VARCHAR2
	) ;

	PROCEDURE cr_send_signature(
		x_send_sig OUT NOCOPY VARCHAR2
	);

	PROCEDURE cr_send_body(
		x_send_body OUT NOCOPY VARCHAR2
	);

	PROCEDURE generate_create_body(
		p_element        IN VARCHAR2
		,p_element_type   IN VARCHAR2
		,p_mandatory_flag IN VARCHAR2
		,p_source_type    IN VARCHAR2
		,p_data_source    IN VARCHAR2
		,p_source_ref     IN VARCHAR2
		,p_cardinality    IN VARCHAR2
		,p_parameter_flag IN VARCHAR2
	);

	PROCEDURE bld_msgevt(
		x_error_code    OUT NOCOPY NUMBER
		,x_error_message OUT NOCOPY VARCHAR2
		,x_package_spec  OUT NOCOPY VARCHAR2
		,x_package_body  OUT NOCOPY VARCHAR2
		,x_synonym       OUT NOCOPY VARCHAR2
	) ;

----------------------------------------------------------------------------
--Copy Message Definition---------------------------------------------------
PROCEDURE Create_msg_type(p_old_msg_code       IN VARCHAR2,
                          p_new_msg_code       IN VARCHAR2,
                          p_new_disp_name      IN VARCHAR2,
                          p_return_code        OUT NOCOPY NUMBER,
                          p_error_description  OUT NOCOPY VARCHAR2);

PROCEDURE Create_msg_element(p_old_msg_code       IN VARCHAR2,
                             p_new_msg_code       IN VARCHAR2,
                             p_return_code        OUT NOCOPY NUMBER,
                             p_error_description  OUT NOCOPY VARCHAR2);

PROCEDURE COPY_MESG_STR(p_old_msg_code IN VARCHAR2,
                          p_new_msg_code IN VARCHAR2,
                          p_element_name IN VARCHAR2,
                          p_element_id IN NUMBER,
                          p_return_code  OUT NOCOPY NUMBER,
                          p_error_description OUT NOCOPY VARCHAR2) ;

PROCEDURE CREATE_MSG_STR(P_PARENT_ELEMENT_ID      IN NUMBER,
                         P_CHILD_ELEMENT_ID       IN NUMBER,
                         P_MSG_CODE               IN VARCHAR2,
                         P_SEQUENCE_IN_PARENT     IN NUMBER ,
                         P_CARDINALITY            IN VARCHAR2,
                         P_DATA_SOURCE            IN VARCHAR2,
                         P_DATA_SOURCE_TYPE       IN VARCHAR2,
                         P_DATA_SOURCE_REFERENCE  IN VARCHAR2,
                         P_ELEMENT_POSITION       IN NUMBER,
                         P_ELEMENT_ALIGNMENT      IN VARCHAR2,
                         P_PADDING                IN VARCHAR2,
                         p_return_code            OUT NOCOPY NUMBER,
                         p_error_description      OUT NOCOPY VARCHAR2) ;



FUNCTION get_new_child_element_id  (p_new_msg_code VARCHAR2,
                    p_child_element_name VARCHAR2
                    ) RETURN NUMBER  ;

FUNCTION get_new_parent_element_id  (p_new_msg_code VARCHAR2,
                    p_element_name VARCHAR2) RETURN NUMBER ;

---------------------------------------------------------------------------------
---Copy Message definition----------------------------------------------------------


FUNCTION get_new_child_element_id
               (p_new_msg_code VARCHAR2,
                p_child_element_name VARCHAR2) RETURN NUMBER IS

lv_element_id  NUMBER ;

BEGIN
          SELECT msg_element_id
            INTO lv_element_id
            FROM xnp_msg_elements
           WHERE name = p_child_element_name
             AND msg_code = p_new_msg_code;

RETURN lv_element_id ;

EXCEPTION

     WHEN  OTHERS THEN
         ROLLBACK TO Mesg;
        RAISE;
END get_new_child_element_id;



FUNCTION get_new_parent_element_id
             (p_new_msg_code VARCHAR2,
              p_element_name VARCHAR2) RETURN NUMBER IS

lv_element_id  NUMBER ;

BEGIN

        SELECT msg_element_id
          INTO lv_element_id
          FROM xnp_msg_elements
          WHERE name = p_element_name
            AND msg_code = p_new_msg_code;

RETURN lv_element_id ;

EXCEPTION
     WHEN  OTHERS THEN
        ROLLBACK TO Mesg;
        RAISE;
END get_new_parent_element_id;


PROCEDURE CopyMesg(
        p_old_msg_code IN VARCHAR2,
        p_new_msg_code IN VARCHAR2,
        p_new_disp_name IN VARCHAR2,
        p_return_code   OUT NOCOPY NUMBER,
        p_error_description  OUT NOCOPY VARCHAR2)

IS
 l_return_code   NUMBER :=0;
 l_error_description VARCHAR2(32767);

BEGIN
   SAVEPOINT Mesg;
   p_return_code :=0;
   Create_msg_type(p_old_msg_code       =>  CopyMesg.p_old_msg_code,
                   p_new_msg_code       =>  CopyMesg.p_new_msg_code,
                   p_new_disp_name      =>  CopyMesg.p_new_disp_name,
                   p_return_code         =>  l_return_code ,
                   p_error_description   =>  l_error_description );

   Create_msg_element(p_old_msg_code    =>  CopyMesg.p_old_msg_code,
                   p_new_msg_code       =>  CopyMesg.p_new_msg_code,
                   p_return_code         =>  l_return_code ,
                   p_error_description   =>  l_error_description );
EXCEPTION WHEN OTHERS
THEN
  ROLLBACK  to Mesg;
   p_return_code       := l_return_code ;
   p_error_description := l_error_description ;

END CopyMesg;

PROCEDURE Create_msg_type(p_old_msg_code IN VARCHAR2,
                          p_new_msg_code IN VARCHAR2,
                          p_new_disp_name IN VARCHAR2,
                          p_return_code OUT NOCOPY NUMBER,
                          p_error_description  OUT NOCOPY VARCHAR2)

IS
   l_rowid   rowid;
   lv_element_name VARCHAR2(3000);


  CURSOR c_mesg_type IS
         SELECT MSG_TYPE,
                STATUS,
                PRIORITY,
                QUEUE_NAME,
                PROTECTED_FLAG,
                ROLE_NAME,
                LAST_COMPILED_DATE,
                VALIDATE_LOGIC,
                IN_PROCESS_LOGIC,
                OUT_PROCESS_LOGIC,
                DEFAULT_PROCESS_LOGIC,
                DTD_URL,
                DISPLAY_NAME,
                DESCRIPTION
          FROM XNP_MSG_TYPES_VL
             WHERE MSG_CODE = p_old_msg_code;




BEGIN
  -- Insert into Mesg_types_b,mesg_types_tl table
  --
   p_return_code:=0;
   FOR c_mesg_rec IN c_mesg_type
   LOOP
       XNP_MSG_TYPES_PKG.INSERT_ROW
            (
             X_ROWID                   =>  l_rowid,
             X_MSG_CODE                =>  p_new_msg_code,
             X_MSG_TYPE                =>  c_mesg_rec.msg_type,
             X_STATUS                  =>  'UNCOMPILED',
             X_PRIORITY                =>  c_mesg_rec.PRIORITY,
             X_QUEUE_NAME              =>  c_mesg_rec.QUEUE_NAME,
             X_PROTECTED_FLAG          =>  c_mesg_rec.PROTECTED_FLAG,
             X_ROLE_NAME               =>  c_mesg_rec.ROLE_NAME,
             X_LAST_COMPILED_DATE      =>  sysdate,
             X_VALIDATE_LOGIC          =>  c_mesg_rec.VALIDATE_LOGIC     ,
             X_IN_PROCESS_LOGIC        =>  c_mesg_rec.IN_PROCESS_LOGIC ,
             X_OUT_PROCESS_LOGIC       =>  c_mesg_rec.OUT_PROCESS_LOGIC,
             X_DEFAULT_PROCESS_LOGIC   =>  c_mesg_rec.DEFAULT_PROCESS_LOGIC,
             X_DTD_URL                 =>  c_mesg_rec.DTD_URL,
             X_DISPLAY_NAME            =>  p_new_disp_name ,--c_mesg_rec.DISPLAY_NAME,
             X_DESCRIPTION             =>  c_mesg_rec.DESCRIPTION,
             X_CREATION_DATE           =>  SYSDATE,
             X_CREATED_BY              =>  FND_GLOBAL.USER_ID,
             X_LAST_UPDATE_DATE        =>  SYSDATE,
             X_LAST_UPDATED_BY         =>  FND_GLOBAL.USER_ID,
             X_LAST_UPDATE_LOGIN       =>  FND_GLOBAL.LOGIN_ID);
   END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
        p_return_code:=SQLCODE;
       p_error_description:=SQLERRM;
END Create_msg_type;

PROCEDURE Create_msg_element(p_old_msg_code IN VARCHAR2,
        p_new_msg_code IN VARCHAR2,
        p_return_code   OUT NOCOPY NUMBER,
        p_error_description  OUT NOCOPY VARCHAR2)
IS
l_return_code NUMBER:=0;
l_error_description VARCHAR2(2000);
l_new_parent_element_id NUMBER ;
l_new_child_element_id  NUMBER ;
lv_element_name VARCHAR2(40);

        CURSOR c_msg_element IS
           SELECT NAME,
                  MANDATORY_FLAG,
                  PARAMETER_FLAG,
                  ELEMENT_DATATYPE,
                  ELEMENT_DEFAULT_VALUE,
                  DATA_LENGTH,
                  PARAMETER_SEQUENCE,
                  MSG_ELEMENT_ID                       --- Added for msg_structure

            FROM  XNP_MSG_ELEMENTS
            WHERE MSG_CODE= p_old_msg_code;

       CURSOR c_old_master is
          select str.SEQUENCE_IN_PARENT,
                 str.CARDINALITY,
                 str.DATA_SOURCE,
                 str.DATA_SOURCE_TYPE,
                 str.DATA_SOURCE_REFERENCE,
                 str.ELEMENT_POSITION,
                 str.ELEMENT_ALIGNMENT,
                 str.PADDING
           from xnp_msg_structures str,
                xnp_msg_elements elm
           where str.parent_element_id = elm.msg_element_id
           AND   elm.msg_code=p_old_msg_code
           AND   elm.NAME='MESSAGE' ;

BEGIN
   p_return_code:=0;
   For c_msg_element_rec IN c_msg_element
    LOOP
        IF c_msg_element_rec.NAME = p_old_msg_code THEN
           lv_element_name :=p_new_msg_code;
        ELSE
           lv_element_name :=c_msg_element_rec.NAME;
        END IF;

INSERT INTO XNP_MSG_ELEMENTS
             (
              MSG_ELEMENT_ID         ,
              MSG_CODE               ,
              NAME                   ,
              MANDATORY_FLAG         ,
              PARAMETER_FLAG         ,
              ELEMENT_DATATYPE       ,
              ELEMENT_DEFAULT_VALUE  ,
              DATA_LENGTH            ,
              PARAMETER_SEQUENCE     ,
              CREATED_BY             ,
              CREATION_DATE          ,
              LAST_UPDATE_DATE       ,
              LAST_UPDATED_BY        ,
              LAST_UPDATE_LOGIN      )
            VALUES(
              XNP_MSG_ELEMENTS_S.NEXTVAL,
              p_new_msg_code,
              lv_element_name,
              c_msg_element_rec.MANDATORY_FLAG,
              c_msg_element_rec.PARAMETER_FLAG,
              c_msg_element_rec.ELEMENT_DATATYPE,
              c_msg_element_rec.ELEMENT_DEFAULT_VALUE,
              c_msg_element_rec.DATA_LENGTH,
              c_msg_element_rec.PARAMETER_SEQUENCE,
              FND_GLOBAL.USER_ID,
              SYSDATE,
              SYSDATE,
              FND_GLOBAL.USER_ID,
              FND_GLOBAL.LOGIN_ID
            );
      END LOOP;
---Create a structure for "MESSAGE" element and element named as new message code

         FOR c_old_master_rec IN c_old_master
           LOOP
              l_new_child_element_id := get_new_child_element_id  (p_new_msg_code=> p_new_msg_code,
                                                                   p_child_element_name => p_new_msg_code) ;

              l_new_parent_element_id := get_new_parent_element_id  (p_new_msg_code,
                                                                     'MESSAGE') ;

              CREATE_MSG_STR(P_PARENT_ELEMENT_ID      => l_new_parent_element_id ,
                             P_CHILD_ELEMENT_ID       => l_new_child_element_id ,
                             P_MSG_CODE               => p_new_msg_code ,
                             P_SEQUENCE_IN_PARENT     => c_old_master_rec.SEQUENCE_IN_PARENT ,
                             P_CARDINALITY            => c_old_master_rec.CARDINALITY ,
                             P_DATA_SOURCE            => c_old_master_rec.DATA_SOURCE ,
                             P_DATA_SOURCE_TYPE       => c_old_master_rec.DATA_SOURCE_TYPE ,
                             P_DATA_SOURCE_REFERENCE  => c_old_master_rec.DATA_SOURCE_REFERENCE ,
                             P_ELEMENT_POSITION       => c_old_master_rec.ELEMENT_POSITION ,
                             P_ELEMENT_ALIGNMENT      => c_old_master_rec.ELEMENT_ALIGNMENT ,
                             P_PADDING                => c_old_master_rec.PADDING ,
                             P_RETURN_CODE            => l_return_code,
                             P_ERROR_DESCRIPTION      => l_error_description);
           END LOOP;


---Create a structures for all other child elements for the message

         l_new_child_element_id := get_new_child_element_id
                                       (p_new_msg_code=> p_old_msg_code,
                                        p_child_element_name => p_old_msg_code);

             COPY_MESG_STR(p_old_msg_code  => p_old_msg_code,
                           p_new_msg_code => p_new_msg_code,
                           p_element_name => p_new_msg_code,
                           p_element_id   => l_new_child_element_id,
                           p_return_code  => l_return_code,
                           p_error_description =>l_error_description);

EXCEPTION
   WHEN OTHERS THEN
    p_return_code:=SQLCODE;
    p_error_description:=SQLERRM;

END Create_msg_element;




PROCEDURE COPY_MESG_STR(p_old_msg_code IN VARCHAR2,
                          p_new_msg_code IN VARCHAR2,
                          p_element_name IN VARCHAR2,
                          p_element_id IN NUMBER,
                          p_return_code OUT NOCOPY NUMBER,
                          p_error_description OUT NOCOPY VARCHAR2)

  IS
  l_new_parent_element_id NUMBER ;
  l_new_child_element_id  NUMBER ;
  l_return_code   NUMBER:=0;
  l_error_description VARCHAR2(4000);

-- this cursor is reqd to fetch the detail of 'Message' and
-- old_message_code in msg_structures.


       Cursor c_old_child is
          SELECT str.child_element_id,
                 str.SEQUENCE_IN_PARENT,
                 str.CARDINALITY,
                 str.DATA_SOURCE,
                 str.DATA_SOURCE_TYPE,
                 str.DATA_SOURCE_REFERENCE,
                 str.ELEMENT_POSITION,
                 str.ELEMENT_ALIGNMENT,
                 str.PADDING,
                 elm.NAME
          FROM   xnp_msg_structures str,
                 xnp_msg_elements  elm
          WHERE  str.msg_code = p_old_msg_code
          AND    str.parent_element_id = p_element_id
          AND    str.child_element_id = elm.msg_element_id;

    BEGIN
      p_return_code:=0;
      for c_old_child_rec in c_old_child
          LOOP


if c_old_child_rec.NAME = COPY_MESG_STR.p_old_msg_code then
             l_new_child_element_id := get_new_child_element_id(p_new_msg_code=>COPY_MESG_STR.p_new_msg_code,
                                                                p_child_element_name => COPY_MESG_STR.p_new_msg_code);
            else
             l_new_child_element_id := get_new_child_element_id(p_new_msg_code=>COPY_MESG_STR.p_new_msg_code,
                                                                p_child_element_name => c_old_child_rec.name);
            end if ;

             l_new_parent_element_id := get_new_parent_element_id(p_new_msg_code => COPY_MESG_STR.p_new_msg_code,
                                                                  p_element_name => COPY_MESG_STR.p_element_name);

              CREATE_MSG_STR(P_PARENT_ELEMENT_ID      => l_new_parent_element_id ,
                             P_CHILD_ELEMENT_ID       => l_new_child_element_id ,
                             P_MSG_CODE               => p_new_msg_code ,
                             P_SEQUENCE_IN_PARENT     => c_old_child_rec.SEQUENCE_IN_PARENT ,
                             P_CARDINALITY            => c_old_child_rec.CARDINALITY ,
                             P_DATA_SOURCE            => c_old_child_rec.DATA_SOURCE ,
                             P_DATA_SOURCE_TYPE       => c_old_child_rec.DATA_SOURCE_TYPE ,
                             P_DATA_SOURCE_REFERENCE  => c_old_child_rec.DATA_SOURCE_REFERENCE ,
                             P_ELEMENT_POSITION       => c_old_child_rec.ELEMENT_POSITION ,
                             P_ELEMENT_ALIGNMENT      => c_old_child_rec.ELEMENT_ALIGNMENT ,
                             P_PADDING                => c_old_child_rec.PADDING,
                             P_RETURN_CODE            =>l_return_code,
                             P_ERROR_DESCRIPTION      =>l_error_description );


            COPY_MESG_STR(p_old_msg_code => p_old_msg_code ,
                          p_new_msg_code => p_new_msg_code,
                          p_element_name  => c_old_child_rec.name,
                          p_element_id    => c_old_child_rec.child_element_id,
                          p_return_code   => l_return_code,
                          p_error_description =>l_error_description);

         END LOOP;
EXCEPTION
   WHEN OTHERS THEN
    p_return_code:=SQLCODE;
    p_error_description:=SQLERRM;
END COPY_MESG_STR ;


/********  PROCEDURE CREATE_MSG_STR    **************/


PROCEDURE CREATE_MSG_STR(P_PARENT_ELEMENT_ID      IN NUMBER,
                             P_CHILD_ELEMENT_ID       IN NUMBER,
                             P_MSG_CODE               IN VARCHAR2,
                             P_SEQUENCE_IN_PARENT     IN NUMBER ,
                             P_CARDINALITY            IN VARCHAR2,
                             P_DATA_SOURCE            IN VARCHAR2,
                             P_DATA_SOURCE_TYPE       IN VARCHAR2,
                             P_DATA_SOURCE_REFERENCE  IN VARCHAR2,
                             P_ELEMENT_POSITION       IN NUMBER,
                             P_ELEMENT_ALIGNMENT      IN VARCHAR2,
                             P_PADDING                IN VARCHAR2,
                             P_RETURN_CODE            OUT NOCOPY NUMBER,
                             P_ERROR_DESCRIPTION      OUT NOCOPY VARCHAR2)
    IS

     BEGIN

        p_return_code:=0;
        INSERT INTO XNP_MSG_STRUCTURES
               (STRUCTURE_ID              ,
                PARENT_ELEMENT_ID         ,
                CHILD_ELEMENT_ID          ,
                MSG_CODE                  ,
                SEQUENCE_IN_PARENT        ,
                CARDINALITY               ,
                DATA_SOURCE               ,
                DATA_SOURCE_TYPE          ,
                DATA_SOURCE_REFERENCE     ,
                ELEMENT_POSITION          ,
                ELEMENT_ALIGNMENT         ,
                PADDING                   ,
                CREATED_BY                ,
                CREATION_DATE             ,
                LAST_UPDATED_BY           ,
                LAST_UPDATE_DATE          ,
                LAST_UPDATE_LOGIN    )
         VALUES( XNP_MSG_STRUCTURES_S.NEXTVAL,
                 P_PARENT_ELEMENT_ID      ,
                 P_CHILD_ELEMENT_ID       ,
                 P_MSG_CODE               ,
                 P_SEQUENCE_IN_PARENT     ,
                 P_CARDINALITY            ,
                 P_DATA_SOURCE            ,
                 P_DATA_SOURCE_TYPE       ,
                 P_DATA_SOURCE_REFERENCE  ,
                 P_ELEMENT_POSITION       ,
                 P_ELEMENT_ALIGNMENT      ,
                 P_PADDING                ,
                 FND_GLOBAL.USER_ID       ,
                 SYSDATE                  ,
                 FND_GLOBAL.USER_ID       ,
                 SYSDATE                  ,
                 FND_GLOBAL.LOGIN_ID      );


           EXCEPTION
         WHEN OTHERS THEN
         p_return_code:=SQLCODE;
         p_error_description:=SQLERRM;

     END CREATE_MSG_STR;

------------------------------------------------------------------------------

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-----  Procedure:    CR_DFLT_PROCESS_BODY()
-----  Purpose:      generates code for procedure DEFAULT_PROCESS()
----------------------------------------------------------------------------
----------------------------------------------------------------------------

PROCEDURE cr_dflt_process_body(
	x_dflt_process OUT NOCOPY VARCHAR2
)
IS
	l_default_sig   VARCHAR2(16000) ;

BEGIN

	cr_dflt_process_sig ( l_default_sig ) ;

	l_default_sig := l_default_sig || ' IS' || g_new_line  ;
	x_dflt_process := 'BEGIN' || g_new_line || g_new_line ;
	x_dflt_process := x_dflt_process || 'NULL ;' || g_new_line
			|| g_new_line ;
	x_dflt_process := x_dflt_process || g_dflt_process_logic
	|| g_new_line || g_new_line ;
	x_dflt_process := x_dflt_process || 'END ;'  ;
	x_dflt_process := l_default_sig || x_dflt_process ;

END cr_dflt_process_body;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-----  Procedure:    CR_PROCESS_BODY()
-----  Purpose:      generates code for procedure PROCESS()
----------------------------------------------------------------------------
----------------------------------------------------------------------------

PROCEDURE cr_process_body(
	x_process_body OUT NOCOPY VARCHAR2
)
IS
	l_process_sig   VARCHAR2(16000) ;

BEGIN

	cr_process_signature ( l_process_sig ) ;

	l_process_sig := l_process_sig || ' IS' || g_new_line  ;
	x_process_body := 'BEGIN' || g_new_line || g_new_line ;
	x_process_body := x_process_body || 'NULL ;' || g_new_line
				|| g_new_line ;
	x_process_body := x_process_body || g_process_logic
	|| g_new_line || g_new_line ;
	x_process_body := x_process_body || 'END ;'||g_new_line  ;
	x_process_body := l_process_sig || x_process_body ;

END cr_process_body;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-----  Procedure:    CR_VALIDATE_BODY()
-----  Purpose:      generates code for procedure VALIDATE()
---------------------------------------------------------------------------
---------------------------------------------------------------------------

PROCEDURE cr_validate_body(
	x_validate_body OUT NOCOPY VARCHAR2
)
IS

	l_validate_sig             VARCHAR2(16000) ;

BEGIN

	cr_validate_signature ( l_validate_sig ) ;

	l_validate_sig := l_validate_sig || ' IS' || g_new_line  ;
	x_validate_body := 'BEGIN' || g_new_line || g_new_line ;
	x_validate_body := x_validate_body || 'NULL ;' || g_new_line
			|| g_new_line ;
	x_validate_body := x_validate_body || g_validate_logic
		|| g_new_line || g_new_line ;
	x_validate_body := x_validate_body || 'END ;'||g_new_line  ;
	x_validate_body := l_validate_sig || x_validate_body ;

END cr_validate_body;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-----  Procedure:    CR_PROCESS_SIGNATURE()
-----  Purpose:      Creates the signature for procedure PROCESS().
----------------------------------------------------------------------------
----------------------------------------------------------------------------

PROCEDURE cr_process_signature(
	x_process_sig OUT NOCOPY VARCHAR2
)
IS
BEGIN

	x_process_sig := x_process_sig || 'PROCEDURE PROCESS (  '
		|| '  p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,'
		|| g_new_line
		|| '  p_msg_text IN VARCHAR2,' || g_new_line
		|| '  x_error_code OUT  NUMBER,' || g_new_line
		|| '  x_error_message  OUT VARCHAR2,'  || g_new_line
		|| '  p_process_reference IN VARCHAR2 DEFAULT NULL )' ;

END cr_process_signature;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-----  Procedure:    CR_DFLT_PROCESS_SIG()
-----  Purpose:      Creates the signature for procedure DEFAULT_PROCESS().
----------------------------------------------------------------------------
----------------------------------------------------------------------------

PROCEDURE cr_dflt_process_sig(
	x_dflt_process_sig OUT NOCOPY VARCHAR2
)
IS
BEGIN

	x_dflt_process_sig := x_dflt_process_sig
		|| 'PROCEDURE DEFAULT_PROCESS (  '
		|| '  p_msg_header IN XNP_MESSAGE.MSG_HEADER_REC_TYPE,'
		|| g_new_line
		|| '  p_msg_text IN VARCHAR2,' || g_new_line
		|| '  x_error_code OUT  NUMBER,' || g_new_line
		|| '  x_error_message  OUT VARCHAR2 ) ' ;

END cr_dflt_process_sig;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-----  Procedure:    CR_VALIDATE_SIGNATURE()
-----  Purpose:      Creates the signature for procedure VALIDATE().
----------------------------------------------------------------------------
----------------------------------------------------------------------------

PROCEDURE cr_validate_signature(
	x_validate_sig OUT NOCOPY VARCHAR2
)
IS
BEGIN

	x_validate_sig := x_validate_sig || 'PROCEDURE VALIDATE (  '
		|| '  p_msg_header IN OUT XNP_MESSAGE.MSG_HEADER_REC_TYPE,'
		|| g_new_line
		|| '  p_msg_text IN VARCHAR2,' || g_new_line
		|| '  x_error_code OUT  NUMBER,' || g_new_line
		|| '  x_error_message  OUT VARCHAR2 ) ' ;

END cr_validate_signature;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-----  Procedure:    COMPILE()
-----  Purpose:      Public interface for building a message.
----------------------------------------------------------------------------
----------------------------------------------------------------------------

PROCEDURE compile(
	p_msg_code IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,x_package_spec  OUT NOCOPY VARCHAR2
	,x_package_body  OUT NOCOPY VARCHAR2
	,x_synonym       OUT NOCOPY VARCHAR2
)
IS

	l_sysdate            DATE ;
        l_flag               VARCHAR2(1);

	CURSOR update_msg_type IS
		SELECT 'X' FROM xnp_msg_types_b
		WHERE msg_code = p_msg_code
		FOR UPDATE OF status , last_compiled_date;

BEGIN

    x_error_code := 0 ;
    x_error_message := NULL ;

    /** VBhatia -- 05/02/2002 **/
    SELECT protected_flag
      INTO l_flag
    FROM xnp_msg_types_b
    WHERE msg_code = p_msg_code;

    IF l_flag <> 'Y' THEN   /** -- end -- **/

	xnp_msg_schema.validate(p_msg_code => p_msg_code,
		x_error_code => x_error_code,
		x_error_message => x_error_message ) ;

	IF (x_error_code <> 0) THEN
		RETURN;
	END IF;

	g_message_code := p_msg_code ;

	OPEN get_msg_type_data ;

	FETCH get_msg_type_data INTO
		g_event_indr,
		g_msg_priority,
		g_process_logic,
		g_out_process_logic,
		g_dflt_process_logic,
		g_validate_logic,
		g_queue_name,
		g_dtd_url ;

	CLOSE get_msg_type_data ;

	bld_msgevt(
		x_error_code
		,x_error_message
		,x_package_spec
		,x_package_body
		,x_synonym ) ;

	l_sysdate := SYSDATE ;

    END IF;

    IF ( x_error_code = 0 ) THEN
        FOR cur_rec IN update_msg_type LOOP

            UPDATE xnp_msg_types_b
	    SET status='COMPILED',
            last_compiled_date = l_sysdate
	    WHERE CURRENT OF update_msg_type ;

	END LOOP ;
    END IF ;


EXCEPTION
	WHEN OTHERS THEN
		IF ( get_msg_type_data%ISOPEN ) THEN
			CLOSE get_msg_type_data ;
		END IF ;
		IF ( update_msg_type%ISOPEN ) THEN
			CLOSE update_msg_type ;
		END IF ;
			x_error_code := SQLCODE;
			x_error_message := SQLERRM;

END compile;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-----  Procedure:    COMPILE_SPEC()
-----  Purpose:      Compiles the package specification.
---------------------------------------------------------------------------
---------------------------------------------------------------------------

PROCEDURE compile_spec(
	p_pkg_name IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS

BEGIN

	x_error_code := 0 ;
	x_error_message := NULL ;

        xdp_utilities.create_pkg( p_pkg_name                => p_pkg_name
                                 ,p_pkg_type               => 'PACKAGE'
		                 ,p_application_short_name => 'XNP'
		                 ,x_error_code             => x_error_code
		                 ,x_error_message          => x_error_message) ;

END compile_spec;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-----  Procedure:    COMPILE_BODY()
-----  Purpose:      Compiles the package body.
---------------------------------------------------------------------------
---------------------------------------------------------------------------

PROCEDURE compile_body(
	p_pkg_name IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
)
IS

BEGIN

	x_error_code := 0 ;
	x_error_message := NULL ;

        xdp_utilities.create_pkg(
                 p_pkg_name               => p_pkg_name
                ,p_pkg_type               => 'PACKAGE BODY'
                ,p_application_short_name => 'XNP'
                ,x_error_code             => x_error_code
                ,x_error_message          => x_error_message) ;

END compile_body;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-----  Procedure:    CR_PKG_BODY()
-----  Purpose:      Creates the package body.
---------------------------------------------------------------------------
---------------------------------------------------------------------------

PROCEDURE cr_pkg_body(
	 x_error_code    OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,x_package_body  OUT NOCOPY VARCHAR2
)
IS

	l_pkg_name            VARCHAR2(64) ;
	l_package_body        VARCHAR2(32767) ;
	l_create_body         VARCHAR2(32767) ;
	l_publish_body        VARCHAR2(32767) ;
	l_send_body           VARCHAR2(32767) ;
	l_process_body        VARCHAR2(32767) ;
	l_dflt_process_body   VARCHAR2(32767) ;
	l_validate_body       VARCHAR2(32767) ;
	l_header_body         VARCHAR2(32767) ;
	l_start_body          VARCHAR2(32767) ;
        l_pkg_body            VARCHAR2(32767) ;
        l_body_len            NUMBER := 0 ;
        l_msg_len             NUMBER := 0 ;
        l_pkg_msg             VARCHAR2(2000) := NULL;
BEGIN

	x_error_code := 0 ;
	x_error_message := NULL ;
	x_package_body  := NULL ;

        xdp_utilities.initialize_pkg;

--  The following statement has been commented out, replaced with the one follows
--	l_pkg_name := g_pkg_prefix || g_message_code || g_pkg_suffix;
--  By Anping Wang, bug refer. 1650015
--  02/19/2001

	l_pkg_name := XNP_MESSAGE.g_pkg_prefix || g_message_code || XNP_MESSAGE.g_pkg_suffix;

        xdp_utilities.build_pkg('CREATE OR REPLACE PACKAGE BODY ' || l_pkg_name || ' AS '
                           || g_new_line || g_new_line ) ;

	x_package_body := x_package_body
	|| '/**************************************************************'
	|| g_new_line
	|| '  Copyright (c)1999 Oracle Corporation, Redwood Shores, CA, USA'
	|| g_new_line || '  All Rights Reserved' || g_new_line
	|| '  PACKAGE:  ' || l_pkg_name || g_new_line
	|| '  CREATED:  ' || TO_CHAR( sysdate, 'DD-MON-YYYY' ) || g_new_line
	|| '  BY:       ' || 'Oracle Service Fulfillment Manager iMessage Studio' || g_new_line
	|| '****************************************************************/'
	|| g_new_line || g_new_line ;

	cr_create_body( l_create_body ) ;

	IF (g_event_indr <> 'TIMER') THEN
		cr_publish_body( l_publish_body ) ;
                xdp_utilities.build_pkg(l_publish_body||g_new_line  || g_new_line);
		cr_send_body( l_send_body ) ;
                xdp_utilities.build_pkg(l_send_body||g_new_line  || g_new_line);
	END IF;

	cr_process_body( l_process_body ) ;
        xdp_utilities.build_pkg(l_process_body||g_new_line  || g_new_line);

	cr_dflt_process_body( l_dflt_process_body ) ;
        xdp_utilities.build_pkg(l_dflt_process_body||g_new_line  || g_new_line);

	cr_validate_body( l_validate_body ) ;
        xdp_utilities.build_pkg(l_validate_body||g_new_line  || g_new_line);

	IF (g_event_indr = 'TIMER') THEN
		cr_start_body (l_start_body) ;
                xdp_utilities.build_pkg(l_start_body||g_new_line  );
	END IF ;

        xdp_utilities.build_pkg(' '||g_new_line || ' END ' ||l_pkg_name  ||';');

        FOR i IN 1..xdp_utilities.g_message_list.COUNT
            LOOP
               l_body_len := LENGTH(x_package_body);
               l_msg_len  := LENGTH(xdp_utilities.g_message_list(i));

               IF ( l_body_len + l_msg_len ) < 31800 THEN
                  x_package_body := x_package_body||g_new_line||xdp_utilities.g_message_list(i) ;
               ELSE
                  x_package_body := x_package_body||g_new_line||substr(xdp_utilities.g_message_list(i),1,(31800 - l_body_len)) ;
                  fnd_message.set_name('XNP','XNP_INCOMPLETE_PKG_DEFINITION');
                  fnd_message.set_token('MSG_CODE',g_message_code);
                  l_pkg_msg := fnd_message.get ;

                  EXIT;
               END IF ;
            END LOOP ;
                  x_package_body := x_package_body ||g_new_line || g_new_line|| l_pkg_msg ;

	compile_body (l_pkg_name,
		      x_error_code,
		      x_error_message ) ;


END cr_pkg_body;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-----  Procedure:    CR_PKG_SPEC()
-----  Purpose:      Creates the package specification.
---------------------------------------------------------------------------
---------------------------------------------------------------------------

PROCEDURE cr_pkg_spec(
	x_error_code    OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,x_package_spec  OUT NOCOPY VARCHAR2
)
IS

	l_pkg_name              VARCHAR2(64) ;
	l_package_spec          VARCHAR2(32767) ;
	l_publish_sig           VARCHAR2(16000) ;
	l_send_sig              VARCHAR2(16000) ;
	l_create_sig            VARCHAR2(16000) ;
	l_validate_sig          VARCHAR2(16000) ;
	l_process_sig           VARCHAR2(16000) ;
	l_dflt_process_sig      VARCHAR2(16000) ;
	l_timer_start_sig       VARCHAR2(16000) ;
        l_pkg_spec              VARCHAR2(32767);
        l_spec_len              NUMBER;
        l_msg_len               NUMBER;
        l_pkg_msg               VARCHAR2(2000) := NULL;

BEGIN

	x_error_code := 0 ;
	x_error_message := NULL ;
	x_package_spec  := NULL ;
--
--  The following statement has been commented out, replaced with the one follows
--	l_pkg_name := g_pkg_prefix || g_message_code || g_pkg_suffix;
--  By Anping Wang, bug refer. 1650015
--  02/19/2001
--
        xdp_utilities.initialize_pkg;

	l_pkg_name := XNP_MESSAGE.g_pkg_prefix || g_message_code || XNP_MESSAGE.g_pkg_suffix ;


	x_package_spec := x_package_spec
	|| '/**************************************************************'
	|| g_new_line
	|| '  Copyright (c)1999 Oracle Corporation, Redwood Shores, CA, USA'
	|| g_new_line || '  All Rights Reserved' || g_new_line
	|| '  PACKAGE:  ' || l_pkg_name || g_new_line
	|| '  CREATED:  ' || TO_CHAR( sysdate, 'DD-MON-YYYY' ) || g_new_line
	|| '  BY:       ' || 'Oracle MessageBuilder' || g_new_line
	|| '****************************************************************/'
	|| g_new_line || g_new_line ;

        xdp_utilities.build_pkg('CREATE OR REPLACE PACKAGE ' || l_pkg_name || ' AUTHID CURRENT_USER AS '
                           || g_new_line || g_new_line ) ;

	cr_create_signature ( l_create_sig ) ;

	l_create_sig := l_create_sig || ';' || g_new_line ;

	IF (g_event_indr <> 'TIMER') THEN

		cr_publish_signature ( l_publish_sig ) ;
		l_publish_sig := l_publish_sig || ';' || g_new_line ;
		cr_send_signature ( l_send_sig ) ;
		l_send_sig := l_send_sig || ';' || g_new_line ;

	END IF;

	cr_process_signature ( l_process_sig ) ;
	l_process_sig := l_process_sig || ';' || g_new_line ;

	cr_dflt_process_sig (  l_dflt_process_sig ) ;
	l_dflt_process_sig := l_dflt_process_sig || ';' || g_new_line ;

	cr_validate_signature  (  l_validate_sig ) ;
	l_validate_sig := l_validate_sig || ';' || g_new_line ;

	IF (g_event_indr = 'TIMER') THEN
		cr_start_signature (l_timer_start_sig) ;
		l_timer_start_sig := l_timer_start_sig || ';' || g_new_line ;
	END IF;

/* Adding all  individual signatures to the tabe of records - xdp_utilities.g_message_list */

        xdp_utilities.build_pkg(l_create_sig||g_new_line ||g_new_line);
        xdp_utilities.build_pkg(l_publish_sig||g_new_line ||g_new_line);
        xdp_utilities.build_pkg(l_send_sig||g_new_line ||g_new_line);
        xdp_utilities.build_pkg(l_process_sig||g_new_line ||g_new_line);
        xdp_utilities.build_pkg(l_dflt_process_sig||g_new_line ||g_new_line);
        xdp_utilities.build_pkg(l_validate_sig||g_new_line ||g_new_line);
        xdp_utilities.build_pkg(l_timer_start_sig||g_new_line ||g_new_line);
        xdp_utilities.build_pkg(' '||g_new_line ||g_new_line|| ' END ' ||l_pkg_name  ||';'||g_new_line ||g_new_line);

        FOR j IN 1..xdp_utilities.g_message_list.COUNT
           LOOP
              l_spec_len := LENGTH(x_package_spec);
              l_msg_len  := LENGTH(xdp_utilities.g_message_list(j));

              IF (l_spec_len + l_msg_len ) < 31800 THEN
                x_package_spec := x_package_spec||g_new_line||xdp_utilities.g_message_list(j) ;
              ELSE
                x_package_spec := x_package_spec||g_new_line||substr(xdp_utilities.g_message_list(j),1,(31800 - l_spec_len));
                fnd_message.set_name('XNP','XNP_INCOMPLETE_PKG_DEFINITION');
                fnd_message.set_token('MSG_CODE',g_message_code);
                l_pkg_msg := fnd_message.get ;
                EXIT;
              END IF ;
           END LOOP ;

           x_package_spec := x_package_spec ||g_new_line || g_new_line|| l_pkg_msg ;

 	compile_spec ( l_pkg_name,
	  	       x_error_code,
		       x_error_message ) ;

END cr_pkg_spec;

---------------------------------------------------------------------------
-----  Procedure:    CR_PUBLISH_BODY()
-----  Purpose:      Creates the body for procedure PUBLISH().
---------------------------------------------------------------------------

PROCEDURE cr_publish_body(
	x_publish_body OUT NOCOPY VARCHAR2
)
IS

BEGIN

	cr_publish_signature ( x_publish_body ) ;
	x_publish_body := x_publish_body || ' IS' || g_new_line || g_new_line  ;

	x_publish_body := x_publish_body
	|| '  e_NO_DESTINATION EXCEPTION ;' || g_new_line ;

	x_publish_body := x_publish_body
	|| '  l_recipient_list VARCHAR2 (2000) ;' || g_new_line ;

	x_publish_body := x_publish_body
	|| '  l_consumer_list VARCHAR2 (4000) ;' || g_new_line ;

	x_publish_body := x_publish_body
	|| '  l_queue_name VARCHAR2 (2000) ;' || g_new_line ;

	x_publish_body := x_publish_body
	|| '  l_msg_header  XNP_MESSAGE.MSG_HEADER_REC_TYPE ;' || g_new_line ;

	x_publish_body := x_publish_body
	|| '  l_msg_text VARCHAR2(32767) ;' || g_new_line ;

	x_publish_body :=  x_publish_body
	|| 'BEGIN' || g_new_line || g_new_line ;

	x_publish_body :=  x_publish_body
	|| '  x_error_code := 0 ;' || g_new_line
	|| '  x_error_message := NULL ;' || g_new_line || g_new_line ;

	-- BUG # 1500177
	-- commented code is replaced by the new code bellow.
	-- Now the correct consumer_name is obtained if passed as null

	x_publish_body := x_publish_body || g_new_line
	|| '/* check if the consumer list is NULL */'
	|| g_new_line || g_new_line ;

	x_publish_body := x_publish_body || g_new_line
	|| '  l_consumer_list := p_consumer_list ;'
	|| g_new_line || g_new_line ;

	x_publish_body :=  x_publish_body || g_new_line
	|| '  IF (l_consumer_list IS NULL) THEN' || g_new_line
	|| '    XNP_MESSAGE.GET_SUBSCRIBER_LIST( ' || ''''
	|| g_message_code || ''', '
	|| 'l_consumer_list );' || g_new_line
	|| '  END IF;' || g_new_line || g_new_line ;


	x_publish_body := x_publish_body || g_new_line
	|| '  l_recipient_list := p_recipient_list ;'
	|| g_new_line || g_new_line ;


	x_publish_body := x_publish_body
	|| 'l_queue_name := ' || '''' || g_queue_name || '''' || ';'
	|| g_new_line ;

	x_publish_body := x_publish_body || g_new_line
	|| '/* create the XML message */' || g_new_line || g_new_line ;

	x_publish_body := x_publish_body
	|| '  ' || 'CREATE_MSG (' || g_new_line ;

	FOR current_rec IN get_parameter_data
	LOOP
		x_publish_body :=  x_publish_body || '    ' || g_np_prefix
		|| current_rec.name || '=>' || g_np_prefix || current_rec.name ;
		x_publish_body :=  x_publish_body || g_comma || g_new_line ;

	END LOOP ;

	x_publish_body :=  x_publish_body
		|| '    x_msg_header=>l_msg_header,' || g_new_line
		|| '    x_msg_text=>l_msg_text,' || g_new_line
		|| '    x_error_code=>x_error_code,' || g_new_line
		|| '    x_error_message=>x_error_message,' || g_new_line
		|| '    p_sender_name=>p_sender_name,' || g_new_line
		|| '    p_recipient_list=>l_recipient_list,' || g_new_line
		|| '    p_version=>p_version,' || g_new_line
		|| '    p_reference_id=>p_reference_id,' || g_new_line
		|| '    p_opp_reference_id=>p_opp_reference_id,' || g_new_line
		|| '    p_order_id=>p_order_id,' || g_new_line
		|| '    p_wi_instance_id=>p_wi_instance_id,' || g_new_line
		|| '    p_fa_instance_id=>p_fa_instance_id ) ;' || g_new_line
		|| g_new_line ;

	x_publish_body := x_publish_body
		|| '  x_message_id := l_msg_header.message_id ;' || g_new_line ;

	x_publish_body := x_publish_body || g_new_line||g_new_line
		|| '/* enqueue the XML message for delivery */' || g_new_line
		|| g_new_line ;


	IF (g_event_indr = 'MSG') THEN
		IF (UPPER(g_queue_name) = 'XNP_OUT_MSG_Q')
		THEN

		-- BUG # 1500177
		-- added fe_name parameter to be passed while calling push()
		-- It is passed with the value from xnp_standard.fe_value.
	    -- The package variable is populated by xnp_standard before call
	    -- to <message>.send() is made.

			x_publish_body := x_publish_body
			|| '  IF (x_error_code = 0) THEN' || g_new_line
			|| '    XNP_MESSAGE.push ( '  || g_new_line
			|| '      p_msg_header => l_msg_header, ' || g_new_line
			|| '      p_body_text => l_msg_text, ' || g_new_line
			|| '      p_queue_name => xnp_event.c_outbound_msg_q, '
			|| g_new_line
			|| '      p_recipient_list => l_consumer_list, '
			|| g_new_line
			|| '      p_fe_name => xnp_standard.fe_name, '
			|| g_new_line
-- || '      p_correlation_id => TO_CHAR(x_message_id), '
			|| '      p_correlation_id => l_msg_header.message_code, '
			|| g_new_line
			|| '      p_priority=>''' || g_msg_priority || ''','
			|| g_new_line ;
		ELSIF (UPPER(g_queue_name) = 'XNP_IN_MSG_Q') THEN
			x_publish_body := x_publish_body
			|| '  IF (x_error_code = 0) THEN' || g_new_line||g_new_line
			|| '    XNP_MESSAGE.push ( '  || g_new_line
			|| '      p_msg_header => l_msg_header, ' || g_new_line
			|| '      p_body_text => l_msg_text, ' || g_new_line
			|| '      p_queue_name => xnp_event.c_inbound_msg_q, '
			|| g_new_line
-- || '      p_correlation_id => ' || ''''
-- || 'MSG_SERVER' || '''' || ', '
			|| '      p_correlation_id => l_msg_header.message_code, '
			|| g_new_line
			|| '      p_priority=>''' || g_msg_priority || ''', '
			|| g_new_line ;
		ELSIF (UPPER(g_queue_name) = 'XNP_IN_EVT_Q') THEN
			x_publish_body := x_publish_body
			|| '  IF (x_error_code = 0) THEN' || g_new_line||g_new_line
			|| '    XNP_MESSAGE.push ( '  || g_new_line
			|| '      p_msg_header => l_msg_header, ' || g_new_line
			|| '      p_body_text => l_msg_text, ' || g_new_line
			|| '      p_queue_name => xnp_event.c_internal_evt_q, '
			|| g_new_line
-- || '      p_correlation_id => TO_CHAR(x_message_id), '
			|| '      p_correlation_id => l_msg_header.message_code, '
--			|| 'MSG_SERVER' || '''' || ', '
			|| g_new_line
			|| '      p_priority=>''' || g_msg_priority || ''', '
			|| g_new_line ;
		ELSIF (UPPER(g_queue_name) = 'XNP_IN_TMR_Q') THEN
			x_publish_body := x_publish_body
			|| '  IF (x_error_code = 0) THEN' || g_new_line||g_new_line
			|| '    XNP_MESSAGE.push ( '  || g_new_line
			|| '      p_msg_header => l_msg_header, ' || g_new_line
			|| '      p_body_text => l_msg_text, ' || g_new_line
			|| '      p_queue_name => xnp_event.c_timer_q, '
			|| g_new_line
-- || '      p_correlation_id => TO_CHAR(x_message_id), '
			|| '      p_correlation_id => l_msg_header.message_code, '
--			|| 'MSG_SERVER' || '''' || ', '
			|| g_new_line
			|| '      p_priority=>''' || g_msg_priority || ''', '
			|| g_new_line ;
                ELSE x_publish_body := x_publish_body
                        || '  IF (x_error_code = 0) THEN' || g_new_line||g_new_line
                        || '    XNP_MESSAGE.PUSH_WF( '  || g_new_line
                        || '      p_msg_header => l_msg_header, ' || g_new_line
                        || '      p_body_text => l_msg_text, ' || g_new_line
                        || '      p_queue_name => ''' || g_queue_name || ''', '
                        || g_new_line
-- || '      p_correlation_id => TO_CHAR(x_message_id), '
                        || '      p_correlation_id => l_msg_header.message_code, '
--                      || 'MSG_SERVER' || '''' || ', '
                        || g_new_line
                        || '      p_priority=>''' || g_msg_priority || ''', '
                        || g_new_line ;

		END IF ;


		IF (g_ack_reqd_flag = 'Y') THEN
			x_publish_body := x_publish_body
			|| '      p_commit_mode => XNP_MESSAGE.C_IMMEDIATE ); '
			|| g_new_line ;
		ELSE
			x_publish_body := x_publish_body
			|| '      p_commit_mode => XNP_MESSAGE.C_ON_COMMIT ); '
			|| g_new_line ;
		END IF ;

		x_publish_body := x_publish_body || g_new_line
		|| '/* out processing logic */' || g_new_line || g_new_line ;

		x_publish_body := x_publish_body || g_new_line
		|| g_out_process_logic || g_new_line
		|| '  END IF ;' || g_new_line ||g_new_line;

---- In case of EVENTS the EVENT will be published to both
---- the Internal and External event queues

	ELSE
            IF  UPPER(g_queue_name) like 'XNP%' THEN

		x_publish_body := x_publish_body
		|| '  IF (x_error_code = 0) THEN' || g_new_line||g_new_line
		|| '    XNP_MESSAGE.push ( '  || g_new_line
		|| '      p_msg_header => l_msg_header, ' || g_new_line
		|| '      p_body_text => l_msg_text, ' || g_new_line
		|| '      p_queue_name => xnp_event.c_internal_evt_q, '
		|| g_new_line
-- || '      p_correlation_id => ' || '''' || 'MSG_SERVER'
-- || '''' || ', '
		|| '      p_correlation_id => l_msg_header.message_code, '
		|| g_new_line
		|| '      p_priority=>''' || g_msg_priority || ''', '
		|| g_new_line ;

            ELSE
                x_publish_body := x_publish_body
                || '  IF (x_error_code = 0) THEN' || g_new_line||g_new_line
                || '    XNP_MESSAGE.PUSH_WF( '  || g_new_line
                || '      p_msg_header => l_msg_header, ' || g_new_line
                || '      p_body_text => l_msg_text, ' || g_new_line
                || '      p_queue_name => ''' || g_queue_name || ''', '
                || g_new_line
                || '      p_correlation_id => l_msg_header.message_code, '
                || g_new_line
                || '      p_priority=>''' || g_msg_priority || ''', '
                || g_new_line ;

            END IF;

		IF (g_ack_reqd_flag = 'Y') THEN
			x_publish_body := x_publish_body
			|| '      p_commit_mode => XNP_MESSAGE.C_IMMEDIATE ); '
			|| g_new_line ;
		ELSE
			x_publish_body := x_publish_body
			|| '      p_commit_mode => XNP_MESSAGE.C_ON_COMMIT ); '
			|| g_new_line ;
		END IF ;

		x_publish_body := x_publish_body
		|| '    IF (l_consumer_list IS NOT NULL) THEN' || g_new_line
		|| '      XNP_MESSAGE.GET_SEQUENCE(l_msg_header.message_id) ;'
		|| g_new_line ||g_new_line
                || '      l_msg_header.direction_indr := '||''''||'O'||''''||';'
		|| g_new_line ||g_new_line
		|| '      XNP_MESSAGE.push ( '  || g_new_line
		|| '        p_msg_header => l_msg_header, ' || g_new_line
		|| '        p_body_text => l_msg_text, ' || g_new_line
		|| '      p_queue_name => xnp_event.c_outbound_msg_q, '
		|| g_new_line
		|| '        p_recipient_list => l_consumer_list, ' || g_new_line
-- || '        p_correlation_id => TO_CHAR(x_message_id), '
		|| '      p_correlation_id => l_msg_header.message_code, '
		|| g_new_line
		|| '        p_priority=>''' || g_msg_priority || ''' ) ; '
		|| g_new_line
		|| '    END IF ;' || g_new_line ||g_new_line;

		x_publish_body := x_publish_body || g_new_line||g_new_line
		|| '/* out processing logic */' || g_new_line || g_new_line ;

		x_publish_body := x_publish_body || g_new_line
		|| g_out_process_logic || g_new_line
		|| '  END IF ;' || g_new_line||g_new_line ;

	END IF ;

	x_publish_body := x_publish_body
	|| 'EXCEPTION' || g_new_line||g_new_line
	|| '  WHEN e_NO_DESTINATION THEN' || g_new_line
	|| '    x_error_code := XNP_ERRORS.G_NO_DESTINATION ;' || g_new_line
	|| '  WHEN OTHERS THEN' || g_new_line
	|| '    x_error_code := SQLCODE ;' || g_new_line
	|| '    x_error_message := SQLERRM ;' || g_new_line ;

	x_publish_body := x_publish_body
	|| 'END ;'||g_new_line  ;

	EXCEPTION
		WHEN OTHERS THEN
			IF (get_parameter_data%ISOPEN) THEN
				close get_parameter_data ;
			END IF ;
			RAISE ;
END cr_publish_body;

---------------------------------------------------------------------------
-----  Procedure:    CR_PUBLISH_SIGNATURE()
-----  Purpose:      Creates the signature for procedure PUBLISH().
---------------------------------------------------------------------------

PROCEDURE cr_publish_signature(
	x_publish_sig OUT NOCOPY VARCHAR2
)
IS

	l_quote	        char ;

BEGIN

	x_publish_sig := x_publish_sig || 'PROCEDURE PUBLISH  ( ' ;

	FOR current_rec IN get_parameter_data
	LOOP
		x_publish_sig :=  x_publish_sig || '  ' || g_np_prefix
		|| current_rec.name || ' ' || current_rec.element_datatype ;

		IF (current_rec.element_datatype = 'NUMBER') THEN
			l_quote := '' ;
		ELSE
			l_quote := '''' ;
		END IF ;

		IF (current_rec.element_default_value <> 'NP_NULL') THEN
			x_publish_sig :=  x_publish_sig || ' := ' || l_quote
			|| current_rec.element_default_value || l_quote ;
		END IF ;

		IF ((current_rec.mandatory_flag = 'N')
		AND (current_rec.element_default_value = 'NP_NULL')) THEN
			x_publish_sig :=  x_publish_sig || ' DEFAULT NULL' ;
		END IF ;

		x_publish_sig :=  x_publish_sig || g_comma || g_new_line ;

	END LOOP ;

	x_publish_sig :=  x_publish_sig
	|| '  x_message_id OUT  NUMBER,' || g_new_line
	|| '  x_error_code OUT  NUMBER,' || g_new_line
	|| '  x_error_message OUT VARCHAR2,  ' || g_new_line
	|| '  p_consumer_list IN VARCHAR2 DEFAULT NULL,  ' || g_new_line
	|| '  p_sender_name IN VARCHAR2 DEFAULT NULL,  ' || g_new_line
	|| '  p_recipient_list IN VARCHAR2 DEFAULT NULL,' || g_new_line
	|| '  p_version IN NUMBER DEFAULT 1,' || g_new_line
	|| '  p_reference_id IN VARCHAR2 DEFAULT NULL,' || g_new_line
	|| '  p_opp_reference_id IN VARCHAR2 DEFAULT NULL,' || g_new_line
	|| '  p_order_id IN NUMBER DEFAULT NULL,' || g_new_line
	|| '  p_wi_instance_id  IN NUMBER DEFAULT NULL,' || g_new_line
	|| '  p_fa_instance_id  IN NUMBER  DEFAULT NULL ) ' ;

	EXCEPTION
		WHEN OTHERS THEN
		IF (get_parameter_data%ISOPEN) THEN
			close get_parameter_data ;
		END IF ;
		RAISE ;
END cr_publish_signature;

---------------------------------------------------------------------------
---------------------------------------------------------------------------
-----  Procedure:    CR_CREATE_SIGNATURE()
-----  Purpose:      Creates the signature for procedure CREATE().
---------------------------------------------------------------------------
---------------------------------------------------------------------------

PROCEDURE cr_create_signature(
	x_create_sig OUT NOCOPY VARCHAR2
)
IS

l_quote	        char ;

BEGIN

	x_create_sig := x_create_sig || 'PROCEDURE CREATE_MSG  ( ' ;

	FOR current_rec IN get_parameter_data
	LOOP
		x_create_sig :=  x_create_sig || '  ' || g_np_prefix
		|| current_rec.name || ' ' || current_rec.element_datatype ;

		IF (current_rec.element_datatype = 'NUMBER') THEN
			l_quote := '' ;
		ELSE
			l_quote := '''' ;
		END IF ;

		IF (current_rec.element_default_value <> 'NP_NULL') THEN
			x_create_sig :=  x_create_sig || ' := ' || l_quote
			|| current_rec.element_default_value || l_quote ;
		END IF ;

		IF ((current_rec.mandatory_flag = 'N')
		AND (current_rec.element_default_value = 'NP_NULL')) THEN
			x_create_sig :=  x_create_sig || ' DEFAULT NULL' ;
		END IF ;

		x_create_sig :=  x_create_sig || g_comma || g_new_line ;

	END LOOP ;

  x_create_sig :=  x_create_sig
    || '  x_msg_header OUT  XNP_MESSAGE.MSG_HEADER_REC_TYPE,' || g_new_line
    || '  x_msg_text   OUT  VARCHAR2,' || g_new_line
    || '  x_error_code OUT  NUMBER,' || g_new_line
    || '  x_error_message OUT VARCHAR2,' || g_new_line
    || '  p_sender_name IN VARCHAR2 DEFAULT NULL,' || g_new_line
    || '  p_recipient_list IN VARCHAR2 DEFAULT NULL,' || g_new_line
    || '  p_version IN NUMBER DEFAULT 1,' || g_new_line
    || '  p_reference_id IN VARCHAR2 DEFAULT NULL,' || g_new_line
    || '  p_opp_reference_id IN VARCHAR2 DEFAULT NULL,' || g_new_line
    || '  p_order_id IN NUMBER DEFAULT NULL,' || g_new_line
    || '  p_wi_instance_id  IN NUMBER DEFAULT NULL,' || g_new_line
    || '  p_fa_instance_id  IN NUMBER  DEFAULT NULL,'|| g_new_line
    || '  p_delay  IN NUMBER  DEFAULT NULL,'|| g_new_line
    || '  p_interval  IN NUMBER  DEFAULT NULL ) ' ;

  EXCEPTION
    WHEN OTHERS THEN
      IF (get_parameter_data%ISOPEN) THEN
        close get_parameter_data ;
      END IF ;
      RAISE ;
END CR_CREATE_SIGNATURE;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-----  Procedure:    CR_SEND_SIGNATURE()
-----  Purpose:      Creates the signature for procedure SEND().
----------------------------------------------------------------------------
----------------------------------------------------------------------------

PROCEDURE cr_send_signature(
	x_send_sig OUT NOCOPY VARCHAR2
)
IS

	l_quote	        char ;

BEGIN


	x_send_sig := x_send_sig || 'PROCEDURE SEND  ( ' ;

	FOR current_rec IN get_parameter_data
	LOOP
		x_send_sig :=  x_send_sig || '  ' || g_np_prefix
		|| current_rec.name || ' ' || current_rec.element_datatype ;

		IF (current_rec.element_datatype = 'NUMBER') THEN
			l_quote := '' ;
		ELSE
			l_quote := '''' ;
		END IF ;

		IF (current_rec.element_default_value <> 'NP_NULL') THEN
			x_send_sig :=  x_send_sig || ' DEFAULT ' || l_quote
			|| current_rec.element_default_value || l_quote ;
		END IF ;


		IF ((current_rec.mandatory_flag = 'N')
		AND (current_rec.element_default_value = 'NP_NULL')) THEN
			x_send_sig :=  x_send_sig || ' DEFAULT NULL' ;
		END IF ;

		x_send_sig :=  x_send_sig || g_comma || g_new_line ;

	END LOOP ;

	x_send_sig :=  x_send_sig
	|| '  x_message_id OUT  NUMBER,' || g_new_line
	|| '  x_error_code OUT  NUMBER,' || g_new_line
	|| '  x_error_message OUT VARCHAR2,  ' || g_new_line
	|| '  p_consumer_name  IN VARCHAR2,  ' || g_new_line
	|| '  p_sender_name  IN VARCHAR2 DEFAULT NULL,  ' || g_new_line
	|| '  p_recipient_name  IN VARCHAR2 DEFAULT NULL,  ' || g_new_line
	|| '  p_version  IN NUMBER DEFAULT 1,  ' || g_new_line
	|| '  p_reference_id IN VARCHAR2 DEFAULT NULL,' || g_new_line
	|| '  p_opp_reference_id IN VARCHAR2 DEFAULT NULL,' || g_new_line
	|| '  p_order_id IN NUMBER DEFAULT NULL,' || g_new_line
	|| '  p_wi_instance_id  IN NUMBER DEFAULT NULL,' || g_new_line
	|| '  p_fa_instance_id  IN NUMBER  DEFAULT NULL ) ' ;

	EXCEPTION
		WHEN OTHERS THEN
			IF (get_parameter_data%ISOPEN) THEN
				close get_parameter_data ;
		END IF ;
		RAISE ;

END cr_send_signature;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
-----  Procedure:    generate_create_body()
-----  Purpose:      Recursively generates code for procedure PUBLISH().
----------------------------------------------------------------------------
----------------------------------------------------------------------------

PROCEDURE generate_create_body(
	P_ELEMENT IN VARCHAR2
	,P_ELEMENT_TYPE IN VARCHAR2
	,P_MANDATORY_FLAG IN VARCHAR2
	,P_SOURCE_TYPE IN VARCHAR2
	,P_DATA_SOURCE IN VARCHAR2
	,P_SOURCE_REF IN VARCHAR2
	,P_CARDINALITY IN VARCHAR2
	,P_PARAMETER_FLAG IN VARCHAR2
)
IS

	l_child              XNP_MSG_ELEMENTS.name%TYPE ;
	l_datatype           XNP_MSG_ELEMENTS.element_datatype%TYPE ;
	l_mandatory_indr     XNP_MSG_ELEMENTS.mandatory_flag%TYPE ;
	l_data_source_type   XNP_MSG_STRUCTURES.data_source_type%TYPE ;
	l_data_source        XNP_MSG_STRUCTURES.data_source%TYPE ;
	l_data_source_ref    XNP_MSG_STRUCTURES.data_source_reference%TYPE ;
	l_cardinality        XNP_MSG_STRUCTURES.cardinality%TYPE ;
	l_parameter_flag     XNP_MSG_ELEMENTS.parameter_flag%TYPE ;
	l_loop_counter       NUMBER := 0 ;

	CURSOR get_children ( parent_name  IN  VARCHAR2 ) IS
		SELECT MET.name,
			MET.element_datatype,
			MET.mandatory_flag,
			MSE.data_source_type,
			MSE.data_source,
			MSE.data_source_reference,
			MSE.cardinality,
			MET.parameter_flag
		FROM xnp_msg_elements MET, xnp_msg_structures MSE
		WHERE MSE.msg_code = g_message_code
		AND MSE.child_element_id = MET.msg_element_id
		AND MSE.parent_element_id = (
			SELECT msg_element_id FROM xnp_msg_elements MET1
			WHERE MET1.name = parent_name
			AND MET1.msg_code = g_message_code )
		ORDER BY MSE.sequence_in_parent ;

BEGIN

-----
--  check the source type,if the source type is SQL declare a cursor in the
--  declaration section.  SQL source types can be defined at an intermediate
--  or leaf-level node.   A procedure source type is only defined at leaf level.
-----

	IF (p_parameter_flag <> 'Y') THEN

		IF ((g_event_indr = 'TIMER') AND
		(p_element <> g_message_code)) THEN

                      g_temp_tab(g_temp_tab.COUNT + 1 ) := '  IF (p_' || p_element || ' IS NULL) THEN' ;
                      g_temp_tab(g_temp_tab.COUNT + 1 ) := '    NULL; ' || g_new_line ;

		END IF ;

		IF ( p_source_type = 'SQL' ) THEN

		   l_loop_counter := g_loop_counter ;
		   g_loop_counter := g_loop_counter + 1 ;

		   g_mandatory_list := '' ;
		   g_mandatory_check := FALSE ;

		   g_decl_section := g_decl_section
		   || '  l_loop_index_' || TO_CHAR (l_loop_counter)
		   ||' NUMBER ;' || g_new_line ;

                   g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_loop_index_' || TO_CHAR(l_loop_counter)
                                                         || ' := 0 ;'
                                                         || g_new_line ;

                   g_temp_tab(g_temp_tab.COUNT + 1 ) := '  FOR ' || g_np_prefix || p_element || '  IN ('
                                                         || p_data_source || ')'
                                                         || g_new_line ;
                   g_temp_tab(g_temp_tab.COUNT + 1 ) := ' LOOP '||g_new_line ;

                   g_temp_tab(g_temp_tab.COUNT + 1 ) := '    l_loop_index_' || TO_CHAR(l_loop_counter)
                                                         || ' := l_loop_index_'
                                                         || TO_CHAR(l_loop_counter)|| ' + 1 ;'
                                                         || g_new_line  ;

		END IF ;

-----
--  get the children, if no children found we are at the leaf level.
--  Note that the open and fetch is only done for ORACLE to set
--  the %NOTFOUND cursor variable.
-----

	OPEN  get_children ( p_element ) ;
	FETCH get_children INTO
		l_child,
		l_datatype,
		l_mandatory_indr,
		l_data_source_type,
		l_data_source,
		l_data_source_ref,
		l_cardinality,
		l_parameter_flag ;

	IF ( get_children%NOTFOUND ) THEN
-----
--  check if the element has a procedure type source, if true generate code
--  to execute the function.
-----
-----
--  if the source type is NULL and the data source is NULL, it means that
--  the data reference is referring to a data source defined at a previous
--  level.
-----
		IF (( p_source_type IS NULL ) AND
		    ( p_data_source IS NULL )) THEN

-- check if the leaf is mandatory and generate appropriate code

			IF  ( p_mandatory_flag = 'Y' ) THEN

			    g_mandatory_check := TRUE ;
			    g_mandatory_list := g_mandatory_list || ', '
			    || p_element ;

			    IF ( p_source_ref IS NOT NULL ) THEN
                               g_temp_tab(g_temp_tab.COUNT + 1 ) := '    IF ( ' || p_source_ref
                                                                        || ' IS NULL) THEN' ;
                               g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_name(' ||'''' || 'XNP'|| ''''
                                                                        ||', ' ||'''' || 'XNP_MISSING_MANDATORY_ATTR'||''''
                                                                        ||' );' ;
                               g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_token( '||''''||'ATTRIBUTE'
                                                                        ||''''||','||''''||p_element||''''||' ) ;' ;
                               g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '      x_error_message := fnd_message.get ; ' ;
                               g_temp_tab(g_temp_tab.COUNT + 1 ) := '      RAISE e_MISSING_MANDATORY_DATA ;' ;
                               g_temp_tab(g_temp_tab.COUNT + 1 ) := '    END IF ;'
                                                                          || g_new_line ;
			    END IF ;
			END IF ;

			IF (p_source_ref IS NOT NULL) THEN

                            g_temp_tab(g_temp_tab.COUNT + 1 ) := '    XNP_XML_UTILS.write_leaf_element ( '
                                                                  || '''' || p_element || ''', '
                                                                  || p_source_ref || ' ) ;' ;
			END IF ;
		ELSE
-----
--  source type, datasource and reference could be defined at the leaf level.
--  check if it is of SQL source type and write the data element accordingly.
-----
		IF ( p_source_type =  'SQL' ) THEN

			IF  ( p_mandatory_flag = 'Y' ) THEN
				g_mandatory_check := TRUE ;
				g_mandatory_list := g_mandatory_list || ', '
				|| p_element ;

                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    IF ( ' || p_source_ref
                                                                 || ' IS NULL) THEN' ;
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_name(' ||'''' || 'XNP'|| ''''
                                                                    ||', ' ||'''' || 'XNP_MISSING_MANDATORY_ATTR'||''''
                                                                    ||' );' ;
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_token( '||''''||'ATTRIBUTE'
                                                                    ||''''||','||''''||p_element||''''||' ) ;' ;
                           g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '      x_error_message := fnd_message.get ; ' ;
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '      RAISE e_MISSING_MANDATORY_DATA ;';
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    END IF ;'
                                                                 || g_new_line ;
			END IF ;

                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '    XNP_XML_UTILS.write_leaf_element ( '
                                                                 || ''''|| p_element || ''', '
                                                                 || p_source_ref || ' ) ;' ;
-----
--  it is not a SQL type, it can be a PROCEDURE, or an ORDER or a WORK_ITEM
--  or a FA type, so declare a variable and assign a value to it accordingly.
-----
		ELSE
			IF ( p_element_type = 'VARCHAR2') THEN
				g_decl_section := g_decl_section || g_new_line
				|| '  ' || g_np_prefix || p_element || '   '
				|| p_element_type || '( 16000)' ||  ' ;'
				|| g_new_line ;
			ELSE
				g_decl_section := g_decl_section
				|| g_new_line
				|| '  ' || g_np_prefix || p_element || '   '
				|| p_element_type ||  ' ;' || g_new_line ;
			END IF ;

			IF ( p_source_type = 'PROCEDURE' ) THEN

                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix  || p_element
                                                                 || ' := '|| p_source_ref || ' ;'
                                                                 || g_new_line ;

			END IF ;

                         --  Added code for XML Function

                        IF (p_source_type = 'XMLFN') THEN

                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix  || p_element||
                                                                ' := '|| p_source_ref || ' ;'||
                                                                g_new_line ;
                        END IF ;

                         --

			IF ( p_source_type = 'ORDER' ) THEN

                            g_temp_tab(g_temp_tab.COUNT + 1 ) := '    BEGIN'|| g_new_line;

-----
--  if no data reference is specified use the element name as a tag to
--  look up, else use the reference as the tag.
-----
				IF (p_source_ref IS NULL) THEN

                                    g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix
                                                                          || p_element|| ' := '
                                                                          || 'XDP_ENGINE.get_order_param_value ( p_order_id, ';
                                    g_temp_tab(g_temp_tab.COUNT + 1 ) := '    '''|| p_element || ''' );' ;
				ELSE
                                     g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix
                                                                          || p_element || ' := '
                                                                          || 'XDP_ENGINE.get_order_param_value ( p_order_id, ';
                                     g_temp_tab(g_temp_tab.COUNT + 1 ) := '    '''|| p_source_ref || ''' );' ;
				END IF ;

                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '      EXCEPTION  WHEN NO_DATA_FOUND THEN' ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_name(' ||'''' || 'XNP'|| ''''
                                                                         ||', ' ||'''' || 'XNP_ORDER_DATA_NOT_FOUND'||''''
                                                                         ||' );' ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_token( '||''''||'PARAMETER'
                                                                         ||''''||','||''''||p_element||''''||' ) ;' ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '      x_error_message := fnd_message.get ; ' ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '    END;'|| g_new_line ;
			END IF ;

			IF ( p_source_type = 'SDP_WI' ) THEN

                             g_temp_tab(g_temp_tab.COUNT + 1 ) := '    BEGIN'|| g_new_line ;

				IF (p_source_ref IS NULL) THEN
                                    g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix || p_element|| ' := '
                                                                          || 'XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, ';
                                    g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '    '''|| p_element || ''' );' ;
				ELSE
                                    g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix || p_element|| ' := '
                                                                          || 'XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, ';
                                    g_temp_tab(g_temp_tab.COUNT + 1 ) := '    '''|| p_source_ref || ''' );';
				END IF ;

                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '      EXCEPTION WHEN NO_DATA_FOUND THEN' || g_new_line ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_name(' ||'''' || 'XNP'|| ''''
                                                                         ||', ' ||'''' || 'XNP_WI_DATA_NOT_FOUND'||''''
                                                                         ||' );' ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_token( '||''''||'PARAMETER'
                                                                         ||''''||','||''''||p_element||''''||' ) ;' ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '      x_error_message := fnd_message.get ; ' ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '    END;'|| g_new_line ;
			END IF ;

			IF ( p_source_type = 'SDP_FA' ) THEN

                            g_temp_tab(g_temp_tab.COUNT + 1 ) := '    BEGIN'|| g_new_line ;

				IF (p_source_ref IS NULL) THEN
                                   g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix || p_element|| ' := '
                                                                          || 'XDP_ENGINE.get_fa_param_value ( p_fa_instance_id, ';
                                   g_temp_tab(g_temp_tab.COUNT + 1 ) := '    '''|| p_element || ''' );' ;
				ELSE
                                     g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix || p_element|| ' := '
                                                                          || 'XDP_ENGINE.get_fa_param_value ( p_fa_instance_id, ';
                                     g_temp_tab(g_temp_tab.COUNT + 1 ) := '    '''|| p_source_ref || ''' );';
				END IF ;

                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '      EXCEPTION WHEN NO_DATA_FOUND THEN' || g_new_line ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_name(' ||'''' || 'XNP'|| ''''
                                                                         ||', ' ||'''' || 'XNP_FA_DATA_NOT_FOUND'||''''
                                                                         ||' );' ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_token( '||''''||'PARAMETER'
                                                                         ||''''||','||''''||p_element||''''||' ) ;' ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '      x_error_message := fnd_message.get ; ' ;
                                g_temp_tab(g_temp_tab.COUNT + 1 ) := '    END;'|| g_new_line ;
			END IF ;

			IF  ( p_mandatory_flag = 'Y' ) THEN
				g_mandatory_check := TRUE ;
				g_mandatory_list := g_mandatory_list || ', '
				|| p_element ;

                             g_temp_tab(g_temp_tab.COUNT + 1 ) := '    IF ( '  || g_np_prefix || p_element|| ' IS NULL) THEN' ;
                             g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_name(' ||'''' || 'XNP'|| ''''
                                                                      ||', ' ||'''' || 'XNP_MISSING_MANDATORY_ATTR'||''''
                                                                      ||' );' ;
                             g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_token( '||''''||'ATTRIBUTE'
                                                                      ||''''||','||''''||p_element||''''||' ) ;' ;
                             g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '      x_error_message := fnd_message.get ; ' ;
                             g_temp_tab(g_temp_tab.COUNT + 1 ) := '      RAISE e_MISSING_MANDATORY_DATA ;';
                             g_temp_tab(g_temp_tab.COUNT + 1 ) := '    END IF ;' || g_new_line ;
			END IF ;

                         --  Modified code for XML Function

                        IF p_source_type ='XMLFN' THEN
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    XNP_XML_UTILS.write_element (' || ''''
                                                                 ||  p_element|| ''', ' || g_np_prefix
                                                                 ||  p_element|| ' ) ;';
                        ELSE
                            g_temp_tab(g_temp_tab.COUNT + 1 ) := '    XNP_XML_UTILS.write_leaf_element ( ' || ''''
                                                                  ||  p_element|| ''', ' || g_np_prefix
                                                                  ||  p_element|| ' ) ;';
                        END IF ;
		END IF ;
	END IF ;

	ELSE

-- children found, close the cursor, reopen and start recursion

		CLOSE get_children ;

                IF  ((p_element <> g_message_code) AND ( p_element_type <> 'DUMMY' ))  THEN
                    g_temp_tab(g_temp_tab.COUNT + 1 ) := '    XNP_XML_UTILS.begin_segment ( ' || ''''||  p_element
                                                         || '''' || ' ) ;' ;
                END IF ;

		IF ((p_source_ref IS NOT NULL) AND (p_source_type IS NULL)) THEN
                   g_temp_tab(g_temp_tab.COUNT + 1 ) := 'xnp_xml_utils.append('||p_source_ref || ');';
		END IF ;

		IF ((p_source_ref IS NOT NULL) AND (p_source_type = 'ORDER')) THEN

                    g_temp_tab(g_temp_tab.COUNT + 1 ) := '    BEGIN'|| g_new_line ;

			IF (p_source_ref IS NULL) THEN

                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix  || p_element || ' := '
                                                                 || 'XDP_ENGINE.get_order_param_value ( p_order_id, ';
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    '''|| p_element || ''' );' ;
			ELSE
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix || p_element || ' := '
                                                                 || 'XDP_ENGINE.get_order_param_value ( p_order_id, '
                                                                 || g_new_line ;
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    '''|| p_source_ref || ''' );' ;
			END IF ;

                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '      EXCEPTION  WHEN NO_DATA_FOUND THEN' || g_new_line ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_name(' ||'''' || 'XNP'|| ''''
                                                                 ||', ' ||'''' || 'XNP_ORDER_DATA_NOT_FOUND'||''''
                                                                 ||' );' ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_token( '||''''||'PARAMETER'
                                                                 ||''''||','||''''||p_element||''''||' ) ;' ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '      x_error_message := fnd_message.get ; ' ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '    END;'|| g_new_line ;
		END IF ;

		IF ((p_source_ref IS NOT NULL) AND
		(p_source_type = 'SDP_WI')) THEN

                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '    BEGIN'|| g_new_line ;

			IF (p_source_ref IS NULL) THEN
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix || p_element || ' := '
                                                                 || 'XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, ';
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    '''|| p_element || ''' );' ;
			ELSE

                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix || p_element || ' := '
                                                                 || 'XDP_ENGINE.get_workitem_param_value ( p_wi_instance_id, ';
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    '''|| p_source_ref || ''' );' ;
			END IF ;

                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '      EXCEPTION  WHEN NO_DATA_FOUND THEN' || g_new_line ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_name(' ||'''' || 'XNP'|| ''''
                                                                 ||', ' ||'''' || 'XNP_WI_DATA_NOT_FOUND'||''''
                                                                 ||' );' ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_token( '||''''||'PARAMETER'
                                                                 ||''''||','||''''||p_element||''''||' ) ;' ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '      x_error_message := fnd_message.get ; ' ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '    END;'|| g_new_line ;
		END IF ;

		IF ((p_source_ref IS NOT NULL) AND (p_source_type = 'SDP_FA')) THEN

                        g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '    BEGIN' || g_new_line ;

			IF (p_source_ref IS NULL) THEN
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix || p_element || ' := ';
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := 'XDP_ENGINE.get_fa_param_value ( p_fa_instance_id, ';
                           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    '''|| p_element || ''' );' ;
			ELSE
                            g_temp_tab(g_temp_tab.COUNT + 1 ) := '    ' || g_np_prefix || p_element || ' := ';
                            g_temp_tab(g_temp_tab.COUNT + 1 ) := 'XDP_ENGINE.get_fa_param_value ( p_fa_instance_id, '
                                                                 || '    ''' || p_source_ref || ''' );' ;
			END IF;

                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '      EXCEPTION   WHEN NO_DATA_FOUND THEN' || g_new_line ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_name(' ||'''' || 'XNP'|| ''''
                                                                 ||', ' ||'''' || 'XNP_FA_DATA_NOT_FOUND'||''''
                                                                 ||' );' ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_token( '||''''||'PARAMETER'
                                                                 ||''''||','||''''||p_element||''''||' ) ;' ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '      x_error_message := fnd_message.get ; ' ;
                        g_temp_tab(g_temp_tab.COUNT + 1 ) := '    END;' || g_new_line ;
		END IF ;

		IF ((p_source_ref IS NOT NULL) AND
			((p_source_type = 'ORDER') OR
			(p_source_type = 'SDP_WI') OR
			(p_source_type = 'SDP_FA'))) THEN

			g_decl_section := g_decl_section || g_new_line
			|| '  ' || g_np_prefix || p_element || '   '
			|| p_element_type || '( 16000)' ||  ' ;' || g_new_line ;

			IF (p_mandatory_flag = 'Y') THEN
				g_mandatory_check := TRUE ;
				g_mandatory_list := g_mandatory_list
				|| 'Missing Mandatory Attribute - '
				|| p_element || ''' ;' || g_new_line
				|| '      RAISE e_MISSING_MANDATORY_DATA ;'
				|| g_new_line
				|| '    END IF ;' || g_new_line ;
			END IF;

                         g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '    XNP_XML_UTILS.write_leaf_element ( ' || ''''
                                                                ||  p_element|| ''', ' || g_np_prefix
                                                                || p_element || ' ) ;';
		END IF ;

		FOR my_child IN get_children ( p_element ) LOOP

			generate_create_body (my_child.name,
			my_child.element_datatype,
			my_child.mandatory_flag,
			my_child.data_source_type,
			my_child.data_source,
			my_child.data_source_reference,
			my_child.cardinality,
			my_child.parameter_flag ) ;

		END LOOP ;

                IF  ((p_element <> g_message_code) AND (p_element_type <> 'DUMMY'))   THEN
                    g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '  XNP_XML_UTILS.end_segment ( ' || ''''||  p_element || '''' || ' ) ;';
                END IF ;

	END IF ;

	IF ( p_source_type = 'SQL' ) THEN

		IF ( p_cardinality = 'ONE_ONLY' ) THEN
                    g_temp_tab(g_temp_tab.COUNT + 1 ) :=   '    EXIT ;' || g_new_line ;
		END IF ;

                g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '  END LOOP ;' || g_new_line ;

		IF (g_mandatory_check = TRUE) THEN
                   g_temp_tab(g_temp_tab.COUNT + 1 ) := '  IF ( l_loop_index_' || TO_CHAR(l_loop_counter)|| ' = 0 ) THEN' ;
                   g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_name(' ||'''' || 'XNP'|| ''''
                                                            ||', ' ||'''' || 'XNP_MISSING_MANDATORY_DATA'||''''
                                                            ||' );' ;
                   g_temp_tab(g_temp_tab.COUNT + 1 ) := '       fnd_message.set_token( '||''''||'ELEMENT'
                                                            ||''''||','||''''||g_mandatory_list||''''||' ) ;' ;
                   g_temp_tab(g_temp_tab.COUNT + 1 ) :=  '      x_error_message := fnd_message.get ; ' ;
                   g_temp_tab(g_temp_tab.COUNT + 1 ) := '    RAISE e_MISSING_MANDATORY_DATA ;' ;
                   g_temp_tab(g_temp_tab.COUNT + 1 ) := '  END IF ;' || g_new_line ;
		END IF ;
	END IF ;

	IF ((g_event_indr = 'TIMER') AND
		(p_element <> g_message_code)) THEN

           g_temp_tab(g_temp_tab.COUNT + 1 ) :=  'ELSE' ;
           g_temp_tab(g_temp_tab.COUNT + 1 ) :='  xnp_xml_utils.write_element(' || '''' || p_element|| ''','
                                                 ||' p_' || p_element || ');' ;
           g_temp_tab(g_temp_tab.COUNT + 1 ) :=  'END IF;' || g_new_line ;
	END IF;

-- Not a Parameter, so no recursive call

	ELSE
		IF  ( p_mandatory_flag = 'Y' ) THEN
		     g_mandatory_check := TRUE ;
		     g_mandatory_list := g_mandatory_list || ', '
		     || p_element ;

                     g_temp_tab(g_temp_tab.COUNT + 1 ) := '    IF ( '  || g_np_prefix || p_element|| ' IS NULL) THEN' ;
                     g_temp_tab(g_temp_tab.COUNT + 1 ) := '      x_error_message :=' || ''''|| 'Missing Mandatory Attribute - '
                                                                || p_element || ''' ;' ;
                     g_temp_tab(g_temp_tab.COUNT + 1 ) := '     fnd_message.set_name(' ||''''||'XNP'||''''||','
                                                                ||''''||'XNP_MISSING_MANDATORY_ATTR'||''''||');' ;
                     g_temp_tab(g_temp_tab.COUNT + 1 ) := '     fnd_message.set_token(' ||''''||'ATTRIBUTE'||''''||','
                                                                ||''''||p_element||''''||' ) ;';
                     g_temp_tab(g_temp_tab.COUNT + 1 ) := '     x_error_message := fnd_message.get ; ' ;
                     g_temp_tab(g_temp_tab.COUNT + 1 ) := '      RAISE e_MISSING_MANDATORY_DATA ;' ;
                     g_temp_tab(g_temp_tab.COUNT + 1 ) := '    END IF ;' || g_new_line ;
		END IF ;
                g_temp_tab(g_temp_tab.COUNT + 1 ) := '    XNP_XML_UTILS.write_leaf_element ( ' || '''' ||  p_element || ''', '
                                                                                               || g_np_prefix || p_element || ' ) ;' ;
	END IF ;

-- End parameter check

	IF ( get_children%ISOPEN ) THEN
		CLOSE get_children ;
	END IF ;

	EXCEPTION
		WHEN OTHERS THEN

			IF (get_children%ISOPEN) THEN
				close get_children ;
			END IF ;
			RAISE ;

END generate_create_body;


----------------------------------------------------------------------------
----------------------------------------------------------------------------
-----  Procedure:    BLD_MSGEVT()
-----  Purpose:      Starts the package construction.
----------------------------------------------------------------------------
----------------------------------------------------------------------------

PROCEDURE BLD_MSGEVT(
	x_error_code    OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	,x_package_spec  OUT NOCOPY VARCHAR2
	,x_package_body  OUT NOCOPY VARCHAR2
	,x_synonym       OUT NOCOPY VARCHAR2
)
IS

	l_quote	        CHAR ;
	l_cursor        NUMBER ;
	l_sql_text      VARCHAR2(512) ;
	l_ret		BOOLEAN ;
	l_schema	VARCHAR2(1024) ;
	l_industry	VARCHAR2(1024) ;
	l_status	VARCHAR2(1024) ;

BEGIN

	x_error_code    := 0 ;
	x_error_message := NULL ;
	x_package_spec  := NULL ;
	x_package_body  := NULL ;
	x_synonym       := NULL ;

	cr_pkg_spec ( x_error_code,
		      x_error_message,
		      x_package_spec ) ;

	IF (( x_error_code = 0 ) AND
		( x_error_message IS NULL )) THEN

		cr_pkg_body ( x_error_code,
			      x_error_message,
			      x_package_body ) ;

		l_ret := FND_INSTALLATION.GET_APP_INFO(
				application_short_name=>'FND'
				,status=>l_status
				,industry=>l_industry
				,oracle_schema=>l_schema
			);

		IF (( x_error_code = 0 ) AND
			( x_error_message IS NULL )) THEN

			BEGIN

			l_sql_text := 'DROP SYNONYM ' || g_message_code ;
			x_synonym  := l_sql_text ;

			AD_DDL.DO_DDL(
				applsys_schema=>l_schema
				,application_short_name=>'XNP'
				,statement_type=>ad_ddl.drop_synonym
				,statement=>l_sql_text
				,object_name=>g_message_code
			);

			EXCEPTION
				WHEN OTHERS THEN
				NULL;

			END;
--
-- The following statement has been commented out, replaced with the one follows
-- By Anping Wang, bug refer. 1650015
-- 02/19/2001
--			l_sql_text := 'CREATE SYNONYM ' || g_message_code
--			|| ' FOR ' || g_pkg_prefix || g_message_code
--			|| g_pkg_suffix ;
--
			l_sql_text := 'CREATE SYNONYM ' || g_message_code
			|| ' FOR ' || XNP_MESSAGE.g_pkg_prefix || g_message_code
			|| XNP_MESSAGE.g_pkg_suffix ;

			x_synonym  := l_sql_text ;

			AD_DDL.DO_DDL(
				applsys_schema=>l_schema
				,application_short_name=>'XNP'
				,statement_type=>ad_ddl.create_synonym
				,statement=>l_sql_text
				,object_name=>g_message_code
			);

		END IF ;

	END IF ;

	EXCEPTION
		WHEN OTHERS THEN

			x_error_code := SQLCODE ;
			x_error_message := SQLERRM ;

END bld_msgevt;

----------------------------------------------------------------------------
-----  Procedure:    CR_SEND_BODY()
-----  Purpose:      Creates the body for procedure SEND().
----------------------------------------------------------------------------

PROCEDURE cr_send_body(
	X_SEND_BODY OUT NOCOPY VARCHAR2
)
IS
	l_send_sig  VARCHAR2(16000) ;

BEGIN

	cr_send_signature ( l_send_sig ) ;

	x_send_body := l_send_sig || ' IS' || g_new_line || g_new_line  ;

	x_send_body := x_send_body
	|| 'l_recipient_name  VARCHAR2(80);' || g_new_line ;

	IF (UPPER(g_queue_name) = 'XNP_OUT_MSG_Q') THEN

		x_send_body := x_send_body
		|| 'l_ack_header      XNP_MESSAGE.MSG_HEADER_REC_TYPE ;'
		|| g_new_line
		|| 'l_ack_code        VARCHAR2(40);' || g_new_line
		|| 'l_error_code      NUMBER ;'
		|| 'l_error_message   VARCHAR2(512);' || g_new_line
		|| 'l_ack_msg         VARCHAR2(32767) ;' || g_new_line ;

	END IF ;

	x_send_body := x_send_body || g_new_line
	|| 'BEGIN' || g_new_line || g_new_line ;

	x_send_body :=  x_send_body
	|| '  x_error_code := 0;' || g_new_line
	|| '  x_error_message := NULL ;' || g_new_line || g_new_line ;

	x_send_body :=  x_send_body
	|| '  l_recipient_name := p_recipient_name ;' || g_new_line
	|| '  IF (l_recipient_name IS NULL) THEN' || g_new_line
	|| '    l_recipient_name := p_consumer_name ;' || g_new_line
	|| '  END IF;'  || g_new_line ;

	x_send_body :=  x_send_body
	|| '  ' || 'PUBLISH (' || g_new_line ;

	FOR current_rec IN get_parameter_data
	LOOP
		x_send_body :=  x_send_body || '    ' || g_np_prefix
		|| current_rec.name
		|| '=>' || g_np_prefix || current_rec.name ;

    		x_send_body :=  x_send_body || g_comma || g_new_line ;

	END LOOP ;

	x_send_body :=  x_send_body
		|| '    x_message_id=>x_message_id,' || g_new_line
		|| '    x_error_code=>x_error_code,' || g_new_line
		|| '    x_error_message=>x_error_message,' || g_new_line
		|| '    p_consumer_list=>p_consumer_name,' || g_new_line
		|| '    p_sender_name=>p_sender_name,' || g_new_line
		|| '    p_recipient_list=>l_recipient_name,' || g_new_line
		|| '    p_version=>p_version,' || g_new_line
		|| '    p_reference_id=>p_reference_id,' || g_new_line
		|| '    p_opp_reference_id=>p_opp_reference_id,' || g_new_line
		|| '    p_order_id=>p_order_id,' || g_new_line
		|| '    p_wi_instance_id=>p_wi_instance_id,' || g_new_line
		|| '    p_fa_instance_id=>p_fa_instance_id ) ;' || g_new_line ;

	IF (g_ack_reqd_flag = 'Y') THEN

		x_send_body := x_send_body || g_new_line
		|| '/****' || g_new_line
		|| '  Get an ACK back for the out going message,' || g_new_line
		|| '  Remove the message if the ACK is not received'
		|| g_new_line
		|| '  within the speicified time. ' || g_new_line
		|| '****/' || g_new_line || g_new_line ;

		x_send_body := x_send_body
		|| '  IF (x_error_code = 0) THEN' || g_new_line || g_new_line
		|| '    XNP_MESSAGE.POP ( '
		|| '      p_queue_name => xnp_event.c_inbound_msg_q, '
		|| g_new_line
		|| '    x_msg_header => l_ack_header,' || g_new_line
		|| '    x_body_text => l_ack_msg,' || g_new_line
		|| '    x_error_code => x_error_code,' || g_new_line
		|| '    x_error_message => x_error_message,' || g_new_line
-- || '    p_correlation_id => TO_CHAR(x_message_id) ) ;'
		|| '      p_correlation_id => l_msg_header.message_code, '
		|| g_new_line || g_new_line
		|| '    IF (x_error_code <> XNP_ERRORS.G_DEQUEUE_TIMEOUT )THEN'
		|| g_new_line
		|| '      XNP_XML_UTILS.DECODE(l_ack_msg, ' || ''''
		|| 'CODE' || ''',' || 'l_ack_code) ;'
		|| g_new_line
		|| '      XNP_XML_UTILS.DECODE(l_ack_msg, ' || ''''
		|| 'DESCRIPTION' || ''',' || 'x_error_message) ;'
		|| g_new_line
		|| '      x_error_code := TO_NUMBER(l_ack_code) ;' || g_new_line
		|| '    ELSE' || g_new_line
		|| '      XNP_MESSAGE.UPDATE_STATUS(x_message_id, '
		|| '''' || 'TIMEOUT' || ''');' || g_new_line
		|| '    END IF ;' || g_new_line || g_new_line
		|| '  END IF;' || g_new_line || g_new_line ;

	END IF ;

	x_send_body := x_send_body
		|| 'END ;' ;

	EXCEPTION
		WHEN OTHERS THEN
			IF (get_parameter_data%ISOPEN) THEN
				CLOSE get_parameter_data ;
			END IF ;
			RAISE ;

END cr_send_body ;

----------------------------------------------------------------------------
-----  Procedure:    CR_START_SIGNATURE()
-----  Purpose:      Creates the signature for procedure START().
-----                Applicable only to timers.
----------------------------------------------------------------------------

PROCEDURE cr_start_signature(
	x_start_sig OUT NOCOPY VARCHAR2
)
IS

	l_quote	        char ;

BEGIN

	x_start_sig := x_start_sig || 'PROCEDURE FIRE  ( ' ;

	x_start_sig :=  x_start_sig
	|| '  x_timer_id   OUT  NUMBER,' || g_new_line
	|| '  x_timer_contents   OUT  VARCHAR2,' || g_new_line
	|| '  x_error_code OUT  NUMBER,' || g_new_line
	|| '  x_error_message OUT VARCHAR2,' || g_new_line
	|| '  p_sender_name IN VARCHAR2 DEFAULT NULL,' || g_new_line
	|| '  p_recipient_list IN VARCHAR2 DEFAULT NULL,' || g_new_line
	|| '  p_version IN NUMBER DEFAULT 1,' || g_new_line
	|| '  p_reference_id IN VARCHAR2 DEFAULT NULL,' || g_new_line
	|| '  p_opp_reference_id IN VARCHAR2 DEFAULT NULL,' || g_new_line
	|| '  p_order_id IN NUMBER DEFAULT NULL,' || g_new_line
	|| '  p_wi_instance_id  IN NUMBER DEFAULT NULL,' || g_new_line
	|| '  p_fa_instance_id  IN NUMBER  DEFAULT NULL ) ' ;

END cr_start_signature;

----------------------------------------------------------------------------
-----  Procedure:    CR_START_BODY()
-----  Purpose:      generates code for procedure VALIDATE()
----------------------------------------------------------------------------

PROCEDURE cr_start_body(
	X_START_BODY OUT NOCOPY VARCHAR2
)
IS

	l_start_sig             VARCHAR2(16000) ;
	l_start_body            VARCHAR2(32767) ;

BEGIN

	cr_start_signature ( l_start_sig ) ;

	l_start_body := l_start_sig ||
	'
	IS

	l_msg_header xnp_message.msg_header_rec_type ;
	l_msg_text VARCHAR2(32767);
	' || g_new_line || g_new_line;

	l_start_body := l_start_body ||
	'
	BEGIN
	x_error_code := 0;
	x_error_message := NULL;

	CREATE_MSG (x_msg_header       => l_msg_header,
	            x_msg_text         => l_msg_text,
	            x_error_code       => x_error_code,
	            x_error_message    => x_error_message,
	            p_sender_name      => p_sender_name,
	            p_recipient_list   => p_recipient_list,
	            p_version          => p_version,
	            p_reference_id     => p_reference_id,
	            p_opp_reference_id => p_reference_id,
	            p_order_id         => p_order_id,
	            p_wi_instance_id   => p_wi_instance_id,
	            p_fa_instance_id   => p_fa_instance_id );

	IF (x_error_code = 0) THEN
	    xnp_timer.start_timer(l_msg_header,
	    l_msg_text,
	    x_error_code,
	    x_error_message );
	    x_timer_id := l_msg_header.message_id ;
	    x_timer_contents := l_msg_text;
	END IF;

	END ;
	' || g_new_line ;

	x_start_body := l_start_body ;

END cr_start_body;

---------------------------------------------------------------------------
-----  Procedure:    CR_CREATE_BODY()
-----  Purpose:      Creates the body for procedure CREATE().
---------------------------------------------------------------------------

PROCEDURE cr_create_body(
	x_create_body OUT NOCOPY VARCHAR2
)
IS
	l_create_sig        VARCHAR2(16000) ;

	l_child              XNP_MSG_ELEMENTS.name%TYPE ;
	l_datatype           XNP_MSG_ELEMENTS.element_datatype%TYPE ;
	l_mandatory_indr     XNP_MSG_ELEMENTS.mandatory_flag%TYPE ;
	l_data_source_type   XNP_MSG_STRUCTURES.data_source_type%TYPE ;
	l_data_source        XNP_MSG_STRUCTURES.data_source%TYPE ;
	l_data_source_ref    XNP_MSG_STRUCTURES.data_source_reference%TYPE ;
	l_cardinality        XNP_MSG_STRUCTURES.cardinality%TYPE ;
	l_parameter_flag     XNP_MSG_ELEMENTS.parameter_flag%TYPE ;
	l_fnd_message        VARCHAR2(4000) ;
        l_msg_type           VARCHAR2(10) ;

        CURSOR get_msg_type IS
               SELECT msg_type
                 FROM xnp_msg_types_b
                WHERE msg_code = g_message_code ;

	CURSOR get_children ( parent_name  IN  VARCHAR2 ) IS
		SELECT MET.name,
		       MET.element_datatype,
		       MET.mandatory_flag,
		       MSE.data_source_type,
		       MSE.data_source,
		       MSE.data_source_reference,
		       MSE.cardinality,
		       MET.parameter_flag
		  FROM xnp_msg_elements MET,
                       xnp_msg_structures MSE
		 WHERE MSE.msg_code          = g_message_code
	  	   AND MSE.child_element_id  = MET.msg_element_id
		   AND MSE.parent_element_id = ( SELECT msg_element_id
                                                   FROM xnp_msg_elements MET1
			                          WHERE MET1.name = parent_name
			                            AND MET1.msg_code = g_message_code )
		 ORDER BY MSE.sequence_in_parent ;

	e_INVALID_MSG_CODE EXCEPTION ;

BEGIN
        g_temp_tab.DELETE;
	g_create_body    := NULL ;
	g_decl_section   := NULL ;
	g_excep_section  := NULL ;
	g_mandatory_list := NULL ;

        OPEN get_msg_type ;
       FETCH get_msg_type INTO l_msg_type ;

       IF (get_msg_type%NOTFOUND ) THEN
          RAISE e_INVALID_MSG_CODE ;
       END IF ;
       CLOSE get_msg_type ;

	OPEN  get_children ( 'MESSAGE' ) ;
	FETCH get_children INTO
		l_child,
		l_datatype,
		l_mandatory_indr,
		l_data_source_type,
		l_data_source,
		l_data_source_ref,
		l_cardinality,
		l_parameter_flag ;

	IF ( get_children%NOTFOUND ) THEN
		CLOSE get_children ;
		RAISE e_INVALID_MSG_CODE ;
	END IF ;

	CLOSE get_children ;

	cr_create_signature ( l_create_sig ) ;
	l_create_sig := l_create_sig || ' IS' || g_new_line ;

	g_excep_section := g_excep_section || g_new_line
	|| '/* handle exceptions */' || g_new_line || '  EXCEPTION' || g_new_line ;

	g_decl_section := g_decl_section
	|| '  e_MISSING_MANDATORY_DATA EXCEPTION ;' || g_new_line ;
	g_decl_section := g_decl_section
	|| '  e_NO_DESTINATION EXCEPTION ;' || g_new_line ;

	g_decl_section := g_decl_section
	|| '  l_xml_body VARCHAR2(32767) ;' || g_new_line ;

	g_decl_section := g_decl_section
	|| '  l_xml_doc  VARCHAR2(32767) ;' || g_new_line ;

	g_decl_section := g_decl_section
	|| '  l_xml_header VARCHAR2(32767) ;' || g_new_line ;

	g_decl_section := g_decl_section
	|| '  l_msg_header  XNP_MESSAGE.MSG_HEADER_REC_TYPE ;' || g_new_line ;


       /* Build create body and add it to the global table of records */

        g_temp_tab(g_temp_tab.COUNT + 1 ) := 'BEGIN' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  x_error_code := 0 ;' ;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  x_error_message := NULL ;' ;

-- Header Start

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.initialize_doc ( ) ;' || g_new_line;

-- construct XML message header

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '/*construct the XML header */' || g_new_line ;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '/* retreive the next message ID */' || g_new_line ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_MESSAGE.get_sequence ( l_msg_header.message_id ) ;'
                                             || g_new_line;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  IF (p_reference_id IS NULL) THEN' ;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '    l_msg_header.reference_id := l_msg_header.message_id ;';
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  ELSE' ;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '    l_msg_header.reference_id := p_reference_id ;';
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  END IF ;' ;

-- Append parameters to header

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '/* append header parameters to make header */'
                                             || g_new_line ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.write_element ( '|| ''''
                                              || 'MESSAGE_ID' || ''','
                                              || 'l_msg_header.message_id'
                                              || ' ) ;' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.write_leaf_element ( '
                                              || '''' || 'REFERENCE_ID' || ''','
                                              || 'l_msg_header.reference_id'
                                              || ' ) ;' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.opp_reference_id := p_opp_reference_id ;';

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.write_leaf_element ( '
                                              || '''' || 'OPP_REFERENCE_ID' || ''','
                                              || 'l_msg_header.opp_reference_id ) ;' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.message_code := ' || ''''
                                              || g_message_code || ''' ;' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.write_leaf_element ( '
                                              || '''' || 'MESSAGE_CODE' || ''','
                                              || 'l_msg_header.message_code' || ' ) ;' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.version := p_version ;' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.write_leaf_element ( '
                                              || '''' || 'VERSION' || ''','
                                              || 'l_msg_header.version' || ' ) ;' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.creation_date := SYSDATE ;' ;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.recipient_name := p_recipient_list ;' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.write_element ( '
                                              || '''' || 'CREATION_DATE'
                                              || ''','|| 'l_msg_header.creation_date' || ' ) ;' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.sender_name := p_sender_name ;' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.write_leaf_element ( '
                                              || '''' || 'SENDER_NAME' || ''','
                                              || 'l_msg_header.sender_name' || ' ) ;' ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.write_leaf_element ( '
                                              || '''' || 'RECIPIENT_NAME' || ''','
                                              || 'l_msg_header.recipient_name' || ' ) ;' ;

	IF (g_event_indr = 'MSG') THEN
	    IF (UPPER(g_queue_name) = UPPER(XNP_EVENT.CC_OUTBOUND_MSG_Q)) THEN
              g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.direction_indr := '
                                                    || ''''|| 'O' || ''' ;' ;
	    ELSE
                g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.direction_indr := '
                                                      || ''''|| 'I' || ''' ;' ;
  	    END IF ;
	ELSE
           g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.direction_indr := '
                                                 || ''''|| 'E' || ''' ;' ;
	END IF ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.order_id := p_order_id ;' ;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.wi_instance_id := p_wi_instance_id ;' ;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  l_msg_header.fa_instance_id := p_fa_instance_id ;'
                                              ||g_new_line ;

	FOR current_rec IN get_parameter_data
	LOOP
           g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.write_leaf_element ( '
                                                 || '''' || current_rec.name  || ''', '
                                                 || g_np_prefix || current_rec.name
                                                 || ' );' ;

	END LOOP ;


-- End Header
-- Get Header for out parameter assignment

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '/* retreieve the XML header */' || g_new_line ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.get_document ( l_xml_header ) ;'
                                              || g_new_line ;

---- Start complete xml doc.
---- Intialize Doc. Write header and start creating body.

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '/* append the XML headerto message */'
                                             || g_new_line ;

	IF (g_dtd_url IS NOT NULL) THEN

           g_temp_tab(g_temp_tab.COUNT + 1 ) := ' XNP_XML_UTILS.initialize_doc ( '
                                                 || '''' || g_message_code || ''', '|| ''''
                                                 || g_dtd_url
                                                 || ''');' ;

	ELSE
                g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.initialize_doc ( ) ;' ;
                g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.xml_decl ;' ;

	END IF ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.begin_segment ( '
                                              || ''''|| 'MESSAGE'
                                              || ''') ;' ;

        IF l_msg_type NOT IN ('MSG_NOHEAD','EVT_NOHEAD') THEN
           g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.write_element( '
                                                 || ''''|| 'HEADER'
                                                 || ''', l_xml_header );' ;
        END IF ;

--Body Start

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '/* construct the message body */' || g_new_line ;

        IF l_datatype <> 'DUMMY' THEN
           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    XNP_XML_UTILS.begin_segment ( '
                                                 || '''' ||  l_child || '''' || ' ) ;'
                                                 || g_new_line ;
        END IF ;

	generate_create_body ( l_child,
		l_datatype,
		l_mandatory_indr,
		l_data_source_type,
		l_data_source,
		l_data_source_ref,
		l_cardinality,
		l_parameter_flag ) ;

        IF l_datatype <> 'DUMMY' THEN
           g_temp_tab(g_temp_tab.COUNT + 1 ) := '    XNP_XML_UTILS.end_segment ( '
                                                 || ''''||  l_child || ''''
                                                 || ' ) ;' ;
        END IF ;

        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.end_segment ( ' || ''''
                                              || 'MESSAGE' || ''') ;' ;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  XNP_XML_UTILS.get_document( l_xml_doc ) ;'
                                              || g_new_line ;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '/* assign the header and msg text to output parameters */'
                                             || g_new_line ;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  x_msg_header := l_msg_header ;' ;
        g_temp_tab(g_temp_tab.COUNT + 1 ) := '  x_msg_text   := l_xml_doc ;' || g_new_line ;

	g_excep_section := g_excep_section
	|| '  WHEN e_MISSING_MANDATORY_DATA THEN' || g_new_line
	|| '    x_error_code := XNP_ERRORS.G_MISSING_MANDATORY_DATA ;'
	||      g_new_line
	|| '  WHEN OTHERS THEN' || g_new_line
	|| '    x_error_code := SQLCODE ;' || g_new_line
	|| '    x_error_message := ' || '''' || g_message_code
	|| '.create_msg()::'''
	|| ' || SQLERRM ;' || g_new_line;

	g_excep_section := g_excep_section || 'END ;'||g_new_line || g_new_line  ;

       /* Add create signature , excep section , decl section to the table of records */

         xdp_utilities.build_pkg(l_create_sig||g_new_line || g_new_line);
         xdp_utilities.build_pkg(g_decl_section||g_new_line || g_new_line);

         FOR i IN 1..g_temp_tab.COUNT
             LOOP
                xdp_utilities.build_pkg(g_temp_tab(i));
             END LOOP;

         xdp_utilities.build_pkg(g_excep_section);

	EXCEPTION
		WHEN e_INVALID_MSG_CODE THEN
			IF ( get_children%ISOPEN ) THEN
				CLOSE get_children ;
			END IF ;
			FND_MESSAGE.set_name ('XNP', 'NO_MSG_STRUCTURE') ;
			l_fnd_message := FND_MESSAGE.get ;
			RAISE_APPLICATION_ERROR (
				XNP_ERRORS.G_NO_MSG_STRUCTURE, l_fnd_message) ;
		WHEN OTHERS THEN
			IF (get_parameter_data%ISOPEN) THEN
				CLOSE get_parameter_data ;
			END IF ;
			IF ( get_children%ISOPEN ) THEN
				CLOSE get_children ;
			END IF ;
		      RAISE ;

END cr_create_body;
-------------------------------
-- Package initialization code
------------------------------

BEGIN

DECLARE
	l_ack_reqd_flag VARCHAR2(2) := NULL;

	BEGIN
		FND_PROFILE.GET( NAME => 'ACK_REQD_FLAG',
			VAL => l_ack_reqd_flag ) ;
		IF (l_ack_reqd_flag IS NOT NULL) THEN
			g_ack_reqd_flag := l_ack_reqd_flag ;
		END IF ;

	END ;

END xnp_msg_builder;

/
