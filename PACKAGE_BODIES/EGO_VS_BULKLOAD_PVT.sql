--------------------------------------------------------
--  DDL for Package Body EGO_VS_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_VS_BULKLOAD_PVT" AS
/* $Header: EGOVVSBB.pls 120.0.12010000.17 2010/06/11 13:38:58 yjain noship $ */

/*==========================================================================+
|   Copyright (c) 1993 Oracle Corporation Belmont, California, USA          |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : EGOVVSBB.pls                                               |
| DESCRIPTION  : This file is a packaged procedure for importing value set  |
|                and corresponding values using interface or concurrent     |
|                program route.                                             |
+==========================================================================*/

   ---------------------------------------------------------------
   -- Global Variables and Constants --
   ---------------------------------------------------------------
   G_PKG_NAME                     CONSTANT  VARCHAR2(30)   := 'EGO_VS_BULKLOAD_PVT';
   G_APP_SHORT_NAME               CONSTANT  VARCHAR2(3)    := 'EGO';

   ---------------------------------------------------------------
   -- Transaction Type.                                         --
   ---------------------------------------------------------------

   G_CREATE                       CONSTANT  VARCHAR2(10) := 'CREATE';
   G_UPDATE                       CONSTANT  VARCHAR2(10) := 'UPDATE';
   G_SYNC                         CONSTANT  VARCHAR2(10) := 'SYNC';
   G_VAL_TRANS_TYPE                         VARCHAR2(10) := NULL;


   ---------------------------------------------------------------
   -- API Return status.                                      --
   ---------------------------------------------------------------
   G_RET_STS_SUCCESS              CONSTANT  VARCHAR2(1) :=  FND_API.G_RET_STS_SUCCESS;
   G_RET_STS_ERROR                CONSTANT  VARCHAR2(1) :=  FND_API.G_RET_STS_ERROR;
   G_RET_STS_UNEXP_ERROR          CONSTANT  VARCHAR2(1) :=  FND_API.G_RET_STS_UNEXP_ERROR;


   ---------------------------------------------------------------
   -- WHO Columns        .                                      --
   ---------------------------------------------------------------
   G_USER_ID                                NUMBER      :=  FND_GLOBAL.User_Id;
   G_LOGIN_ID                               NUMBER      :=  FND_GLOBAL.Login_Id;
   G_APPLICATION_ID                         NUMBER;
   G_APPL_NAME                              VARCHAR2(3) := 'EGO';
   G_Party_Id                               NUMBER      :=  FND_GLOBAL.Party_Id;
   G_Party_Name                             VARCHAR2(500);
   G_Locking_Party_Name                     VARCHAR2(500);

   G_PROG_APPL_ID                 CONSTANT  NUMBER      :=  FND_GLOBAL.PROG_APPL_ID;
   G_PROGRAM_ID                   CONSTANT  NUMBER      :=  FND_GLOBAL.CONC_PROGRAM_ID;
   G_REQUEST_ID                   CONSTANT  NUMBER      :=  FND_GLOBAL.CONC_REQUEST_ID;


   ---------------------------------------------------------------
   -- Data Types for Value Set.--
   ---------------------------------------------------------------
   G_CHAR_DATA_TYPE               CONSTANT  VARCHAR2(1) := 'C';
   G_NUMBER_DATA_TYPE             CONSTANT  VARCHAR2(1) := 'N';
   G_DATE_DATA_TYPE               CONSTANT  VARCHAR2(1) := 'X';
   G_DATE_TIME_DATA_TYPE          CONSTANT  VARCHAR2(1) := 'Y';


   G_COL_DATE_DATA_TYPE           CONSTANT  VARCHAR2(1) := 'D';

   G_NUMBER_FORMAT                CONSTANT  VARCHAR2(20):= 'Number';
   G_DATE_FORMAT                  CONSTANT  VARCHAR2(20):= 'Standard Date';
   G_DATETIME_FORMAT              CONSTANT  VARCHAR2(20):= 'Standard DateTime';




   ---------------------------------------------------------------
   -- Validation Type for Value Set.--
   ---------------------------------------------------------------
   G_TRANS_IND_VALIDATION_CODE    CONSTANT  VARCHAR2(1) := 'X';
   G_INDEPENDENT_VALIDATION_CODE  CONSTANT  VARCHAR2(1) := 'I';
   G_NONE_VALIDATION_CODE         CONSTANT  VARCHAR2(1) := 'N';
   G_TABLE_VALIDATION_CODE        CONSTANT  VARCHAR2(1) := 'F';


   ---------------------------------------------------------------
   -- Longlist Type for Value Set.--                            --
   ---------------------------------------------------------------
   G_LOV_LONGLIST_FLAG            CONSTANT  VARCHAR2(1) := 'N';
   G_POPLIST_LONGLIST_FLAG        CONSTANT  VARCHAR2(1) := 'X';

   --------------------------------------------------------------
   -- The Entity Codes are used for error-handling purposes. --
   --------------------------------------------------------------
   G_BO_IDENTIFIER_VS             CONSTANT  VARCHAR2(30)  := 'VS_BO';
   G_ENTITY_VS                    CONSTANT  VARCHAR2(30)  := 'VS';
   G_ENTITY_CHILD_VS              CONSTANT  VARCHAR2(30)  := 'CHILD_VS';
   G_ENTITY_VS_VAL                CONSTANT  VARCHAR2(30)  := 'VS_VALUE';
   G_ENTITY_VS_VER                CONSTANT  VARCHAR2(30)  := 'VS_VERSION';
   G_ENTITY_VS_TABLE              CONSTANT  VARCHAR2(30)  := 'VS_TABLE';

   G_ENTITY_VS_HEADER_TAB         CONSTANT  VARCHAR2(240) := 'EGO_FLEX_VALUE_SET_INTF';
   G_ENTITY_VAL_HEADER_TAB        CONSTANT  VARCHAR2(240) := 'EGO_FLEX_VALUE_INTF';
   G_ENTITY_VAL_TL_HEADER_TAB     CONSTANT  VARCHAR2(240) := 'EGO_FLEX_VALUE_TL_INTF';

   --------------------------------------------------------------
   -- The Object Name for locking and object. --
   --------------------------------------------------------------
   G_OBJECT_VALUE_SET             CONSTANT  VARCHAR2(30)  := 'EGO_VALUE_SET';
   G_P4TP_PROFILE_ENABLED                   BOOLEAN      :=  FALSE;


   G_TABLE_NAME                   CONSTANT  VARCHAR2(30) := 'EGO_FLEX_VALUE_SET_INTF';
   G_TOKEN_TBL    	                        Error_Handler.Token_Tbl_Type;

   --------------------------------------------------------------
   -- The Entity Codes are used for error-handling purposes. --
   --------------------------------------------------------------
   G_VALUE_SET                    CONSTANT  NUMBER        := 1;
   G_VALUE                        CONSTANT  VARCHAR2(30)  := 2;
   --G_Child_VS                     CONSTANT  VARCHAR2(30)  := 3;
   G_DEBUG                                  NUMBER        := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);



  --  The new standard is to treat missing values as NULL and to use the
  --
  --G_NULL_XXX constants to assign a value of NULL to a variable if needed.
  G_NULL_NUM  	                  CONSTANT  NUMBER  	  := 9.99E125;
  G_NULL_CHAR   	                CONSTANT  VARCHAR2(1) := Chr(0);
  G_NULL_DATE    	                CONSTANT  DATE    	  := TO_DATE('1','j');


  G_PROCESS_RECORD                CONSTANT  NUMBER := 1;
  G_ERROR_RECORD                  CONSTANT  NUMBER := 3;
  G_SUCCESS_RECORD                CONSTANT  NUMBER := 7;

   --------------------------------------------------------------
   -- Variable to fid out source of program call.              --
   --------------------------------------------------------------

  G_EGO_MD_INTF                   CONSTANT  NUMBER := 2;
  G_EGO_MD_API                    CONSTANT  NUMBER := 1;
  G_FLOW_TYPE                               NUMBER :=G_EGO_MD_API;



  G_USER_LANG   		                        VARCHAR2(10);
  G_NLS_LANGUAGE		                        VARCHAR2(100);
  G_OUT_VERSION_SEQ_ID	                    NUMBER;










  -----------------------------------------------
  -- Write Debug statements to Concurrent Log  --
  -----------------------------------------------
  PROCEDURE Write_Debug ( p_pkg_name  IN  VARCHAR2,
                          p_api_name  IN  VARCHAR2,
                          p_msg       IN  VARCHAR2)
  IS

  BEGIN

      ego_metadata_bulkload_pvt.write_debug(p_pkg_name||'.'||p_api_name||p_msg);

  END write_debug;






  -----------------------------------------------
  -- Function to get application Id            --
  -----------------------------------------------
  FUNCTION Get_Application_Id

    RETURN NUMBER

  IS

      l_application_id NUMBER        := NULL;
      l_api_name       VARCHAR2(100) := 'Get_Application_Id';

  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API ');


      -- Get application id
      SELECT application_id
        INTO l_Application_Id
      FROM fnd_application
      WHERE application_short_name ='EGO';

      write_debug(G_PKG_Name,l_api_name,' End of API l_Application_Id = '||l_Application_Id);

      RETURN l_Application_Id;--G_Application_Id;

  EXCEPTION
      WHEN OTHERS THEN
          write_debug(G_PKG_Name,l_api_name,' In Exception ');
          l_Application_Id  :=  NULL;
  END;



  ---------------------------------------------------------------------------------
  -- Procedure to convert a entity name to entity id , If exist.
  ---------------------------------------------------------------------------------
  Procedure Convert_Name_To_Id (
            Name                IN              VARCHAR2,
            Entity_Id           IN              NUMBER,
            Parent_Id           IN              NUMBER  DEFAULT NULL, -- Here Parent Id will be Id of parent entity for a sub entity.
            Id                  OUT NOCOPY      NUMBER)

  IS

    l_name      VARCHAR2(1000)  :=  Name;
    l_id        NUMBER          :=  NULL;
    l_parent_id NUMBER          :=  Parent_Id;

    l_api_name       VARCHAR2(100) := 'Convert_Name_To_Id';

    -- Cursor to get Value Set id
    CURSOR  cur_value_set_id( cp_value_set_name  VARCHAR2)
    IS
        SELECT flex_value_set_id
        FROM fnd_flex_value_sets
        WHERE flex_value_set_name = cp_value_set_name;


    -- Cursor to get Value id
    CURSOR cur_value_id ( cp_value_set_id   NUMBER,
                          cp_flex_value     VARCHAR2)
    IS

      SELECT val.flex_value_id  value_id
      FROM  fnd_flex_value_sets vs,
            fnd_flex_values val
      WHERE vs.flex_value_set_id  = val.flex_value_set_id
        AND vs.flex_value_set_id  = cp_value_set_id
        AND val.flex_value        = cp_flex_value;

  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API  ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API  ');

      -- Coverting Value Set Name to Id
      If Entity_Id =G_Value_Set THEN

        -- Get value set id
          FOR i IN cur_value_set_id(l_name)
          LOOP

            l_id  := i.flex_value_set_id;

          END LOOP;



      ELSIF Entity_Id=G_Value THEN

        -- Get value set id if value set name is passed
          FOR i IN cur_value_id(l_parent_id, l_name)
          LOOP

            l_id  := i.value_id;

          END LOOP;

      END IF;--

      Id  :=  l_id;

      write_debug(G_PKG_Name,l_api_name,' End of API  : Value of id = '||Id);
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API  : Value of id = '||Id);

  EXCEPTION
      WHEN OTHERS THEN
          Id  :=  NULL;
          write_debug(G_PKG_Name,l_api_name,' In exception part : Error Msg : '||SQLERRM);
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In exception part : Error Msg : '||SQLERRM);

  END Convert_Name_To_Id;



  ---------------------------------------------------------------------------------
  -- Procedure to convert a entity name to entity id , If exist.
  ---------------------------------------------------------------------------------
  Procedure Convert_Id_To_Name (
            Id                  IN OUT NOCOPY   NUMBER,
            Entity_Id           IN              NUMBER,
            Parent_Id           IN              NUMBER  DEFAULT NULL, -- Here Parent Id will be Id of parent entity for a sub entity.
            Name                OUT NOCOPY      VARCHAR2 )

  IS

    l_name      VARCHAR2(1000)  :=  NULL;
    l_id        NUMBER          :=  Id;
    l_parent_id NUMBER          :=  Parent_Id;
    l_api_name  VARCHAR2(100)   := 'Convert_Id_To_Name';

    -- Cursor to get value_set_name for a passed in value set id
    CURSOR  cur_value_set_name(cp_value_set_id  NUMBER)
    IS
      SELECT flex_value_set_name
      FROM fnd_flex_value_sets
      WHERE flex_value_set_id = cp_value_set_id;


    -- Cursor to find out if value already exist in system.
    CURSOR cur_value_name(  cp_flex_value_set_id  NUMBER,
                            cp_flex_value_id      NUMBER )
    IS
      SELECT flex_value
      FROM fnd_flex_values
      WHERE flex_value_set_id= cp_flex_value_set_id
        AND flex_value_id = cp_flex_value_id;



  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API  ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API  ');

      -- Coverting Value Set Name to Id
      If Entity_Id =G_Value_Set THEN

          FOR i IN cur_value_set_name(l_id)
          LOOP

            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' G_Value_Set l_id = '|| l_id ||' l_name = '|| l_name );

            l_name  := i.flex_value_set_name;
          END LOOP;

          IF l_name IS NULL THEN
            Id      :=  NULL;
          END IF;




      ELSIF Entity_Id=G_Value THEN

          FOR i IN cur_value_name(l_parent_id,l_id)
          LOOP
            l_name  :=  i.flex_value;
          EXIT
            WHEN cur_value_name%NOTFOUND;
          END LOOP;

          IF l_name IS NULL THEN

            Id      :=  NULL;

          END IF;


      END IF;--

      Name  :=  l_name;

      write_debug(G_PKG_Name,l_api_name,' End of API  : Value of Name = '||Name);
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API  : Value of Name = '||Name);

  EXCEPTION
      WHEN OTHERS THEN
          Name  :=  NULL;
          write_debug(G_PKG_Name,l_api_name,' In exception part: Error '||SQLERRM);
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In exception part: Error '||SQLERRM);


  END Convert_Id_To_Name;





  ---------------------------------------------------------------------------------
  -- Check if passed in parameter is in valid date format
  ---------------------------------------------------------------------------------
  FUNCTION Is_Valid_Date  ( p_user_date IN  VARCHAR2 )
    RETURN NUMBER
  IS

      l_dummydate   DATE;
      l_api_name    VARCHAR2(100) := 'Is_Valid_Date';

      l_yr_end      VARCHAR2(1) :=NULL;
      l_mm_end      VARCHAR2(1) :=NULL;


  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API  ');


      l_Yr_End := SubStr(p_user_date ,5,1);
      --Dbms_Output.put_line(' l_Yr  = '||l_Yr_End );

      IF l_Yr_End ='-' THEN

          l_mm_End := SubStr(p_user_date ,8,1);
          --Dbms_Output.put_line(' l_mm  = '||l_mm_End  );

          IF l_mm_End <> '-' THEN

            RETURN(1);

          END IF;

      ELSE
        RETURN(1);

      END IF;




      l_dummydate   := TO_DATE(p_user_date,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT);
      RETURN (0);

      write_debug(G_PKG_Name,l_api_name,' End of API ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API  ');

  EXCEPTION
      WHEN OTHERS THEN
      RETURN (1);

  END;




  -- Bug 9701510
  PROCEDURE Convert_Value_To_DbDate ( p_value         IN  OUT NOCOPY        VARCHAR2)
  IS


      l_api_name                VARCHAR2(100) :=  'Convert_Value_To_DbDate';
      l_mask_format             VARCHAR2(100) :=NULL;
      l_value                   VARCHAR2(100) :=LTrim(RTrim(p_value));
      l_User_Pref_Date          DATE  ;
      l_User_Pref_Date_val      VARCHAR2(100);
      l_return_status           VARCHAR2(1)  :=  G_RET_STS_SUCCESS;



  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API. ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API. ');


      -- Call API to get current value of mask.
      FND_PROFILE.GET('ICX_DATE_FORMAT_MASK',l_mask_format);

      -- Get char value in date format
      --l_User_Pref_Date := To_Date (l_value,l_mask_format );

      l_User_Pref_Date := To_Date (l_value,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT );
      --Dbms_Output.put_line('  Format mask in user preferred format is : '||l_mask_format);

      --l_User_Pref_Date_val := LTrim(RTrim ( To_Char(l_User_Pref_Date,l_mask_format)));

      -- Mask it to DB format if require.
      l_value := LTrim(RTrim (To_Char( l_User_Pref_Date,EGO_USER_ATTRS_COMMON_PVT.G_DATE_FORMAT)));
      --Dbms_Output.put_line(' DB Date format: '||l_value);

      -- Assign value back.
      p_value := l_value;



      write_debug(G_PKG_Name,l_api_name,' End of API. ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API. ');


  EXCEPTION
      WHEN OTHERS THEN

            write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  In Exception of API. Error : '||SubStr(SQLERRM,1,500) );

            /*x_return_status := G_RET_STS_UNEXP_ERROR;
            x_return_msg    := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);*/

  END;




  -- Bug 9701510
  PROCEDURE Validate_User_Preferred_Date (p_value             IN OUT NOCOPY     VARCHAR2,
                                          p_format_code       IN                VARCHAR2,
                                          p_transaction_id    IN                VARCHAR2,
                                          x_return_status     OUT NOCOPY        VARCHAR2,
                                          x_return_msg        OUT NOCOPY        VARCHAR2)

  IS

      l_api_name                VARCHAR2(100) :=  'Validate_User_Preferred_Date';
      l_mask_format             VARCHAR2(100) :=  NULL;
      l_value                   VARCHAR2(100) :=  LTrim(RTrim(p_value));
      l_User_Pref_Date          DATE  ;
      l_User_Pref_Date_val      VARCHAR2(100);
      l_format_meaning          VARCHAR2(100) :=  NULL;

      l_format_code             VARCHAR2(1)   :=  p_format_code;
      l_transaction_id	        NUMBER        :=  p_transaction_id;

      -- Local variable for Error handling
      l_error_message_name      VARCHAR2(240);
      l_entity_code             VARCHAR2(30) :=  G_ENTITY_VS_VAL;
      l_table_name              VARCHAR2(240):=  G_ENTITY_VAL_HEADER_TAB;
      l_return_status           VARCHAR2(1)  :=  G_RET_STS_SUCCESS;
      l_application_id          NUMBER       :=  G_Application_Id;
      l_token_table             ERROR_HANDLER.Token_Tbl_Type;
      l_valid_type              NUMBER       :=  NULL;

      CURSOR Cur_format_meaning(cp_format_code VARCHAR2)
      IS
      SELECT meaning
      FROM ego_vs_format_codes_v
      WHERE lookup_code = cp_format_code;



  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API. ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API. ');

      --Dbms_Output.put_line(' Passed in value is : '||l_value);


      -- Call API to get current value of mask.
      FND_PROFILE.GET('ICX_DATE_FORMAT_MASK',l_mask_format);



      /*FOR i IN Cur_Format_Meaning (l_format_code)
      LOOP

          l_format_meaning  := i.meaning;

      END LOOP;


      -- Get char value in date format
      l_User_Pref_Date      := To_Date (l_value,l_mask_format );


      l_User_Pref_Date_val  := To_Char(l_User_Pref_Date,l_mask_format);
      --Dbms_Output.put_line(' Value in user preferred date format:'||l_User_Pref_Date_val);




      IF l_User_Pref_Date_val <> l_value THEN

          --Dbms_Output.put_line(' Date is not entered in user preferred format ');
          l_return_status := G_RET_STS_ERROR;

          IF p_format_code IN (G_DATE_DATA_TYPE) THEN --,G_DATE_TIME_DATA_TYPE) THEN

                l_error_message_name          := 'EGO_EF_DATE_INT_NAME_ERR';

                l_token_table(1).TOKEN_NAME   := 'FORMAT_MEANING';
                l_token_table(1).TOKEN_VALUE  := l_format_meaning;

                l_token_table(2).TOKEN_NAME   := 'DATE_EXAMPLE';
                l_token_table(2).TOKEN_VALUE  := To_Char(SYSDATE,l_mask_format) ;



                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                   => l_error_message_name
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => l_token_table
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => l_table_name
                );

                l_token_table.DELETE;


          END IF;



          IF p_format_code IN (G_DATE_TIME_DATA_TYPE) THEN

                l_error_message_name          := 'EGO_EF_DATE_TIME_INT_NAME_ERR';
                -- Set process_status to 3
                l_token_table(1).TOKEN_NAME   := 'FORMAT_MEANING';
                l_token_table(1).TOKEN_VALUE  := l_format_meaning;

                l_token_table(2).TOKEN_NAME   := 'DATE_EXAMPLE';
                l_token_table(2).TOKEN_VALUE  := To_Char(SYSDATE,l_mask_format) ;



                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                   => l_error_message_name
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => l_token_table
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => l_table_name
                );

                l_token_table.DELETE;

          END IF;

      END IF;
      */




      --Dbms_Output.put_line(' Calling Is_Valid_Date API .');
      l_valid_type  := Is_Valid_Date (l_value);
      --Dbms_Output.put_line(' Call to Is_Valid_Date API is done. Value of l_valid_type =.'||l_valid_type);

      -- For a Date type VS, length should not be greater than 11.
      IF  l_format_code =  G_DATE_DATA_TYPE THEN

          IF Length(l_value) >11 THEN

              l_valid_type := 1;

          END IF;

      END IF;


      IF  l_valid_type = 1 THEN

        --Dbms_Output.put_line(' Date format is not valid format.');

        IF  l_format_code =  G_DATE_DATA_TYPE THEN

          l_error_message_name          := 'EGO_EF_DATE_INT_NAME_ERR';

          l_token_table(1).TOKEN_NAME   := 'FORMAT_MEANING';
          l_token_table(1).TOKEN_VALUE  := G_DATE_FORMAT;

          l_token_table(2).TOKEN_NAME   := 'DATE_EXAMPLE';
          l_token_table(2).TOKEN_VALUE  := To_Char(SYSDATE,'YYYY-MM-DD') ;


        ELSIF l_format_code =  G_DATE_TIME_DATA_TYPE THEN

          l_error_message_name          := 'EGO_EF_DATE_TIME_INT_NAME_ERR';

          l_token_table(1).TOKEN_NAME   := 'FORMAT_MEANING';
          l_token_table(1).TOKEN_VALUE  := G_DATETIME_FORMAT;
          l_token_table(2).TOKEN_NAME   := 'DATE_EXAMPLE';
          l_token_table(2).TOKEN_VALUE  := To_Char(SYSDATE,'YYYY-MM-DD') ;

        END IF ; -- END IF  l_format_code =  G_DATE_DATA_TYPE THEN

        --Log error
        l_return_status               := G_RET_STS_ERROR;


        ERROR_HANDLER.Add_Error_Message(
          p_message_name                   => l_error_message_name
          ,p_application_id                => G_App_Short_Name
          ,p_token_tbl                     => l_token_table
          ,p_message_type                  => G_RET_STS_ERROR
          ,p_row_identifier                => l_transaction_id
          ,p_entity_code                   => l_entity_code
          ,p_table_name                    => l_table_name);

        l_token_table.DELETE;


      END IF;-- END F  l_valid_num = 1 THEN

      l_valid_type :=NULL;






      IF l_return_status IS NULL THEN

            l_return_status := G_RET_STS_SUCCESS;

      END IF;



      x_return_status := l_return_status;
      write_debug(G_PKG_Name,l_api_name,' End of API. ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API. ');


  EXCEPTION
      WHEN OTHERS THEN

            write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  In Exception of API. Error : '||SubStr(SQLERRM,1,500) );

            x_return_status := G_RET_STS_UNEXP_ERROR;
            x_return_msg    := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);


  END;





  ---------------------------------------------------------------------------------
  -- Check if passed in parameter is in valid number format
  ---------------------------------------------------------------------------------
  FUNCTION Is_Valid_Number( p_user_num IN   VARCHAR2)
    RETURN NUMBER

  IS

    l_api_name    VARCHAR2(100) := 'Is_Valid_Number';

  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API ');
      --Dbms_Output.put_line(G_PKG_Name||' Start of API  ');

      -- Return '1' is input is not in number format
      IF NOT REGEXP_LIKE(p_user_num, '^[0-9]+$')  THEN
        RETURN (1);

      ELSE
        RETURN (0);

      END IF;

      write_debug(G_PKG_Name,l_api_name,' End of API ');
      --Dbms_Output.put_line(G_PKG_Name||' End of API  ');


  EXCEPTION
      WHEN OTHERS THEN
      RETURN (1);

  END;





  -----------------------------------------------
  --  API  Get_Effective_Version_Date          --
  -----------------------------------------------
  PROCEDURE Get_Effective_Version_Date (  p_value_set_id          IN         NUMBER,
                                          p_version_seq_id        IN         NUMBER,
                                          x_start_active_date     OUT NOCOPY DATE,
                                          x_end_active_date       OUT NOCOPY DATE
                                        )
  IS

      l_value_set_id    NUMBER        :=  p_value_set_id;
      l_version_seq_id  NUMBER        :=  p_version_seq_id;
      l_api_name        VARCHAR2(100) := 'Get_Effective_Version_Date';

      CURSOR Cur_Version_date
      IS
      SELECT start_active_date, end_active_date
      FROM ego_flex_valueset_version_b
      WHERE flex_value_set_id = l_value_set_id
        AND version_seq_id  = l_version_seq_id;


  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API  ');

      FOR i IN Cur_version_date
      LOOP
        x_start_active_date :=  i.start_active_date;
        x_end_active_date   :=  i.end_active_date;
      END LOOP;

      write_debug(G_PKG_Name,l_api_name,' End of API  ');

  EXCEPTION
      WHEN OTHERS THEN

          write_debug(G_PKG_Name,l_api_name,' In exception part  '||SQLERRM);
          x_start_active_date :=  NULL;
          x_end_active_date   :=  NULL;

  END Get_Effective_Version_Date;









  ---------------------------------------------------------------------------------
  -- Procedure to validate child VS.
  ---------------------------------------------------------------------------------
  PROCEDURE Validate_Child_Value_Set (
                                      p_value_set_name      IN    VARCHAR2,
                                      p_value_set_id        IN    NUMBER,
                                      p_validation_code     IN    VARCHAR2,
                                      p_longlist_flag       IN    VARCHAR2,
                                      p_format_code         IN    VARCHAR2,
                                      p_version_seq_id      IN    NUMBER,
                                      p_transaction_id      IN    NUMBER,
                                      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_return_msg         OUT NOCOPY VARCHAR2)

  IS

          l_api_name            VARCHAR2(100) := 'Validate_Child_Value_Set';
          l_value_set_name      VARCHAR2(100) :=  p_value_set_name;
          l_value_set_id        NUMBER        :=  p_value_set_id;
          l_validation_code     VARCHAR2(1)   :=  p_validation_code;
          l_longlist_flag       VARCHAR2(1)   :=  p_longlist_flag;
          l_format_code         VARCHAR2(1)   :=  p_format_code;
          l_version_seq_id      NUMBER        :=  p_version_seq_id;
          l_transaction_id	    NUMBER        :=  p_transaction_id;

          /* Local variable to be used in error handling mechanism*/
          l_entity_code         VARCHAR2(40)  :=  G_ENTITY_CHILD_VS;
          l_table_name          VARCHAR2(240) :=  G_ENTITY_VS_HEADER_TAB;
          l_application_id      NUMBER        :=  G_Application_Id;

          l_token_table         ERROR_HANDLER.Token_Tbl_Type;
          l_error_message_name  VARCHAR2(500);
          l_return_status       VARCHAR2(1)   := G_RET_STS_SUCCESS;


  BEGIN

          write_debug(G_PKG_Name,l_api_name,' Start of API. ');
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API. ');


          -- Validation code validation
          IF l_validation_code NOT IN (G_TABLE_VALIDATION_CODE) THEN



              write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                          ||l_value_set_name||','||l_value_set_id||')'||' A child value set should be of table type. ');




              l_return_status               := G_RET_STS_ERROR;
              l_error_message_name          := 'EGO_CHILD_VS_VALIDATION_ERROR';

              l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
              l_token_table(1).TOKEN_VALUE  := l_value_set_name;

              l_token_table(2).TOKEN_NAME   := 'VALUE_SET_ID';
              l_token_table(2).TOKEN_VALUE  := l_value_set_id;


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => G_ENTITY_CHILD_VS
                ,p_table_name                    => G_ENTITY_VS_HEADER_TAB
              );

              -- Set process_status to 3

              l_token_table.DELETE;


          END IF;






          -- Version validation
          IF  l_version_seq_id IS NOT NULL THEN

              write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                          ||l_value_set_name||','||l_value_set_id||')'||' A child value set can not be a versioned value set.');



              l_error_message_name          := 'EGO_TABLE_VS_VERSION_ERROR';
              l_return_status               := G_RET_STS_ERROR;

              l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
              l_token_table(1).TOKEN_VALUE  := l_value_set_name;


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name
              );

              l_token_table.DELETE;

          END IF; --IF  l_validation_code = G_TABLE_VALIDATION_CODE THEN



          -- Check for Longlist Flag
          IF l_longlist_flag NOT IN (G_LOV_LONGLIST_FLAG,G_POPLIST_LONGLIST_FLAG)  THEN



              write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                          ||l_value_set_name||','||l_value_set_id||')'||' A child value set does not have valid longlist flag. ');


              l_error_message_name          := 'EGO_VSET_LONGLIST_ERROR';
              l_return_status               := G_RET_STS_ERROR;

              l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
              l_token_table(1).TOKEN_VALUE  := l_value_set_name;


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name
              );

              l_token_table.DELETE;

          END IF;



          -- Check for Date Type
          IF l_format_code NOT IN (G_CHAR_DATA_TYPE,G_NUMBER_DATA_TYPE,G_DATE_DATA_TYPE, G_DATE_TIME_DATA_TYPE)  THEN


              write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                          ||l_value_set_name||','||l_value_set_id||')'||' A child value set does not have valid data type. ');


              l_error_message_name          := 'EGO_VSET_DATA_TYPE_ERROR';
              l_return_status               := G_RET_STS_ERROR;


              l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
              l_token_table(1).TOKEN_VALUE  := l_value_set_name;


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name
              );

              l_token_table.DELETE;

          END IF;



          IF l_return_status IS NULL THEN

                l_return_status := G_RET_STS_SUCCESS;

          END IF;
          x_return_status := l_return_status;


          write_debug(G_PKG_Name,l_api_name,' End of API. ');
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API. ');

  EXCEPTION
      WHEN OTHERS THEN

          write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  In Exception of API. Error : '||SubStr(SQLERRM,1,500) );

          x_return_status := G_RET_STS_UNEXP_ERROR;
          x_return_msg    := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	      RETURN;


  END Validate_Child_Value_Set;






  ---------------------------------------------------------------------------------
  -- Procedure to validate table type VS.
  ---------------------------------------------------------------------------------
  PROCEDURE Validate_Table_Value_Set (
                                      p_value_set_name            IN    VARCHAR2,
                                      p_value_set_id              IN    NUMBER,
                                      p_format_code               IN    VARCHAR2,

                                      p_application_table_name    IN    VARCHAR2,
                                      p_additional_where_clause   IN    VARCHAR2  DEFAULT NULL,

                                      p_value_column_name         IN    VARCHAR2,
                                      p_value_column_type         IN    VARCHAR2,
                                      p_value_column_size         IN    NUMBER,

                                      p_id_column_name            IN    VARCHAR2  DEFAULT NULL ,
                                      p_id_column_type            IN    VARCHAR2  DEFAULT NULL ,
                                      p_id_column_size            IN    NUMBER    DEFAULT NULL ,

                                      p_meaning_column_name       IN    VARCHAR2  DEFAULT NULL ,
                                      p_meaning_column_type       IN    VARCHAR2  DEFAULT NULL ,
                                      p_meaning_column_size       IN    NUMBER    DEFAULT NULL ,

                                      p_transaction_id      IN    NUMBER,
                                      x_return_status      OUT NOCOPY VARCHAR2,
                                      x_return_msg         OUT NOCOPY VARCHAR2)

  IS

        l_api_name                VARCHAR2(100) := 'Validate_Table_Value_Set';
        l_value_set_name          VARCHAR2(100) :=  p_value_set_name;
        l_value_set_id            NUMBER        :=  p_value_set_id;

        l_application_table_name  VARCHAR2(240) :=  p_application_table_name;
        l_additional_where_clause VARCHAR2(240) :=  p_additional_where_clause;
        l_value_column_name       VARCHAR2(240) :=  p_value_column_name;
        l_value_column_type       VARCHAR2(1)   :=  p_value_column_type;
        l_value_column_size       NUMBER        :=  p_value_column_size;


        l_id_column_name          VARCHAR2(240) :=  p_id_column_name;
        l_id_column_type          VARCHAR2(1)   :=  p_id_column_type;
        l_id_column_size          NUMBER        :=  p_id_column_size;

        l_meaning_column_name     VARCHAR2(240) :=  p_meaning_column_name;
        l_meaning_column_type     VARCHAR2(1)   :=  p_meaning_column_type;
        l_meaning_column_size     NUMBER        :=  p_meaning_column_size;


        /* Local variable to be used in error handling mechanism*/
        l_entity_code         VARCHAR2(40)      :=  G_ENTITY_VS;
        l_table_name          VARCHAR2(240)     :=  G_ENTITY_VS_HEADER_TAB;
        l_transaction_id	    NUMBER            :=  p_transaction_id;
        l_application_id      NUMBER            :=  G_Application_Id;

        l_return_status       VARCHAR2(1)       := G_RET_STS_SUCCESS;

        l_token_table         ERROR_HANDLER.Token_Tbl_Type;
        l_error_message_name  VARCHAR2(500);
        l_tab_exist           NUMBER            :=  NULL;
        l_col_exist           NUMBER            :=  NULL;

        l_cols                VARCHAR2(1000)    :=  NULL;
        l_where_clause        VARCHAR2(2000)    :=  NULL;
        l_sql                 VARCHAR2(2000)    :=  NULL;



        /*CURSOR Cur_Tab_Exist(cp_application_table_name VARCHAR2)
        IS
        SELECT 1 AS tab_exist
        FROM all_objects
        WHERE object_name =Upper(l_application_table_name)
          AND object_type IN ('VIEW','SYNONYM','TABLE');


        CURSOR Cur_Col_Exist( cp_application_table_name VARCHAR2,
                              cp_value_column_name      VARCHAR2 )
        IS
        SELECT 1 AS col_exist
        FROM all_tab_columns
        WHERE TABLE_NAME    =   Upper(l_application_table_name)
            AND COLUMN_NAME =   Upper(l_value_column_name);

        */


  BEGIN

          write_debug(G_PKG_Name,l_api_name,' Start of API. ');
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API. ');

          IF p_format_code IN (G_CHAR_DATA_TYPE,G_NUMBER_DATA_TYPE ) THEN

                IF  l_value_column_type <> p_format_code THEN

                    write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                                ||l_value_set_name||','||l_value_set_id||')'||' The Data Type of the Value Set and the Value Column do not match. ');

                    l_error_message_name          := 'EGO_VS_VAL_DATA_TYPE_MISMATCH';
                    l_return_status               := G_RET_STS_ERROR;

                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                  => l_error_message_name
                      ,p_application_id                => G_App_Short_Name
                      ,p_token_tbl                     => l_token_table
                      ,p_message_type                  => G_RET_STS_ERROR
                      ,p_row_identifier                => l_transaction_id
                      ,p_entity_code                   => l_entity_code
                      ,p_table_name                    => l_table_name
                    );

                END IF; --



                IF  l_id_column_type  IS NOT NULL THEN
                    IF  l_id_column_type <> p_format_code THEN

                        write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                                    ||l_value_set_name||','||l_value_set_id||')'||' The Data Type of the Value Set and the Id Column do not match. ');

                        l_error_message_name          := 'EGO_VS_VAL_DATA_TYPE_MISMATCH';
                        l_return_status               := G_RET_STS_ERROR;

                        ERROR_HANDLER.Add_Error_Message(
                          p_message_name                  => l_error_message_name
                          ,p_application_id                => G_App_Short_Name
                          ,p_token_tbl                     => l_token_table
                          ,p_message_type                  => G_RET_STS_ERROR
                          ,p_row_identifier                => l_transaction_id
                          ,p_entity_code                   => l_entity_code
                          ,p_table_name                    => l_table_name
                        );

                    END IF; --

                END IF;

          END IF; -- END IF p_format_code IN (G_CHAR_DATA_TYPE,G_NUMBER_DATA_TYPE ) THEN


          -- Bug 9702862
          IF p_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE) THEN

                IF  l_value_column_type <> G_COL_DATE_DATA_TYPE THEN

                    write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                                ||l_value_set_name||','||l_value_set_id||')'||' The Data Type of the Value Set and the Value Column do not match. ');

                    l_error_message_name          := 'EGO_VS_VAL_DATA_TYPE_MISMATCH';
                    l_return_status               := G_RET_STS_ERROR;

                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                  => l_error_message_name
                      ,p_application_id                => G_App_Short_Name
                      ,p_token_tbl                     => l_token_table
                      ,p_message_type                  => G_RET_STS_ERROR
                      ,p_row_identifier                => l_transaction_id
                      ,p_entity_code                   => l_entity_code
                      ,p_table_name                    => l_table_name
                    );

                END IF; --



                IF  l_id_column_type  IS NOT NULL THEN
                    IF  l_id_column_type <> G_COL_DATE_DATA_TYPE THEN

                        write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                                    ||l_value_set_name||','||l_value_set_id||')'||' The Data Type of the Value Set and the Id Column do not match. ');

                        l_error_message_name          := 'EGO_VS_VAL_DATA_TYPE_MISMATCH';
                        l_return_status               := G_RET_STS_ERROR;

                        ERROR_HANDLER.Add_Error_Message(
                          p_message_name                  => l_error_message_name
                          ,p_application_id                => G_App_Short_Name
                          ,p_token_tbl                     => l_token_table
                          ,p_message_type                  => G_RET_STS_ERROR
                          ,p_row_identifier                => l_transaction_id
                          ,p_entity_code                   => l_entity_code
                          ,p_table_name                    => l_table_name
                        );

                    END IF; --

                END IF;

          END IF; -- END IF p_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE ) THEN






          IF  l_meaning_column_type  IS NOT NULL THEN
              IF  l_meaning_column_type NOT IN (G_CHAR_DATA_TYPE,G_NUMBER_DATA_TYPE ,G_DATE_DATA_TYPE) THEN

                  write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                              ||l_value_set_name||','||l_value_set_id||')'||' The Data Type of the Value Set and the meaning Column do not match. ');

                  l_error_message_name          := 'EGO_VS_VAL_DATA_TYPE_MISMATCH';
                  l_return_status               := G_RET_STS_ERROR;

                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                  => l_error_message_name
                    ,p_application_id                => G_App_Short_Name
                    ,p_token_tbl                     => l_token_table
                    ,p_message_type                  => G_RET_STS_ERROR
                    ,p_row_identifier                => l_transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => l_table_name
                  );

              END IF; --

          END IF;




          IF ( l_application_table_name IS NOT NULL OR l_value_column_name IS NOT NULL
                OR l_additional_where_clause IS NOT NULL )  THEN


                  BEGIN

                        l_cols :=l_value_column_name;

                        IF l_id_column_name IS NOT NULL THEN

                            l_cols :=l_cols||','||l_id_column_name;

                        END IF;


                        IF l_meaning_column_name IS NOT NULL THEN

                            l_cols :=l_cols||','||l_meaning_column_name;

                        END IF;

                        IF  l_additional_where_clause IS NOT NULL THEN

                            IF ( ( InStr(  Upper(LTrim(RTrim(l_additional_where_clause))), 'WHERE ' ) <> 1  )  AND  ( InStr(  Upper(LTrim(RTrim(l_additional_where_clause))), 'ORDER ' ) <> 1  ) )  THEN

                                l_where_clause := ' WHERE '||l_additional_where_clause;

                            ELSE

                                l_where_clause := l_additional_where_clause;

                            END IF;



                        END IF;

                        l_sql := 'SELECT '||l_cols||' FROM '||l_application_table_name||' '||l_where_clause;

                        write_debug(G_PKG_Name,l_api_name, ' Prepared sql for table validation '||l_sql);
                        --Dbms_Output.put_line(G_PKG_Name||','||l_api_name||' Prepared sql for table validation '||l_sql);

                        EXECUTE IMMEDIATE l_sql;


                  EXCEPTION
                      WHEN OTHERS THEN

                            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                                        ||l_value_set_name||','||l_value_set_id||')'
                                                        ||' Value Set is defined incorrectly. Please contact a system administrator to set up the Value Set correctly. Table Name : '
                                                        ||l_application_table_name||' Value Col Name : '||l_value_column_name);

                            l_error_message_name          := 'EGO_VS_TABLE_SETUP_ERROR';
                            l_return_status               := G_RET_STS_ERROR;

                            ERROR_HANDLER.Add_Error_Message(
                              p_message_name                  => l_error_message_name
                              ,p_application_id                => G_App_Short_Name
                              ,p_token_tbl                     => l_token_table
                              ,p_message_type                  => G_RET_STS_ERROR
                              ,p_row_identifier                => l_transaction_id
                              ,p_entity_code                   => l_entity_code
                              ,p_table_name                    => l_table_name);

                  END;


          END IF;



          /*IF l_application_table_name IS NOT NULL AND l_value_column_name IS NOT NULL THEN

                  FOR i IN Cur_Tab_Exist (l_application_table_name)
                  LOOP
                      l_tab_exist := i.tab_exist;
                  END LOOP;




                  FOR i IN Cur_Col_Exist (l_application_table_name,l_value_column_name)
                  LOOP
                      l_col_exist := i.Col_exist;
                  END LOOP;


                  IF  ( l_tab_exist IS NULL OR l_col_exist IS NULL ) THEN


                      write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                                  ||l_value_set_name||','||l_value_set_id||')'||' Value Set is defined incorrectly. Please contact a system administrator to set up the
                                                  Value Set correctly. Table Name : '||l_application_table_name||' Value Col Name : '||l_value_column_name);

                      l_error_message_name          := 'EGO_VS_TABLE_SETUP_ERROR';
                      l_return_status               := G_RET_STS_ERROR;

                      ERROR_HANDLER.Add_Error_Message(
                        p_message_name                  => l_error_message_name
                        ,p_application_id                => G_App_Short_Name
                        ,p_token_tbl                     => l_token_table
                        ,p_message_type                  => G_RET_STS_ERROR
                        ,p_row_identifier                => l_transaction_id
                        ,p_entity_code                   => l_entity_code
                        ,p_table_name                    => l_table_name);

                  END IF;

          END IF;*/



          -- Validation already done in validate_value_set API.
          /*IF  l_version_seq_id IS NOT NULL THEN

              write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                          ||l_value_set_name||','||l_value_set_id||')'||' A table type value set can not be a versioned value set.');



              l_error_message_name          := 'EGO_TABLE_VS_VERSION_ERROR';
              l_return_status               := G_RET_STS_ERROR;

              l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
              l_token_table(1).TOKEN_VALUE  := l_value_set_name;


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name
              );

              l_token_table.DELETE;

          END IF; --IF  l_validation_code = G_TABLE_VALIDATION_CODE THEN
          */





          IF l_return_status IS NULL THEN

                l_return_status := G_RET_STS_SUCCESS;

          END IF;
          x_return_status := l_return_status;


          write_debug(G_PKG_Name,l_api_name,' End of API. ');
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API. ');

  EXCEPTION
      WHEN OTHERS THEN

          write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  In Exception of API. Error : '||SubStr(SQLERRM,1,500) );

          x_return_status := G_RET_STS_UNEXP_ERROR;
          x_return_msg    := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	      RETURN;


  END Validate_Table_Value_Set;







---------------------------------------------------------------------------------
-- Procedure to resolve transaction type for a entity.
---------------------------------------------------------------------------------
PROCEDURE Resolve_Transaction_Type
              ( p_set_process_id    IN          NUMBER,
                x_return_status     OUT NOCOPY  VARCHAR2,
                x_return_msg        OUT NOCOPY  VARCHAR2
              )

IS
  l_set_process_id  NUMBER(15,0)    := p_set_process_id;
  l_api_name        VARCHAR2(100)   := 'Resolve_Transaction_Type';

BEGIN

  write_debug(G_PKG_Name,l_api_name,' Start of API  ');
  --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API  ');
  ---------------------------------------------------
  -- Update transaction type for value set inteface table.
  ---------------------------------------------------

  -- Create Mode Value Set
  UPDATE Ego_Flex_Value_Set_Intf efvsi
  SET efvsi.transaction_type= G_CREATE,
      efvsi.last_updated_by = g_user_id,
      efvsi.last_update_date = SYSDATE,
      efvsi.last_update_login = g_login_id
  WHERE (p_set_process_id IS NULL
          OR set_process_id = p_set_process_id
        )
    AND NOT EXISTS
    (
      SELECT 1
      FROM fnd_flex_value_sets  ffvs
      WHERE ffvs.flex_value_set_name = efvsi.value_set_name
    )
    AND Upper(efvsi.transaction_type) =G_SYNC;


  -- Update Mode Value Set
  UPDATE Ego_Flex_Value_Set_Intf efvsi
  SET efvsi.transaction_type= G_UPDATE,
      efvsi.last_updated_by = g_user_id,
      efvsi.last_update_date = SYSDATE,
      efvsi.last_update_login = g_login_id
  WHERE (p_set_process_id IS NULL
          OR set_process_id = p_set_process_id
        )
    AND EXISTS
    (
      SELECT 1
      FROM fnd_flex_value_sets  ffvs
      WHERE ffvs.flex_value_set_name = efvsi.value_set_name
    )
    AND Upper(efvsi.transaction_type) =G_SYNC;





  ---------------------------------------------------
  -- Update transaction type for value inteface table.
  ---------------------------------------------------

  -- Create Mode Value.
  UPDATE Ego_Flex_Value_Intf evsvi
  SET evsvi.transaction_type= G_CREATE,
      evsvi.last_updated_by = g_user_id,
      evsvi.last_update_date = SYSDATE,
      evsvi.last_update_login = g_login_id

  WHERE (p_set_process_id IS NULL
          OR set_process_id = p_set_process_id
        )
    AND NOT EXISTS --evsvi.flex_value NOT IN
    (
      SELECT flex_value
      FROM fnd_flex_value_sets FVS,
           fnd_flex_values FVSV
           --Ego_Flex_Value_Set_Intf EVS
      WHERE fvs.flex_value_set_id= fvsv.flex_value_set_id
        AND fvs.flex_value_set_name = evsvi.value_set_name
        --AND evs.value_set_name = evsv.value_set_name

    )
    AND Upper(transaction_type) =G_SYNC;

  -- Update Mode Value.
  UPDATE Ego_Flex_Value_Intf EVSV
  SET EVSV.transaction_type= G_UPDATE ,
      last_updated_by = g_user_id,
      last_update_date = SYSDATE,
      last_update_login = g_login_id

      --flex_value_id = fvsv.flex_value_id  --?
  WHERE (p_set_process_id IS NULL
          OR EVSV.set_process_id = p_set_process_id
        )
    AND EVSV.flex_value IN
    (
      SELECT FVSV.flex_value
      FROM fnd_flex_value_sets FVS,
           fnd_flex_values FVSV
           --Ego_Flex_Value_Set_Intf EVS
      WHERE fvs.flex_value_set_id= fvsv.flex_value_set_id
        AND fvs.flex_value_set_name = evsv.value_set_name
        --AND evs.value_set_name = evsv.value_set_name

    )
    AND Upper(EVSV.transaction_type) =G_SYNC;




  ---------------------------------------------------
  -- Update transaction type for translatable value inteface table.
  ---------------------------------------------------

  -- Create Mode translatable values.
  UPDATE Ego_Flex_Value_Tl_Intf EVSTV
  SET transaction_type= G_CREATE
  WHERE (p_set_process_id IS NULL
          OR set_process_id = p_set_process_id
        )
    AND flex_value NOT IN
    (
      SELECT fvsv.flex_value
      FROM fnd_flex_value_sets FVS,
           fnd_flex_values    FVSV,
           fnd_flex_values_tl FVSTV,
           Ego_Flex_Value_Set_Intf EVS,
           Ego_Flex_Value_Intf EVSV
      WHERE fvs.flex_value_set_id= fvsv.flex_value_set_id
        AND fvsv.flex_value_id= fvstv.flex_value_id
        AND fvs.flex_value_set_name = EVSTV.value_set_name
        AND evs.value_set_name= EVSV.value_set_name
        AND EVSV.flex_value= EVSTV.flex_value

    )
    AND Upper(transaction_type) =G_SYNC;


  -- Update Mode translatable values.
  UPDATE Ego_Flex_Value_Tl_Intf EVSTV
  SET transaction_type= G_UPDATE,
      last_updated_by = g_user_id,
      last_update_date = SYSDATE,
       last_update_login = g_login_id

      --flex_value_id= fvsv.flex_value_id --?
  WHERE (p_set_process_id IS NULL
          OR EVSTV.set_process_id = p_set_process_id
        )
    AND EVSTV.flex_value IN
    (
      SELECT fvsv.flex_value
      FROM fnd_flex_value_sets FVS,
           fnd_flex_values    FVSV,
           fnd_flex_values_tl FVSTV,
           Ego_Flex_Value_Set_Intf EVS
      WHERE fvs.flex_value_set_id= fvsv.flex_value_set_id
        AND fvsv.flex_value_id= fvstv.flex_value_id
        AND fvs.flex_value_set_name = evs.value_set_name
        AND evstv.flex_value= fvsv.flex_value

    )
    AND Upper(transaction_type) =G_SYNC;

  write_debug(G_PKG_Name,l_api_name,' End of API  ');

EXCEPTION
  WHEN OTHERS THEN
    write_debug(G_PKG_Name,l_api_name,' In Exception part. Error '||SQLERRM);
  	x_return_status := G_RET_STS_UNEXP_ERROR;
    x_return_msg := G_PKG_Name||'.'||l_api_name||'  - '||SQLERRM;
 	  RETURN;

END Resolve_Transaction_Type;







  ---------------------------------------------------
  -- Procedure to validate transaction type
  ---------------------------------------------------
  PROCEDURE Validate_Transaction_Type
                ( p_set_process_id    IN          NUMBER,
                  x_return_status     OUT NOCOPY  VARCHAR2,
                  x_return_msg        OUT NOCOPY  VARCHAR2
                )

  IS

      l_api_name            VARCHAR2(100)   := 'Validate_Transaction_Type';
      l_set_process_id      NUMBER(15,0)    :=  p_set_process_id;
      l_err_message_name    VARCHAR2(50)    :=  'EGO_TRANS_TYPE_INVALID';
      l_err_message_text    VARCHAR2(500)   := fnd_message.get;

  BEGIN
      write_debug(G_PKG_Name,l_api_name,' Start of API  ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API  ');
      ---------------------------------------------------
      -- Insert errored record for value Set inteface table.
      ---------------------------------------------------

      -- Insert record for invalida transaction type into error for table EGO_FLEX_VALUE_SET_INTF
      INSERT
      INTO
        MTL_INTERFACE_ERRORS
        (
          TRANSACTION_ID,
          UNIQUE_ID,
          ORGANIZATION_ID,
          COLUMN_NAME,
          TABLE_NAME,
          MESSAGE_NAME,
          ERROR_MESSAGE,
          bo_identifier,
          ENTITY_IDENTIFIER,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE
        )
      SELECT
        evsi.transaction_id,
        MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
        NULL,
        NULL,
        G_ENTITY_VS_HEADER_TAB,
        l_err_message_name,
        l_err_message_text,
        G_BO_IDENTIFIER_VS,
        G_ENTITY_VS,
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, G_USER_ID),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, G_USER_ID),
        NVL(LAST_UPDATE_LOGIN, G_LOGIN_ID),
        G_REQUEST_ID,
        NVL(PROGRAM_APPLICATION_ID, G_PROG_APPL_ID),
        NVL(PROGRAM_ID, G_PROGRAM_ID),
        NVL(PROGRAM_UPDATE_DATE, sysdate)
      FROM Ego_Flex_Value_Set_Intf evsi
      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND Upper(transaction_type) NOT IN (G_CREATE, G_UPDATE,G_SYNC)
        AND process_status=G_PROCESS_RECORD;



      -- Error out record for those where transaction_type NOT IN (G_CREATE,G_UPDATE)
      UPDATE Ego_Flex_Value_Set_Intf
      SET process_status=G_ERROR_RECORD
      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND Upper(transaction_type) NOT IN (G_CREATE, G_UPDATE,G_SYNC);




      -- Insert record for invalida transaction type for table EGO_FLEX_VALUE_INTF
      INSERT
      INTO
        MTL_INTERFACE_ERRORS
        (
          TRANSACTION_ID,
          UNIQUE_ID,
          ORGANIZATION_ID,
          COLUMN_NAME,
          TABLE_NAME,
          MESSAGE_NAME,
          ERROR_MESSAGE,
          bo_identifier,
          ENTITY_IDENTIFIER,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE
        )
      SELECT
        evsvi.transaction_id,
        MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
        NULL,
        NULL,
        G_ENTITY_VAL_HEADER_TAB,
        l_err_message_name,
        l_err_message_text,
        G_BO_IDENTIFIER_VS,
        G_ENTITY_VS_VAL,
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, G_USER_ID),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, G_USER_ID),
        NVL(LAST_UPDATE_LOGIN, G_LOGIN_ID),
        G_REQUEST_ID,
        NVL(PROGRAM_APPLICATION_ID, G_PROG_APPL_ID),
        NVL(PROGRAM_ID, G_PROGRAM_ID),
        NVL(PROGRAM_UPDATE_DATE, sysdate)
      FROM Ego_Flex_Value_Intf evsvi
      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND Upper(transaction_type) NOT IN (G_CREATE, G_UPDATE,G_SYNC)
        AND process_status=G_PROCESS_RECORD;


      -- Set process_status for invalid transaction_type.
      UPDATE Ego_Flex_Value_Intf
      SET process_status=G_ERROR_RECORD
      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND Upper(transaction_type) NOT IN (G_CREATE, G_UPDATE,G_SYNC);




      -- Insert record for invalida transaction type in EGO_FLEX_VALUE_TL_INTF
      INSERT
      INTO
        MTL_INTERFACE_ERRORS
        (
          TRANSACTION_ID,
          UNIQUE_ID,
          ORGANIZATION_ID,
          COLUMN_NAME,
          TABLE_NAME,
          MESSAGE_NAME,
          ERROR_MESSAGE,
          bo_identifier,
          ENTITY_IDENTIFIER,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE
        )
      SELECT
        evstvi.transaction_id,
        MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
        NULL,
        NULL,
        G_ENTITY_VAL_TL_HEADER_TAB,
        l_err_message_name,
        l_err_message_text,
        G_BO_IDENTIFIER_VS,
        G_ENTITY_VS_VAL,
        NVL(LAST_UPDATE_DATE, SYSDATE),
        NVL(LAST_UPDATED_BY, G_USER_ID),
        NVL(CREATION_DATE,SYSDATE),
        NVL(CREATED_BY, G_USER_ID),
        NVL(LAST_UPDATE_LOGIN, G_LOGIN_ID),
        G_REQUEST_ID,
        NVL(PROGRAM_APPLICATION_ID, G_PROG_APPL_ID),
        NVL(PROGRAM_ID, G_PROGRAM_ID),
        NVL(PROGRAM_UPDATE_DATE, sysdate)
      FROM Ego_Flex_Value_Tl_Intf evstvi
      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND Upper(transaction_type) NOT IN (G_CREATE, G_UPDATE,G_SYNC)
        AND process_status=G_PROCESS_RECORD;



      -- Check transaction_type in translatable value table.
      UPDATE Ego_Flex_Value_Tl_Intf
      SET process_status=G_ERROR_RECORD
      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND Upper(transaction_type) NOT IN (G_CREATE, G_UPDATE,G_SYNC);

      write_debug(G_PKG_Name,l_api_name,' End of API  ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API  ');

  EXCEPTION
      WHEN OTHERS THEN

          write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error :  '||SQLERRM);
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In Exception of API. Error :  '||SQLERRM);
          x_return_status := G_RET_STS_UNEXP_ERROR;
          x_return_msg := G_PKG_Name||'.'||l_api_name||'  - '||SQLERRM;
   	      RETURN;

  END Validate_Transaction_type;





  -- Bug 9804379
  --------------------------------------------------------------------------------
  -- Procedure to sync draft version with latest release version of a value set.
  -------------------------------------------------------------------------------
  PROCEDURE Sync_VS_With_Draft ( p_value_set_id      IN NUMBER
                                ,p_version_number    IN NUMBER
                                ,x_return_status     OUT NOCOPY VARCHAR2
                                ,x_return_msg        OUT NOCOPY VARCHAR2)
  IS


      CURSOR Sync_Draft
      IS
          SELECT flex_value_id,SEQUENCE
          FROM ego_flex_value_version_b
          WHERE version_seq_id = p_version_number
            AND flex_value_set_id = p_value_set_id;

      l_api_name                      VARCHAR2(100) := 'Sync_VS_With_Draft';
      DraftRec          Sync_Draft%rowtype;

  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API  ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API  ');


      DELETE FROM  EGO_FLEX_VALUE_VERSION_TL
      WHERE VERSION_SEQ_ID =0
        AND FLEX_VALUE_ID IN  ( SELECT FLEX_VALUE_ID
                                FROM EGO_FLEX_VALUE_VERSION_B
                                WHERE FLEX_VALUE_SET_ID =P_VALUE_SET_ID
                                  AND VERSION_SEQ_ID = 0);

      DELETE FROM EGO_FLEX_VALUE_VERSION_B
      WHERE FLEX_VALUE_SET_ID =P_VALUE_SET_ID
        AND VERSION_SEQ_ID = 0;



      OPEN Sync_Draft;
      LOOP

          FETCH Sync_Draft INTO DraftRec;
          EXIT WHEN  Sync_Draft%NOTFOUND;

          INSERT INTO EGO_FLEX_VALUE_VERSION_B
                  ( FLEX_VALUE_SET_ID,FLEX_VALUE_ID,VERSION_SEQ_ID,SEQUENCE,CREATED_BY,
                    CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
          VALUES  ( P_VALUE_SET_ID,DraftRec.FLEX_VALUE_ID,0,DraftRec.SEQUENCE,FND_GLOBAL.PARTY_ID,
                    SYSDATE,FND_GLOBAL.PARTY_ID,SYSDATE,FND_GLOBAL.LOGIN_ID );


      END LOOP;
      CLOSE Sync_Draft;


      INSERT INTO EGO_FLEX_VALUE_VERSION_TL
                  ( FLEX_VALUE_ID,VERSION_SEQ_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,
                    LAST_UPDATE_LOGIN,DESCRIPTION,FLEX_VALUE_MEANING,LANGUAGE,SOURCE_LANG)

              SELECT FLEX_VALUE_ID,0,SYSDATE,FND_GLOBAL.PARTY_ID,SYSDATE,FND_GLOBAL.PARTY_ID,
                    FND_GLOBAL.LOGIN_ID,DESCRIPTION,FLEX_VALUE_MEANING,LANGUAGE,SOURCE_LANG FROM EGO_FLEX_VALUE_VERSION_TL
              WHERE VERSION_SEQ_ID = P_VERSION_NUMBER AND FLEX_VALUE_ID
                IN ( SELECT FLEX_VALUE_ID
                    FROM EGO_FLEX_VALUE_VERSION_B
                    WHERE  FLEX_VALUE_SET_ID = P_VALUE_SET_ID
                        AND VERSION_SEQ_ID =  P_VERSION_NUMBER);


      x_return_status :=G_RET_STS_SUCCESS;


      write_debug(G_PKG_Name,l_api_name,' End of API  ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API  ');


  EXCEPTION

      WHEN OTHERS THEN

          write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error :  '||SQLERRM);
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In Exception of API. Error :  '||SQLERRM);
          x_return_status := G_RET_STS_UNEXP_ERROR;
          x_return_msg := G_PKG_Name||'.'||l_api_name||'  - '||SQLERRM;

   	      RETURN;


  END Sync_VS_With_Draft;








  --------------------------------------------------------------------------------
  -- Procedure is to release a value set.
  --------------------------------------------------------------------------------
  PROCEDURE Release_Value_Set_Version(
                    p_value_set_id       IN NUMBER,
                    p_description        IN VARCHAR2,
                    p_start_date         IN TIMESTAMP,
                    p_version_seq_id     IN NUMBER,
                    p_transaction_id     IN NUMBER,
                    x_out_vers_seq_id    OUT NOCOPY NUMBER,
                    x_return_status      OUT NOCOPY VARCHAR2,
                    x_return_msg         OUT NOCOPY VARCHAR2 )
  IS

      --Local variable
      l_api_name                      VARCHAR2(100) := 'Release_Value_Set_Version';
      l_same_rel_date                 NUMBER;
      l_future_effective              BOOLEAN ;
      l_relver_end_date               DATE ;
      l_prev_future_version           NUMBER;
      l_min_start_active_date         DATE ;
      l_return_status                 VARCHAR2(1);
      l_return_msg                    VARCHAR2(1000);

      l_version_seq_id                NUMBER;
      l_min_future_start_date         DATE;
      l_value_set_id                  NUMBER:=p_value_set_id;
      l_description                   VARCHAR2(1000)  :=p_description;
      l_transaction_id	              NUMBER          :=p_transaction_id;


      l_entity_code                   VARCHAR2(40) :=  G_ENTITY_VS_VER;
      l_table_name                    VARCHAR2(240):=  G_ENTITY_VS_HEADER_TAB;
      l_application_id                NUMBER       :=  G_Application_Id;

      l_token_table                   ERROR_HANDLER.Token_Tbl_Type;
      l_error_message_name            VARCHAR2(500);


      l_target_max_ver                NUMBER    :=  NULL ;
      l_draft_exist                   NUMBER    :=  NULL;
      l_draft_version                 BOOLEAN   :=  FALSE;

      l_locking_party_id              NUMBER   :=  NULL ;
      l_lock_flag                     VARCHAR2(1) :=  NULL ;
      l_UnLock                        BOOLEAN;

      CURSOR Getversiondates
      IS
        SELECT start_active_date ,end_active_date,version_seq_id
        FROM ego_flex_valueset_version_b
        WHERE flex_value_set_id =  p_value_set_id AND version_seq_id  <> 0 ;


      -- Cursor to get maximum available version on target instance.
      CURSOR Cur_Max_Ver(cp_value_set_id       NUMBER)
      IS
        SELECT Max(version_seq_id) max_ver --,start_active_date, end_active_date
        FROM ego_flex_valueset_version_b
        WHERE flex_value_set_id = cp_value_set_id
          AND  version_seq_id  <> 0;



      -- Cursor to check if draft version is there.
      CURSOR Cur_Draft_Ver(cp_value_set_id     NUMBER)
      IS
        SELECT (version_seq_id) draft_ver
        FROM ego_flex_valueset_version_b
        WHERE flex_value_set_id = cp_value_set_id
          AND  version_seq_id = 0;




      VersionDate_rec Getversiondates%rowtype;



  BEGIN


        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API  ');
        write_debug(G_PKG_Name,l_api_name,' Start of API  ');



        -- Here we will have start_date either as present date or future effective date
        IF(p_start_date < SYSDATE OR p_start_date IS NULL ) THEN


              write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS Id)=('
                                          ||l_value_set_id||')'||' Passed in start date belongs to past date. ');




              x_return_status               :=  G_RET_STS_ERROR;
              l_error_message_name          := 'EGO_VSET_VERSION_DATE_ERROR';

              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name);

              RETURN;

        END IF ;





        --Validate if Value Set has been released on same Start Date or End date should not be same.
        SELECT COUNT(*) INTO  l_same_rel_date
        FROM EGO_FLEX_VALUESET_VERSION_B
        WHERE FLEX_VALUE_SET_ID = P_VALUE_SET_ID
          AND ( START_ACTIVE_DATE=  P_START_DATE
                OR END_ACTIVE_DATE = P_START_DATE
              )
          AND VERSION_SEQ_ID <>0;




        -- Log an error
        IF(l_same_rel_date > 0) THEN


              write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS Id)=('
                                          ||l_value_set_id||')'||' Value Set has already been released on same Start Date. ');

              x_return_status               :=  G_RET_STS_ERROR;
              l_error_message_name          := 'EGO_VSET_VER_RELDATE_ERROR';
              l_token_table(1).TOKEN_NAME   := 'VALUE_SET_ID';
              l_token_table(1).TOKEN_VALUE  := l_value_set_id;

              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name);

              l_token_table.DELETE;

              RETURN;
        END IF ;




        OPEN Getversiondates;
        LOOP

            FETCH Getversiondates INTO VersionDate_rec;

            EXIT WHEN Getversiondates%NOTFOUND;


            -- Setting Value for l_future_effective.It means if l_future_effective is true than the
            --releasing version  Start active date  falls in between the already released version start active date and
            --end active date.
            IF ( p_start_date >= VersionDate_rec.start_active_date
                  AND ( p_start_date <= VersionDate_rec.end_active_date OR VersionDate_rec.end_active_date IS NULL )
              ) THEN

                  l_future_effective := TRUE;
                  l_prev_future_version := VersionDate_rec.version_seq_id;
                  l_relver_end_date :=   VersionDate_rec.end_active_date;   -- End date of new version to be released

                  EXIT;

            END IF;

        END LOOP;
        CLOSE Getversiondates;



        -- Get Max Version at target system
        FOR i IN Cur_Max_Ver (p_value_set_id)
        LOOP
            l_target_max_ver  :=  i.max_ver;

        END LOOP;



        -- Check if draft version exist
        FOR i IN Cur_Draft_Ver (p_value_set_id)
        LOOP

            l_draft_exist  :=  i.draft_ver;

        END LOOP;



        -- If No version record exist then set l_draft_version to true to create draft record
        IF l_draft_exist IS NULL
        THEN

            l_draft_version :=  TRUE;

        END IF;






        IF l_draft_version THEN

            write_debug(G_PKG_Name,l_api_name,' Creating draft Version ');
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Creating draft Version G_Party_id = '||G_Party_id);

            -- Create record for draft version with sysdate as start date
            INSERT INTO EGO_FLEX_VALUESET_VERSION_B
                    (flex_value_set_id,version_seq_id,description, start_active_date, end_active_date ,
                    created_by,creation_date,last_updated_by,last_update_date,last_update_login)
            VALUES  ( l_value_set_id, 0, l_description, SYSDATE, NULL,
                      G_Party_Id,SYSDATE,G_Party_Id,SYSDATE,G_Login_Id);


            -- Inserting record in lock table to lock the record.
            -- Need to see if I need to insert it.
            INSERT INTO  EGO_OBJECT_LOCK
                        ( LOCK_ID,OBJECT_NAME,PK1_VALUE,LOCKING_PARTY_ID,LOCK_FLAG,
                          CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
            VALUES      ( EGO_OBJECT_LOCK_S.NEXTVAL,'EGO_VALUE_SET',l_value_set_id,G_Party_id,'L',
                          G_Party_id,SYSDATE,G_Party_id,SYSDATE,G_Login_Id)   ;

            write_debug(G_PKG_Name,l_api_name,' Draft Version created ');
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Draft Version created ');

        END IF; -- END IF l_draft_version THEN


        write_debug(G_PKG_Name,l_api_name,'  Passed in version seq id is :  '||p_version_seq_id||' Start Date is : '||To_Char(p_start_date,'dd.mm.yyyy hh24:mi:ss'));
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  Passed in version seq id is :  '||p_version_seq_id||' Start Date is : '||To_Char(p_start_date,'dd.mm.yyyy hh24:mi:ss'));


        write_debug(G_PKG_Name,l_api_name,' Version sqe id to be created on target system is :  '||l_target_max_ver);
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  Version sqe id to be created on target system is :  '||l_target_max_ver);








        -- Bug 9804411
        -- Get user who locked this object
        ego_metadata_bulkload_pvt.Get_Lock_Info ( p_object_name       =>  G_OBJECT_VALUE_SET,
                                                  p_pk1_value         =>  l_value_set_id,
                                                  x_locking_party_id  =>  l_locking_party_id,
                                                  x_lock_flag         =>  l_lock_flag,
                                                  x_return_msg        =>  l_return_msg,
                                                  x_return_status     =>  l_return_status);


        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Locking Party is : '||l_locking_party_id);
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' After calling to Get_Lock_Info. return status is : '||l_return_status);

        IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS ) THEN

            l_return_status                     := G_RET_STS_SUCCESS;

        ELSIF (l_return_status = G_RET_STS_ERROR ) THEN


            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS Id)=('
                                      ||l_value_set_id||')'||' Error in getting lock information. ');



            x_return_status             := l_return_status;

		        G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
            G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS_VER;
            G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
            G_TOKEN_TBL(2).Token_Value  :=  G_CREATE;
            G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
            G_TOKEN_TBL(3).Token_Value  :=  'EGO_VS_BULKLOAD_PVT';
            G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
            G_TOKEN_TBL(4).Token_Value  :=  'Get_Lock_Info';


            ERROR_HANDLER.Add_Error_Message (
              p_message_name                   => 'EGO_ENTITY_API_FAILED'
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => G_TOKEN_TBL
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => G_ENTITY_VS_VER
              ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

            G_TOKEN_TBL.DELETE;


        ELSE    -- case of unexpected error

            x_return_status := G_RET_STS_UNEXP_ERROR;
            x_return_msg    := l_return_msg;
            RETURN;

        END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN

        -- Bug 9804411
        -- If creation of version failed then do not process value entity further.
        IF l_return_status = G_RET_STS_SUCCESS THEN

              -- Check if same user locked record
              IF l_lock_flag = 'L'  AND Nvl(l_locking_party_id,G_Party_Id)  <> G_Party_Id THEN

                    ego_metadata_bulkload_pvt.Get_Party_Name (  p_party_id    =>  l_locking_party_id,
                                                                x_party_name  =>  G_Locking_Party_Name);

                    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' This Value Set is locked by some other user.'||G_Locking_Party_Name);
                    write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS Id)=('
                                                ||l_value_set_id||')'||' This Value Set is locked by some other user. ');

                    l_return_status               :=  G_RET_STS_ERROR;
                    l_error_message_name          := 'EGO_ENTITY_LOCKED';
                    l_token_table(1).TOKEN_NAME   := 'ENTITY_NAME';
                    l_token_table(1).TOKEN_VALUE  := G_ENTITY_VS;

                    l_token_table(2).TOKEN_NAME   := 'PARTY_NAME';
                    l_token_table(2).TOKEN_VALUE  := G_Locking_Party_Name;


                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                   => l_error_message_name
                      ,p_application_id                => G_App_Short_Name
                      ,p_token_tbl                     => l_token_table
                      ,p_message_type                  => G_RET_STS_ERROR
                      ,p_row_identifier                => l_transaction_id
                      ,p_entity_code                   => l_entity_code
                      ,p_table_name                    => l_table_name);

                    l_token_table.DELETE;



              END IF;



              IF l_return_status = G_RET_STS_SUCCESS THEN
              -- Bug 9804411


                    IF(l_future_effective) THEN

                        Update ego_flex_valueset_version_b
                        SET end_active_date= p_start_date-1/(24*60*60),
                            LAST_UPDATED_BY= G_Party_Id,
                            LAST_UPDATE_DATE = SYSDATE,
                            LAST_UPDATE_LOGIN = G_LOGIN_ID
                        WHERE flex_value_set_id = p_value_set_id
                          AND version_seq_id= l_prev_future_version;


                        -- need to decide which version we need to insert, same as user passed of l_target_max_ver+1
                        INSERT INTO EGO_FLEX_VALUESET_VERSION_B
                                (flex_value_set_id, version_seq_id,description, start_active_date,end_active_date,
                                created_by,creation_date,last_updated_by,last_update_date,last_update_login)
                        VALUES (l_value_set_id, Nvl(l_target_max_ver,0)+1,l_description, p_start_date,l_relver_end_date,
                                G_Party_Id,sysdate,G_Party_Id,sysdate,G_Login_id)   ;


                    -- Case when we already have version released in future and all of them have start date greater then passed in date
                    ELSE

                        -- Get least future effective start active date which is higher then passed in date
                        SELECT Min(start_active_date ) INTO l_min_future_start_date
                        FROM  EGO_FLEX_VALUESET_VERSION_B
                        WHERE   FLEX_VALUE_SET_ID =  p_value_set_id
                          AND version_seq_id >0;

                        -- This is the case where passed in start date will always be greater than all available version
                        IF ( l_min_future_start_date < p_start_date) THEN


                          Update ego_flex_valueset_version_b
                          SET end_active_date= p_start_date-1/(24*60*60),
                              LAST_UPDATED_BY= G_Party_Id,
                              LAST_UPDATE_DATE = SYSDATE,
                              LAST_UPDATE_LOGIN = G_LOGIN_ID
                          WHERE flex_value_set_id = p_value_set_id
                            AND (start_active_date =( SELECT Max(start_active_date )
                                                      FROM ego_flex_valueset_version_b
                                                      WHERE flex_value_set_id =  p_value_set_id
                                                        AND version_seq_id >0
                                                    )
                                );

                      END IF;


                      -- Create a new version
                      INSERT INTO EGO_FLEX_VALUESET_VERSION_B
                              (flex_value_set_id, version_seq_id,description, start_active_date,end_active_date,
                              created_by,creation_date,last_updated_by,last_update_date,last_update_login)
                      VALUES (l_value_set_id, Nvl(l_target_max_ver,0)+1,l_description, p_start_date,NULL ,
                              G_Party_Id,sysdate,G_Party_Id,sysdate,G_Login_id)   ;


                      -- This is the case where passed in start date will always be lesser than all available version
                      IF ( p_start_date< l_min_future_start_date)  THEN

                          Update ego_flex_valueset_version_b
                          SET end_active_date= l_min_future_start_date-1/(24*60*60),
                              LAST_UPDATED_BY= G_Party_Id,
                              LAST_UPDATE_DATE = SYSDATE,
                              LAST_UPDATE_LOGIN = G_LOGIN_ID
                          WHERE flex_value_set_id = p_value_set_id
                            AND start_active_date = p_start_date ;

                      END IF ;

                    END IF; -- END IF(l_future_effective) THEN



                    IF l_lock_flag = 'U' THEN

                      l_UnLock := TRUE;

                    ELSE

                      l_UnLock := FALSE;

                    END IF;


                    -- Bug 9804411
                    -- Insert/update a record into ego_object_lock based on status of lock flag.
                    ego_metadata_bulkload_pvt.Lock_Unlock_Object  ( p_object_name       =>  G_OBJECT_VALUE_SET,
                                                                    p_pk1_value         =>  l_value_set_id,
                                                                    p_party_id          =>  G_PARTY_ID,
                                                                    p_lock_flag         =>  l_UnLock,
                                                                    -- If current lock_flag is 'U' then insert a new rec with 'U' else update current rec with 'U'
                                                                    x_return_msg        =>  l_return_msg,
                                                                    x_return_status     =>  l_return_status);


                    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  After Call to  Lock_Unlock_Object. Return status is '||l_return_status);

                    IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS ) THEN

                        l_return_status                     := G_RET_STS_SUCCESS;

                    ELSIF (l_return_status = G_RET_STS_ERROR ) THEN


                        write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS Id)=('
                                                  ||l_value_set_id||')'||' Error in setting lock. ');


                        x_return_status             := l_return_status;

		                    G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                        G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS_VER;
                        G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                        G_TOKEN_TBL(2).Token_Value  :=  G_CREATE;
                        G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                        G_TOKEN_TBL(3).Token_Value  :=  'EGO_VS_BULKLOAD_PVT';
                        G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                        G_TOKEN_TBL(4).Token_Value  :=  'Lock_Unlock_Object';


                        ERROR_HANDLER.Add_Error_Message (
                          p_message_name                   => 'EGO_ENTITY_API_FAILED'
                          ,p_application_id                => G_App_Short_Name
                          ,p_token_tbl                     => G_TOKEN_TBL
                          ,p_message_type                  => G_RET_STS_ERROR
                          ,p_row_identifier                => l_transaction_id
                          ,p_entity_code                   => G_ENTITY_VS_VER
                          ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

                        G_TOKEN_TBL.DELETE;


                    ELSE    -- case of unexpected error

                        x_return_status := G_RET_STS_UNEXP_ERROR;
                        x_return_msg    := l_return_msg;
                        RETURN;

                    END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN



              END IF;   -- Bug 9804411

        END IF;         -- Bug 9804411


        x_out_vers_seq_id   :=   Nvl(l_target_max_ver,0)+1;

        write_debug(G_PKG_Name,l_api_name,' Version seq id to be created on target system is  = '||x_out_vers_seq_id );
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Version seq id to be created on target system is = '||x_out_vers_seq_id );

        write_debug(G_PKG_Name,l_api_name,' End of API  ');
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API  ');

        -- Set return status finally.
        IF l_return_status IS NULL
        THEN
            l_return_status    := G_RET_STS_SUCCESS;
        END IF;
        x_return_status :=  l_return_status;




  EXCEPTION
        WHEN OTHERS THEN

            write_debug(G_PKG_Name,l_api_name,' In Exception of API Release_Value_Set_Version. Error : '||SubStr(SQLERRM,1,500));
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In Exception of API Release_Value_Set_Version. Error : '||SubStr(SQLERRM,1,500));

            x_return_status := G_RET_STS_UNEXP_ERROR;
            x_return_msg := G_PKG_Name||'.'||l_api_name||'  - '||SQLERRM;
   	        --RETURN;

  END Release_Value_Set_Version;





  --------------------------------------------------------------------------------
  -- Procedure to get key value for a given value set.
  --------------------------------------------------------------------------------
  PROCEDURE Get_Key_VS_Columns
            ( p_value_set_id        IN                NUMBER,
              p_transaction_id      IN                NUMBER,
              x_maximum_size        IN OUT  NOCOPY    VARCHAR2,
              x_maximum_value       IN OUT  NOCOPY    VARCHAR2,
              x_minimum_value       IN OUT  NOCOPY    VARCHAR2,
              x_description         IN OUT  NOCOPY    VARCHAR2,
              x_longlist_flag       IN OUT  NOCOPY    VARCHAR2,
              x_format_code         IN OUT  NOCOPY    VARCHAR2,
              x_validation_code     IN OUT  NOCOPY    VARCHAR2,
              x_return_status       OUT     NOCOPY    VARCHAR2,
              x_return_msg          OUT     NOCOPY    VARCHAR2
            )
  IS


          l_api_name            VARCHAR2(100) := 'Get_Key_VS_Columns';
          l_value_set_id        NUMBER        :=  p_value_set_id;
          l_value_set_name      VARCHAR2(60)  :=  NULL;
          l_validation_code     VARCHAR2(1)   :=  NULL;
          l_longlist_flag       VARCHAR2(1)   :=  NULL;
          l_format_code         VARCHAR2(1)   :=  NULL;
          l_transaction_id	    NUMBER        :=  p_transaction_id;

          /* Local variable to be used in error handling mechanism*/
          l_entity_code         VARCHAR2(40)  :=  G_ENTITY_VS;
          l_table_name          VARCHAR2(240) :=  G_ENTITY_VS_HEADER_TAB;
          l_application_id      NUMBER        :=  G_Application_Id;

          l_token_table         ERROR_HANDLER.Token_Tbl_Type;
          l_error_message_name  VARCHAR2(500);


          CURSOR cur_value
          IS
          SELECT validation_type, format_type, maximum_value,minimum_value,longlist_flag,maximum_size,description
          FROM fnd_flex_value_sets
          WHERE flex_value_set_id = p_value_set_id;


          CURSOR cur_value_set_name
          IS
          SELECT flex_value_set_name
          FROM fnd_flex_value_sets
          WHERE flex_value_set_id = p_value_set_id;


  BEGIN

        write_debug(G_PKG_Name,l_api_name,' Start of API  ');

        FOR Cur_VSName IN cur_value_set_name
        LOOP
            l_value_set_name :=Cur_VSName.flex_value_set_name;

        END LOOP;

        FOR i IN cur_value
        LOOP


            l_format_code       :=  i.format_type;
            l_validation_code   :=  i.validation_type;
            l_longlist_flag     :=  i.longlist_flag;


            IF x_format_code IS NULL THEN
              x_format_code       :=  i.format_type;
            END IF;

            IF x_validation_code IS NULL THEN
              x_validation_code   :=  i.validation_type;
            END IF; -- END IF x_validation_code IS NULL THEN


            IF x_longlist_flag IS NULL THEN
              x_longlist_flag :=  i.longlist_flag;
            END IF;

            -- User can pass null value as well.
            IF x_description IS NULL THEN
              x_description :=  i.description;
            END IF;

            -- Get maximum size. It will always be greater than zero.
            -- Updateable only for NUMBER and CHAR type
            IF  x_format_code IN (  G_NUMBER_DATA_TYPE,G_CHAR_DATA_TYPE) THEN

                IF x_maximum_size IS NULL THEN
                  x_maximum_size :=  i.maximum_size;
                END IF;

            END IF; -- END IF  x_format_code IN (  G_NUMBER_DATA_TYPE,G_CHAR_DATA_TYPE) THEN


            -- Max/ Min value only for NONE type VS and data type not in char
            IF  (x_format_code IN (  G_NUMBER_DATA_TYPE,G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE )
                    AND x_validation_code= G_NONE_VALIDATION_CODE
                ) THEN


                IF x_maximum_value IS NULL THEN
                    x_maximum_value :=  i.maximum_value;
                END IF;


                IF x_minimum_value IS NULL THEN
                    x_minimum_value :=  i.minimum_value;
                END IF;


            END IF;

        END LOOP;


        IF l_format_code <> x_format_code THEN


            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS Id)=('
                                        ||l_value_set_id||')'||' Pass correct data type for value set. ');



            l_error_message_name          := 'EGO_VSET_DATA_TYPE_ERROR';
            x_return_status               := G_RET_STS_ERROR;

            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
            l_token_table(1).TOKEN_VALUE  := l_value_set_name;


            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name);


            l_token_table.DELETE;


        END IF;



        IF l_validation_code <> x_validation_code THEN

            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS Id)=('
                                        ||l_value_set_id||')'||' Pass correct validation code for value set. ');


            l_error_message_name          := 'EGO_VSET_VALIDATION_ERROR';
            x_return_status               := G_RET_STS_ERROR;
            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
            l_token_table(1).TOKEN_VALUE  := l_value_set_name;


            ERROR_HANDLER.Add_Error_Message(
               p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name);

            l_token_table.DELETE;

        END IF;




        IF l_longlist_flag  <> x_longlist_flag THEN

            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS Id)=('
                                        ||l_value_set_id||')'||' Pass correct longlist flag for value set. ');

            l_error_message_name          := 'EGO_VSET_LONGLIST_ERROR';
            x_return_status               := G_RET_STS_ERROR;


            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
            l_token_table(1).TOKEN_VALUE  := l_value_set_name;

            ERROR_HANDLER.Add_Error_Message(
               p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

            l_token_table.DELETE;

        END IF;


        -- Bug 9702845
        --This code is written in validate_value_set API thus not writing again.
        /*IF  (x_format_code IN (  G_NUMBER_DATA_TYPE,G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE )
                            AND x_validation_code= G_NONE_VALIDATION_CODE
                        ) THEN


                IF x_maximum_value < x_minimum_value  THEN


                    write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS Id)=('
                                                ||l_value_set_id||')'||' Maximum value should always be greater than minimum value. ');



                    l_error_message_name          := 'EGO_VAL_MUST_LT_MAXVALUE';
                    x_return_status               := G_RET_STS_ERROR;

                    l_token_table(1).TOKEN_NAME   := 'MAXVALUE';
                    l_token_table(1).TOKEN_VALUE  := x_maximum_value;


                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                  => l_error_message_name
                      ,p_application_id                => G_App_Short_Name
                      ,p_token_tbl                     => l_token_table
                      ,p_message_type                  => G_RET_STS_ERROR
                      ,p_row_identifier                => l_transaction_id
                      ,p_entity_code                   => l_entity_code
                      ,p_table_name                    => l_table_name);


                    l_token_table.DELETE;


                END IF;

        END IF;-- END IF  (x_format_code IN (  G_NUMBER_DATA_TYPE,G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE )
        */


        IF x_return_status IS NULL THEN
            x_return_status	:=	G_RET_STS_SUCCESS;
        END IF; --

        write_debug(G_PKG_Name,l_api_name,' End of API  x_return_status = '||x_return_status);


  EXCEPTION

        WHEN OTHERS THEN
            write_debug(G_PKG_Name,l_api_name,' In Exception of API Get_Key_VS_Columns ');
            x_return_status := G_RET_STS_UNEXP_ERROR;
            x_return_msg := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	        RETURN;

  END Get_Key_VS_Columns;




  --------------------------------------------------------------------------------
  -- Procedure to get key value for a given value of a value set.
  --------------------------------------------------------------------------------
  PROCEDURE Get_Key_Value_Columns
            ( p_value_set_id        IN                NUMBER,
              p_value_id            IN                NUMBER,
              x_display_name        IN OUT  NOCOPY    VARCHAR2,
              x_disp_sequence       IN OUT  NOCOPY    NUMBER,
              x_start_date_active   IN OUT  NOCOPY    VARCHAR2,
              x_end_date_active     IN OUT  NOCOPY    VARCHAR2,
              x_description         IN OUT  NOCOPY    VARCHAR2,
              x_enabled_flag        IN OUT  NOCOPY    VARCHAR2,
              x_return_status       OUT     NOCOPY    VARCHAR2,
              x_return_msg          OUT     NOCOPY    VARCHAR2
            )
  IS


        l_api_name          VARCHAR2(100) := 'Get_Key_Value_Columns';

        CURSOR Cur_Value
        IS
        SELECT FLEX_VALUE_MEANING,DESCRIPTION, START_DATE_ACTIVE,END_DATE_ACTIVE, ENABLED_FLAG
        FROM FND_FLEX_VALUES ,FND_FLEX_VALUES_TL
        WHERE  FND_FLEX_VALUES.flex_value_set_id = p_value_set_id
          AND FND_FLEX_VALUES.FLEX_VALUE_ID = p_value_id
          AND FND_FLEX_VALUES.FLEX_VALUE_ID = FND_FLEX_VALUES_TL.FLEX_VALUE_ID
          AND LANGUAGE = userenv('LANG')
          AND ROWNUM=1;




        -- Cursor to get display sequence.
        CURSOR c_get_disp_sequence (cp_flex_value_id  IN  NUMBER)
        IS
        SELECT disp_sequence
        FROM ego_vs_values_disp_order
        WHERE value_set_value_id = cp_flex_value_id;


  BEGIN

        write_debug(G_PKG_Name,l_api_name,' Start of API  ');

        FOR i IN cur_value
        LOOP

            IF x_display_name IS NULL THEN
              x_display_name :=  i.FLEX_VALUE_MEANING;
            END IF;

            -- User can pass null value as well.
            IF x_description IS NULL THEN
              x_description :=  i.description;
            END IF;


            IF x_start_date_active IS NULL THEN
                x_start_date_active :=  i.start_date_active;
            END IF; -- END IF


            IF x_end_date_active IS NULL THEN
                x_end_date_active :=  i.end_date_active;
            END IF; -- END IF

            -- User can pass null value as well.
            IF x_enabled_flag IS NULL THEN
              x_enabled_flag :=  i.enabled_flag;
            END IF;

        END LOOP;



        IF x_disp_sequence IS NULL THEN
            FOR Disp_Seq IN   c_get_disp_sequence (p_value_id)
            LOOP

              x_disp_sequence :=  Disp_Seq.disp_sequence;

            END LOOP; -- END FOR Disp_Seq IN   c_get_disp_sequence (p_value_id)

        END IF; -- END IF x_disp_sequence IS NULL THEN



        IF x_return_status IS NULL THEN
          x_return_status	:=	G_RET_STS_SUCCESS;
        END IF; -- END IF x_return_status IS NULL THEN


        write_debug(G_PKG_Name,l_api_name,' End of API  x_return_status = '||x_return_status);
        --Dbms_Output.put_line(G_PKG_NAME||'.'||l_api_name||'  End of API  x_return_status = '||x_return_status);



  EXCEPTION
        WHEN OTHERS THEN
            write_debug(G_PKG_Name,l_api_name,' In Exception of API Get_Key_Value_Columns '||SubStr(SQLERRM,1,500) );
            --Dbms_Output.put_line(G_PKG_NAME||'.'||l_api_name||'   In Exception of API Get_Key_Value_Columns '||SubStr(SQLERRM,1,500) );

            x_return_status := G_RET_STS_UNEXP_ERROR;
            x_return_msg := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	        RETURN;

  END Get_Key_Value_Columns;






  --------------------------------------------------------------------------------
  -- Procedure to populate data back to value set interface table.
  --------------------------------------------------------------------------------
  PROCEDURE Populate_VS_Interface ( p_valueset_tbl    IN          Ego_Metadata_Pub.Value_Set_Tbl,
                                    x_return_status   OUT NOCOPY  VARCHAR2,
                                    x_return_msg      OUT NOCOPY  VARCHAR2)
  IS

      l_api_name       VARCHAR2(100) := 'Populate_VS_Interface';
      l_trans_id       Dbms_Sql.number_table;

  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API. Count of record is   '||p_valueset_tbl.Count );
      --Dbms_Output.put_line(G_PKG_NAME||'.'||l_api_name||'   Start of API. Count of record is   '||p_valueset_tbl.Count );



      FOR i IN p_valueset_tbl.FIRST..p_valueset_tbl.LAST
      LOOP

          l_trans_id(i) := p_valueset_tbl(i).transaction_id;

      END LOOP;



      FORALL i IN p_valueset_tbl.first..p_valueset_tbl.last
        UPDATE Ego_Flex_Value_Set_Intf
        SET ROW = p_valueset_tbl(i)
        WHERE transaction_id = l_trans_id(i);




      /*FORALL i IN p_valueset_tbl.first..p_valueset_tbl.last
          UPDATE Ego_Flex_Value_Set_Intf
          SET value_set_id              =  p_valueset_tbl(i).value_set_id,
              value_set_name            =  p_valueset_tbl(i).value_set_name,
              description               =  p_valueset_tbl(i).description,
              version_description       =  p_valueset_tbl(i).version_description,
              format_type               =  p_valueset_tbl(i).format_type,
              longlist_flag             =  p_valueset_tbl(i).longlist_flag,
              validation_type           =  p_valueset_tbl(i).validation_type,
              parent_value_set_name     =  p_valueset_tbl(i).parent_value_set_name,
              version_seq_id            =  p_valueset_tbl(i).version_seq_id,
              start_active_date         =  p_valueset_tbl(i).start_active_date,
              end_active_date           =  p_valueset_tbl(i).end_active_date,
              maximum_size              =  p_valueset_tbl(i).maximum_size,
              minimum_value             =  p_valueset_tbl(i).minimum_value,
              maximum_value             =  p_valueset_tbl(i).maximum_value,
              value_column_name         =  p_valueset_tbl(i).value_column_name,
              value_column_type         =  p_valueset_tbl(i).value_column_type,
              value_column_size         =  p_valueset_tbl(i).value_column_size,
              id_column_name            =  p_valueset_tbl(i).id_column_name,
              id_column_size            =  p_valueset_tbl(i).id_column_size,
              id_column_type            =  p_valueset_tbl(i).id_column_type,
              meaning_column_name       =  p_valueset_tbl(i).meaning_column_name,
              meaning_column_size       =  p_valueset_tbl(i).meaning_column_size,
              meaning_column_type       =  p_valueset_tbl(i).meaning_column_type,
              table_application_id      =  p_valueset_tbl(i).table_application_id,
              application_table_name    =  p_valueset_tbl(i).application_table_name,
              additional_where_clause   =  p_valueset_tbl(i).additional_where_clause,
              transaction_type          =  p_valueset_tbl(i).transaction_type,
              --transaction_id            =  p_valueset_tbl(i).transaction_id,
              process_status            =  p_valueset_tbl(i).process_status,
              set_process_id            =  p_valueset_tbl(i).set_process_id,
              request_id                =  p_valueset_tbl(i).request_id,
              program_application_id    =  p_valueset_tbl(i).request_id,
              program_id                =  p_valueset_tbl(i).program_application_id,
              program_update_date       =  p_valueset_tbl(i).program_update_date,
              last_update_date          =  p_valueset_tbl(i).last_update_date,
              last_updated_by           =  p_valueset_tbl(i).last_updated_by,
              creation_date             =  p_valueset_tbl(i).creation_date,
              created_by                =  p_valueset_tbl(i).created_by,
              last_update_login         =  p_valueset_tbl(i).last_update_login

      WHERE process_status  = G_PROCESS_RECORD
        AND transaction_id = p_valueset_tbl(i).transaction_id;  */


      write_debug(G_PKG_Name,l_api_name,' End of API  ');
      --Dbms_Output.put_line(G_PKG_NAME||'.'||l_api_name||' End of API  ');



      IF x_return_status IS NULL THEN
        x_return_status	:=	G_RET_STS_SUCCESS;
      END IF; -- END IF x_return_status IS NULL THEN


  EXCEPTION
      WHEN OTHERS THEN
          write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
          --Dbms_Output.put_line(G_PKG_NAME||'.'||l_api_name||' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );

          x_return_status := G_RET_STS_UNEXP_ERROR;
          x_return_msg := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	      RETURN;
  END Populate_VS_Interface;








  --------------------------------------------------------------------------------
  -- Procedure to populate data back to value interface table.
  --------------------------------------------------------------------------------

  PROCEDURE Populate_VS_Val_Interface ( p_valueset_val_tbl    IN          Ego_Metadata_Pub.Value_Set_Value_Tbl,
                                        x_return_status      OUT NOCOPY  VARCHAR2,
                                        x_return_msg         OUT NOCOPY  VARCHAR2)
  IS

      l_api_name       VARCHAR2(100) := 'Populate_VS_Val_Interface';
      l_trans_id       Dbms_Sql.number_table;

  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API. Count of passed in table  p_valueset_val_tbl = '||p_valueset_val_tbl.Count);
      --Dbms_Output.put_line(G_PKG_NAME||'.'||l_api_name||'  Start of API. Count of passed in table  p_valueset_val_tbl = '||p_valueset_val_tbl.Count);


      FOR i IN p_valueset_val_tbl.FIRST..p_valueset_val_tbl.LAST
      LOOP

          l_trans_id(i) := p_valueset_val_tbl(i).transaction_id;

      END LOOP;



      FORALL i IN p_valueset_val_tbl.first..p_valueset_val_tbl.last
        UPDATE Ego_Flex_Value_Intf
        SET ROW = p_valueset_val_tbl(i)
        WHERE transaction_id = l_trans_id(i);




      /*FORALL i IN p_valueset_val_tbl.first..p_valueset_val_tbl.last

          UPDATE Ego_Flex_Value_Intf
          SET value_set_id              =  p_valueset_val_tbl(i).value_set_id,
              value_set_name            =  p_valueset_val_tbl(i).value_set_name,
              flex_value                =  p_valueset_val_tbl(i).flex_value,
              flex_value_id             =  p_valueset_val_tbl(i).flex_value_id,
              version_seq_id            =  p_valueset_val_tbl(i).version_seq_id,
              disp_sequence             =  p_valueset_val_tbl(i).disp_sequence,
              start_active_date         =  p_valueset_val_tbl(i).start_active_date,
              end_active_date           =  p_valueset_val_tbl(i).end_active_date,
              enabled_flag              =  p_valueset_val_tbl(i).enabled_flag,

              transaction_type          =  p_valueset_val_tbl(i).transaction_type,
              --transaction_id            =  p_valueset_val_tbl(i).transaction_id,

              process_status            =  p_valueset_val_tbl(i).process_status,
              set_process_id            =  p_valueset_val_tbl(i).set_process_id,

              request_id                =  p_valueset_val_tbl(i).request_id,
              program_application_id    =  p_valueset_val_tbl(i).request_id,
              program_id                =  p_valueset_val_tbl(i).program_application_id,
              program_update_date       =  p_valueset_val_tbl(i).program_update_date,

              last_update_date          =  p_valueset_val_tbl(i).last_update_date,
              last_updated_by           =  p_valueset_val_tbl(i).last_updated_by,
              creation_date             =  p_valueset_val_tbl(i).creation_date,
              created_by                =  p_valueset_val_tbl(i).created_by,
              last_update_login         =  p_valueset_val_tbl(i).last_update_login

          WHERE process_status  = G_PROCESS_RECORD
            AND transaction_id  = p_valueset_val_tbl(i).transaction_id;*/

        write_debug(G_PKG_Name,l_api_name,' End of API Populate_VS_Val_Interface ');
        --Dbms_Output.put_line(G_PKG_NAME||'.'||l_api_name||'  End of API Populate_VS_Val_Interface ');

  EXCEPTION

        WHEN OTHERS THEN
            write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
            --Dbms_Output.put_line(G_PKG_NAME||'.'||l_api_name||' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );

            x_return_status := G_RET_STS_UNEXP_ERROR;
            x_return_msg := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	        RETURN;

  END Populate_VS_Val_Interface;







  --------------------------------------------------------------------------------
  -- Procedure to populate data back to value interface table.
  --------------------------------------------------------------------------------
  PROCEDURE Populate_VS_Val_Tl_Interface (p_valueset_val_tl_tbl     IN          Ego_Metadata_Pub.Value_Set_Value_Tl_Tbl,
                                          x_return_status           OUT NOCOPY  VARCHAR2,
                                          x_return_msg              OUT NOCOPY  VARCHAR2)
  IS

      l_api_name       VARCHAR2(100) := 'Populate_VS_Val_Tl_Interface';
      l_trans_id       Dbms_Sql.number_table;

  BEGIN

      write_debug(G_PKG_Name,l_api_name,' Start of API. Count of passed in table p_valueset_val_tl_tbl :  '||p_valueset_val_tl_tbl.Count);
      --Dbms_Output.put_line(G_PKG_NAME||'.'||l_api_name||' Start of API. Count of passed in table p_valueset_val_tl_tbl :  '||p_valueset_val_tl_tbl.Count);



      FOR i IN p_valueset_val_tl_tbl.FIRST..p_valueset_val_tl_tbl.LAST
      LOOP

          l_trans_id(i) := p_valueset_val_tl_tbl(i).transaction_id;

      END LOOP;



      FORALL i IN p_valueset_val_tl_tbl.first..p_valueset_val_tl_tbl.last
        UPDATE Ego_Flex_Value_Tl_Intf
        SET ROW = p_valueset_val_tl_tbl(i)
        WHERE transaction_id = l_trans_id(i);





      /*FORALL i IN p_valueset_val_tl_tbl.first..p_valueset_val_tl_tbl.last
        UPDATE Ego_Flex_Value_Tl_Intf
        SET value_set_id              =  p_valueset_val_tl_tbl(i).value_set_id,
            value_set_name            =  p_valueset_val_tl_tbl(i).value_set_name,
            flex_value                =  p_valueset_val_tl_tbl(i).flex_value,
            flex_value_id             =  p_valueset_val_tl_tbl(i).flex_value_id,
            version_seq_id            =  p_valueset_val_tl_tbl(i).version_seq_id,

            "LANGUAGE"                =  p_valueset_val_tl_tbl(i).LANGUAGE,
            description               =  p_valueset_val_tl_tbl(i).description,
            source_lang               =  p_valueset_val_tl_tbl(i).source_lang,
            flex_value_meaning        =  p_valueset_val_tl_tbl(i).flex_value_meaning,

            transaction_type          =  p_valueset_val_tl_tbl(i).transaction_type,
            --transaction_id            =  p_valueset_val_tl_tbl(i).transaction_id,

            process_status            =  p_valueset_val_tl_tbl(i).process_status,
            set_process_id            =  p_valueset_val_tl_tbl(i).set_process_id,

            request_id                =  p_valueset_val_tl_tbl(i).request_id,
            program_application_id    =  p_valueset_val_tl_tbl(i).request_id,
            program_id                =  p_valueset_val_tl_tbl(i).program_application_id,
            program_update_date       =  p_valueset_val_tl_tbl(i).program_update_date,

            last_update_date          =  p_valueset_val_tl_tbl(i).last_update_date,
            last_updated_by           =  p_valueset_val_tl_tbl(i).last_updated_by,
            creation_date             =  p_valueset_val_tl_tbl(i).creation_date,
            created_by                =  p_valueset_val_tl_tbl(i).created_by,
            last_update_login         =  p_valueset_val_tl_tbl(i).last_update_login

        WHERE process_status  = G_PROCESS_RECORD
          AND transaction_id  = p_valueset_val_tl_tbl(i).transaction_id;*/


      write_debug(G_PKG_Name,l_api_name,' End of API. ');
      --Dbms_Output.put_line(G_PKG_NAME||'.'||l_api_name||' End of API. ');

  EXCEPTION
      WHEN OTHERS THEN

          write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
          --Dbms_Output.put_line(G_PKG_NAME||'.'||l_api_name||' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
          x_return_status := G_RET_STS_UNEXP_ERROR;
          x_return_msg := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	      RETURN;

  END Populate_VS_Val_Tl_Interface;






  -------------------------------------------------------------------------------------
  -- Procedure to initialize interface tables.
  -------------------------------------------------------------------------------------
  PROCEDURE Initialize_VS_Interface (
            p_api_version      IN         NUMBER,
            p_set_process_id   IN         NUMBER,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_return_msg       OUT NOCOPY VARCHAR2)
  IS


      l_api_name                VARCHAR2(100) := 'Initialize_VS_Interface';

      TYPE Value_name_Tbl IS TABLE OF EGO_FLEX_VALUE_SET_INTF.value_set_name%TYPE  INDEX BY BINARY_INTEGER;
      l_name_tab                VALUE_NAME_TBL;   --:= value_name_tbl();
      l_err_message_name        VARCHAR2(240);
      l_err_message_text        VARCHAR2(2000);
      l_return_status           VARCHAR2(1);
      l_return_msg              VARCHAR2(1000);



      --Get value set name from interface table.
      CURSOR cur_valueset
      IS
      SELECT value_set_name
      FROM Ego_Flex_Value_Set_Intf
      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND process_status=G_PROCESS_RECORD
        AND transaction_type = G_CREATE;


        --Get value set name from interface table for those which has version as negative .
      CURSOR cur_version_valueset
      IS
      SELECT value_set_name
      FROM Ego_Flex_Value_Set_Intf
      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND process_status=G_PROCESS_RECORD
        AND Nvl(version_seq_id,0)<0;


        --Get child value set name .
      CURSOR cur_child_valueset
      IS
      SELECT value_set_name
      FROM Ego_Flex_Value_Set_Intf
      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND process_status=G_PROCESS_RECORD
        AND parent_value_set_name IS NOT NULL;


  BEGIN


      write_debug(G_PKG_Name,l_api_name,' Start of API  ');



      -- Update value for transaction_id in value set interface table.
      UPDATE Ego_Flex_Value_Set_Intf
      SET  transaction_id   = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL,
          transaction_type = Upper(transaction_type),
          last_updated_by  = G_USER_ID,
          last_update_date =sysdate,
          last_update_login=G_LOGIN_ID,
          created_by       = G_USER_ID,
          creation_date    = SYSDATE,
          request_id       = g_request_id,
          program_application_id = g_prog_appl_id,
          program_id       = g_program_id,
          program_update_date = SYSDATE
      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND transaction_id IS NULL
        AND process_status=G_PROCESS_RECORD;


    -- Update value for transaction_id and transaction_type in value interface table.
      UPDATE Ego_Flex_Value_Intf
      SET  transaction_id   = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL,
          transaction_type = Upper(transaction_type),
          last_updated_by  = G_USER_ID,
          last_update_date =sysdate,
          last_update_login=G_LOGIN_ID,
          created_by       = G_USER_ID,
          creation_date    = SYSDATE,
          request_id       = g_request_id,
          program_application_id = g_prog_appl_id,
          program_id       = g_program_id,
          program_update_date = SYSDATE

      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND transaction_id IS NULL
        --AND Upper(transaction_type) IN (G_CREATE, G_UPDATE, G_Delete,G_SYNC)
        AND process_status=G_PROCESS_RECORD;


      -- Update value for transaction_id in translatable value interface table.
      UPDATE Ego_Flex_Value_Tl_Intf
      SET  transaction_id   = MTL_SYSTEM_ITEMS_INTERFACE_S.NEXTVAL ,
          transaction_type = Upper(transaction_type),
          last_updated_by  = G_USER_ID,
          last_update_date = SYSDATE,
          last_update_login= G_LOGIN_ID ,
          created_by       = G_USER_ID,
          creation_date    = SYSDATE,
          request_id       = g_request_id,
          program_application_id = g_prog_appl_id,
          program_id       = g_program_id,
          program_update_date = SYSDATE

      WHERE (p_set_process_id IS NULL
              OR set_process_id = p_set_process_id
            )
        AND transaction_id IS NULL
        --AND Upper(transaction_type) IN (G_CREATE, G_UPDATE, G_Delete,G_SYNC)
        AND process_status=G_PROCESS_RECORD;



      write_debug(G_PKG_Name,l_api_name,' Call to Resolve_Transaction_Type API. ');

      -- Call procedure to resolve transaction type.
      --Resolve_Transaction_Type(p_set_process_id,l_return_status,l_return_msg);


      --YJ
      -- initialize Application_id
      G_Application_Id  :=  Get_Application_Id();
      -- Initialize party name

      ego_metadata_bulkload_pvt.Get_Party_Name (  p_party_id    =>  G_party_id,
                                                  x_party_name  =>  G_Party_Name);



      -- Check if Telco profile is enabled for version VS.
      write_debug(G_PKG_Name,l_api_name,' Call to Validate_Transaction_Type. ');
      -- Bug 9802900
      Validate_Telco_profile(p_set_process_id,l_return_status,l_return_msg);



      IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS ) THEN

          l_return_status                     := G_RET_STS_SUCCESS;

      ELSIF (l_return_status = G_RET_STS_ERROR ) THEN


          write_debug(G_PKG_Name,l_api_name,' Error in validating Telco Profile. ');
          x_return_status             := l_return_status;

      ELSE    -- case of unexpected error

          x_return_status := G_RET_STS_UNEXP_ERROR;
          x_return_msg    := l_return_msg;
          RETURN;

      END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN






      write_debug(G_PKG_Name,l_api_name,' Call to Validate_Transaction_Type. ');
      -- Call procedure to resolve transaction type.
      Validate_Transaction_Type(p_set_process_id,l_return_status,l_return_msg);



        -- Validation for version seq id
      /*OPEN cur_version_valueset;
      LOOP
        FETCH cur_version_valueset BULK COLLECT INTO l_name_tab limit 2000;
        FORALL i IN 1..l_name_tab.Count
          UPDATE Ego_Flex_Value_Set_Intf                -- Do bulk update
          SET process_status= 3
          WHERE value_set_name=l_name_tab(i);

        EXIT WHEN cur_version_valueset%NOTFOUND;

      END LOOP;
      CLOSE cur_version_valueset;



        -- Validation for child value set validation type
      OPEN cur_child_valueset;
      LOOP
        FETCH cur_child_valueset BULK COLLECT INTO l_name_tab limit 2000;
        FORALL i IN 1..l_name_tab.Count
          UPDATE Ego_Flex_Value_Set_Intf                -- Do bulk update
          SET process_status= 3
          WHERE value_set_name=l_name_tab(i)
            AND validation_type NOT IN (G_TABLE_VALIDATION_CODE);

        EXIT WHEN cur_child_valueset%NOTFOUND;

      END LOOP;
      CLOSE cur_child_valueset;   */

      -- Think of any validation for child value set where parent value set should be in 'I','X'

    write_debug(G_PKG_Name,l_api_name,' End of API  ');

  EXCEPTION
      WHEN OTHERS THEN
          write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
          x_return_status := G_RET_STS_UNEXP_ERROR;
          x_return_msg    := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	      RETURN;


  END Initialize_VS_Interface;  --End of bulk validation API





  -- YJ
  -- Bug 9802900
  PROCEDURE Validate_Telco_profile (p_set_process_id   IN         NUMBER,
                                    x_return_status    OUT NOCOPY VARCHAR2,
                                    x_return_msg       OUT NOCOPY VARCHAR2)

  IS


        l_api_name                VARCHAR2(100) := 'Validate_Telco_profile';
        l_err_message_name        VARCHAR2(240);
        l_err_message_text        VARCHAR2(2000);
        l_return_status           VARCHAR2(1);
        l_return_msg              VARCHAR2(1000);


  BEGIN

        write_debug(G_PKG_Name,l_api_name,' Start of API  ');
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API  ');


        G_P4TP_PROFILE_ENABLED := CASE  FND_PROFILE.VALUE('EGO_ENABLE_P4T')
                                        WHEN 'Y' THEN TRUE
                                        ELSE FALSE
                                  END;




        IF NOT G_P4TP_PROFILE_ENABLED THEN

              l_err_message_name := 'EGO_P4T_PROFILE_DISABLED_ERROR';

              FND_MESSAGE.SET_NAME(G_APPL_NAME,l_err_message_name );
              FND_MESSAGE.SET_TOKEN('ENTITY_NAME' , G_ENTITY_VS_VER);

              l_err_message_text := FND_MESSAGE.GET;




              INSERT
              INTO
                MTL_INTERFACE_ERRORS
                (
                  TRANSACTION_ID,
                  UNIQUE_ID,
                  ORGANIZATION_ID,
                  COLUMN_NAME,
                  TABLE_NAME,
                  MESSAGE_NAME,
                  ERROR_MESSAGE,
                  bo_identifier,
                  ENTITY_IDENTIFIER,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN,
                  REQUEST_ID,
                  PROGRAM_APPLICATION_ID,
                  PROGRAM_ID,
                  PROGRAM_UPDATE_DATE
                )
              SELECT
                evsi.transaction_id,
                MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
                NULL,
                NULL,
                G_ENTITY_VS_HEADER_TAB,
                l_err_message_name,
                l_err_message_text,
                G_BO_IDENTIFIER_VS,
                G_ENTITY_VS_VER,
                NVL(LAST_UPDATE_DATE, SYSDATE),
                NVL(LAST_UPDATED_BY, G_USER_ID),
                NVL(CREATION_DATE,SYSDATE),
                NVL(CREATED_BY, G_USER_ID),
                NVL(LAST_UPDATE_LOGIN, G_LOGIN_ID),
                G_REQUEST_ID,
                NVL(PROGRAM_APPLICATION_ID, G_PROG_APPL_ID),
                NVL(PROGRAM_ID, G_PROGRAM_ID),
                NVL(PROGRAM_UPDATE_DATE, sysdate)
              FROM Ego_Flex_Value_Set_Intf evsi
              WHERE (p_set_process_id IS NULL
                      OR set_process_id = p_set_process_id
                    )
                AND process_status=G_PROCESS_RECORD
                AND version_seq_id IS NOT NULL;



              -- Error out version related records
              UPDATE Ego_Flex_Value_Set_Intf
              SET process_status=G_ERROR_RECORD
              WHERE (p_set_process_id IS NULL
                      OR set_process_id = p_set_process_id
                    )
                AND version_seq_id IS NOT NULL;





              INSERT
              INTO
                MTL_INTERFACE_ERRORS
                (
                  TRANSACTION_ID,
                  UNIQUE_ID,
                  ORGANIZATION_ID,
                  COLUMN_NAME,
                  TABLE_NAME,
                  MESSAGE_NAME,
                  ERROR_MESSAGE,
                  bo_identifier,
                  ENTITY_IDENTIFIER,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN,
                  REQUEST_ID,
                  PROGRAM_APPLICATION_ID,
                  PROGRAM_ID,
                  PROGRAM_UPDATE_DATE
                )
              SELECT
                evsvi.transaction_id,
                MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
                NULL,
                NULL,
                G_ENTITY_VAL_HEADER_TAB,
                l_err_message_name,
                l_err_message_text,
                G_BO_IDENTIFIER_VS,
                G_ENTITY_VS_VER,
                NVL(LAST_UPDATE_DATE, SYSDATE),
                NVL(LAST_UPDATED_BY, G_USER_ID),
                NVL(CREATION_DATE,SYSDATE),
                NVL(CREATED_BY, G_USER_ID),
                NVL(LAST_UPDATE_LOGIN, G_LOGIN_ID),
                G_REQUEST_ID,
                NVL(PROGRAM_APPLICATION_ID, G_PROG_APPL_ID),
                NVL(PROGRAM_ID, G_PROGRAM_ID),
                NVL(PROGRAM_UPDATE_DATE, sysdate)
              FROM Ego_Flex_Value_Intf evsvi
              WHERE (p_set_process_id IS NULL
                      OR set_process_id = p_set_process_id
                    )
                AND process_status=G_PROCESS_RECORD
                AND version_seq_id IS NOT NULL;


              -- Error out version related records
              UPDATE Ego_Flex_Value_Intf
              SET process_status=G_ERROR_RECORD
              WHERE (p_set_process_id IS NULL
                      OR set_process_id = p_set_process_id
                    )
                AND version_seq_id IS NOT NULL;





              INSERT
              INTO
                MTL_INTERFACE_ERRORS
                (
                  TRANSACTION_ID,
                  UNIQUE_ID,
                  ORGANIZATION_ID,
                  COLUMN_NAME,
                  TABLE_NAME,
                  MESSAGE_NAME,
                  ERROR_MESSAGE,
                  bo_identifier,
                  ENTITY_IDENTIFIER,
                  LAST_UPDATE_DATE,
                  LAST_UPDATED_BY,
                  CREATION_DATE,
                  CREATED_BY,
                  LAST_UPDATE_LOGIN,
                  REQUEST_ID,
                  PROGRAM_APPLICATION_ID,
                  PROGRAM_ID,
                  PROGRAM_UPDATE_DATE
                )
              SELECT
                evstvi.transaction_id,
                MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
                NULL,
                NULL,
                G_ENTITY_VAL_TL_HEADER_TAB,
                l_err_message_name,
                l_err_message_text,
                G_BO_IDENTIFIER_VS,
                G_ENTITY_VS_VER,
                NVL(LAST_UPDATE_DATE, SYSDATE),
                NVL(LAST_UPDATED_BY, G_USER_ID),
                NVL(CREATION_DATE,SYSDATE),
                NVL(CREATED_BY, G_USER_ID),
                NVL(LAST_UPDATE_LOGIN, G_LOGIN_ID),
                G_REQUEST_ID,
                NVL(PROGRAM_APPLICATION_ID, G_PROG_APPL_ID),
                NVL(PROGRAM_ID, G_PROGRAM_ID),
                NVL(PROGRAM_UPDATE_DATE, sysdate)
              FROM Ego_Flex_Value_Tl_Intf evstvi
              WHERE (p_set_process_id IS NULL
                      OR set_process_id = p_set_process_id
                    )
                AND process_status=G_PROCESS_RECORD
                AND version_seq_id IS NOT NULL;



              -- Error out version related records
              UPDATE Ego_Flex_Value_Tl_Intf
              SET process_status=G_ERROR_RECORD
              WHERE (p_set_process_id IS NULL
                      OR set_process_id = p_set_process_id
                    )
                AND version_seq_id IS NOT NULL;

        END IF; --IF NOT G_P4TP_PROFILE_ENABLED THEN


        write_debug(G_PKG_Name,l_api_name,' End of API  ');
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API  ');

  EXCEPTION
        WHEN OTHERS THEN

            write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error :  '||SQLERRM);
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In Exception of API. Error :  '||SQLERRM);
            x_return_status := G_RET_STS_UNEXP_ERROR;
            x_return_msg := G_PKG_Name||'.'||l_api_name||'  - '||SQLERRM;

   	        RETURN;


  END Validate_Telco_profile;


  -------------------------------------------------------------------------------------
  -- Procedure to validate value sets.
  -------------------------------------------------------------------------------------
  PROCEDURE Validate_value_Set (
                                p_value_set_name      IN    VARCHAR2,
                                p_validation_code     IN    VARCHAR2,
                                p_longlist_flag       IN    VARCHAR2,
                                p_format_code         IN    VARCHAR2,
                                p_maximum_size        IN    NUMBER,
                                p_maximum_value       IN    VARCHAR2,
                                p_minimum_value       IN    VARCHAR2,
                                p_version_seq_id      IN    NUMBER,
                                p_transaction_id      IN    NUMBER,
                                p_transaction_type    IN    VARCHAR2,
                                x_return_status      OUT NOCOPY VARCHAR2,
                                x_return_msg         OUT NOCOPY VARCHAR2)

  IS

        l_api_name       VARCHAR2(100)    := 'Validate_value_Set';

        l_transaction_type  VARCHAR2(30)  :=  p_transaction_type;
        l_validation_code   VARCHAR2(1)   :=  p_validation_code;
        l_longlist_flag     VARCHAR2(1)   :=  p_longlist_flag;
        l_format_code       VARCHAR2(1)   :=  p_format_code;
        l_version_seq_id    NUMBER        :=  p_version_seq_id;
        l_value_set_name    VARCHAR2(500) :=  p_value_set_name;
        l_maximum_value     VARCHAR2(150) :=  p_maximum_value;
        l_minimum_value     VARCHAR2(150) :=  p_minimum_value;
        l_maximum_size      NUMBER        :=  p_maximum_size;



        /* Local variable to be used in error handling mechanism*/
        l_entity_code       VARCHAR2(40) :=  G_ENTITY_VS;
        l_table_name        VARCHAR2(240):=  G_ENTITY_VS_HEADER_TAB;

        l_token_table            ERROR_HANDLER.Token_Tbl_Type;
        l_application_id         NUMBER :=  G_Application_Id;
        l_error_message_name     VARCHAR2(500);
        --l_error_row_identifier   NUMBER;
        l_transaction_id	       NUMBER :=p_transaction_id;
        l_process_status         NUMBER:=NULL;

  BEGIN

        write_debug(G_PKG_Name,l_api_name,' Start of API. ');
        ----Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API. ');


        -- Check for Validation Code
        IF  l_validation_code NOT IN (G_TRANS_IND_VALIDATION_CODE,G_INDEPENDENT_VALIDATION_CODE,G_NONE_VALIDATION_CODE,G_TABLE_VALIDATION_CODE)  THEN

            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS name)=('
                                        ||l_value_set_name||')'||' Pass correct validation code for value set. ');



            l_error_message_name          := 'EGO_VSET_VALIDATION_ERROR';
            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
            l_token_table(1).TOKEN_VALUE  := l_value_set_name;
            x_return_status               := G_RET_STS_ERROR;


            ERROR_HANDLER.Add_Error_Message(
               p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

            l_token_table.DELETE;
        END IF;

        -- Check for Longlist Flag
        IF l_longlist_flag NOT IN (G_LOV_LONGLIST_FLAG,G_POPLIST_LONGLIST_FLAG)  THEN

            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS name)=('
                                        ||l_value_set_name||')'||' Pass correct longlist flag for value set. ');

            l_error_message_name          := 'EGO_VSET_LONGLIST_ERROR';
            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
            l_token_table(1).TOKEN_VALUE  := l_value_set_name;
            x_return_status               := G_RET_STS_ERROR;

            ERROR_HANDLER.Add_Error_Message(
               p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

            l_token_table.DELETE;

        END IF;

        -- Check for Date Type
        IF l_format_code NOT IN (G_CHAR_DATA_TYPE,G_NUMBER_DATA_TYPE,G_DATE_DATA_TYPE, G_DATE_TIME_DATA_TYPE)  THEN

            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS name)=('
                                        ||l_value_set_name||')'||' Pass correct data type for value set. ');

            l_error_message_name          := 'EGO_VSET_DATA_TYPE_ERROR';
            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
            l_token_table(1).TOKEN_VALUE  := l_value_set_name;
            x_return_status               := G_RET_STS_ERROR;

            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

            l_token_table.DELETE;

        END IF;



        -- Check for version validation for negative version
        IF  (l_version_seq_id IS NOT NULL AND l_version_seq_id <0 )THEN

            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS name)=('
                                        ||l_value_set_name||')'||' A version seq id can not be a negative number. ');



            l_error_message_name          := 'EGO_VS_VERSION_NUMBER_ERROR';
            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
            l_token_table(1).TOKEN_VALUE  := l_value_set_name;
            x_return_status               := G_RET_STS_ERROR;

            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

            l_token_table.DELETE;

        END IF; --IF  l_validation_code = G_TABLE_VALIDATION_CODE THEN





        -- Check fo table type
        IF  l_validation_code = G_TABLE_VALIDATION_CODE AND l_version_seq_id IS NOT NULL THEN

          write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS name)=('
                                        ||l_value_set_name||')'||' A table type of value set can not be a versioned value set. ');



            l_error_message_name          := 'EGO_TABLE_VS_VERSION_ERROR';
            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
            l_token_table(1).TOKEN_VALUE  := l_value_set_name;
            x_return_status               := G_RET_STS_ERROR;

            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

            l_token_table.DELETE;

        END IF; --IF  l_validation_code = G_TABLE_VALIDATION_CODE THEN




        -- Bug 9702845
        IF  (l_format_code IN (  G_NUMBER_DATA_TYPE,G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE )
                            AND l_validation_code= G_NONE_VALIDATION_CODE
                        ) THEN


                IF l_maximum_value < l_minimum_value  THEN


                    write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS name)=('
                                                ||l_value_set_name||')'||' Maximum value should always be greater than minimum value. ');



                    l_error_message_name          := 'EGO_VAL_MUST_LT_MAXVALUE';
                    x_return_status               := G_RET_STS_ERROR;

                    l_token_table(1).TOKEN_NAME   := 'MAXVALUE';
                    l_token_table(1).TOKEN_VALUE  := l_maximum_value;


                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                  => l_error_message_name
                      ,p_application_id                => G_App_Short_Name
                      ,p_token_tbl                     => l_token_table
                      ,p_message_type                  => G_RET_STS_ERROR
                      ,p_row_identifier                => l_transaction_id
                      ,p_entity_code                   => l_entity_code
                      ,p_table_name                    => l_table_name);


                    l_token_table.DELETE;


                END IF;

        END IF;-- END IF  (l_format_code IN (  G_NUMBER_DATA_TYPE,G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE )




        IF  l_format_code IN (  G_NUMBER_DATA_TYPE,G_CHAR_DATA_TYPE )  THEN --G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE )

                IF l_maximum_size IS NULL THEN


                    write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS name)=('
                                                ||l_value_set_name||')'||' Maximum size is required. ');



                    l_error_message_name          := 'EGO_VS_MAXSIZE_REQ';
                    x_return_status               := G_RET_STS_ERROR;


                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                  => l_error_message_name
                      ,p_application_id                => G_App_Short_Name
                      ,p_token_tbl                     => l_token_table
                      ,p_message_type                  => G_RET_STS_ERROR
                      ,p_row_identifier                => l_transaction_id
                      ,p_entity_code                   => l_entity_code
                      ,p_table_name                    => l_table_name);



                END IF;

        END IF;-- END IF  (l_format_code IN (  G_NUMBER_DATA_TYPE,G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE )



        IF  l_format_code =G_DATE_DATA_TYPE THEN

                l_maximum_size := 11;

        END IF;-- END IF

        IF  l_format_code =G_DATE_TIME_DATA_TYPE THEN

                l_maximum_size := 20;

        END IF;-- END IF





      --END IF;-- END  IF l_transaction_type = G_CREATE THEN

      write_debug(G_PKG_Name,l_api_name,' End of API. ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API. ');

  EXCEPTION

      WHEN OTHERS THEN
          write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  In Exception of API. Error : '||SubStr(SQLERRM,1,500) );

          x_return_status := G_RET_STS_UNEXP_ERROR;
          x_return_msg    := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	      RETURN;


  END Validate_Value_Set;






  ---------------------------------------------------------------------------------
  -- Procedure to be used to import value set while called using concurrent program.
  ---------------------------------------------------------------------------------
  PROCEDURE Import_Value_Set_Intf (p_set_process_id   IN          NUMBER,
                                  x_return_status    OUT NOCOPY  VARCHAR2,
                                  x_return_msg       OUT NOCOPY  VARCHAR2)
  IS


        l_api_name                VARCHAR2(100) := 'Import_Value_Set_Intf';


        l_valueset_tab            Ego_Metadata_Pub.Value_Set_Tbl;--:= Value_Set_Tbl();
        l_valueset_val_tab        Ego_Metadata_Pub.Value_Set_Value_Tbl;--:= Value_Set_Tbl();
        l_valueset_val_tl_tbl     Ego_Metadata_Pub.Value_Set_Value_Tl_Tbl;
        l_return_status           VARCHAR2(10);
        l_msg_count               NUMBER;
        l_return_msg              VARCHAR2(1000);

        l_out_version_seq_id      NUMBER;

        l_err_message_name        VARCHAR2(50);
        l_err_message_text        VARCHAR2(500);

        -- Variables for record type
        l_vs_val_rec              Ego_Metadata_Pub.Value_Set_Value_Tbl;
        l_valueset_rec            Ego_Metadata_Pub.Value_Set_Tbl;

        l_install_lang		        VARCHAR2(10);
        l_nls_language	  	      VARCHAR2(100);
        l_dynamic_sql		          VARCHAR2(1000);

        l_lang_exist              VARCHAR2(100):=NULL ;
        l_version_vs_val_exist    BOOLEAN      :=FALSE;



        --=========================================
        -- Cursor for Non Version VS and Values
        --=========================================

        -- Cursor to get non versioned parent value Set
        CURSOR Cur_Non_Vers_VS
        IS
        SELECT *
        FROM Ego_Flex_Value_Set_Intf
        WHERE (p_set_process_id IS NULL
                OR set_process_id = p_set_process_id
              )
          AND version_seq_id IS NULL
          AND process_status=G_PROCESS_RECORD
          AND parent_value_set_name is NULL
          ORDER BY value_set_name;






        -- Get values.
        CURSOR Cur_Non_Vers_Values
        IS
        SELECT *
        FROM Ego_Flex_Value_Intf evsvi
        WHERE (p_set_process_id IS NULL
                OR evsvi.set_process_id = p_set_process_id
              )
          AND evsvi.process_status=G_PROCESS_RECORD
          AND evsvi.version_seq_id IS NULL

          AND EXISTS
            ( SELECT 1
              FROM Ego_Flex_Value_Set_Intf evsi
              WHERE
                (   (p_set_process_id IS NULL
                      OR evsi.set_process_id = p_set_process_id
                    )
                AND (evsi.value_set_name= evsvi.value_set_name
                      OR evsi.value_set_id= evsvi.value_set_id
                    )
                AND  evsi.process_status = G_SUCCESS_RECORD
                AND  evsi.version_seq_id IS NULL
                AND  evsi.parent_value_set_name IS NULL
                )

              UNION

                SELECT 1
                FROM  Fnd_Flex_Value_Sets ffvs
                WHERE (ffvs.flex_value_set_name= evsvi.value_set_name
                        OR ffvs.flex_value_set_id= evsvi.value_set_id
                      )
                  AND NOT EXISTS
                      ( SELECT 1
                        FROM Ego_Flex_valueSet_Version_b efvsv
                        WHERE ffvs.flex_value_set_id= efvsv.flex_value_set_id
                      )
                  AND NOT EXISTS
                      ( SELECT 1
                        FROM Ego_value_Set_Ext evse
                        WHERE ffvs.flex_value_set_id = evse.value_set_id
                      )

                  AND  ffvs.parent_flex_value_set_id IS NULL
            )

        ORDER BY value_set_name, value_set_id ;




        -- For translatable values
        CURSOR Cur_Non_Vers_Trans_Values  ( cp_value_set_name VARCHAR2,
                                            cp_value_set_id   NUMBER,
                                            cp_flex_value     VARCHAR2,
                                            cp_flex_value_id  NUMBER,
                                            cp_language_code  VARCHAR2 )

        IS
        SELECT *
        FROM Ego_Flex_Value_tl_Intf evstvi
        WHERE
            (
              ( p_set_process_id IS NULL
                OR evstvi.set_process_id = p_set_process_id
              )
              AND ( evstvi.flex_value = cp_flex_value
                    OR
                    evstvi.flex_value_id = cp_flex_value_id
                  )
              AND
                  ( evstvi.value_set_name = cp_value_set_name
                    OR
                    evstvi.value_set_id = cp_value_set_id
                  )


              AND EXISTS
                ( SELECT 1
                  FROM Ego_Flex_Value_Intf      evsvi,
                        Ego_Flex_Value_Set_Intf  evsi
                  WHERE
                    (   (p_set_process_id IS NULL
                          OR evsvi.set_process_id = p_set_process_id
                        )
                    AND
                        (p_set_process_id IS NULL
                          OR evsi.set_process_id = p_set_process_id
                        )
                    AND (
                          ( evsi.value_set_name= evsvi.value_set_name
                            AND evsvi.value_set_name= evstvi.value_set_name
                          )
                          OR
                          ( evsi.value_set_id= evsvi.value_set_id
                            AND evsvi.value_set_id= evstvi.value_set_id
                          )
                        )

                    AND (evsvi.flex_value= evstvi.flex_value
                          OR evsvi.flex_value_id = evstvi.flex_value_id
                        )
                    AND  evsi.process_status = G_SUCCESS_RECORD
                    AND  evsvi.process_status = G_PROCESS_RECORD
                    AND  evsi.parent_value_set_name IS NULL
                    AND  evsi.version_seq_id IS NULL
                    AND  evsvi.version_seq_id IS NULL
                    )
                  UNION

                  SELECT 1
                  FROM Ego_Flex_Value_Intf      evsvi,
                        Fnd_Flex_Value_Sets     ffvs
                  WHERE
                    (   (p_set_process_id IS NULL
                          OR evsvi.set_process_id = null
                        )
                    AND (
                          ( ffvs.flex_value_set_name= evsvi.value_set_name
                            AND evsvi.value_set_name= evstvi.value_set_name
                          )
                          OR
                          ( ffvs.flex_value_set_id= evsvi.value_set_id
                            AND evsvi.value_set_id= evstvi.value_set_id
                          )
                        )

                    AND (evsvi.flex_value= evstvi.flex_value
                          OR evsvi.flex_value_id = evstvi.flex_value_id
                        )
                    AND  evsvi.process_status = G_PROCESS_RECORD
                    AND  ffvs.parent_flex_value_set_id IS NULL
                    AND  NOT EXISTS
                          ( SELECT 1
                            FROM Ego_Flex_valueSet_Version_b efvsv
                            WHERE ffvs.flex_value_set_id= efvsv.flex_value_set_id
                          )
                    AND NOT EXISTS
                          ( SELECT 1
                            FROM Ego_value_Set_Ext evse
                            WHERE ffvs.flex_value_set_id = evse.value_set_id
                          )
                    AND  evsvi.version_seq_id IS NULL
                    )


                )

              AND evstvi.version_seq_id IS NULL
              AND evstvi.process_status=G_PROCESS_RECORD
              AND "LANGUAGE" = cp_language_code
            )
        --GROUP BY LANGUAGE
        ORDER BY VALUE_set_name       ;




        -- Cursor to get orphan value record
        CURSOR Cur_Orphan_val
        IS
        SELECT *
          FROM Ego_Flex_Value_Intf evsvi
          WHERE (p_set_process_id IS NULL
                  OR evsvi.set_process_id = p_set_process_id
                )
            AND evsvi.process_status=G_PROCESS_RECORD
            AND evsvi.version_seq_id IS NULL
          ORDER BY value_set_name, value_set_id;





        -- Cursor to get orphan translatable values
        CURSOR Cur_Orphan_Trans_Values  (cp_language_code  VARCHAR2 )
        IS
        SELECT *
        FROM Ego_Flex_Value_tl_Intf evstvi
        WHERE
            (
              ( p_set_process_id IS NULL
                OR evstvi.set_process_id = p_set_process_id
              )
              AND evstvi.version_seq_id IS NULL
              AND evstvi.process_status=G_PROCESS_RECORD
              AND "LANGUAGE" = cp_language_code
            )
        ORDER BY VALUE_set_name;







        -- Get all available languages.
        CURSOR Cur_NLS_Lang
        IS
        SELECT language_code, nls_language
        FROM FND_LANGUAGES
        WHERE installed_flag IN ('I','B');





        CURSOR Cur_Trans_Lang ( cp_value_id       NUMBER ,
                                cp_version_seq_id NUMBER,
                                cp_lang_code      VARCHAR2)
        IS
        ( SELECT 1 AS lang_code
            FROM EGO_FLEX_VALUE_VERSION_TL
            WHERE flex_value_id = cp_value_id
              AND version_seq_id  = cp_version_seq_id
              AND "LANGUAGE" = cp_lang_code
        );






        --=================================
        -- Cursor for Versioned VS and values
        --================================


        -- Cursor to get versioned value Set
        CURSOR Cur_Vers_VS
        IS
        SELECT *
        FROM Ego_Flex_Value_Set_Intf
        WHERE (p_set_process_id IS NULL
                OR set_process_id = p_set_process_id
              )
          AND version_seq_id IS NOT NULL
          AND process_status=G_PROCESS_RECORD
          ORDER BY value_set_name, version_seq_id;



        -- Get versioned values
        CURSOR Cur_Vers_Values (cp_value_set_name   VARCHAR2,
                                cp_value_set_id     NUMBER,
                                cp_version_seq_id   NUMBER)
        IS
        SELECT *
        FROM Ego_Flex_Value_Intf evsvi
        WHERE (p_set_process_id IS NULL
                OR evsvi.set_process_id = p_set_process_id
              )
          AND evsvi.process_status=G_PROCESS_RECORD
          AND evsvi.version_seq_id IS NOT NULL
          AND ( evsvi.value_set_name = cp_value_set_name
                OR
                evsvi.value_set_id = cp_value_set_id
              )
          AND evsvi.version_seq_id = cp_version_seq_id
          AND EXISTS
            ( SELECT 1
              FROM Ego_Flex_Value_Set_Intf evsi
              WHERE
                (   (p_set_process_id IS NULL
                      OR evsi.set_process_id = p_set_process_id
                    )
                AND (evsi.value_set_name= evsvi.value_set_name
                      OR evsi.value_set_id= evsvi.value_set_id
                    )
                AND  evsi.process_status = G_PROCESS_RECORD -- YTJ -- Cross verify if status is going to be this one.
                AND  evsi.version_seq_id = evsvi.version_seq_id -- IS NULL
                )
            )
        ORDER BY value_set_name, value_set_id,version_seq_id ;





        -- For translatable values
        CURSOR Cur_Vers_Trans_Values      ( cp_value_set_name   VARCHAR2,
                                            cp_value_set_id     NUMBER,
                                            cp_version_seq_id   NUMBER,
                                            cp_flex_value       VARCHAR2,
                                            cp_flex_value_id    NUMBER )
        IS
        SELECT *
        FROM Ego_Flex_Value_tl_Intf evstvi
        WHERE
            (
              ( p_set_process_id IS NULL
                OR evstvi.set_process_id = p_set_process_id
              )
              AND evstvi.version_seq_id = cp_version_seq_id
              AND evstvi.process_status=G_PROCESS_RECORD
              AND ( evstvi.value_set_name = cp_value_set_name
                    OR
                    evstvi.value_set_id = cp_value_set_id
                  )
              AND ( evstvi.flex_value = cp_flex_value
                    OR
                    evstvi.flex_value_id = cp_flex_value_id
                  )
              AND EXISTS
                ( SELECT 1
                  FROM Ego_Flex_Value_Intf      evsvi,
                        Ego_Flex_Value_Set_Intf  evsi
                  WHERE
                    (   (p_set_process_id IS NULL
                          OR evsvi.set_process_id = p_set_process_id
                        )
                    AND
                        (p_set_process_id IS NULL
                          OR evsi.set_process_id = p_set_process_id
                        )
                    AND (
                          ( evsi.value_set_name= evsvi.value_set_name
                            AND evsvi.value_set_name= evstvi.value_set_name
                          )
                          OR
                          ( evsi.value_set_id= evsvi.value_set_id
                            AND evsvi.value_set_id= evstvi.value_set_id
                          )
                        )

                    AND (evsvi.flex_value= evstvi.flex_value
                          OR evsvi.flex_value_id = evstvi.flex_value_id
                        )
                    AND ( evsi.version_seq_id = evsvi.version_seq_id
                          AND  evsvi.version_seq_id =evstvi.version_seq_id
                        )
                    AND  evsi.process_status = G_PROCESS_RECORD -- YTJ -- Cross verify if status is going to be this one
                    AND  evsvi.process_status = G_PROCESS_RECORD

                    )
                )


            )
            ORDER BY flex_value, flex_value_id,version_seq_id;





        --=================================
        -- Cursor for Child VS and values
        --================================

        -- Cursor to get Child value Set
        CURSOR Cur_Child_VS
        IS
        SELECT *
        FROM Ego_Flex_Value_Set_Intf
        WHERE (p_set_process_id IS NULL
                OR set_process_id = p_set_process_id
              )
          AND process_status=G_PROCESS_RECORD
          AND parent_value_set_name IS NOT NULL
          AND version_seq_id IS NULL
          ORDER BY value_set_name, value_set_id;






        CURSOR Cur_Child_Values
        IS
        SELECT *
        FROM Ego_Flex_Value_Intf evsvi
        WHERE (p_set_process_id IS NULL
                OR evsvi.set_process_id = p_set_process_id
              )
          AND evsvi.process_status=G_PROCESS_RECORD
          AND evsvi.version_seq_id IS NULL
          AND EXISTS

            ( SELECT 1
              FROM Ego_Flex_Value_Set_Intf evsi
              WHERE
                (   (p_set_process_id IS NULL
                      OR evsi.set_process_id = p_set_process_id
                    )
                AND (evsi.value_set_name= evsvi.value_set_name
                      OR evsi.value_set_id= evsvi.value_set_id
                    )
                AND  evsi.process_status = G_PROCESS_RECORD
                AND  evsi.version_seq_id IS NULL
                AND  evsi.parent_value_set_name IS NOT NULL
                )

              UNION
              SELECT 1
              FROM Fnd_Flex_Value_Sets ffvs
              WHERE
                (   ( ffvs.flex_value_set_name= evsvi.value_set_name
                      OR ffvs.flex_value_set_id= evsvi.value_set_id
                    )
                  AND NOT EXISTS
                    ( SELECT 1
                      FROM Ego_Flex_valueSet_Version_b efvsv
                      WHERE ffvs.flex_value_set_id= efvsv.flex_value_set_id
                    )

                  AND  EXISTS
                    ( SELECT 1
                      FROM Ego_value_Set_Ext evse
                      WHERE ffvs.flex_value_set_id = evse.value_set_id
                    )
                )




            )
        ORDER BY evsvi.value_set_name, evsvi.value_set_id ;





  BEGIN


        write_debug(G_PKG_Name,l_api_name,' Start of API. ');
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API. ');


        G_FLOW_TYPE :=G_EGO_MD_INTF;
        --G_Application_Id  :=  Get_Application_Id();


        write_debug(G_PKG_Name,l_api_name,' Call to Initialize_VS_Interface API.');
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Call to Initialize_VS_Interface API.');

        --2.1.1-- Call Bulk Validation API
        Initialize_VS_Interface (1,p_set_process_id,l_return_status,l_msg_count,l_return_msg);


        -- check the return status
        IF (l_return_status =G_RET_STS_UNEXP_ERROR )
        THEN

          x_return_status :=  G_RET_STS_UNEXP_ERROR;
          x_return_msg    :=  l_return_msg;
          RETURN;


        END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN





        --==================================================
        -- Part1: - Process Non Versioned Parent value Set
        --==================================================

        --Construct PL/SQL table for non child value sets  and Call to process non child value set API
        write_debug(G_PKG_Name,l_api_name,' Start processing Non Ver VS ');
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start processing Non Ver VS ');



        --FOR i IN Cur_Non_Vers_VS
        OPEN Cur_Non_Vers_VS;
        LOOP

            FETCH Cur_Non_Vers_VS BULK COLLECT INTO l_valueset_tab limit 2000;

            write_debug(G_PKG_Name,l_api_name,' Count of record in value set table '||l_valueset_tab.Count);
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Count of record in value set table '||l_valueset_tab.Count);

            -- Call Process VS API.
            IF l_valueset_tab.Count>0 THEN

                Process_Value_Set (1,l_valueset_tab,p_set_process_id,FALSE,l_return_status,l_msg_count,l_return_msg);

                -- check the return status
                IF (l_return_status =G_RET_STS_UNEXP_ERROR )
                THEN

                  x_return_status :=  G_RET_STS_UNEXP_ERROR;
                  x_return_msg    :=  l_return_msg;
                  RETURN;

                END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN


                Populate_VS_Interface ( l_valueset_tab, l_return_status,l_return_msg);

                -- Issue a commit after each iteration
                COMMIT;

            END IF; -- END IF l_valueset_tab.Count>0

          EXIT WHEN l_valueset_tab.COUNT < 2000;


        END LOOP;
        CLOSE Cur_Non_Vers_VS;


        write_debug(G_PKG_Name,l_api_name,' Completed processing non version value sets. Count of record in table l_valueset_tab. '||l_valueset_tab.count);
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Completed processing non version value sets. Count of record in table l_valueset_tab. '||l_valueset_tab.count);




        -- Write Code to process
        l_err_message_name       :=  'EGO_VALUE_SET_CREATION_FAILED';
        fnd_message.set_name('EGO','EGO_VALUE_SET_CREATION_FAILED');
        l_err_message_text       := fnd_message.get;


        -- Insert record in  error table for those record whose value set creation failed.
        --
        INSERT
        INTO
          MTL_INTERFACE_ERRORS
          (
            TRANSACTION_ID,
            UNIQUE_ID,
            ORGANIZATION_ID,
            COLUMN_NAME,
            TABLE_NAME,
            BO_Identifier,
            Entity_Identifier,
            MESSAGE_NAME,
            ERROR_MESSAGE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE
          )
        SELECT
          evsvi.transaction_id,
          MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
          NULL,
          NULL,
          G_ENTITY_VAL_HEADER_TAB,
          G_BO_IDENTIFIER_VS,
          G_ENTITY_VS_VAL,
          l_err_message_name,
          l_err_message_text,
          NVL(LAST_UPDATE_DATE, SYSDATE),
          NVL(LAST_UPDATED_BY, G_USER_ID),
          NVL(CREATION_DATE,SYSDATE),
          NVL(CREATED_BY, G_USER_ID),
          NVL(LAST_UPDATE_LOGIN, G_LOGIN_ID),
          G_REQUEST_ID,
          NVL(PROGRAM_APPLICATION_ID, G_PROG_APPL_ID),
          NVL(PROGRAM_ID, G_PROGRAM_ID),
          NVL(PROGRAM_UPDATE_DATE, sysdate)
        FROM Ego_Flex_Value_Intf evsvi
        WHERE
            (
              ( p_set_process_id IS NULL
                OR evsvi.set_process_id = p_set_process_id
              )
            AND EXISTS

              ( SELECT 1
                FROM Ego_Flex_Value_Set_Intf evsi
                WHERE
                  (   (p_set_process_id IS NULL
                        OR evsi.set_process_id = p_set_process_id
                      )
                  AND (evsi.value_set_name= evsvi.value_set_name
                        OR evsi.value_set_id= evsvi.value_set_id
                      )
                  AND  evsi.process_status = G_ERROR_RECORD
                  AND  evsi.version_seq_id IS NULL
                  AND  evsi.parent_value_set_name IS NULL
                  )
              )
            AND NOT EXISTS
                (
                  SELECT 1
                  FROM  Fnd_Flex_Value_Sets ffvs
                  WHERE (ffvs.flex_value_set_name= evsvi.value_set_name
                          OR ffvs.flex_value_set_id= evsvi.value_set_id
                        )
                    AND NOT EXISTS
                        ( SELECT 1
                          FROM Ego_Flex_valueSet_Version_b efvsv
                          WHERE ffvs.flex_value_set_id= efvsv.flex_value_set_id
                        )
                    AND NOT EXISTS
                        ( SELECT 1
                          FROM Ego_Value_Set_Ext evse
                          WHERE ffvs.flex_value_set_id= evse.value_set_id
                        )

                    AND  ffvs.parent_flex_value_set_id IS NULL
                )

              AND evsvi.version_seq_id IS NULL
              AND evsvi.process_status=G_PROCESS_RECORD
            );




        --  Before processing value table, Update process flag in value intf table with status 3 for those record which has failed to process
        UPDATE ego_flex_value_intf evsvi
        SET evsvi.process_status=G_ERROR_RECORD,
            evsvi.LAST_UPDATED_BY= G_User_Id,
            evsvi.LAST_UPDATE_DATE = SYSDATE,
            evsvi.LAST_UPDATE_LOGIN = G_LOGIN_ID

        WHERE
            (
              ( p_set_process_id IS NULL
                OR evsvi.set_process_id = p_set_process_id
              )

            AND EXISTS

              ( SELECT 1
                FROM Ego_Flex_Value_Set_Intf evsi
                WHERE
                  (   (p_set_process_id IS NULL
                        OR evsi.set_process_id = p_set_process_id
                      )
                  AND (evsi.value_set_name= evsvi.value_set_name
                        OR evsi.value_set_id= evsvi.value_set_id
                      )
                  AND  evsi.process_status = G_ERROR_RECORD
                  AND  evsi.version_seq_id IS NULL
                  AND  evsi.parent_value_set_name IS NULL
                  )
              )
            AND NOT EXISTS
                (
                  SELECT 1
                  FROM  Fnd_Flex_Value_Sets ffvs
                  WHERE (ffvs.flex_value_set_name= evsvi.value_set_name
                          OR ffvs.flex_value_set_id= evsvi.value_set_id
                        )
                    AND NOT EXISTS
                        ( SELECT 1
                          FROM Ego_Flex_valueSet_Version_b efvsv
                          WHERE ffvs.flex_value_set_id= efvsv.flex_value_set_id
                        )
                    AND NOT EXISTS
                        ( SELECT 1
                          FROM Ego_Value_Set_Ext evse
                          WHERE ffvs.flex_value_set_id= evse.value_set_id
                        )

                    AND  ffvs.parent_flex_value_set_id IS NULL
                )

              AND evsvi.version_seq_id IS NULL
              AND evsvi.process_status=G_PROCESS_RECORD
            );



        --To Do
        -- Check if whold logic of production table also need to be written
        -- Insert record in  error table for those record whose value set creation failed.
        --
        INSERT
        INTO
          MTL_INTERFACE_ERRORS
          (
            TRANSACTION_ID,
            UNIQUE_ID,
            ORGANIZATION_ID,
            COLUMN_NAME,
            TABLE_NAME,
            BO_Identifier,
            Entity_Identifier,
            MESSAGE_NAME,
            ERROR_MESSAGE,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE
          )
        SELECT
          evstvi.transaction_id,
          MTL_SYSTEM_ITEMS_INTERFACE_S.nextval,
          NULL,
          NULL,
          G_ENTITY_VAL_TL_HEADER_TAB,
          G_BO_IDENTIFIER_VS,
          G_ENTITY_VS_VAL,
          l_err_message_name,
          l_err_message_text,
          NVL(LAST_UPDATE_DATE, SYSDATE),
          NVL(LAST_UPDATED_BY, G_USER_ID),
          NVL(CREATION_DATE,SYSDATE),
          NVL(CREATED_BY, G_USER_ID),
          NVL(LAST_UPDATE_LOGIN, G_LOGIN_ID),
          G_REQUEST_ID,
          NVL(PROGRAM_APPLICATION_ID, G_PROG_APPL_ID),
          NVL(PROGRAM_ID, G_PROGRAM_ID),
          NVL(PROGRAM_UPDATE_DATE, sysdate)
        FROM Ego_Flex_Value_Tl_Intf evstvi
        WHERE
            (
              ( p_set_process_id IS NULL
                OR evstvi.set_process_id = p_set_process_id
              )
              AND EXISTS
                ( SELECT 1
                  FROM Ego_Flex_Value_Intf evsvi
                  WHERE
                    (   (p_set_process_id IS NULL
                          OR evsvi.set_process_id = p_set_process_id
                        )
                    AND (evsvi.value_set_name= evstvi.value_set_name
                          OR evsvi.value_set_id= evstvi.value_set_id
                        )
                    AND (evsvi.flex_value= evstvi.flex_value
                          OR evsvi.flex_value_id = evstvi.flex_value_id
                        )
                    AND  evsvi.process_status = G_ERROR_RECORD
                    AND  evsvi.version_seq_id IS NULL
                    )
                )

              AND evstvi.version_seq_id IS NULL
              AND evstvi.process_status=G_PROCESS_RECORD
            );





        --  Before processing value table, Update process flag in value intf table with status 3 for those record which has failed to process
        UPDATE Ego_Flex_Value_Tl_Intf evstvi
        SET evstvi.process_status=G_ERROR_RECORD,
            evstvi.LAST_UPDATED_BY= G_User_Id,
            evstvi.LAST_UPDATE_DATE = SYSDATE,
            evstvi.LAST_UPDATE_LOGIN = G_LOGIN_ID
        WHERE
            (
              ( p_set_process_id IS NULL
                OR evstvi.set_process_id = p_set_process_id
              )
              AND EXISTS
                ( SELECT 1
                  FROM Ego_Flex_Value_Intf evsvi
                  WHERE
                    (   (p_set_process_id IS NULL
                          OR evsvi.set_process_id = p_set_process_id
                        )
                    AND (evsvi.value_set_name= evstvi.value_set_name
                          OR evsvi.value_set_id= evstvi.value_set_id
                        )
                    AND (evsvi.flex_value= evstvi.flex_value
                          OR evsvi.flex_value_id = evstvi.flex_value_id
                        )
                    AND  evsvi.process_status = G_ERROR_RECORD
                    AND  evsvi.version_seq_id IS NULL
                    )
                )

              AND evstvi.version_seq_id IS NULL
              AND evstvi.process_status=G_PROCESS_RECORD
            );




        -- To get default language code
        SELECT UserEnv('Lang') INTO G_User_Lang FROM dual;



        -- Get default NLS Language
        SELECT nls_language INTO G_NLS_LANGUAGE
        FROM FND_LANGUAGES
        WHERE language_code =G_User_Lang
          AND installed_flag IN ('I','B');




        -- Process TL Data based on each languge
        FOR i IN Cur_NLS_Lang
        LOOP

            l_install_lang  :=  i.language_code;
            l_nls_language  :=  i.nls_language;


            l_dynamic_sql   := 'ALTER SESSION SET NLS_LANGUAGE = '||l_nls_language;

            write_debug(G_PKG_Name,l_api_name,' Prepared dynamic sql to set NLS language. SQL statement is  : '||l_dynamic_sql );
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Prepared dynamic sql to set NLS language. SQL statement is  : '||l_dynamic_sql );

            EXECUTE IMMEDIATE l_dynamic_sql;





            -- Non versioned and non child values.
            OPEN Cur_Non_Vers_Values;
            LOOP
                FETCH Cur_Non_Vers_Values BULK COLLECT INTO l_valueset_val_tab limit 2000;

                write_debug(G_PKG_Name,l_api_name,' Created pl-sql table for non version values. Count of record in table l_valueset_val_tab. : '||l_valueset_val_tab.count);
                --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Created pl-sql table for non version values. Count of record in table l_valueset_val_tab. : '||l_valueset_val_tab.count);


                IF l_valueset_val_tab.Count>0 THEN

                    FOR j IN l_valueset_val_tab.first..l_valueset_val_tab.last LOOP

                        write_debug(G_PKG_Name,l_api_name,' Values to be imported are value '||l_valueset_val_tab(j).flex_value);
                        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Values to be imported is value '||l_valueset_val_tab(j).flex_value);

                        OPEN Cur_Non_Vers_Trans_Values(l_valueset_val_tab(j).value_set_name,l_valueset_val_tab(j).value_set_id,l_valueset_val_tab(j).flex_value, l_valueset_val_tab(j).flex_value_id,l_install_lang);
                        LOOP

                            l_vs_val_rec(1) :=l_valueset_val_tab(j);


                            FETCH Cur_Non_Vers_Trans_Values
                            BULK COLLECT INTO l_valueset_val_tl_tbl limit 50;

                            write_debug(G_PKG_Name,l_api_name,' Before call to Process_Value_Set_Value, Count of record for translatable values are : '||l_valueset_val_tl_tbl.COUNT);


                            IF (l_valueset_val_tl_tbl.Count >0 ) THEN

                                Process_Value_Set_Value (1,l_vs_val_rec ,l_valueset_val_tl_tbl,p_set_process_id,FALSE,l_return_status,l_msg_count,l_return_msg);

                                -- Populate Values
                                Populate_VS_Val_Interface (l_vs_val_rec, l_return_status,l_return_msg);

                                -- Populate Values
                                Populate_VS_Val_Tl_Interface (l_valueset_val_tl_tbl, l_return_status,l_return_msg);

                            END IF;

                        EXIT
                          WHEN l_valueset_val_tl_tbl.COUNT < 50;
                        END LOOP;
                        CLOSE Cur_Non_Vers_Trans_Values;

                    END LOOP; -- END FOR j IN  l_valueset_val_tab.first..l_valueset_val_tab.last

                END IF; -- IF l_valueset_val_tab.Count>0 THEN

                -- Issue a commit after each iteration
                COMMIT;


            EXIT
              WHEN l_valueset_val_tab.COUNT < 2000;
            END LOOP; -- END FOR i IN Cur_Non_Vers_Values
            CLOSE Cur_Non_Vers_Values;

            write_debug(G_PKG_Name,l_api_name,' Completed processing of values for language : ' ||l_nls_language);

        END LOOP; -- END FOR i IN Cur_NLS_Lang


        l_dynamic_sql   := NULL;

        l_dynamic_sql   := 'ALTER SESSION SET NLS_LANGUAGE = '||G_NLS_LANGUAGE;

        write_debug(G_PKG_Name,l_api_name,' Prepared dynamic sql to set NLS language to base language  '||l_dynamic_sql );

        EXECUTE IMMEDIATE l_dynamic_sql;










        --==================================================
        -- Part2: - Process Versioned Parent value Set
        --==================================================

        -- Non versioned and non child values.
        write_debug(G_PKG_Name,l_api_name,' Before processing version value set ');
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  Before processing version value set ');



        OPEN Cur_Vers_VS;
        LOOP

              FETCH Cur_Vers_VS BULK COLLECT INTO l_valueset_tab limit 2000;

              write_debug(G_PKG_Name,l_api_name,' Fetched Version VS records. Count of record is :  '||l_valueset_tab.Count );
              --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Fetched Version VS records. Count of record is :  '||l_valueset_tab.Count );



              -- Process record if exist.
              IF  l_valueset_tab.Count>0 THEN

                  /*-- Call Process VS API.  This will create all Value Set and corresponding draft version.
                  Process_Value_Set (1,l_valueset_tab,p_set_process_id,FALSE,l_return_status,l_msg_count,l_return_msg);*/

                  FOR j IN l_valueset_tab.first..l_valueset_tab.last
                  LOOP

                    -- Create Savepoint for each versioned record processing.
                    SAVEPOINT CREATE_VERSION_VALUE_SET;


                    l_valueset_rec(1) :=  l_valueset_tab(j);

                    -- Call Process VS API.  This will create all Value Set and corresponding draft version.
                    Process_Value_Set (1,l_valueset_rec,p_set_process_id,FALSE,l_return_status,l_msg_count,l_return_msg);

                    l_valueset_tab(j) := l_valueset_rec(1);



                    write_debug(G_PKG_Name,l_api_name,' Created savepoint CREATE_VERSION_VALUE_SET  ');
                    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Created savepoint CREATE_VERSION_VALUE_SET  ');

                    IF l_valueset_tab(j).process_status <> G_ERROR_RECORD THEN

                      -- Call API to release a value set version.
                      Release_Value_Set_Version( l_valueset_tab(j).value_set_id,
                                                l_valueset_tab(j).version_description,
                                                l_valueset_tab(j).start_active_date,
                                                l_valueset_tab(j).version_seq_id,
                                                l_valueset_tab(j).transaction_id,
                                                G_OUT_VERSION_SEQ_ID,
                                                l_return_status,
                                                l_return_msg );


                      write_debug(G_PKG_Name,l_api_name,' Call to  Release_Value_Set_Version is done. Return Status is '||l_return_status);
                      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Call to  Release_Value_Set_Version is done. Return Status is '||l_return_status);


                      IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS ) THEN

                          l_valueset_tab(j).process_status    := G_PROCESS_RECORD;
                          x_return_status                     := G_RET_STS_SUCCESS;
                          l_return_status                     := G_RET_STS_SUCCESS;
                          -- YTJ -- Confirm if it need to be G_SUCCESS_RECORD

                      ELSIF (l_return_status = G_RET_STS_ERROR ) THEN


                          write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_valueset_tab(j).transaction_id||'-(VS Id)=('
                                                    ||l_valueset_tab(j).value_set_id||')'||' Release of value set failed. ');



                          x_return_status                     := l_return_status;
                          l_valueset_tab(j).process_status    := G_ERROR_RECORD;

		                      G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                          G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS_VER;
                          G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                          G_TOKEN_TBL(2).Token_Value  :=  l_valueset_tab(j).transaction_type;
                          G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                          G_TOKEN_TBL(3).Token_Value  :=  'EGO_VS_BULKLOAD_PVT';
                          G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                          G_TOKEN_TBL(4).Token_Value  :=  'Release_Value_Set_Version';


                          ERROR_HANDLER.Add_Error_Message (
                            p_message_name                   => 'EGO_ENTITY_API_FAILED'
                            ,p_application_id                => G_App_Short_Name
                            ,p_token_tbl                     => G_TOKEN_TBL
                            ,p_message_type                  => G_RET_STS_ERROR
                            ,p_row_identifier                => l_valueset_tab(j).transaction_id
                            ,p_entity_code                   => G_ENTITY_VS_VER
                            ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

                          G_TOKEN_TBL.DELETE;


                      ELSE    -- case of unexpected error

                          x_return_status := G_RET_STS_UNEXP_ERROR;
                          x_return_msg    := l_return_msg;
                          RETURN;

                      END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN


                      -- If creation of version failed then do not process value entity further.
                      IF l_return_status = G_RET_STS_SUCCESS THEN

                          -- This API will return version_seq_id as output parameter.

                          OPEN Cur_Vers_Values(l_valueset_tab(j).value_set_name,l_valueset_tab(j).value_set_id,l_valueset_tab(j).version_seq_id);
                          LOOP


                            FETCH Cur_Vers_Values --(l_valueset_tab(j).value_set_name,l_valueset_tab(j).value_set_id,l_valueset_tab(j).version_seq_id)
                            BULK COLLECT INTO l_valueset_val_tab limit 2000;

                            --Dbms_Output.put_line(' Getting values for a version : Count is : '||l_valueset_val_tab.Count);


                            IF l_valueset_val_tab.Count>0 THEN

                              FOR l IN l_valueset_val_tab.first..l_valueset_val_tab.last LOOP



                                OPEN Cur_Vers_Trans_Values ( l_valueset_val_tab(l).value_set_name,l_valueset_val_tab(l).value_set_id,
                                                            l_valueset_val_tab(l).version_seq_id,l_valueset_val_tab(l).flex_value,l_valueset_val_tab(l).flex_value_id );
                                LOOP

                                    FETCH Cur_Vers_Trans_Values BULK COLLECT INTO l_valueset_val_tl_tbl limit 50;

                                    l_vs_val_rec(1) :=l_valueset_val_tab(l);

                                    --Bug 9710195
                                    --If atleast one value exist per value set, then set flag
                                    l_version_vs_val_exist := TRUE;

                                    Process_Value_Set_Value (1,l_vs_val_rec,l_valueset_val_tl_tbl,p_set_process_id,FALSE,l_return_status,l_msg_count,l_return_msg);


                                    IF l_return_status  = G_RET_STS_ERROR THEN
                                        x_return_status :=l_return_status;
                                    END IF;


                                    --Dbms_Output.put_line(' Processing is done. x_return_status = '||x_return_status);

                                    -- Populate Values
                                    Populate_VS_Val_Interface (l_vs_val_rec,l_return_status,l_return_msg);


                                    -- Populate Values
                                    Populate_VS_Val_Tl_Interface (l_valueset_val_tl_tbl,l_return_status,l_return_msg);


                                  EXIT
                                      WHEN l_valueset_val_tl_tbl.COUNT < 50;

                                END LOOP; -- END FOR m IN  Cur_Vers_Trans_Values ( l_valueset_val_tab(l).value_set_name,
                                CLOSE Cur_Vers_Trans_Values;




                                -- Write a code to insert record for all those translatable values which has not inserted or passed by user
                                FOR p IN Cur_NLS_Lang
                                LOOP

                                    l_lang_exist  :=  NULL;

                                    OPEN Cur_Trans_Lang (l_vs_val_rec(1).flex_value_id,G_OUT_VERSION_SEQ_ID,p.LANGUAGE_code );
                                    LOOP
                                      -- Initializing l_lang_exist.


                                        FETCH Cur_Trans_Lang INTO l_lang_exist;


                                        -- If lang rec does not exist then insert record for the same.
                                        IF  l_lang_exist IS NULL THEN


                                            INSERT INTO EGO_FLEX_VALUE_VERSION_TL
                                                ( FLEX_VALUE_ID,VERSION_SEQ_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,
                                                  LAST_UPDATE_LOGIN,DESCRIPTION,FLEX_VALUE_MEANING,LANGUAGE,SOURCE_LANG)

                                            SELECT FLEX_VALUE_ID,VERSION_SEQ_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,
                                                  LAST_UPDATE_LOGIN,DESCRIPTION,FLEX_VALUE_MEANING,p.LANGUAGE_code,SOURCE_LANG
                                            FROM EGO_FLEX_VALUE_VERSION_TL
                                            WHERE flex_value_id = l_vs_val_rec(1).flex_value_id
                                              AND version_seq_id  = G_OUT_VERSION_SEQ_ID
                                              AND "LANGUAGE" = UserEnv('lang');


                                        END IF;


                                    EXIT
                                      WHEN Cur_Trans_Lang%NOTFOUND;

                                    END LOOP;
                                    CLOSE Cur_Trans_Lang;

                                END LOOP; -- END FOR p IN Cur_NLS_Lang


                                -- Rollback to savepoint for any exception
                                /*IF l_return_status  = G_RET_STS_ERROR  THEN
                                  ROLLBACK TO CREATE_VERSION_VALUE_SET;
                                END IF; */



                                l_vs_val_rec.DELETE;

                                --Dbms_Output.put_line(' Procesing next version value : ');

                              END LOOP;-- END FOR l IN l_valueset_val_tab.first..l_valueset_val_tab.last LOOP

                            END IF; -- END IF l_valueset_val_tab.count>0 then




                          EXIT
                            WHEN l_valueset_val_tab.COUNT < 2000;
                          END LOOP; -- END FOR k IN Cur_Vers_Values
                          CLOSE Cur_Vers_Values; --(l_valueset_tab(j).value_set_name,l_valueset_tab(j).value_set_id,l_valueset_tab(j).version_seq_id);



                          --Bug 9710195
                          --Atlease one value does not exist.
                          IF NOT l_version_vs_val_exist THEN

                              l_return_status                     := G_RET_STS_ERROR;
                              x_return_status                     := l_return_status;
                              l_valueset_tab(j).process_status    := G_ERROR_RECORD;


                              ERROR_HANDLER.Add_Error_Message (
                                p_message_name                   => 'EGO_VERS_VS_VAL_REQ'
                                ,p_application_id                => G_App_Short_Name
                                ,p_token_tbl                     => G_TOKEN_TBL
                                ,p_message_type                  => G_RET_STS_ERROR
                                ,p_row_identifier                => l_valueset_tab(j).transaction_id
                                ,p_entity_code                   => G_ENTITY_VS_VER
                                ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );


                          END IF;



                          --Dbms_Output.put_line(' Before call to Sync_VS_With_Draft : l_return_status= '||l_return_status||' x_return_status = '||x_return_status);



                          -- If processing is done successfully then sync draft version
                          IF Nvl(l_return_status,G_RET_STS_SUCCESS) = G_RET_STS_SUCCESS  AND x_return_status<>G_RET_STS_ERROR THEN

                            -- Bug 9804379
                            -- If version created successfully then sync up draft version with latest release version
                            Sync_VS_With_Draft (  p_value_set_id    =>  l_valueset_tab(j).value_set_id,
                                                  p_version_number  =>  G_OUT_VERSION_SEQ_ID,
                                                  x_return_status   =>  l_return_status,
                                                  x_return_msg      =>  l_return_msg);


                            --Dbms_Output.put_line(' After call to Sync_VS_With_Draft : l_return_status= '||l_return_status);
                          END IF;


                          IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS ) THEN

                              x_return_status                     := G_RET_STS_SUCCESS;
                              l_return_status                     := G_RET_STS_SUCCESS;

                          ELSIF (l_return_status = G_RET_STS_ERROR ) THEN


                              write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_valueset_tab(j).transaction_id||'-(VS Id)=('
                                                        ||l_valueset_tab(j).value_set_id||')'||' Sync of draft version with latest release version failed. ');



                              x_return_status                     := l_return_status;
                              l_valueset_tab(j).process_status    := G_ERROR_RECORD;

		                          G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                              G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS_VER;
                              G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                              G_TOKEN_TBL(2).Token_Value  :=  l_valueset_tab(j).transaction_type;
                              G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                              G_TOKEN_TBL(3).Token_Value  :=  'EGO_VS_BULKLOAD_PVT';
                              G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                              G_TOKEN_TBL(4).Token_Value  :=  'Sync_VS_With_Draft';


                              ERROR_HANDLER.Add_Error_Message (
                                p_message_name                   => 'EGO_ENTITY_API_FAILED'
                                ,p_application_id                => G_App_Short_Name
                                ,p_token_tbl                     => G_TOKEN_TBL
                                ,p_message_type                  => G_RET_STS_ERROR
                                ,p_row_identifier                => l_valueset_tab(j).transaction_id
                                ,p_entity_code                   => G_ENTITY_VS_VER
                                ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

                              G_TOKEN_TBL.DELETE;


                          ELSE    -- case of unexpected error

                              x_return_status := G_RET_STS_UNEXP_ERROR;
                              x_return_msg    := l_return_msg;
                              RETURN;

                          END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN
                          --YJ





                      END IF; -- END IF l_return_status = G_RET_STS_SUCCESS THEN



                      --Dbms_Output.put_line(' Processed values for a version : Return status = '||x_return_status);



                      -- Rollback to savepoint for any exception
                      IF x_return_status  = G_RET_STS_ERROR  THEN

                          ROLLBACK TO CREATE_VERSION_VALUE_SET;

                          l_valueset_tab(j).process_status :=G_ERROR_RECORD;


                          write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_valueset_tab(j).transaction_id||'-(VS Id)=('
                                                    ||l_valueset_tab(j).value_set_id||')'||' Release of value set failed. ');


                          ERROR_HANDLER.Add_Error_Message (
                            p_message_name                   => 'EGO_VS_RELEASE_FAILED'
                            ,p_application_id                => G_App_Short_Name
                            ,p_token_tbl                     => G_TOKEN_TBL
                            ,p_message_type                  => G_RET_STS_ERROR
                            ,p_row_identifier                => l_valueset_tab(j).transaction_id
                            ,p_entity_code                   => G_ENTITY_VS_VER
                            ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );





                          --Dbms_Output.put_line(' Release API failed. Setting Val and _TL table to error record ');
                          OPEN Cur_Vers_Values(l_valueset_tab(j).value_set_name,l_valueset_tab(j).value_set_id,l_valueset_tab(j).version_seq_id);
                          LOOP


                            FETCH Cur_Vers_Values --(l_valueset_tab(j).value_set_name,l_valueset_tab(j).value_set_id,l_valueset_tab(j).version_seq_id)
                            BULK COLLECT INTO l_valueset_val_tab limit 2000;



                            IF l_valueset_val_tab.Count>0 THEN

                                FOR Val_Cur IN l_valueset_val_tab.first..l_valueset_val_tab.last
                                LOOP


                                    -- Set process status for version value
                                    l_valueset_val_tab(Val_Cur).process_status    := l_valueset_tab(j).process_status;
                                    l_valueset_val_tab(Val_Cur).transaction_type  := l_valueset_tab(j).transaction_type;


                                    write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_valueset_tab(j).transaction_id||'-(VS Id)=('
                                                              ||l_valueset_val_tab(Val_Cur).transaction_id||')'||' Release of value set failed. ');


                                    ERROR_HANDLER.Add_Error_Message (
                                      p_message_name                   => 'EGO_VS_RELEASE_FAILED'
                                      ,p_application_id                => G_App_Short_Name
                                      ,p_token_tbl                     => G_TOKEN_TBL
                                      ,p_message_type                  => G_RET_STS_ERROR
                                      ,p_row_identifier                => l_valueset_val_tab(Val_Cur).transaction_id
                                      ,p_entity_code                   => G_ENTITY_VS_VER
                                      ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );





                                    OPEN Cur_Vers_Trans_Values ( l_valueset_val_tab(Val_Cur).value_set_name,l_valueset_val_tab(Val_Cur).value_set_id,
                                                                l_valueset_val_tab(Val_Cur).version_seq_id,l_valueset_val_tab(Val_Cur).flex_value,l_valueset_val_tab(Val_Cur).flex_value_id );
                                    LOOP


                                        FETCH Cur_Vers_Trans_Values BULK COLLECT INTO l_valueset_val_tl_tbl limit 50;


                                        FOR Tl_Val IN l_valueset_val_tl_tbl.first..l_valueset_val_tl_tbl.last LOOP

                                            l_valueset_val_tl_tbl(Tl_Val).process_status      := l_valueset_tab(j).process_status;
                                            l_valueset_val_tl_tbl(Tl_Val).transaction_type   := l_valueset_tab(j).transaction_type;



                                            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_valueset_tab(j).transaction_id||'-(VS Id)=('
                                                                      ||l_valueset_val_tl_tbl(Tl_Val).transaction_id||')'||' Release of value set failed. ');

                                            ERROR_HANDLER.Add_Error_Message (
                                              p_message_name                   => 'EGO_VS_RELEASE_FAILED'
                                              ,p_application_id                => G_App_Short_Name
                                              ,p_token_tbl                     => G_TOKEN_TBL
                                              ,p_message_type                  => G_RET_STS_ERROR
                                              ,p_row_identifier                => l_valueset_val_tl_tbl(Tl_Val).transaction_id
                                              ,p_entity_code                   => G_ENTITY_VS_VER
                                              ,p_table_name                    => G_ENTITY_VAL_TL_HEADER_TAB );

                                        END LOOP;

                                        l_vs_val_rec(1) :=l_valueset_val_tab(Val_Cur);


                                        Populate_VS_Val_Interface (l_vs_val_rec,l_return_status,l_return_msg);


                                        -- Populate Values
                                        Populate_VS_Val_Tl_Interface (l_valueset_val_tl_tbl,l_return_status,l_return_msg);

                                        -- Release Values.


                                    EXIT
                                        WHEN l_valueset_val_tl_tbl.COUNT < 50;

                                    END LOOP; -- END FOR m IN  Cur_Vers_Trans_Values ( l_valueset_val_tab(l).value_set_name,
                                    CLOSE Cur_Vers_Trans_Values;

                                    l_vs_val_rec.DELETE;


                                END LOOP;-- END FOR l IN l_valueset_val_tab.first..l_valueset_val_tab.last LOOP

                            END IF; -- END IF l_valueset_val_tab.count>0 then




                          EXIT
                            WHEN l_valueset_val_tab.COUNT < 2000;
                          END LOOP; -- END FOR k IN Cur_Vers_Values
                          CLOSE Cur_Vers_Values; --(l_valueset_tab(j).value_set_name,l_valueset_tab(j).value_set_id,l_valueset_tab(j).version_seq_id);

                      END IF; -- END IF x_return_status  = G_RET_STS_ERROR  THEN



                      IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS AND x_return_status<>G_RET_STS_ERROR ) THEN

                        l_valueset_tab(j).process_status    := G_SUCCESS_RECORD;


                      END IF;



                    END IF; -- l_valueset_tab(j).process_status <> G_ERROR_RECORD THEN

                    l_valueset_rec(1) :=  l_valueset_tab(j);

                    Populate_VS_Interface ( l_valueset_rec, l_return_status,l_return_msg);

                    l_valueset_rec.DELETE;
                    l_version_vs_val_exist := FALSE; --Bug 9710195


                  END LOOP; -- END FOR j IN l_valueset_tab.first..l_valueset_tab.last LOOP

                  --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  Processed VS '||l_valueset_tab.COUNT );

                  -- Issue a commit after each iteration
                  COMMIT;

              END IF; --END IF  l_valueset_tab.Count>0 THEN



        EXIT WHEN l_valueset_tab.COUNT < 2000;
        END LOOP; -- END LOOP

        CLOSE Cur_Vers_VS;



        IF x_return_status = G_RET_STS_ERROR THEN
            l_return_status :=G_RET_STS_ERROR;
        END IF;


        write_debug(G_PKG_Name,l_api_name,' Versioned value set is created. Return Status is '||l_return_status);
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Versioned value set is created. Return Status is '||l_return_status);









        --==================================================
        -- Part3: - Process Child value Set
        --==================================================

        write_debug(G_PKG_Name,l_api_name,' Before processing Child VS ' );
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Before processing Child VS ' );

        OPEN Cur_Child_VS;
        LOOP

            FETCH Cur_Child_VS BULK COLLECT INTO l_valueset_tab;-- limit 2000;

            write_debug(G_PKG_Name,l_api_name,' Count of record in table for child VS = '||l_valueset_tab.Count  );
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Count of record in table for child VS = '||l_valueset_tab.Count);

        EXIT WHEN Cur_Child_VS%NOTFOUND;

        END LOOP;  -- END FOR i IN Cur_Child_VS
        CLOSE Cur_Child_VS;




        --FOR k IN Cur_Child_Values
        OPEN Cur_Child_Values;
        LOOP

            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' fetching record from child values ');

            FETCH Cur_Child_Values BULK COLLECT INTO l_valueset_val_tab;

            write_debug(G_PKG_Name,l_api_name,' Count of record in table for child VS Values  = '||l_valueset_val_tab.Count  );
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Count of record in table for child VS Values = '||l_valueset_val_tab.Count );

        EXIT WHEN Cur_Child_Values%NOTFOUND;

        END LOOP; -- END LOOP

        CLOSE Cur_Child_Values;





        IF l_valueset_tab.Count>0 THEN

          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Call to Process_Child_Value_Set  API ');
          Process_Child_Value_Set (1,l_valueset_tab,l_valueset_val_tab,p_set_process_id,FALSE,l_return_status,l_msg_count,l_return_msg);

          -- check the return status
          IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS ) THEN

              l_return_status:= G_RET_STS_SUCCESS;


          ELSIF  ( l_return_status =  G_RET_STS_UNEXP_ERROR ) THEN -- case of unexpected error
              x_return_status := G_RET_STS_UNEXP_ERROR;
              x_return_msg    := l_return_msg;
              RETURN;

          ELSE

            x_return_status:= G_RET_STS_ERROR;

          END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN




          --2.1.8-- Convert back pl/sql table to interface table data
          Populate_VS_Interface ( l_valueset_tab, l_return_status,l_return_msg);


          -- check the return status
          IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS ) THEN

              l_return_status:= G_RET_STS_SUCCESS;

          ELSIF  ( l_return_status =  G_RET_STS_UNEXP_ERROR ) THEN -- case of unexpected error
              x_return_status := G_RET_STS_UNEXP_ERROR;
              x_return_msg    := l_return_msg;
              RETURN;

          ELSE

            x_return_status:= G_RET_STS_ERROR;

          END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN





          -- Populate Values
          Populate_VS_Val_Interface (l_valueset_val_tab, l_return_status,l_return_msg);


          -- check the return status
          IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS ) THEN

              l_return_status:= G_RET_STS_SUCCESS;

          ELSIF  ( l_return_status =  G_RET_STS_UNEXP_ERROR ) THEN -- case of unexpected error
              x_return_status := G_RET_STS_UNEXP_ERROR;
              x_return_msg    := l_return_msg;
              RETURN;

          ELSE

              x_return_status:= G_RET_STS_ERROR;

          END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN

          -- call delete API if flag is true
          /*IF (delete_flag = TRUE ) THEN

            Delete_Processed_Value_Sets(p_set_process_id,x_return_status,x_return_msg);
          END IF;  */

          -- Issue a commit after each iteration
          COMMIT;

          write_debug(G_PKG_Name,l_api_name,' Processing for child VS is done. Return status = '||l_return_status );
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  Processing for child VS is done. Return status = '||l_return_status);


        END IF; -- END IF l_valueset_tab.Count>0 THEN






        --==================================================
        -- Part4: - Process orphan values or translatable values.
        --==================================================
        -- Processing of orphan
        OPEN Cur_Orphan_val;
        LOOP

            FETCH Cur_Orphan_val BULK COLLECT INTO l_valueset_val_tab limit 2000;

            IF l_valueset_val_tab.Count>0 THEN

                --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Calling Process_Isolate_Value API ');

                Process_Isolate_Value (1,l_valueset_val_tab,l_valueset_val_tl_tbl,p_set_process_id,FALSE,l_return_status,l_msg_count,l_return_msg);

                --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Processing is done. ');

                -- Populate Values
                Populate_VS_Val_Interface (l_valueset_val_tab,l_return_status,l_return_msg);



            END IF; -- END IF l_valueset_val_tab.Count>0 THEN

        EXIT WHEN Cur_Orphan_val%NOTFOUND;

        END LOOP; -- END FOR CurValue IN Cur_Orphan_val

        CLOSE Cur_Orphan_val;





        -- Process TL Data based on each languge
        FOR i IN Cur_NLS_Lang
        LOOP
          l_install_lang  :=  i.language_code;
          l_nls_language  :=  i.nls_language;


          l_dynamic_sql   := 'ALTER SESSION SET NLS_LANGUAGE = '||l_nls_language;

          write_debug(G_PKG_Name,l_api_name,' Prepared dynamic sql to set NLS language. SQL statement is  : '||l_dynamic_sql );
          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Prepared dynamic sql to set NLS language. SQL statement is  : '||l_dynamic_sql );

          EXECUTE IMMEDIATE l_dynamic_sql;




          --1.3 Process orphan _TL interface records
          OPEN Cur_Orphan_Trans_Values (l_install_lang);
          LOOP

            FETCH Cur_Orphan_Trans_Values  BULK COLLECT INTO l_valueset_val_tl_tbl limit 2000;

              IF l_valueset_val_tl_tbl.Count>0 THEN

                Process_Isolate_Value (1,l_valueset_val_tab,l_valueset_val_tl_tbl,p_set_process_id,FALSE,l_return_status,l_msg_count,l_return_msg);

                ----Dbms_Output.put_line(' Process_Isolated_Value for TL:  Processing is done. l_return_status = '||l_return_status);

                -- Populate Values
                Populate_VS_Val_Tl_Interface (l_valueset_val_tl_tbl,l_return_status,l_return_msg);

              END IF; -- END IF l_valueset_val_tl_tab.Count>0 THEN


            EXIT WHEN Cur_Orphan_Trans_Values%NOTFOUND;

          END LOOP;
          CLOSE Cur_Orphan_Trans_Values;

          write_debug(G_PKG_Name,l_api_name,' Completed processing of values for language : ' ||l_nls_language);


        END LOOP; -- END FOR i IN Cur_NLS_Lang

        COMMIT;

        l_dynamic_sql   := NULL;

        l_dynamic_sql   := 'ALTER SESSION SET NLS_LANGUAGE = '||G_NLS_LANGUAGE;

        write_debug(G_PKG_Name,l_api_name,' Prepared dynamic sql to set NLS language to base language  '||l_dynamic_sql );

        EXECUTE IMMEDIATE l_dynamic_sql;








        IF l_return_status IS NULL
        THEN
          l_return_status    := G_RET_STS_SUCCESS;
        END IF;

        IF  Nvl(x_return_status,G_RET_STS_SUCCESS)  <> G_RET_STS_ERROR AND  l_return_status  = G_RET_STS_SUCCESS THEN

          x_return_status :=  l_return_status;

        END IF; -- END IF  x_return_status <> G_RET_STS_ERROR AND  l_return_status  = G_RET_STS_SUCCESS;


        write_debug(G_PKG_Name,l_api_name,' End of API ' );
        ----Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API ' );

  EXCEPTION
      WHEN OTHERS THEN

          write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
          ----Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );

          x_return_status := G_RET_STS_UNEXP_ERROR;
          x_return_msg := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	      RETURN;

  END Import_Value_Set_Intf;






--------------------------------------------------------------------------------
-- Procedure to process value set
--------------------------------------------------------------------------------
PROCEDURE Process_Value_Set (
                          p_api_version      IN            NUMBER,
                          p_value_set_tbl    IN OUT NOCOPY Ego_Metadata_Pub.Value_Set_Tbl,
                          p_set_process_id   IN            NUMBER,
                          p_commit           IN            BOOLEAN DEFAULT FALSE,
                          x_return_status    OUT NOCOPY    VARCHAR2,
                          x_msg_count        OUT NOCOPY    NUMBER,
                          x_return_msg         OUT NOCOPY    VARCHAR2)

IS

      l_api_name               VARCHAR2(30) :='Process_Value_Set';
      --if we change required parameters, version goes from n.x to (n+1).x, if we change optional parameters, version goes from x.n to x.(n+1)
      l_api_version            NUMBER := 1.0;
      l_owner                  NUMBER := G_USER_ID;

      l_value_set_name         FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE; -- VARCHAR2(60);
      l_value_set_id           FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_ID%TYPE;
      l_description            FND_FLEX_VALUE_SETS.description%TYPE;
      l_version_description    VARCHAR2(2000);

      l_longlist_flag          VARCHAR2(1);
      l_format_code            VARCHAR2(1);
      l_validation_code        VARCHAR2(1);

      l_parent_value_set_name  FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE; -- VARCHAR2(60);
      l_version_seq_id         NUMBER(10,0);
      l_start_active_date      DATE;
      l_end_active_date        DATE;

      l_maximum_size           FND_FLEX_VALUE_SETS.MAXIMUM_SIZE%TYPE; --NUMBER;
      l_maximum_value          FND_FLEX_VALUE_SETS.MAXIMUM_VALUE%TYPE;
      l_minimum_value          FND_FLEX_VALUE_SETS.MINIMUM_VALUE%TYPE;

      l_transaction_type       VARCHAR2(20);
      l_process_status         NUMBER;
      l_request_id             NUMBER;
      l_program_application_id NUMBER(15,0);
      l_program_id             NUMBER(15,0);
      l_program_update_date    DATE;
      l_set_process_id         NUMBER;

      l_last_update_date       DATE;
      l_last_updated_by        NUMBER(15);
      l_creation_date          DATE;
      l_created_by             NUMBER(15);
      l_last_update_login      NUMBER(15);


      l_value_column_name        fnd_flex_validation_tables.value_column_name%TYPE;
      l_value_column_type        fnd_flex_validation_tables.value_column_type%TYPE;
      l_value_column_size        fnd_flex_validation_tables.value_column_size%TYPE;
      l_id_column_name           fnd_flex_validation_tables.id_column_name%TYPE;
      l_id_column_size           fnd_flex_validation_tables.id_column_size%TYPE;
      l_id_column_type           fnd_flex_validation_tables.id_column_type%TYPE;
      l_meaning_column_name      fnd_flex_validation_tables.meaning_column_name%TYPE;
      l_meaning_column_size      fnd_flex_validation_tables.meaning_column_size%TYPE;
      l_meaning_column_type      fnd_flex_validation_tables.meaning_column_type%TYPE;
      l_table_application_id     fnd_flex_validation_tables.table_application_id%TYPE;
      l_application_table_name   fnd_flex_validation_tables.application_table_name%TYPE;
      l_additional_where_clause  VARCHAR2(2000);

      l_return_status          VARCHAR2(1);
      l_versioned_vs           VARCHAR2(10):= 'False'; -- Parameter to get value if vs is versioned.

      -- target system parameter
      --l_target_max_ver         NUMBER; --Max version_seq_id at target system
      l_current_version        NUMBER; -- Current effective version at target system
      l_future_version         NUMBER;

      l_api_mode               NUMBER         :=  G_FLOW_TYPE;
      l_entity_code            VARCHAR2(40)   :=  G_ENTITY_VS;
      l_table_name             VARCHAR2(240)  :=  G_ENTITY_VS_HEADER_TAB;
      l_application_id         NUMBER         := G_Application_Id;

      l_token_table            ERROR_HANDLER.Token_Tbl_Type;

      l_error_message_name     VARCHAR2(500);
      l_error_row_identifier   NUMBER;
      l_transaction_id	       NUMBER;
      l_return_msg	           VARCHAR2(1000);
      l_table_exist            NUMBER := NULL;


      CURSOR Cur_table ( cp_value_set_id NUMBER )
      IS
      SELECT 1 AS table_exist
      FROM fnd_flex_validation_tables
      WHERE FLEX_VALUE_SET_ID= cp_value_set_id;



      -- Cursor to get value_set_id for a passed in value set name
      CURSOR  cur_value_set_id(cp_value_set_name  VARCHAR2) IS
        SELECT flex_value_set_id
        FROM fnd_flex_value_sets
        WHERE flex_value_set_name = cp_value_set_name;



      -- Cursor to check current effective version in target system
      CURSOR cur_current_version(cp_value_set_id NUMBER ) IS
        SELECT version_seq_id,start_active_date, end_active_date
        FROM ego_flex_valueset_version_b
        WHERE flex_value_set_id = cp_value_set_id
          AND start_active_date <= SYSDATE
          AND Nvl(end_active_date,sysdate)>= SYSDATE ;


      -- Cursor to get max version seq id for a value set in target system.
      CURSOR cur_max_ver(cp_value_set_id  NUMBER)  IS
      SELECT Max(Nvl(version_seq_id,0))   max_version
      FROM ego_flex_valueset_version_b
      WHERE flex_value_set_id = cp_value_set_id;


      -- Cursor to get future version which has max end active date but lesser then passed in start active date
      CURSOR cur_max_future_ver(cp_value_set_id       NUMBER,
                                cp_start_active_date  DATE ) IS
      SELECT version_seq_id, start_active_date, end_active_date
      FROM ego_flex_valueset_version_b
      WHERE flex_value_set_id = cp_value_set_id
        AND ( start_active_date = (
                                    SELECT Max(start_active_date )
                                    FROM  EGO_FLEX_VALUESET_VERSION_B
                                    WHERE   FLEX_VALUE_SET_ID =  cp_value_set_id
                                      AND Nvl(end_active_date,SYSDATE) <= cp_start_active_date
                                  )
            );


BEGIN

    write_debug(G_PKG_Name,l_api_name,' Start of API. ' );
    ----Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API. ' );


    -- Error handler initialization
    ERROR_HANDLER.Set_Bo_Identifier(G_BO_IDENTIFIER_VS);

    -- Get application id
    SELECT application_id
      INTO l_application_id
    FROM fnd_application
    WHERE application_short_name ='EGO';


    -- Get the owner from the session info
    l_owner := g_user_id;

    -- Get detail for each record of value set
    FOR i IN p_value_set_tbl.first..p_value_set_tbl.last
    LOOP
        --Assigning value per record
        l_value_set_name          :=  p_value_set_tbl(i).value_set_name;
        l_value_set_id            :=  p_value_set_tbl(i).value_set_id;
        l_description             :=  p_value_set_tbl(i).description;
                                      /*CASE p_value_set_tbl(i).description
                                          WHEN G_NULL_CHAR THEN NULL
                                          ELSE p_value_set_tbl(i).description
                                      END;*/
        l_version_description     :=  p_value_set_tbl(i).version_description;
        l_format_code             :=  p_value_set_tbl(i).format_type;
        l_longlist_flag           :=  p_value_set_tbl(i).longlist_flag;
        l_validation_code         :=  p_value_set_tbl(i).validation_type;
        l_parent_value_set_name   :=  p_value_set_tbl(i).parent_value_set_name;
                                      /*CASE p_value_set_tbl(i).parent_value_set_name
                                          WHEN G_NULL_CHAR THEN NULL
                                          ELSE p_value_set_tbl(i).parent_value_set_name;*/
        l_version_seq_id          :=  p_value_set_tbl(i).version_seq_id;
        l_start_active_date       :=  p_value_set_tbl(i).start_active_date;
        l_end_active_date         :=  p_value_set_tbl(i).end_active_date;
        l_maximum_size            :=  p_value_set_tbl(i).maximum_size;
        l_minimum_value           :=  p_value_set_tbl(i).minimum_value;
        l_maximum_value           :=  p_value_set_tbl(i).maximum_value;

        l_transaction_type        :=  p_value_set_tbl(i).transaction_type;
        l_transaction_id          :=  p_value_set_tbl(i).transaction_id;
        -- Conc prog who columns
        l_process_status          :=  p_value_set_tbl(i).process_status;
        l_set_process_id          :=  p_value_set_tbl(i).set_process_id;

        l_request_id              :=  p_value_set_tbl(i).request_id;
        l_program_update_date     :=  p_value_set_tbl(i).program_update_date;
        l_program_application_id  :=  p_value_set_tbl(i).program_application_id;
        l_program_id              :=  p_value_set_tbl(i).program_id;

        l_last_update_date        :=  p_value_set_tbl(i).last_update_date;
        l_last_updated_by         :=  p_value_set_tbl(i).last_updated_by;
        l_creation_date           :=  p_value_set_tbl(i).creation_date;
        l_created_by              :=  p_value_set_tbl(i).created_by;
        l_last_update_login       :=  p_value_set_tbl(i).last_update_login;


        l_value_column_name       :=  p_value_set_tbl(i).value_column_name;
        l_value_column_type       :=  p_value_set_tbl(i).value_column_type;
        l_value_column_size       :=  p_value_set_tbl(i).value_column_size;
        l_id_column_name          :=  p_value_set_tbl(i).id_column_name;
        l_id_column_size          :=  p_value_set_tbl(i).id_column_size;
        l_id_column_type          :=  p_value_set_tbl(i).id_column_type;
        l_meaning_column_name     :=  p_value_set_tbl(i).meaning_column_name;
        l_meaning_column_size     :=  p_value_set_tbl(i).meaning_column_size;
        l_meaning_column_type     :=  p_value_set_tbl(i).meaning_column_type;
        l_table_application_id    :=  p_value_set_tbl(i).table_application_id;
        l_application_table_name  :=  p_value_set_tbl(i).application_table_name;
        l_additional_where_clause :=  p_value_set_tbl(i).additional_where_clause;

        l_error_row_identifier    := l_transaction_id;


        write_debug(G_PKG_Name,l_api_name,' : In loop to process each value set. Value Set name is : = '||l_value_set_name ||' value_set_id = '||l_value_set_id);
        ----Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' : In loop to process each value set. Value Set name is : = '||l_value_set_name ||' value_set_id = '||l_value_set_id);

        IF (l_value_set_id IS NULL AND  l_value_set_name IS NULL )
        THEN

            l_error_message_name          := 'EGO_VALUE_SET_REQUIRED_FIELD'; -- Seed message?  Please provide either value id or name
            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
            l_token_table(1).TOKEN_VALUE  := l_value_set_name;

            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_ID';
            l_token_table(1).TOKEN_VALUE  := l_value_set_id;


            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

            l_token_table.DELETE;

            -- Set process_status to 3
            l_process_status    := g_error_record;
            l_return_status     := G_RET_STS_ERROR;
            l_last_updated_by   := g_user_id;
            l_last_update_date  := SYSDATE;
            l_last_update_login := g_login_id;

        END IF; -- END IF (l_value_set_id IS NULL AND  l_value_set_name IS NULL )


        IF l_value_set_id IS NOT NULL THEN
          -- Get Value Set Name
          Convert_Id_To_Name (l_value_set_id ,G_Value_Set,NULL,l_value_set_name);

          --
          IF l_value_set_id IS NULL THEN

            l_error_message_name          := 'EGO_VSET_INVALID_ID';

            -- Set process_status to 3
            l_process_status    := g_error_record;
            l_return_status     := G_RET_STS_ERROR;
            l_last_updated_by   := g_user_id;
            l_last_update_date  := SYSDATE;
            l_last_update_login := g_login_id;



            ERROR_HANDLER.Add_Error_Message(
              p_message_name                   => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

          END IF; -- END IF l_value_set_id IS NULL THEN



        END IF;-- END IF l_value_set_id IS NOT NULL THEN



        IF ( l_value_set_name IS NOT NULL AND l_value_set_id IS NULL ) THEN
          -- Get value Set Id
          Convert_Name_To_Id (l_value_set_name,G_Value_Set,NULL,l_value_set_id);
        END IF; -- END IF ( l_value_set_name IS NOT NULL AND l_value_set_id IS NULL ) THEN

        --Dbms_Output.put_line(' After conversion : l_value_set_id = '||l_value_set_id||' Name= '||l_value_set_name);

        /*-- Get value set id if value set name is passed
        IF l_value_set_id IS NULL AND  l_value_set_name IS NOT NULL THEN
          FOR j IN cur_value_set_id(l_value_set_name)
          LOOP
            l_value_set_id:= j.flex_value_set_id;
          END LOOP;
        END IF;--END IF l_value_set_id IS NULL AND  l_value_set_name IS NOT NULL THEN
        */

        IF l_transaction_type  =G_CREATE AND l_value_set_id IS NOT NULL AND l_version_seq_id IS NULL THEN
            --Dbms_Output.put_line(' Creation error FEM_ADMIN_VSNAME_EXISTS_ERR ');

            l_error_message_name          := 'FEM_ADMIN_VSNAME_EXISTS_ERR';


            ERROR_HANDLER.Add_Error_Message(
              p_message_name                   => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );


            -- Set process_status to 3
            l_process_status    := g_error_record;
            l_return_status     := G_RET_STS_ERROR;
            l_last_updated_by   := g_user_id;
            l_last_update_date  := SYSDATE;
            l_last_update_login := g_login_id;



        END IF ; -- END IF l_transaction_type  :=G_CREATE AND l_value_set_id IS NOT NULL THEN





        IF l_transaction_type  =G_UPDATE AND l_value_set_id IS NULL THEN

            l_error_message_name          := 'EGO_TRANS_TYPE_INVALID';
            l_token_table(1).TOKEN_NAME   := 'Entity';
            l_token_table(1).TOKEN_VALUE  := G_ENTITY_VS;

            -- Set process_status to 3
            l_process_status    := g_error_record;
            l_return_status     := G_RET_STS_ERROR;
            l_last_updated_by   := g_user_id;
            l_last_update_date  := SYSDATE;
            l_last_update_login := g_login_id;


            ERROR_HANDLER.Add_Error_Message(
              p_message_name                   => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );


            l_token_table.DELETE;


        END IF ; -- END IF l_transaction_type  :=G_CREATE AND l_value_set_id IS NOT NULL THEN







        --Check for transaction type and update it correctly
        IF l_transaction_type  =G_SYNC THEN

          -- If value set name already exist then transactiono type is Create else it is Update
          IF l_value_set_id IS NULL
          THEN
            l_transaction_type  :=G_CREATE;
          ELSE
            l_transaction_type  :=G_UPDATE;
          END IF;

        END IF; -- END IF l_transaction_type  =G_SYNC THEN
       write_debug(G_PKG_Name,l_api_name,'  : Transaction type resolved : '||l_transaction_type);
       --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  : Transaction type resolved : '||l_transaction_type);





        IF l_transaction_type=G_UPDATE THEN

            --Get value of require field if they are null
            Get_Key_VS_Columns   (p_value_set_id        => l_value_set_id,
                                  p_transaction_id      => l_transaction_id,
                                  x_maximum_size        => l_maximum_size,
                                  x_maximum_value       => l_maximum_value,
                                  x_minimum_value       => l_minimum_value,
                                  x_description         => l_description,
                                  x_longlist_flag       => l_longlist_flag,
                                  x_format_code         => l_format_code,
                                  x_validation_code     => l_validation_code,
                                  x_return_status       => l_return_status,
                                  x_return_msg          => l_return_msg
                                );



            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' After Getting Key Values x_validation_code = '||l_validation_code );

            -- check the return status
            IF (Nvl(l_return_status,G_RET_STS_SUCCESS)  =G_RET_STS_SUCCESS ) THEN

              l_process_status:= G_PROCESS_RECORD;

            ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

              x_return_status := l_return_status;
              l_process_status:= G_ERROR_RECORD;

              G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
              G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS;
              G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
              G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
              G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
              G_TOKEN_TBL(3).Token_Value  :=  'EGO_VS_BULKLOAD_PVT';
              G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
              G_TOKEN_TBL(4).Token_Value  :=  'Get_Key_VS_Columns';


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => 'EGO_ENTITY_API_FAILED'
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => G_TOKEN_TBL
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => G_ENTITY_VS
                ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

            ELSE

              write_debug(G_PKG_Name,l_api_name,' : Unexpected exceptioon ' );
              x_return_status :=  G_RET_STS_UNEXP_ERROR;
              x_return_msg    :=  l_return_msg;
              RETURN;

            END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN


        END IF;-- END IF l_transaction_type=G_UPDATE THEN

        -- Bug 9702845
        Validate_value_Set (l_value_set_name,
                            l_validation_code,
                            l_longlist_flag,
                            l_format_code,
                            l_maximum_size,
                            l_maximum_value,
                            l_minimum_value,
                            l_version_seq_id,
                            l_transaction_id,
                            l_transaction_type,
                            l_return_status,
                            l_return_msg);


        IF l_format_code IN (G_DATE_DATA_TYPE , G_DATE_TIME_DATA_TYPE) THEN


            IF  l_format_code =G_DATE_DATA_TYPE THEN

                    l_maximum_size := 11;

            ELSE

                    l_maximum_size := 20;

            END IF;-- END IF

        END IF;




        -- check the return status
        IF (l_return_status =G_RET_STS_UNEXP_ERROR )
        THEN

          write_debug(G_PKG_Name,l_api_name,' Unexpected error occured in Validate_value_Set API l_return_msg ='||l_return_msg);

          x_return_status :=  G_RET_STS_UNEXP_ERROR;
          x_return_msg    :=  l_return_msg;
          RETURN;

        ELSIF (l_return_status =G_RET_STS_ERROR ) THEN


          write_debug(G_PKG_Name,l_api_name,' Err_Msg-TID='  ||l_transaction_id||'-(VS,VS Id)=('
                                                                ||l_value_set_name||','||l_value_set_id||')'||' Validation of value set failed. ');


          l_process_status := G_ERROR_RECORD;

        END IF; -- END IF (l_return_status =G_RET_STS_UNEXP_ERROR )




        IF l_validation_code=G_TABLE_VALIDATION_CODE THEN

            IF (  l_application_table_name  IS NOT NULL     OR  l_value_column_name  IS NOT NULL
                  OR  l_value_column_type   IS NOT NULL     OR  l_value_column_size  IS NOT NULL
                  OR  l_additional_where_clause IS NOT NULL ) THEN


                        Validate_Table_Value_Set ( l_value_set_name,
                                                   l_value_set_id,
                                                   l_format_code,
                                                   l_application_table_name,
                                                   l_additional_where_clause,
                                                   l_value_column_name,
                                                   l_value_column_type,
                                                   l_value_column_size,
                                                   l_id_column_name,
                                                   l_id_column_type,
                                                   l_id_column_size,
                                                   l_meaning_column_name,
                                                   l_meaning_column_type,
                                                   l_meaning_column_size,
                                                   l_transaction_id,
                                                   l_return_status,
                                                   l_return_msg) ;

                        -- check the return status
                        IF (l_return_status =G_RET_STS_UNEXP_ERROR )
                        THEN

                            x_return_status :=  G_RET_STS_UNEXP_ERROR;
                            x_return_msg    :=  l_return_msg;
                            RETURN;

                        ELSIF (l_return_status =G_RET_STS_ERROR ) THEN


                            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID='  ||l_transaction_id||'-(VS,VS Id)=('
                                                                                  ||l_value_set_name||','||l_value_set_id||')'||' Validation of table type value set failed. ');


                            l_process_status := G_ERROR_RECORD;

                        END IF; -- END IF (l_return_status =G_RET_STS_UNEXP_ERROR )


            END IF;

        END IF;


       write_debug(G_PKG_Name,l_api_name,' All validation done. Process status is  '||l_process_status);
       --Dbms_Output.put_line(G_PKG_Name||','||l_api_name||' All validation done. Process status is  '||l_process_status);



        -- Start processing value set based on transaction type.
        --Check for transaction type.

        --*******CREATE MODE ***********--
        IF l_process_status = G_PROCESS_RECORD THEN

          IF l_transaction_type=G_CREATE THEN

            /*  Validate_value_Set (l_value_set_name,
                                  l_validation_code,
                                  l_longlist_flag,
                                  l_format_code,
                                  l_version_seq_id,
                                  l_transaction_id,
                                  l_transaction_type,
                                  l_return_status,
                                  l_return_msg);

            -- check the return status
            IF (l_return_status =G_RET_STS_UNEXP_ERROR )
            THEN

              x_return_status :=  G_RET_STS_UNEXP_ERROR;
              x_return_msg    :=  l_return_msg;
              RETURN;

            ELSIF (l_return_status =G_RET_STS_ERROR ) THEN

              l_process_status := G_ERROR_RECORD;

            END IF; -- END IF (l_return_status =G_RET_STS_UNEXP_ERROR )
            */

            -- If value set is of type table then create value set and corresponding values.
            -- No concept of version will be there for it.
            IF l_validation_code=G_TABLE_VALIDATION_CODE THEN
              --Write code to create VS and values for table type.
              IF l_process_status = G_PROCESS_RECORD  THEN

                EGO_EXT_FWK_PUB.Create_Value_Set
                  (
                    p_api_version                   => 1.0
                    ,p_value_set_name                => l_value_set_name
                    ,p_description                   => l_description
                    ,p_format_code                   => l_format_code
                    ,p_maximum_size                  => l_maximum_size
                    ,p_maximum_value                 => l_maximum_value
                    ,p_minimum_value                 => l_minimum_value
                    ,p_long_list_flag                => l_longlist_flag
                    ,p_validation_code               => G_TABLE_VALIDATION_CODE
                    ,p_owner                         => l_owner
                    ,p_init_msg_list                 => fnd_api.g_FALSE
                    ,p_commit                        => fnd_api.g_FALSE
                    ,x_value_set_id                  => l_value_set_id
                    ,x_return_status                 => l_return_status
                    ,x_msg_count                     => x_msg_count
                    ,x_msg_data                      => l_return_msg
                  );

              END IF; -- IF l_process_status = G_PROCESS_RECORD  THEN


              -- check the return status
              IF (Nvl(l_return_status,G_RET_STS_SUCCESS)  =G_RET_STS_SUCCESS ) THEN

                l_process_status:= G_PROCESS_RECORD;

              ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                l_return_status := l_return_status;
                l_process_status:= G_ERROR_RECORD;


		            G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS;
                G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB';
                G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                G_TOKEN_TBL(4).Token_Value  :=  'Create_Value_Set';



                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                   => 'EGO_ENTITY_API_FAILED'
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => G_TOKEN_TBL
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => G_ENTITY_VS
                  ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

                G_TOKEN_TBL.DELETE;

              ELSE


                write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                             ||l_value_set_name||','||l_value_set_id||')'||' Creation of table type value set failed. Call to EGO_EXT_FWK_PUB.Create_Value_Set threw unexpected error ');


                x_return_status :=  G_RET_STS_UNEXP_ERROR;
                x_return_msg:= l_return_msg;
                RETURN;

              END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN

              -- If table information is provided then it is compulsory to have value in (value_column_name,value_column_type,value_column_size)

              IF ( l_application_table_name  IS NOT NULL  AND l_value_column_name IS NOT NULL
                   AND l_value_column_type   IS NOT NULL  AND l_value_column_size  IS NOT NULL ) THEN

                IF l_process_status = G_PROCESS_RECORD  THEN

                  EGO_EXT_FWK_PUB.Insert_Value_Set_Table_Inf
                    (
                      p_api_version                   => 1.0
                      ,p_value_set_id                  => l_value_set_id
                      ,p_table_application_id          => l_table_application_id
                      ,p_table_name                    => l_application_table_name
                      ,p_value_column_name             => l_value_column_name
                      ,p_value_column_type             => l_value_column_type
                      ,p_value_column_size             => l_value_column_size
                      ,p_meaning_column_name           => l_meaning_column_name
                      ,p_meaning_column_type           => l_meaning_column_type   -- Bug 9705126
                      ,p_meaning_column_size           => l_meaning_column_size
                      ,p_id_column_name                => l_id_column_name
                      ,p_id_column_type                => l_id_column_type
                      ,p_id_column_size                => l_id_column_size
                      ,p_where_order_by                => l_additional_where_clause
                      ,p_additional_columns            => ''
                      ,p_owner                         => l_owner --G_CURRENT_USER_ID
                      ,p_init_msg_list                 => fnd_api.g_FALSE
                      ,p_commit                        => fnd_api.g_FALSE
                      ,x_return_status                 => l_return_status
                      ,x_msg_count                     => x_msg_count
                      ,x_msg_data                      => l_return_msg
                    );

                END IF; -- END IF l_process_status = G_PROCESS_RECORD  THEN
                -- check the return status
                IF (Nvl(l_return_status, G_RET_STS_SUCCESS )  =G_RET_STS_SUCCESS ) THEN

                  l_process_status:= G_PROCESS_RECORD;

                ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                  l_return_status := l_return_status;
                  l_process_status:= G_ERROR_RECORD;


		              G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                  G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS_TABLE;
                  G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                  G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                  G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                  G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB';
                  G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                  G_TOKEN_TBL(4).Token_Value  :=  'Insert_Value_Set_Table_Inf';


                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                   => 'EGO_ENTITY_API_FAILED'
                    ,p_application_id                => G_App_Short_Name
                    ,p_token_tbl                     => G_TOKEN_TBL
                    ,p_message_type                  => G_RET_STS_ERROR
                    ,p_row_identifier                => l_transaction_id
                    ,p_entity_code                   => G_ENTITY_VS_TABLE
                    ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );


                  G_TOKEN_TBL.DELETE;

                ELSE

                  x_return_status :=  G_RET_STS_UNEXP_ERROR;
                  x_return_msg:= l_return_msg;
                  RETURN;

                END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN



              END IF;  --END IF l_value_column_name IS NOT NULL THEN

              write_debug(G_PKG_Name,l_api_name,' Process_Value_Set : TABLE TYPE VS set created  x_return_status : = '||x_return_status);
              --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Process_Value_Set : TABLE TYPE VS set created  x_return_status : = '||x_return_status);

            ELSE  -- Case of 'Independent','Translatable Independent' and 'None'


              -- Check for standalone API
              IF l_version_seq_id IS NOT NULL  AND  l_validation_code=G_NONE_VALIDATION_CODE
              THEN

                  l_return_status               :=  G_RET_STS_UNEXP_ERROR;
                  l_error_message_name          := 'EGO_NONE_VS_VERSION_ERROR';
                  l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
                  l_token_table(1).TOKEN_VALUE  := l_value_set_name;

                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                  => l_error_message_name
                    ,p_application_id                => G_App_Short_Name
                    ,p_token_tbl                     => l_token_table
                    ,p_message_type                  => G_RET_STS_ERROR
                    ,p_row_identifier                => l_transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => l_table_name
                  );

                  l_token_table.DELETE;

              END IF;-- END IF l_version_seq_id IS NOT NULL  AND  l_validation_code=G_NONE_VALIDATION_CODE THEN

              -- Create value Set for none type of VS.
              IF ( l_version_seq_id IS NULL
                    AND  l_validation_code IN (G_NONE_VALIDATION_CODE,G_INDEPENDENT_VALIDATION_CODE,G_TRANS_IND_VALIDATION_CODE) ) THEN

                IF l_process_status = G_PROCESS_RECORD  THEN
                    write_debug(G_PKG_Name,l_api_name,' Process_Value_Set : Calling  EGO_EXT_FWK_PUB.Create_Value_Set API for I X and N type of vali code ');

                  EGO_EXT_FWK_PUB.Create_Value_Set
                    (
                      p_api_version                    => l_api_version
                      ,p_value_set_name                => l_value_set_name
                      ,p_description                   => l_description
                      ,p_format_code                   => l_format_code
                      ,p_maximum_size                  => l_maximum_size
                      ,p_maximum_value                 => l_maximum_value
                      ,p_minimum_value                 => l_minimum_value
                      ,p_long_list_flag                => l_longlist_flag
                      ,p_validation_code               => l_validation_code
                      ,p_owner                         => l_owner --G_CURRENT_USER_ID
                      ,p_init_msg_list                 => fnd_api.g_FALSE
                      ,p_commit                        => fnd_api.g_FALSE
                      ,x_return_status                 => l_return_status
                      ,x_value_set_id                  => l_value_set_id
                      ,x_msg_count                     => x_msg_count
                      ,x_msg_data                      => l_return_msg
                    );

                END IF; -- END IF l_process_status = G_PROCESS_RECORD  THEN

              -- check the return status
              IF (Nvl(l_return_status,G_RET_STS_SUCCESS)  =G_RET_STS_SUCCESS ) THEN

                l_process_status:= G_PROCESS_RECORD;

              ELSIF (l_return_status = G_RET_STS_ERROR ) THEN


                l_process_status:= G_ERROR_RECORD;


		            G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS;
                G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB';
                G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                G_TOKEN_TBL(4).Token_Value  :=  'Create_Value_Set';


                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                   => 'EGO_ENTITY_API_FAILED'
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => G_TOKEN_TBL
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => G_ENTITY_VS
                  ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

              ELSE

                x_return_status :=  G_RET_STS_UNEXP_ERROR;
                x_return_msg    := l_return_msg;
                RETURN;

              END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN




              END IF;


              -- Call this API only once for versioned value set
              IF l_version_seq_id IS NOT NULL  AND  l_validation_code IN (G_INDEPENDENT_VALIDATION_CODE,G_TRANS_IND_VALIDATION_CODE) THEN

                -- Check if value set has already been created
                FOR m IN Cur_value_set_id(l_value_set_name)
                LOOP
                  l_value_set_id  := m.flex_value_set_id;
                END LOOP;

                IF l_value_set_id IS NULL  THEN
                  -- If VS has not been created then create VS
                  write_debug(G_PKG_Name,l_api_name,' Calling EGO_EXT_FWK_PUB.Create_Value_Set to create Value Set ');

                  IF l_process_status = G_PROCESS_RECORD  THEN

                    EGO_EXT_FWK_PUB.Create_Value_Set
                      (
                        p_api_version                    => l_api_version
                        ,p_value_set_name                => l_value_set_name
                        ,p_description                   => l_description
                        ,p_format_code                   => l_format_code
                        ,p_maximum_size                  => l_maximum_size
                        ,p_maximum_value                 => l_maximum_value
                        ,p_minimum_value                 => l_minimum_value
                        ,p_long_list_flag                => l_longlist_flag
                        ,p_validation_code               => l_validation_code
                        ,p_owner                         => l_owner --G_CURRENT_USER_ID
                        ,p_init_msg_list                 => fnd_api.g_FALSE
                        ,p_commit                        => fnd_api.g_FALSE
                        ,x_return_status                 => l_return_status
                        ,x_value_set_id                  => l_value_set_id
                        ,x_msg_count                     => x_msg_count
                        ,x_msg_data                      => l_return_msg
                      );

                  END IF; -- END  IF l_process_status = G_PROCESS_RECORD  THEN

                  -- check the return status
                  IF (Nvl(l_return_status,G_RET_STS_SUCCESS)  =G_RET_STS_SUCCESS ) THEN

                    l_process_status:= G_PROCESS_RECORD;

                  ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                    l_return_status := l_return_status;
                    l_process_status:= G_ERROR_RECORD;


		                G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                    G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS;
                    G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                    G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                    G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                    G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB';
                    G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                    G_TOKEN_TBL(4).Token_Value  :=  'Create_Value_Set';


                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                   => 'EGO_ENTITY_API_FAILED'
                      ,p_application_id                => G_App_Short_Name
                      ,p_token_tbl                     => G_TOKEN_TBL
                      ,p_message_type                  => G_RET_STS_ERROR
                      ,p_row_identifier                => l_transaction_id
                      ,p_entity_code                   => G_ENTITY_VS
                      ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

                  ELSE

                    x_return_status :=  G_RET_STS_UNEXP_ERROR;
                    x_return_msg:= l_return_msg;
                    RETURN;

                  END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN




                  write_debug(G_PKG_Name,l_api_name,' API EGO_EXT_FWK_PUB.Create_Value_Set return status x_return_status = '
                                ||x_return_status||'  l_value_set_id= '||l_value_set_id );


                END IF; --IF NOT exist THEN
              END IF; -- END IF l_version_seq_id IS NOT NULL  AND  l_validation_code IN (G_INDEPENDENT_VALIDATION_CODE,G_TRANS_IND_VALIDATION_CODE) THEN


            END IF ; --END IF l_validation_code='F' THEN









          ELSIF l_transaction_type=G_UPDATE THEN


            -- Always call update API irrespective of validation code.
            write_debug(G_PKG_Name,l_api_name,' Call to Process_Value_Set in UPDATE MODE ' );
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Call to Process_Value_Set in UPDATE MODE x_validation_code = '||l_validation_code );

            write_debug(G_PKG_Name,l_api_name,' Getting Key Values  : IN Update mode ' );
            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  Getting Key Values  : IN Update mode ' );

            --Get value of require field if they are null
            /*Get_Key_VS_Columns   (p_value_set_id        => l_value_set_id,
                                  x_maximum_size        => l_maximum_size,
                                  x_maximum_value       => l_maximum_value,
                                  x_minimum_value       => l_minimum_value,
                                  x_description         => l_description,
                                  x_longlist_flag       => l_longlist_flag,
                                  x_format_code         => l_format_code,
                                  x_validation_code     => l_validation_code,
                                  x_return_status       => l_return_status,
                                  x_return_msg          => l_return_msg
                                );



            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' After Getting Key Values x_validation_code = '||l_validation_code );

            -- check the return status
            IF (Nvl(l_return_status,G_RET_STS_SUCCESS)  =G_RET_STS_SUCCESS ) THEN

              l_process_status:= G_PROCESS_RECORD;

            ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

              x_return_status := l_return_status;
              l_process_status:= G_ERROR_RECORD;


		          G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
              G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS;
              G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
              G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
              G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
              G_TOKEN_TBL(3).Token_Value  :=  'EGO_VS_BULKLOAD_PVT';
              G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
              G_TOKEN_TBL(4).Token_Value  :=  'Get_Key_VS_Columns';


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => 'EGO_ENTITY_API_FAILED'
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => G_TOKEN_TBL
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => G_ENTITY_VS
                ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

            ELSE
              write_debug(G_PKG_Name,l_api_name,' : Unexpected exceptioon ' );
              x_return_status :=  G_RET_STS_UNEXP_ERROR;
              x_return_msg    :=  l_return_msg;
              RETURN;

            END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN




            Validate_value_Set (l_value_set_name,
                                l_validation_code,
                                l_longlist_flag,
                                l_format_code,
                                l_version_seq_id,
                                l_transaction_id,
                                l_transaction_type,
                                l_return_status,
                                l_return_msg);



            -- check the return status
            IF (l_return_status =G_RET_STS_UNEXP_ERROR )
            THEN

              x_return_status :=  G_RET_STS_UNEXP_ERROR;
              x_return_msg    :=  l_return_msg;
              RETURN;

            ELSIF (l_return_status =G_RET_STS_ERROR ) THEN

              l_process_status := G_ERROR_RECORD;

            END IF; -- END IF (l_return_status =G_RET_STS_UNEXP_ERROR )

            */

            IF l_process_status = G_PROCESS_RECORD  THEN
              -- Call update API to update value set.
              write_debug(G_PKG_Name,l_api_name,' Calling EGO_EXT_FWK_PUB.Update_Value_Set API ');
              --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Calling EGO_EXT_FWK_PUB.Update_Value_Set API '||l_validation_code);

              --IF l_validation_code <> G_TABLE_VALIDATION_CODE THEN

                EGO_EXT_FWK_PUB.Update_Value_Set
                  (
                      p_api_version                  => l_api_version
                    ,p_value_set_id                  => l_value_set_id
                    ,p_description                   => CASE l_description
                                                          WHEN G_NULL_CHAR THEN NULL
                                                          ELSE l_description
                                                        END --l_description

                    ,p_format_code                   => l_format_code
                    ,p_maximum_size                  => l_maximum_size
                    ,p_maximum_value                 => CASE l_maximum_value
                                                          WHEN G_NULL_NUM THEN NULL
                                                          ELSE l_maximum_value
                                                        END
                    ,p_minimum_value                 => CASE l_minimum_value
                                                          WHEN G_NULL_NUM THEN NULL
                                                          ELSE l_minimum_value
                                                        END
                    ,p_long_list_flag                => l_longlist_flag
                    ,p_validation_code               => l_validation_code
                    ,p_owner                         => l_owner      --G_CURRENT_USER_ID
                    ,p_init_msg_list                 => fnd_api.g_FALSE
                    ,p_commit                        => fnd_api.g_FALSE
                    ,x_return_status                 => l_return_status
                    ,x_msg_count                     => x_msg_count
                    ,x_msg_data                      => l_return_msg
                    ,x_versioned_vs                  => l_versioned_vs
                  );



                -- check the return status
                IF (l_return_status =G_RET_STS_SUCCESS ) THEN

                  l_process_status:= G_PROCESS_RECORD;

                ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                  l_return_status := l_return_status;
                  l_process_status:= G_ERROR_RECORD;


		              G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                  G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS;
                  G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                  G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                  G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                  G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB';
                  G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                  G_TOKEN_TBL(4).Token_Value  :=  'Update_Value_Set';


                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                   => 'EGO_ENTITY_API_FAILED'
                    ,p_application_id                => G_App_Short_Name
                    ,p_token_tbl                     => G_TOKEN_TBL
                    ,p_message_type                  => G_RET_STS_ERROR
                    ,p_row_identifier                => l_transaction_id
                    ,p_entity_code                   => G_ENTITY_VS
                    ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

                ELSE

                  x_return_status :=  G_RET_STS_UNEXP_ERROR;
                  x_return_msg:= l_return_msg;
                  RETURN;

                END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN

              --END IF;-- END IF l_validation_code <> G_TABLE_VALIDATION_CODE THEN

            END IF; -- END IF l_process_status = G_PROCESS_RECORD  THEN





              write_debug(G_PKG_Name,l_api_name,' Call to EGO_EXT_FWK_PUB.Update_Value_Set done x_return_status := '||x_return_status );
              --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Call to EGO_EXT_FWK_PUB.Update_Value_Set done x_return_status := '||x_return_status );

              -- Call API based on validation code

              IF l_validation_code=G_TABLE_VALIDATION_CODE THEN

                FOR Table_Val IN Cur_table (l_value_set_id)
                LOOP
                  l_table_exist := Table_Val.table_exist;
                END LOOP;


                -- Here we have to update table informtion if same has been passed.

                IF (  l_application_table_name IS NOT NULL AND l_value_column_name IS NOT NULL AND
                      l_value_column_type IS NOT NULL AND l_value_column_size  IS NOT NULL ) THEN

                  IF l_process_status = G_PROCESS_RECORD  THEN

                    --Dbms_Output.put_line(' Updating tabletype VS l_table_application_id ='||l_table_application_id||'l_application_table_name = '||l_application_table_name);

                    IF l_table_exist IS NOT NULL THEN

                      -- Call API to update table information
                      EGO_EXT_FWK_PUB.Update_Value_Set_Table_Inf
                            (
                              p_api_version                   => 1.0
                              ,p_value_set_id                  => l_value_set_id
                              ,p_table_application_id          => CASE l_table_application_id
                                                                    WHEN G_NULL_NUM THEN NULL
                                                                    ELSE l_table_application_id
                                                                  END--l_table_application_id
                              ,p_table_name                    => l_application_table_name
                              ,p_value_column_name             => l_value_column_name
                              ,p_value_column_type             => l_value_column_type
                              ,p_value_column_size             => l_value_column_size
                              ,p_meaning_column_name           => l_meaning_column_name
                              ,p_meaning_column_type           => l_meaning_column_type   -- Bug 9705126
                              ,p_meaning_column_size           => l_meaning_column_size
                              ,p_id_column_name                => l_id_column_name
                              ,p_id_column_type                => l_id_column_type
                              ,p_id_column_size                => l_id_column_size
                              ,p_where_order_by                => l_additional_where_clause
                              ,p_additional_columns            => ''
                              ,p_owner                         => l_owner --G_CURRENT_USER_ID
                              ,p_init_msg_list                 => fnd_api.g_FALSE
                              ,p_commit                        => fnd_api.g_FALSE
                              ,x_return_status                 => l_return_status
                              ,x_msg_count                     => x_msg_count
                              ,x_msg_data                      => l_return_msg
                            );



                      -- check the return status
                      IF (l_return_status =G_RET_STS_SUCCESS ) THEN --G_RET_STS_UNEXP_ERROR) THEN

                        l_process_status:= G_PROCESS_RECORD;


                      ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                        l_return_status := l_return_status;
                        l_process_status:= G_ERROR_RECORD;




		                    G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                        G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS_TABLE;
                        G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                        G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                        G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                        G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB' ;
                        G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                        G_TOKEN_TBL(4).Token_Value  :=  'Update_Value_Set_Table_Inf';


                        ERROR_HANDLER.Add_Error_Message(
                          p_message_name                   => 'EGO_ENTITY_API_FAILED'
                          ,p_application_id                => G_App_Short_Name
                          ,p_token_tbl                     => G_TOKEN_TBL
                          ,p_message_type                  => G_RET_STS_ERROR
                          ,p_row_identifier                => l_transaction_id
                          ,p_entity_code                   => G_ENTITY_VS_TABLE
                          ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );


                      ELSE

                        x_return_status :=  G_RET_STS_UNEXP_ERROR;
                        x_return_msg:= l_return_msg;
                        RETURN;

                      END IF;  -- END  IF (l_return_status =G_RET_STS_SUCCESS ) THEN



                    ELSE

                      -- CREATE data for table type VS
                      EGO_EXT_FWK_PUB.Insert_Value_Set_Table_Inf
                        (
                          p_api_version                   => 1.0
                          ,p_value_set_id                  => l_value_set_id
                          ,p_table_application_id          => l_table_application_id
                          ,p_table_name                    => l_application_table_name
                          ,p_value_column_name             => l_value_column_name
                          ,p_value_column_type             => l_value_column_type
                          ,p_value_column_size             => l_value_column_size
                          ,p_meaning_column_name           => l_meaning_column_name   --bug 9705126
                          ,p_meaning_column_type           => l_meaning_column_type
                          ,p_meaning_column_size           => l_meaning_column_size
                          ,p_id_column_name                => l_id_column_name
                          ,p_id_column_type                => l_id_column_type
                          ,p_id_column_size                => l_id_column_size
                          ,p_where_order_by                => l_additional_where_clause
                          ,p_additional_columns            => ''
                          ,p_owner                         => l_owner --G_CURRENT_USER_ID
                          ,p_init_msg_list                 => fnd_api.g_FALSE
                          ,p_commit                        => fnd_api.g_FALSE
                          ,x_return_status                 => l_return_status
                          ,x_msg_count                     => x_msg_count
                          ,x_msg_data                      => l_return_msg
                        );


                      -- check the return status
                      IF (Nvl(l_return_status, G_RET_STS_SUCCESS )  =G_RET_STS_SUCCESS ) THEN

                        l_process_status:= G_PROCESS_RECORD;

                      ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                        l_return_status := l_return_status;
                        l_process_status:= G_ERROR_RECORD;


		                    G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                        G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS_TABLE;
                        G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                        G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                        G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                        G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB';
                        G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                        G_TOKEN_TBL(4).Token_Value  :=  'Insert_Value_Set_Table_Inf';


                        ERROR_HANDLER.Add_Error_Message(
                          p_message_name                   => 'EGO_ENTITY_API_FAILED'
                          ,p_application_id                => G_App_Short_Name
                          ,p_token_tbl                     => G_TOKEN_TBL
                          ,p_message_type                  => G_RET_STS_ERROR
                          ,p_row_identifier                => l_transaction_id
                          ,p_entity_code                   => G_ENTITY_VS_TABLE
                          ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );


                        G_TOKEN_TBL.DELETE;

                      ELSE

                        x_return_status :=  G_RET_STS_UNEXP_ERROR;
                        x_return_msg:= l_return_msg;
                        RETURN;

                      END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN


                    END IF; -- END IF l_table_exist IS NOT NULL THEN

                  END IF; -- IF l_process_status = G_PROCESS_RECORD  THEN

                  --Dbms_Output.put_line('After Updating tabletype VS l_return_status = '||l_return_status);



                END IF; -- END IF (  l_application_table_name IS NOT NULL AND l_value_column_name IS NOT NULL AND

              END IF; -- END IF l_validation_code=G_TABLE_VALIDATION_CODE  THEN

            --END IF;-- IF l_process_status = G_PROCESS_RECORD  THEN

          END IF; -- END IF l_transaction_type=G_CREATE THEN


        END IF; -- END IF l_process_status=G_PROCESS_RECORD

        write_debug(G_PKG_Name,l_api_name,' Value Set  processing is done. Assign variable to pl/sqltable back. ');

        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  End processing value Set : revert back variables to table');
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  l_value_set_id = '||l_value_set_id||' l_value_set_name = '||l_value_set_name ||' process atstus = '||l_process_status);

        -- Set process status to success only for non version VS.
        -- For version VS set status to success during call to release API.
        IF l_version_seq_id IS NULL THEN
          IF Nvl(l_return_status,G_RET_STS_SUCCESS)  = G_RET_STS_SUCCESS THEN

            IF l_process_status=G_PROCESS_RECORD THEN
              l_process_status :=  G_SUCCESS_RECORD;
            END IF;

          ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

            l_return_status    := G_RET_STS_ERROR;
            l_process_status   := G_ERROR_RECORD;

          END IF;

        END IF; -- END IF l_version_seq_id IS NULL THEN




        -- Assign Back all values to table.
        ---*************************--------
        p_value_set_tbl(i).value_set_name			          :=	l_value_set_name;
        p_value_set_tbl(i).value_set_id            	    :=	l_value_set_id;
        p_value_set_tbl(i).description				          :=	l_description;
        p_value_set_tbl(i).version_description          :=	l_version_description;
        p_value_set_tbl(i).format_type				          :=	l_format_code;
        p_value_set_tbl(i).longlist_flag			          :=	l_longlist_flag;
        p_value_set_tbl(i).validation_type			        :=	l_validation_code;

        p_value_set_tbl(i).parent_value_set_name	      :=	l_parent_value_set_name;
        --p_value_set_tbl(i).version_seq_id			          :=	l_version_seq_id;
        p_value_set_tbl(i).start_active_date		        :=	l_start_active_date;
        p_value_set_tbl(i).end_active_date			        :=	l_end_active_date;
        p_value_set_tbl(i).maximum_size               	:=	l_maximum_size;
        p_value_set_tbl(i).minimum_value			          :=	l_maximum_value;
        p_value_set_tbl(i).maximum_value			          :=	l_minimum_value;

        p_value_set_tbl(i).value_column_name		        :=	l_value_column_name;
        p_value_set_tbl(i).value_column_type 		        :=	l_value_column_type;
        p_value_set_tbl(i).value_column_size		        :=	l_value_column_size;
        p_value_set_tbl(i).id_column_name			          :=	l_id_column_name;
        p_value_set_tbl(i).id_column_size			          :=	l_id_column_size;
        p_value_set_tbl(i).id_column_type			          :=	l_id_column_type;
        p_value_set_tbl(i).meaning_column_name		      :=	l_meaning_column_name;
        p_value_set_tbl(i).meaning_column_size		      :=	l_meaning_column_size;
        p_value_set_tbl(i).meaning_column_type		      :=	l_meaning_column_type;

        p_value_set_tbl(i).table_application_id		      :=	l_table_application_id;
        p_value_set_tbl(i).application_table_name	      :=	l_application_table_name;
        p_value_set_tbl(i).additional_where_clause 	    :=	l_additional_where_clause;

        -- transactions related columns
        p_value_set_tbl(i).transaction_type			        :=	l_transaction_type;
        --p_value_set_tbl(i).transaction_id       	      :=	l_transaction_id;

        -- process related columns
        write_debug(G_PKG_Name,l_api_name,' Status : l_process_status '||l_process_status);

        p_value_set_tbl(i).process_status			          :=	l_process_status;
        p_value_set_tbl(i).set_process_id      		      :=	l_set_process_id;

        -- who columns for concurrent program
        p_value_set_tbl(i).request_id          		      :=	l_request_id;
        p_value_set_tbl(i).program_application_id       :=	l_program_application_id;
        p_value_set_tbl(i).program_id             	    :=	l_program_id;
        p_value_set_tbl(i).program_update_date          :=  l_program_update_date;

        -- who columns
        p_value_set_tbl(i).last_update_date    		      :=	l_last_update_date;
        p_value_set_tbl(i).last_updated_by     		      :=	l_last_updated_by;
        p_value_set_tbl(i).creation_date       		      :=	l_creation_date;
        p_value_set_tbl(i).created_by          		      :=	l_created_by;
        p_value_set_tbl(i).last_update_login		        := 	l_last_update_login;
        --------********************-------------







        -- Re-Initializing values
        l_value_set_name          :=  NULL;
        l_value_set_id            :=  NULL;
        l_description             :=  NULL;
        l_format_code             :=  NULL;
        l_longlist_flag           :=  NULL;
        l_validation_code         :=  NULL;
        l_parent_value_set_name   :=  NULL;
        l_version_seq_id          :=  NULL;
        l_start_active_date       :=  NULL;
        l_end_active_date         :=  NULL;
        l_maximum_size            :=  NULL;
        l_minimum_value           :=  NULL;
        l_maximum_value           :=  NULL;
        l_transaction_type        :=  NULL;
        l_process_status          :=  NULL;
        l_request_id              :=  NULL;
        l_set_process_id          :=  NULL;
        l_last_update_date        :=  NULL;
        l_last_updated_by         :=  NULL;
        l_creation_date           :=  NULL;
        l_created_by              :=  NULL;
        l_last_update_login       :=  NULL;


        l_value_column_name       :=  NULL;
        l_value_column_type       :=  NULL;
        l_value_column_size       :=  NULL;
        l_id_column_name          :=  NULL;
        l_id_column_size          :=  NULL;
        l_id_column_type          :=  NULL;
        l_meaning_column_name     :=  NULL;
        l_meaning_column_size     :=  NULL;
        l_meaning_column_type     :=  NULL;
        l_table_application_id    :=  NULL;
        l_application_table_name  :=  NULL;
        l_additional_where_clause :=  NULL;

        l_transaction_id          :=  NULL;
        l_version_description     :=  NULL;
        l_request_id              :=  NULL;
        l_program_application_id  :=  NULL;
        l_program_id              :=  NULL;
        l_program_update_date     :=  NULL;
        l_table_exist             :=  NULL;

    END LOOP;  -- END FOR i IN p_value_set_tbl.first..p_value_set_tbl.last




    -- Set return status
    IF Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS AND  x_return_status <>G_RET_STS_ERROR THEN

      x_return_status :=  G_RET_STS_SUCCESS;
      l_return_status    := G_RET_STS_SUCCESS;

    END IF;


    IF l_return_status =G_RET_STS_ERROR THEN

      x_return_status :=  G_RET_STS_ERROR;

    END IF;




    write_debug(G_PKG_Name,l_api_name,' End of  Process_Value_Set API' );
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of  Process_Value_Set API x_return_status ='||x_return_status );




    IF p_commit THEN
      write_debug(G_PKG_Name,l_api_name,' Issue a commit ');
      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Issue a commit ');

      COMMIT;
    END IF;


EXCEPTION
  WHEN OTHERS THEN
    write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );

    x_return_status := G_RET_STS_UNEXP_ERROR;
    x_return_msg    := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	RETURN;


END Process_Value_Set;



-- Procedure to process value set
PROCEDURE Process_Value_Set_Value (
           p_api_version            IN              NUMBER,
           p_value_set_val_tbl      IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Value_Tbl,
           p_value_set_val_tl_tbl   IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Value_Tl_Tbl,
           p_set_process_id         IN              NUMBER,
           p_commit                 IN              BOOLEAN DEFAULT FALSE,
           x_return_status          OUT NOCOPY      VARCHAR2,
           x_msg_count              OUT NOCOPY      NUMBER,
           x_return_msg             OUT NOCOPY      VARCHAR2)

IS


    l_api_name                VARCHAR2(30):='Process_Value_Set_Value';
    l_api_version             NUMBER := 1.0;
    l_owner                   NUMBER := G_User_Id;
--    l_owner_name            VARCHAR2(40):='ANONYMOUS';

    l_value_set_name          FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE; -- VARCHAR2(60);
    l_value_set_id            FND_FLEX_VALUES.FLEX_VALUE_SET_ID%TYPE;

    l_flex_value              fnd_flex_values.flex_value%TYPE;
    l_flex_value_id           fnd_flex_values.flex_value_id%TYPE;
    l_version_seq_id          NUMBER;
    --l_sequence                 NUMBER;
    l_start_active_date       DATE;
    l_end_active_date         DATE;
    l_vers_start_date         DATE;
    l_vers_end_date           DATE;
    l_enabled_flag            VARCHAR2(10);

    l_transaction_type        VARCHAR2(10);
    l_process_status          NUMBER;
    l_set_process_id          NUMBER;

    l_request_id              NUMBER;
    l_program_update_date     DATE;
    l_program_application_id  NUMBER;
    l_program_id              NUMBER;


    l_last_update_date        DATE;
    l_last_updated_by         NUMBER(15);
    l_creation_date           DATE;
    l_created_by              NUMBER(15);
    l_last_update_login       NUMBER(15);

    l_current_lang_exist      BOOLEAN:= FALSE;

    l_val_version_seq_id      NUMBER;
    l_language		            VARCHAR2(10);
    l_description             VARCHAR2(500);
    l_source_lang		          VARCHAR2(10);
    l_flex_value_meaning      VARCHAR2(500);
    l_transaction_id	        NUMBER;
    l_disp_sequence           NUMBER;
    l_init_msg_list           VARCHAR2(100);
    --l_commit
    l_value_exist             NUMBER;
    l_target_vers_id          NUMBER;
    l_is_versioned            VARCHAR2(20):=NULL;
    l_api_mode                NUMBER   :=  G_FLOW_TYPE;
    l_validation_code         VARCHAR2(10);
    l_format_code             VARCHAR2(10);
    l_token_table             ERROR_HANDLER.Token_Tbl_Type;
    l_application_id          NUMBER;

    l_return_status           VARCHAR2(1) := NULL;

    -- Local variable for Error handling
    l_error_message_name      VARCHAR2(240);
    l_entity_code             VARCHAR2(30) :=  G_ENTITY_VS_VAL;
    l_table_name              VARCHAR2(240):=  G_ENTITY_VAL_HEADER_TAB;

    l_val_ver_exist			      NUMBER;
    l_trans_val_ver_exist     NUMBER;
    l_seq_exist               NUMBER  :=  NULL;
    l_valid_type              NUMBER  :=  NULL;
    l_return_msg	            VARCHAR2(1000);
    --l_description            FND_FLEX_VALUE_SETS.description%TYPE;

    l_vs_maximum_size         NUMBER  :=  NULL;
    l_val_int_name_size       NUMBER  :=  NULL;
    l_val_disp_name_size      NUMBER  :=  NULL;

    l_date_val_old_int_name   VARCHAR2(1000) :=   NULL;
    l_mask_format             VARCHAR2(100) :=    NULL;


    -- Cursor to get value_set_id for a passed in value set name
    CURSOR  cur_value_set_id(cp_value_set_name  VARCHAR2) IS
      SELECT flex_value_set_id
      FROM fnd_flex_value_sets
      WHERE flex_value_set_name = cp_value_set_name;

    -- Cursor to find out if value already exist in system.
    CURSOR cur_value( cp_flex_value_set_id  NUMBER,
                      cp_flex_value         VARCHAR2) IS
      SELECT flex_value_id
      FROM fnd_flex_values
      WHERE flex_value_set_id= cp_flex_value_set_id
        AND flex_value= cp_flex_value;


    -- Cursor to find out if value already exist in system.
    CURSOR cur_value_name(  cp_flex_value_set_id  NUMBER,
                            cp_flex_value_id      NUMBER )
    IS
      SELECT flex_value
      FROM fnd_flex_values
      WHERE flex_value_set_id= cp_flex_value_set_id
        AND flex_value_id = cp_flex_value_id;


    CURSOR Cur_Validation (cp_value_set_id    IN    NUMBER )
    IS
      SELECT  validation_type, format_type ,maximum_size
      FROM  fnd_flex_value_sets
      WHERE flex_Value_set_id = cp_value_set_id;

    -- Cursor to get value_set_name for a passed in value set id
    CURSOR  cur_value_set_name(cp_value_set_id  NUMBER)
    IS
      SELECT flex_value_set_name
      FROM fnd_flex_value_sets
      WHERE flex_value_set_id = cp_value_set_id;




    CURSOR Cur_Value_Ver_Exist(cp_value_set_id    NUMBER,
                              cp_value_id        NUMBER,
                              cp_version_seq_id  NUMBER )
    IS
    SELECT 1  AS exist
    FROM  EGO_FLEX_VALUE_VERSION_B
    WHERE flex_value_set_id = cp_value_set_id
      AND flex_value_id = cp_value_id
      AND version_seq_id  = cp_version_seq_id;



    CURSOR Cur_Trans_Value_Ver_Exist( --cp_value_set_id    NUMBER,
                                      cp_value_id        NUMBER,
                                      cp_version_seq_id  NUMBER,
                                      cp_lang_code       VARCHAR2 )
    IS
    SELECT 1  AS exist
    FROM  EGO_FLEX_VALUE_VERSION_TL
    WHERE --value_set_id = cp_value_set_id AND
          flex_value_id = cp_value_id
      AND version_seq_id  = cp_version_seq_id
      AND "LANGUAGE" = cp_lang_code;


  -- Cursor to get display sequence.
  CURSOR c_get_disp_sequence (cp_flex_value_id  IN  NUMBER)
  IS
  SELECT disp_sequence
  FROM ego_vs_values_disp_order
  WHERE value_set_value_id = cp_flex_value_id;


  -- Cursor to validate sequnce.
  CURSOR Cur_Seq_Validation ( cp_value_set_id  NUMBER,
                              cp_value_id      NUMBER,
                              cp_disp_sequence NUMBER)
  IS
  SELECT 1 AS Seq_exist
  FROM  Ego_VS_Values_Disp_Order
  WHERE disp_sequence = cp_disp_sequence
    AND value_set_id = cp_value_set_id
    AND ( value_set_value_id <> cp_value_id
          OR cp_value_id IS NULL );


  -- Cursor to validate sequnce.
  CURSOR Cur_Vers_Seq_Validation (  cp_value_set_id   NUMBER,
                                    cp_value_id       NUMBER,
                                    cp_disp_sequence  NUMBER,
                                    cp_version_seq_id NUMBER)
  IS
  SELECT 1 AS Seq_exist
  FROM  EGO_FLEX_VALUE_VERSION_B
  WHERE flex_value_set_id    = cp_value_set_id
    AND version_seq_id  = cp_version_seq_id
    AND SEQUENCE   = cp_disp_sequence;



BEGIN

    write_debug(G_PKG_Name,l_api_name,' Start of API. ' );
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API. ' );

    --Reset all global variables
    --FND_MSG_PUB.Initialize;

    -- Get Application Id
    --G_Application_Id  := Get_Application_Id();

    -- Bug 9701510
    -- Call API to get current value of mask.
    FND_PROFILE.GET('ICX_DATE_FORMAT_MASK',l_mask_format);


    ERROR_HANDLER.Set_Bo_Identifier(G_BO_IDENTIFIER_VS);

    FOR i IN p_value_set_val_tbl.first..p_value_set_val_tbl.last
    LOOP
        --Assigning value per record
        l_value_set_name        :=  p_value_set_val_tbl(i).value_set_name;

        l_value_set_id          :=  p_value_set_val_tbl(i).value_set_id;
        l_flex_value            :=  p_value_set_val_tbl(i).flex_value;
        l_date_val_old_int_name :=  p_value_set_val_tbl(i).flex_value; -- Use only for date/datetime type of VS
        l_flex_value_id         :=  p_value_set_val_tbl(i).flex_value_id;
        l_version_seq_id        :=  p_value_set_val_tbl(i).version_seq_id;
        l_disp_sequence         :=  p_value_set_val_tbl(i).disp_sequence;
        l_start_active_date     :=  p_value_set_val_tbl(i).start_active_date;
        l_end_active_date       :=  p_value_set_val_tbl(i).end_active_date;
        l_enabled_flag          :=  p_value_set_val_tbl(i).enabled_flag;

        l_transaction_type      :=  p_value_set_val_tbl(i).transaction_type;
        l_transaction_id        :=  p_value_set_val_tbl(i).transaction_id;


        l_process_status        :=  p_value_set_val_tbl(i).process_status;
        l_set_process_id        :=  p_value_set_val_tbl(i).set_process_id;


        l_request_id              :=  p_value_set_val_tbl(i).request_id;
        l_program_update_date     :=  p_value_set_val_tbl(i).program_update_date;
        l_program_application_id  :=  p_value_set_val_tbl(i).program_application_id;
        l_program_id              :=  p_value_set_val_tbl(i).program_id;



        l_last_update_date      :=  p_value_set_val_tbl(i).last_update_date;
        l_last_updated_by       :=  p_value_set_val_tbl(i).last_updated_by;
        l_creation_date         :=  p_value_set_val_tbl(i).creation_date;
        l_created_by            :=  p_value_set_val_tbl(i).created_by;
        l_last_update_login     :=  p_value_set_val_tbl(i).last_update_login;


        write_debug(G_PKG_Name,l_api_name,'  Start of Loop to get values : value  = '||l_flex_value||' and Value Id = '||l_flex_value_id);



        IF l_value_set_id IS NOT NULL THEN

            -- Get Value Set Name
            Convert_Id_To_Name (l_value_set_id ,G_Value_Set,NULL,l_value_set_name);


            --
            IF l_value_set_id IS NULL THEN

                l_error_message_name          := 'EGO_VSET_INVALID_ID';
                -- Set process_status to 3
                l_process_status    := g_error_record;
                l_return_status     := G_RET_STS_ERROR;
                l_last_updated_by   := g_user_id;
                l_last_update_date  := SYSDATE;
                l_last_update_login := g_login_id;



                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                   => l_error_message_name
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => l_token_table
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => l_table_name);

            END IF; -- END IF l_value_set_id IS NULL THEN



        END IF;-- END IF l_value_set_id IS NOT NULL THEN



        IF ( l_value_set_name IS NOT NULL AND l_value_set_id IS NULL ) THEN
          -- Get value Set Id
          Convert_Name_To_Id (l_value_set_name,G_Value_Set,NULL,l_value_set_id);
        END IF; -- END IF ( l_value_set_name IS NOT NULL AND l_value_set_id IS NULL ) THEN

        --Dbms_Output.put_line(' After conversion of VS '||' VS NAme = '||l_value_set_name||' VS Id = '||l_value_set_id);



          -- Check if required value has been passed.
        IF (l_value_set_name IS NULL AND l_value_set_id IS NULL )  THEN

              l_process_status              := G_ERROR_RECORD;
              l_return_status               := G_RET_STS_ERROR;


              l_error_message_name          := 'EGO_VALUE_SET_REQUIRED_FIELD';
              l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
              l_token_table(1).TOKEN_VALUE  := l_value_set_name;

              l_token_table(2).TOKEN_NAME   := 'VALUE_SET_ID';
              l_token_table(2).TOKEN_VALUE  := l_value_set_name;


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name
              );

        END IF;-- END IF (l_value_set_name IS NULL AND l_value_set_id IS NULL )  THEN



        -- Bug 9701510
        -- Get validation code and format code for VS.
        FOR j IN Cur_Validation(l_value_set_id)
        LOOP
          l_validation_code :=  j.validation_type;
          l_format_code     :=  j.format_type;
          l_vs_maximum_size :=  j.maximum_size;
        END LOOP;

        --Dbms_Output.put_line(' VALIDATION CODE POST PROCESING: l_validation_code = '||l_validation_code ||' l_value_set_id = '||l_value_set_id);
        --YJ



        IF l_flex_value_id IS NOT NULL THEN
            -- Get value name



            Convert_Id_To_Name (l_flex_value_id,G_Value,l_value_set_id,l_flex_value);

            --
            IF l_flex_value_id IS NULL THEN

              l_error_message_name          := 'EGO_VSET_VAL_INVALID_ID';
              -- Set process_status to 3
              l_process_status    := g_error_record;
              l_return_status     := G_RET_STS_ERROR;
              l_last_updated_by   := g_user_id;
              l_last_update_date  := SYSDATE;
              l_last_update_login := g_login_id;



              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name
              );

            END IF; -- END IF l_value_set_id IS NULL THEN


        END IF;-- END IF l_flex_value_id IS NOT NULL THEN




        -- get Value_id from a given value.
        IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN

            -- For Date and DateTime VS, Convert value to DB Date format.
            -- Bug 9701510
            IF l_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE) THEN

                Validate_User_Preferred_Date (l_flex_value,
                                              l_format_code,
                                              l_transaction_id,
                                              l_return_status,
                                              l_return_msg);



                -- check the return status
                IF (l_return_status =G_RET_STS_UNEXP_ERROR )
                THEN

                  write_debug(G_PKG_Name,l_api_name,' Unexpected error occured in Validate_User_Preferred_Date API l_return_msg ='||l_return_msg);

                  x_return_status :=  G_RET_STS_UNEXP_ERROR;
                  x_return_msg    :=  l_return_msg;
                  RETURN;

                ELSIF (l_return_status =G_RET_STS_ERROR ) THEN


                  write_debug(G_PKG_Name,l_api_name,' Err_Msg-TID='  ||l_transaction_id||'-(VS,VS Id, Value)=('
                                                                        ||l_value_set_name||','||l_value_set_id||','||l_flex_value||')'||' Validation of value failed. ');


                  l_process_status := G_ERROR_RECORD;


                END IF; -- END IF (l_return_status =G_RET_STS_UNEXP_ERROR )



                Convert_Value_To_DbDate (l_flex_value);


            END IF;
            -- Bug 9701510

            Convert_Name_To_Id (l_flex_value,G_Value,l_value_set_id,l_flex_value_id);

        END IF; -- END IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN





        -- Check if required value has been passed.
        IF (l_flex_value IS NULL AND l_flex_value_id IS NULL )  THEN

              l_process_status              := G_ERROR_RECORD;
              l_return_status               := G_RET_STS_ERROR;

              l_error_message_name          := 'EGO_VALUE_REQUIRED_FIELD';
              l_token_table(1).TOKEN_NAME   := 'FLEX_VALUE';
              l_token_table(1).TOKEN_VALUE  := l_flex_value;

              l_token_table(2).TOKEN_NAME   := 'FLEX_VALUE_ID';
              l_token_table(2).TOKEN_VALUE  := l_flex_value_id;


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name
              );

              RETURN;

        END IF;-- END IF (l_value_set_name IS NULL AND l_value_set_id IS NULL )  THEN

        --END IF;-- END IF l_api_mode = EGO_GLOBALS.G_EGO_MD_API



        --Check for transaction type and update it correctly
        IF l_transaction_type  =G_SYNC THEN

          IF l_flex_value_id IS NOT NULL THEN
            l_transaction_type  :=G_UPDATE;
          ELSE
            l_transaction_type  :=G_CREATE;
          END IF;

        END IF; -- END IF l_transaction_type  =G_SYNC THEN



        IF l_version_seq_id IS NULL THEN
            -- Code to verify if disp_sequence is not duplicate.
            FOR j IN Cur_Seq_Validation (l_value_set_id, l_flex_value_id,l_disp_sequence)
            LOOP
                l_seq_exist := j.Seq_exist;
            END LOOP;


            IF l_seq_exist IS NOT NULL THEN

                --Dbms_Output.put_line(' Duplicate sequence error ');

                l_process_status              := G_ERROR_RECORD;
                l_return_status               := G_RET_STS_ERROR;
                l_last_updated_by             := g_user_id;
                l_last_update_date            := SYSDATE;
                l_last_update_login           := g_login_id;

                l_error_message_name          := 'EGO_EF_VAL_SEQ_ERR';

                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                  => l_error_message_name
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => l_token_table
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name );

            END IF; -- END IF l_seq_exist IS NOT NULL THEN


        ELSE   -- Check sequence validation for a specific version for version VS


            -- Code to verify if disp_sequence is not duplicate.
            FOR j IN Cur_Vers_Seq_Validation (l_value_set_id, l_flex_value_id,l_disp_sequence,G_OUT_VERSION_SEQ_ID)
            LOOP
                l_seq_exist := j.Seq_exist;
            END LOOP;


            IF l_seq_exist IS NOT NULL THEN

                --Dbms_Output.put_line(' Duplicate sequence error ');

                l_process_status              := G_ERROR_RECORD;
                l_return_status               := G_RET_STS_ERROR;
                l_last_updated_by             := g_user_id;
                l_last_update_date            := SYSDATE;
                l_last_update_login           := g_login_id;

                l_error_message_name          := 'EGO_EF_VAL_SEQ_ERR';

                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                  => l_error_message_name
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => l_token_table
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => l_table_name );

            END IF; -- END IF l_seq_exist IS NOT NULL THEN





            -- Check for version validation for negative version
            IF  (l_version_seq_id <0 )THEN

                write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS name)=('
                                            ||l_value_set_name||')'||' A version seq id can not be a negative number. ');



                l_error_message_name          := 'EGO_VS_VERSION_NUMBER_ERROR';
                l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
                l_token_table(1).TOKEN_VALUE  := l_value_set_name;
                x_return_status               := G_RET_STS_ERROR;

                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                  => l_error_message_name
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => l_token_table
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => l_table_name
                );

                l_token_table.DELETE;

            END IF; --IF  l_validation_code = G_TABLE_VALIDATION_CODE THEN





        END IF;



        -- Bug 9701510
        /*
        -- Check if validation type for value set is not NONE type.
        FOR j IN Cur_Validation(l_value_set_id)
        LOOP
          l_validation_code :=  j.validation_type;
          l_format_code     :=  j.format_type;
          l_vs_maximum_size :=  j.maximum_size;
        END LOOP;
        */
        -- Bug 9701510
        --Dbms_Output.put_line(' Another VALIDATION CODE POST PROCESING: l_validation_code = '||l_validation_code ||' l_value_set_id = '||l_value_set_id);



        IF l_validation_code IN (G_NONE_VALIDATION_CODE,G_TABLE_VALIDATION_CODE) THEN

              --Dbms_Output.put_line(' ERROR : VALUES for G_NONE_VALIDATION_CODE ');
              l_process_status              := G_ERROR_RECORD;
              l_return_status               := G_RET_STS_ERROR;
              l_last_updated_by             := g_user_id;
              l_last_update_date            := SYSDATE;
              l_last_update_login           := g_login_id;



              l_error_message_name          := 'EGO_VALUE_VALIDATION_ERROR';
              l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
              l_token_table(1).TOKEN_VALUE  := l_value_set_name;

              ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name );

              l_token_table.DELETE;

        END IF; -- END IF l_validation_code IN (G_NONE_VALIDATION_CODE,G_TABLE_VALIDATION_CODE) THEN


        -- Bug 9702841
        -- Validate maximum size validation for VS
        IF l_flex_value IS NOT NULL THEN
            IF l_format_code IN (G_NUMBER_DATA_TYPE,G_CHAR_DATA_TYPE) THEN

                    l_val_int_name_size   := Length(l_flex_value);
                    -- Log error
                    IF  l_val_int_name_size > l_vs_maximum_size THEN

                          l_error_message_name          := 'EGO_VS_MAXSIZE_VALUE_VAL';

                          -- Set process_status to 3
                          l_process_status    := g_error_record;
                          l_return_status     := G_RET_STS_ERROR;
                          l_last_updated_by   := g_user_id;
                          l_last_update_date  := SYSDATE;
                          l_last_update_login := g_login_id;


                          ERROR_HANDLER.Add_Error_Message(
                            p_message_name                   => l_error_message_name
                            ,p_application_id                => G_App_Short_Name
                            ,p_token_tbl                     => l_token_table
                            ,p_message_type                  => G_RET_STS_ERROR
                            ,p_row_identifier                => l_transaction_id
                            ,p_entity_code                   => l_entity_code
                            ,p_table_name                    => l_table_name
                          );


                    END IF;

            END IF;

        END IF;



        --bug 9702828
        -- Check if user passes end date lesser than sysdate
        IF l_end_active_date IS NOT NULL AND  l_end_active_date<> G_NULL_DATE THEN

            IF l_end_active_date < SYSDATE THEN

                l_error_message_name          := 'EGO_ENDDATE_LT_CURRDATE';

                -- Set process_status to 3
                l_process_status    := g_error_record;
                l_return_status     := G_RET_STS_ERROR;
                l_last_updated_by   := g_user_id;
                l_last_update_date  := SYSDATE;
                l_last_update_login := g_login_id;


                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                   => l_error_message_name
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => l_token_table
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => l_table_name);

            END IF;

        END IF;





        IF l_transaction_type  =G_UPDATE AND l_flex_value_id IS NULL THEN

              l_error_message_name          := 'EGO_TRANS_TYPE_INVALID';
              l_token_table(1).TOKEN_NAME   := 'Entity';
              l_token_table(1).TOKEN_VALUE  := G_ENTITY_VS_VAL;

              -- Set process_status to 3
              l_process_status    := g_error_record;
              l_return_status     := G_RET_STS_ERROR;
              l_last_updated_by   := g_user_id;
              l_last_update_date  := SYSDATE;
              l_last_update_login := g_login_id;


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name
              );


              l_token_table.DELETE;


        END IF ; -- END IF l_transaction_type  :=G_CREATE AND l_value_set_id IS NOT NULL THEN



        --Dbms_Output.put_line(' JUST BEFORE CREATE MODE l_value_set_id = '||l_value_set_id);
        IF l_transaction_type  =G_CREATE THEN

            IF l_flex_value_id IS NOT NULL AND l_version_seq_id IS NULL THEN
                --Dbms_Output.put_line(' Creation error EGO_EF_VAL_INT_NAME_EXIST ');

                l_error_message_name          := 'EGO_EF_VAL_INT_NAME_EXIST';
                -- Set process_status to 3
                l_process_status              := G_ERROR_RECORD;
                l_return_status               := G_RET_STS_ERROR;
                l_last_updated_by             := g_user_id;
                l_last_update_date            := SYSDATE;
                l_last_update_login           := g_login_id;



                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                   => l_error_message_name
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => l_token_table
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => l_table_name
                );



            END IF ; -- END IF l_transaction_type  :=G_CREATE AND l_value_set_id IS NOT NULL THEN


            IF l_format_code =G_NUMBER_DATA_TYPE THEN

                l_valid_type   := Is_Valid_Number (l_flex_value);

                IF  l_valid_type = 1 THEN

                    --Log error
                    l_process_status              := G_ERROR_RECORD;
                    l_return_status               := G_RET_STS_ERROR;
                    l_last_updated_by             := g_user_id;
                    l_last_update_date            := SYSDATE;
                    l_last_update_login           := g_login_id;

                    l_error_message_name          := 'EGO_EF_NUM_INT_NAME_ERR';

                    l_token_table(1).TOKEN_NAME   := 'FORMAT_MEANING';
                    l_token_table(1).TOKEN_VALUE  := G_NUMBER_FORMAT;

                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                   => l_error_message_name
                      ,p_application_id                => G_App_Short_Name
                      ,p_token_tbl                     => l_token_table
                      ,p_message_type                  => G_RET_STS_ERROR
                      ,p_row_identifier                => l_transaction_id
                      ,p_entity_code                   => l_entity_code
                      ,p_table_name                    => l_table_name);

                    l_token_table.DELETE;

                END IF;-- END F  l_valid_num = 1 THEN

                l_valid_type :=NULL;

            ELSIF l_format_code IN (G_DATE_DATA_TYPE ,G_DATE_TIME_DATA_TYPE ) THEN



                l_valid_type  := Is_Valid_Date (l_flex_value);

                IF  l_valid_type = 1 THEN

                  IF  l_format_code =  G_DATE_DATA_TYPE THEN

                    l_error_message_name          := 'EGO_EF_DATE_INT_NAME_ERR';

                    l_token_table(1).TOKEN_NAME   := 'FORMAT_MEANING';
                    l_token_table(1).TOKEN_VALUE  := G_DATE_FORMAT;

                    l_token_table(2).TOKEN_NAME   := 'DATE_EXAMPLE';
                    l_token_table(2).TOKEN_VALUE  := To_Char(SYSDATE,'YYYY-MM-DD') ;


                  ELSIF l_format_code =  G_DATE_TIME_DATA_TYPE THEN

                    l_error_message_name          := 'EGO_EF_DATE_TIME_INT_NAME_ERR';

                    l_token_table(1).TOKEN_NAME   := 'FORMAT_MEANING';
                    l_token_table(1).TOKEN_VALUE  := G_DATETIME_FORMAT;
                    l_token_table(2).TOKEN_NAME   := 'DATE_EXAMPLE';
                    l_token_table(2).TOKEN_VALUE  := To_Char(SYSDATE,'YYYY-MM-DD') ;



                  END IF ; -- END IF  l_format_code =  G_DATE_DATA_TYPE THEN

                  --Log error
                  l_process_status              := G_ERROR_RECORD;
                  l_return_status               := G_RET_STS_ERROR;
                  l_last_updated_by             := g_user_id;
                  l_last_update_date            := SYSDATE;
                  l_last_update_login           := g_login_id;


                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                   => l_error_message_name
                    ,p_application_id                => G_App_Short_Name
                    ,p_token_tbl                     => l_token_table
                    ,p_message_type                  => G_RET_STS_ERROR
                    ,p_row_identifier                => l_transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => l_table_name);

                  l_token_table.DELETE;


                END IF;-- END F  l_valid_num = 1 THEN

                l_valid_type :=NULL;

          END IF;-- END IF l_format_code =G_NUMBER_DATA_TYPE THEN


        END IF; -- END IF l_transaction_type  =G_CREATE THEN



        -- Assign correct return status to x_return_status
        IF Nvl(l_return_status,G_RET_STS_SUCCESS) <> G_RET_STS_SUCCESS THEN

           --Dbms_Output.put_line(' IN ERROR MODE FOR VALUE ');
           x_return_status :=  G_RET_STS_ERROR;

        END IF;-- END IF l_return_status <> G_RET_STS_SUCCESS THEN




        write_debug(G_PKG_Name,l_api_name,' Creating SAVEPOINT VALUE_VERSION_CREATE. ' );
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Creating SAVEPOINT VALUE_VERSION_CREATE. ' );

        SAVEPOINT VALUE_VERSION_CREATE;

        G_VAL_TRANS_TYPE  :=  l_transaction_type;



        FOR j IN p_value_set_val_tl_tbl.first..p_value_set_val_tl_tbl.last
        LOOP

          -- Bug 9701510
          -- For Date and DateTime VS, Convert value to DB Date format.
          IF  l_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE)
              AND p_value_set_val_tl_tbl(j).flex_value IS NOT NULL THEN

              Convert_Value_To_DbDate (p_value_set_val_tl_tbl(j).flex_value);

          END IF;
          -- Bug 9701510


          IF ( p_value_set_val_tl_tbl(j).flex_value=l_flex_value
                OR p_value_set_val_tl_tbl(j).flex_value_id=l_flex_value_id ) THEN
            -- Check if this is a versioned value set, If so then please process values for a corresponding vesion.

              IF l_version_seq_id IS NOT NULL THEN

                  IF p_value_set_val_tl_tbl(j).version_seq_id=l_version_seq_id THEN


                      -- get Value_id from a given value. Cross verify if flex_value is created
                      IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN

                        Convert_Name_To_Id (l_flex_value,G_Value,l_value_set_id,l_flex_value_id);

                      END IF; -- END IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN



                      --Check for transaction type and update it correctly
                      IF p_value_set_val_tl_tbl(j).transaction_type  =G_SYNC THEN

                          IF l_flex_value_id IS NOT NULL THEN

                              l_transaction_type                          :=G_UPDATE;
                              p_value_set_val_tl_tbl(j).transaction_type  :=G_UPDATE;

                          ELSE

                              l_transaction_type                          :=G_CREATE;
                              p_value_set_val_tl_tbl(j).transaction_type  :=G_CREATE;

                          END IF;

                      END IF; -- END IF l_transaction_type  =G_SYNC THEN

                      --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  fetching _TL Records, Transaction type is : '||l_transaction_type);

                      IF p_value_set_val_tl_tbl(j).transaction_type = l_transaction_type THEN


                          l_description             :=  p_value_set_val_tl_tbl(j).description;
                          l_source_lang		          :=	p_value_set_val_tl_tbl(j).source_lang;
                          l_flex_value_meaning      :=	p_value_set_val_tl_tbl(j).flex_value_meaning;
                          l_language                :=  p_value_set_val_tl_tbl(j).LANGUAGE;
                          l_source_lang             :=  p_value_set_val_tl_tbl(j).Source_lang;


                          -- Bug 9702841
                          -- Validate maximum size validation for VS
                          IF l_flex_value_meaning IS NOT NULL THEN
                              IF l_format_code IN (G_NUMBER_DATA_TYPE,G_CHAR_DATA_TYPE) THEN

                                      l_val_disp_name_size   := Length(l_flex_value_meaning);
                                      -- Log error
                                      IF  l_val_disp_name_size > l_vs_maximum_size THEN

                                            l_error_message_name          := 'EGO_VS_MAXSIZE_VALUE_VAL';

                                            -- Set process_status to 3
                                            l_process_status    := g_error_record;
                                            l_return_status     := G_RET_STS_ERROR;
                                            l_last_updated_by   := g_user_id;
                                            l_last_update_date  := SYSDATE;
                                            l_last_update_login := g_login_id;


                                            ERROR_HANDLER.Add_Error_Message(
                                              p_message_name                   => l_error_message_name
                                              ,p_application_id                => G_App_Short_Name
                                              ,p_token_tbl                     => l_token_table
                                              ,p_message_type                  => G_RET_STS_ERROR
                                              ,p_row_identifier                => l_transaction_id
                                              ,p_entity_code                   => l_entity_code
                                              ,p_table_name                    => l_table_name
                                            );


                                      END IF;

                              END IF;


                          END IF;

                          IF l_language = UserEnv('Lang')  THEN

                              --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Current lang record exist for value : '||l_flex_value||' Value Id : '||l_flex_value_id );
                              l_current_lang_exist := TRUE;

                          END IF;


                      END IF;--



                    --END IF;
                  END IF;-- End IF p_value_set_val_tl_tbl(j).version_seq_id=l_version_seq_id THEN

              ELSE



                  -- get Value_id from a given value. Cross verify if flex_value is created
                  IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN

                    Convert_Name_To_Id (l_flex_value,G_Value,l_value_set_id,l_flex_value_id);

                  END IF; -- END IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN


                  IF p_value_set_val_tl_tbl(j).transaction_type =  G_SYNC THEN
                    IF l_flex_value_id IS NOT NULL THEN

                      p_value_set_val_tl_tbl(j).transaction_type := G_UPDATE;

                    ELSE

                      p_value_set_val_tl_tbl(j).transaction_type := G_CREATE;

                    END IF;

                  END IF; -- END IF p_value_set_val_tl_tbl.transaction_type =  G_SYNC THEN



                  IF p_value_set_val_tl_tbl(j).transaction_type = l_transaction_type THEN

                      --l_val_version_seq_id	    :=	version_seq_id,
                      l_description             :=  p_value_set_val_tl_tbl(j).description;
                      l_source_lang		          :=	p_value_set_val_tl_tbl(j).source_lang;
                      l_flex_value_meaning      :=	p_value_set_val_tl_tbl(j).flex_value_meaning;
                      l_language                :=  p_value_set_val_tl_tbl(j).LANGUAGE;
                      l_source_lang             :=  p_value_set_val_tl_tbl(j).Source_lang;



                      -- Bug 9702841
                      -- Validate maximum size validation for VS
                      IF l_flex_value_meaning IS NOT NULL THEN
                          IF l_format_code IN (G_NUMBER_DATA_TYPE,G_CHAR_DATA_TYPE) THEN

                                  l_val_disp_name_size   := Length(l_flex_value_meaning);
                                  -- Log error
                                  IF  l_val_disp_name_size > l_vs_maximum_size THEN

                                        l_error_message_name          := 'EGO_VS_MAXSIZE_VALUE_VAL';

                                        -- Set process_status to 3
                                        l_process_status    := g_error_record;
                                        l_return_status     := G_RET_STS_ERROR;
                                        l_last_updated_by   := g_user_id;
                                        l_last_update_date  := SYSDATE;
                                        l_last_update_login := g_login_id;


                                        ERROR_HANDLER.Add_Error_Message(
                                          p_message_name                   => l_error_message_name
                                          ,p_application_id                => G_App_Short_Name
                                          ,p_token_tbl                     => l_token_table
                                          ,p_message_type                  => G_RET_STS_ERROR
                                          ,p_row_identifier                => l_transaction_id
                                          ,p_entity_code                   => l_entity_code
                                          ,p_table_name                    => l_table_name
                                        );


                                  END IF;

                          END IF;

                      END IF;



                  END IF;--


                  --END IF; -- END IF p_value_set_val_tl_tbl(j).LANGUAGE= p_value_set_val_tl_tbl(j).source_lang THEN
              END IF; -- END IF l_version_seq_id IS NOT NULL THEN



          END IF;-- End IF p_value_set_val_tl_tbl(j).flex_value=l_flex_value THEN


        --END LOOP; -- END FOR j IN p_value_set_val_tl_tbl.first..p_value_set_val_tl_tbl.last






          -- Get some key values, if transaction type is update.
          IF l_transaction_type=G_UPDATE THEN

              IF l_process_status = G_PROCESS_RECORD  THEN

                Get_Key_Value_Columns
                    ( p_value_set_id      => l_value_set_id,
                      p_value_id          => l_flex_value_id,
                      x_display_name      => l_flex_value_meaning,
                      x_disp_sequence     => l_disp_sequence,
                      x_start_date_active => l_start_active_date,
                      x_end_date_active   => l_end_active_date,
                      x_description       => l_description,
                      x_enabled_flag      => l_enabled_flag,
                      x_return_status     => l_return_status,
                      x_return_msg        => l_return_msg);




                write_debug(G_PKG_Name,l_api_name,' After call to Get_Key_Value_Columns ');
                --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  After call to Get_Key_Value_Columns ');



                -- check the return status
                IF (Nvl(l_return_status,G_RET_STS_SUCCESS)  =G_RET_STS_SUCCESS ) THEN

                  l_process_status:= G_PROCESS_RECORD;

                ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                  x_return_status := l_return_status;
                  l_process_status:= G_ERROR_RECORD;


		              G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                  G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS;
                  G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                  G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                  G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                  G_TOKEN_TBL(3).Token_Value  :=  'EGO_VS_BULKLOAD_PVT';
                  G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                  G_TOKEN_TBL(4).Token_Value  :=  'Get_Key_Value_Columns';


                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                   => 'EGO_ENTITY_API_FAILED'
                    ,p_application_id                => G_App_Short_Name
                    ,p_token_tbl                     => G_TOKEN_TBL
                    ,p_message_type                  => G_RET_STS_ERROR
                    ,p_row_identifier                => l_transaction_id
                    ,p_entity_code                   => G_ENTITY_VS
                    ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

                ELSE
                  write_debug(G_PKG_Name,l_api_name,' : Unexpected exception ' );
                  x_return_status :=  G_RET_STS_UNEXP_ERROR;
                  x_return_msg    :=  l_return_msg;
                  RETURN;

                END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN


              END IF;




                -- Already checked at the start of API
              IF l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL OR l_enabled_flag IS NULL THEN

                  l_error_message_name          := 'EGO_VAL_KEY_REQ_ERR';

                  -- Set process_status to 3
                  l_process_status              := G_ERROR_RECORD;
                  l_return_status               := G_RET_STS_ERROR;
                  l_last_updated_by             := g_user_id;
                  l_last_update_date            := SYSDATE;
                  l_last_update_login           := g_login_id;


                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                   => l_error_message_name
                    ,p_application_id                => G_App_Short_Name
                    ,p_token_tbl                     => l_token_table
                    ,p_message_type                  => G_RET_STS_ERROR
                    ,p_row_identifier                => l_transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => l_table_name);


              END IF; -- END IF l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL THEN


          END IF;



          --bug 9702828
          -- Check if user passes end date lesser than sysdate
          IF l_end_active_date IS NOT NULL AND  l_end_active_date<> G_NULL_DATE THEN


              IF l_start_active_date IS NOT NULL AND  l_start_active_date<> G_NULL_DATE THEN


                  IF l_start_active_date >l_end_active_date THEN

                      l_error_message_name          := 'EGO_START_DATE_GT_END_DATE';

                      -- Set process_status to 3
                      l_process_status    := g_error_record;
                      l_return_status     := G_RET_STS_ERROR;
                      l_last_updated_by   := g_user_id;
                      l_last_update_date  := SYSDATE;
                      l_last_update_login := g_login_id;


                      ERROR_HANDLER.Add_Error_Message(
                        p_message_name                   => l_error_message_name
                        ,p_application_id                => G_App_Short_Name
                        ,p_token_tbl                     => l_token_table
                        ,p_message_type                  => G_RET_STS_ERROR
                        ,p_row_identifier                => l_transaction_id
                        ,p_entity_code                   => l_entity_code
                        ,p_table_name                    => l_table_name);


                  END IF;

              END IF;

          END IF;




          --Based on transaction type do processing of values.
          IF l_transaction_type=G_CREATE THEN

              -- Check for ValueSetType/Validation type is done as bulk check..
              -- Create a value set to keep sync with existing framework



              IF l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL THEN

                  l_error_message_name          := 'EGO_VAL_KEY_REQ_ERR';

                  --Dbms_Output.put_line( '  l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL THEN ');

                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                   => l_error_message_name
                    ,p_application_id                => G_App_Short_Name
                    ,p_token_tbl                     => l_token_table
                    ,p_message_type                  => G_RET_STS_ERROR
                    ,p_row_identifier                => l_transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => l_table_name
                  );


                  -- Set process_status to 3
                l_process_status              := G_ERROR_RECORD;
                l_return_status               := G_RET_STS_ERROR;
                l_last_updated_by             := g_user_id;
                l_last_update_date            := SYSDATE;
                l_last_update_login           := g_login_id;


              END IF; -- END IF l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL THEN


              -- Check if value has already been created.
              IF l_flex_value_id IS NULL THEN
                IF ( p_value_set_val_tl_tbl(j).flex_value=l_flex_value ) THEN



                  -- Create value only is it has not been created.
                  IF l_process_status = G_PROCESS_RECORD  THEN

                    EGO_EXT_FWK_PUB.Create_Value_Set_Val
                      (
                        p_api_version                    => p_api_version
                        ,p_value_set_name                => l_value_set_name
                        ,p_internal_name                 => l_flex_value
                        ,p_display_name                  => l_flex_value_meaning
                        ,p_description                   => l_description
                        ,p_sequence                      => l_disp_sequence
                        ,p_start_date                    => l_start_active_date
                        ,p_end_date                      => l_end_active_date
                        ,p_enabled                       => l_enabled_flag
                        ,p_owner                         => l_owner
                        ,p_init_msg_list                 => l_init_msg_list
                        ,p_commit                        => FND_API.G_FALSE
                        ,x_return_status                 => l_return_status
                        ,x_msg_count                     => x_msg_count
                        ,x_msg_data                      => l_return_msg
                      );



                    -- check the return status
                    IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS ) THEN

                      l_process_status  := G_PROCESS_RECORD;
                      l_return_status   :=  G_RET_STS_SUCCESS;

                    ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                      l_return_status             :=  G_RET_STS_ERROR;
                      l_process_status            :=  G_ERROR_RECORD;

		                  G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                      G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS_VAL;
                      G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                      G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                      G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                      G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB';
                      G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                      G_TOKEN_TBL(4).Token_Value  :=  'Create_Value_Set_Val';


                      ERROR_HANDLER.Add_Error_Message(
                        p_message_name                   => 'EGO_ENTITY_API_FAILED'
                        ,p_application_id                => G_App_Short_Name
                        ,p_token_tbl                     => G_TOKEN_TBL
                        ,p_message_type                  => G_RET_STS_ERROR
                        ,p_row_identifier                => l_transaction_id
                        ,p_entity_code                   => G_ENTITY_VS_VAL
                        ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );

                    ELSE

                      x_return_status :=  G_RET_STS_UNEXP_ERROR;
                      x_return_msg    :=  l_return_msg;
                      RETURN;

                    END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN





                  /*ELSE
                    -- Setting TL table process status to that of Value table.
                    /*p_value_set_val_tl_tbl(j).process_status := l_process_status;
                    p_value_set_val_tl_tbl(j).value_set_id    :=l_value_set_id;
                    p_value_set_val_tl_tbl(j).value_set_name  :=l_value_set_name;
                    p_value_set_val_tl_tbl(j).flex_value      :=l_flex_value;
                    p_value_set_val_tl_tbl(j).transaction_type:=l_transaction_type;*/


                  END IF; -- END IF l_process_status = G_PROCESS_RECORD  THEN



                END IF; -- END IF ( ( p_value_set_val_tl_tbl(j).flex_value=l_flex_value
              END IF; -- END IF l_flex_value_id IS NULL THEN



              -- get Value_id from a given value as value should have been created by now.
              IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN

                FOR l IN cur_value(l_value_set_id, l_flex_value)
                LOOP
                  l_flex_value_id := l.flex_value_id;
                END LOOP;

              END IF; -- END IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN


              ----******* Create Version Values************------------
              -- Create Versioned value.
              IF ( p_value_set_val_tl_tbl(j).flex_value=l_flex_value
                       OR p_value_set_val_tl_tbl(j).flex_value_id=l_flex_value_id )THEN


                IF l_version_seq_id IS NOT NULL THEN

                  IF p_value_set_val_tl_tbl(j).process_status = G_PROCESS_RECORD AND l_process_status =G_PROCESS_RECORD THEN



                      -- Check if value already exist
                      FOR i IN Cur_Value_Ver_Exist(l_value_set_id,l_flex_value_id,G_OUT_VERSION_SEQ_ID)
                      LOOP
                        l_val_ver_exist := i.exist;
                      END LOOP; -- END FOR i IN Cur_Value_Ver_Exist

                      -- Check if translatable value exist
                      FOR i IN Cur_Trans_Value_Ver_Exist(--l_value_set_id,
                                                          l_flex_value_id,G_OUT_VERSION_SEQ_ID,l_language)
                      LOOP

                          l_trans_val_ver_exist := i.exist;

                      END LOOP; -- END FOR i IN Cur_Value_Ver_Exist





                      IF l_val_ver_exist IS NULL THEN

                          INSERT INTO EGO_FLEX_VALUE_VERSION_B
                                  (FLEX_VALUE_SET_ID,FLEX_VALUE_ID,VERSION_SEQ_ID,SEQUENCE
                                  ,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
                          VALUES  (l_VALUE_SET_ID,l_FLEX_VALUE_ID,G_OUT_VERSION_SEQ_ID, l_disp_sequence,
                                  G_Party_Id,SYSDATE,G_Party_Id ,SYSDATE,G_Login_Id);

                      END IF;

                      --Dbms_Output.put_line(' Inserted reord in EGO_FLEX_VALUE_VERSION_B table '||p_value_set_val_tl_tbl(j).flex_value);


                      IF l_trans_val_ver_exist IS NULL THEN

                          INSERT INTO EGO_FLEX_VALUE_VERSION_TL
                                  ( FLEX_VALUE_ID,VERSION_SEQ_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,
	                                  CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,DESCRIPTION,FLEX_VALUE_MEANING,LANGUAGE,SOURCE_LANG)
                          VALUES  ( l_FLEX_VALUE_ID,G_OUT_VERSION_SEQ_ID,SYSDATE,G_Party_Id, SYSDATE,G_Party_Id,G_Login_Id,
                                    l_description, l_flex_value_meaning,l_language,l_source_lang) ;


                      END IF;

                      --Dbms_Output.put_line(' Inserted reord in EGO_FLEX_VALUE_VERSION_TL table '||p_value_set_val_tl_tbl(j).flex_value);


                      l_process_status:= G_SUCCESS_RECORD;
                      --l_version_seq_id  :=  G_OUT_VERSION_SEQ_ID;


                  END IF; -- END IF p_value_set_val_tl_tbl(j).process_status = G_PROCESS_RECORD THEN


                ELSE

                  IF l_return_status = G_RET_STS_SUCCESS THEN

                    l_process_status:= G_SUCCESS_RECORD;

                    /*p_value_set_val_tl_tbl(j).process_status :=G_SUCCESS_RECORD;
                    p_value_set_val_tl_tbl(j).value_set_id    :=l_value_set_id;
                    p_value_set_val_tl_tbl(j).value_set_name  :=l_value_set_name;
                    p_value_set_val_tl_tbl(j).flex_value_id   :=l_flex_value_id;
                    p_value_set_val_tl_tbl(j).flex_value      :=l_flex_value;
                    p_value_set_val_tl_tbl(j).transaction_type:=l_transaction_type;*/



                  END IF;


                END IF; -- END IF l_version_seq_id IS NOT NULL THEN


              END IF; -- END IF ( p_value_set_val_tl_tbl(j).flex_value=l_flex_value

              --Dbms_Output.put_line(' TL Date : '||p_value_set_val_tl_tbl(j).flex_value||' Id = '||p_value_set_val_tl_tbl(j).flex_value_id );

              -- Write code for version related information.


          ELSIF l_transaction_type=G_UPDATE THEN

              --IF p_value_set_val_tl_tbl(j).LANGUAGE= p_value_set_val_tl_tbl(j).source_lang THEN


                write_debug(G_PKG_Name,l_api_name,' UPDATE MODE : calling EGO_EXT_FWK_PUB.Update_Value_Set_Val API ');
                --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' UPDATE MODE : calling EGO_EXT_FWK_PUB.Update_Value_Set_Val API l_vs_id= '||l_value_set_id);

                -- Get value of display sequence if not passed by user.

              /*IF l_process_status = G_PROCESS_RECORD  THEN

                Get_Key_Value_Columns
                    ( p_value_set_id      => l_value_set_id,
                      p_value_id          => l_flex_value_id,
                      x_display_name      => l_flex_value_meaning,
                      x_disp_sequence     => l_disp_sequence,
                      x_start_date_active => l_start_active_date,
                      x_description       => l_description,
                      x_enabled_flag      => l_enabled_flag,
                      x_return_status     => l_return_status,
                      x_return_msg        => l_return_msg);




                write_debug(G_PKG_Name,l_api_name,' After call to Get_Key_Value_Columns ');
                --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  After call to Get_Key_Value_Columns ');



                -- check the return status
                IF (Nvl(l_return_status,G_RET_STS_SUCCESS)  =G_RET_STS_SUCCESS ) THEN

                  l_process_status:= G_PROCESS_RECORD;

                ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                  x_return_status := l_return_status;
                  l_process_status:= G_ERROR_RECORD;


		              G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                  G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS;
                  G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                  G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                  G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                  G_TOKEN_TBL(3).Token_Value  :=  'EGO_VS_BULKLOAD_PVT';
                  G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                  G_TOKEN_TBL(4).Token_Value  :=  'Get_Key_Value_Columns';


                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                   => 'EGO_ENTITY_API_FAILED'
                    ,p_application_id                => G_App_Short_Name
                    ,p_token_tbl                     => G_TOKEN_TBL
                    ,p_message_type                  => G_RET_STS_ERROR
                    ,p_row_identifier                => l_transaction_id
                    ,p_entity_code                   => G_ENTITY_VS
                    ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

                ELSE
                  write_debug(G_PKG_Name,l_api_name,' : Unexpected exception ' );
                  x_return_status :=  G_RET_STS_UNEXP_ERROR;
                  x_return_msg    :=  l_return_msg;
                  RETURN;

                END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN


              END IF;



                -- Already checked at the start of API
              IF l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL OR l_enabled_flag IS NULL THEN

                  l_error_message_name          := 'EGO_VAL_KEY_REQ_ERR';
                  --Dbms_Output.put_line(l_api_name||' Test IF l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL ');


                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                   => l_error_message_name
                    ,p_application_id                => G_App_Short_Name
                    ,p_token_tbl                     => l_token_table
                    ,p_message_type                  => G_RET_STS_ERROR
                    ,p_row_identifier                => l_transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => l_table_name
                  );


                  -- Set process_status to 3
                l_process_status              := G_ERROR_RECORD;
                l_return_status               := G_RET_STS_ERROR;
                l_last_updated_by             := g_user_id;
                l_last_update_date            := SYSDATE;
                l_last_update_login           := g_login_id;


              END IF; -- END IF l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL THEN

              */



              IF l_process_status = G_PROCESS_RECORD  THEN
                EGO_EXT_FWK_PUB.Update_Value_Set_Val
                  (
                    p_api_version                   => p_api_version
                    ,p_value_set_name                => l_value_set_name
                    ,p_internal_name                 => l_flex_value
                    ,p_display_name                  => l_flex_value_meaning
                    ,p_description                   => CASE l_description
                                                          WHEN G_NULL_CHAR THEN NULL
                                                          ELSE l_description
                                                        END --l_description
                    ,p_sequence                      => l_disp_sequence
                    ,p_start_date                    => CASE l_start_active_date
                                                          WHEN G_NULL_DATE THEN NULL
                                                          ELSE l_start_active_date
                                                        END
                    ,p_end_date                      => CASE l_end_active_date
                                                          WHEN G_NULL_DATE THEN NULL
                                                          ELSE l_end_active_date
                                                        END
                    ,p_enabled                       => l_enabled_flag
                    ,p_owner                         => l_owner
                    ,p_init_msg_list                 => l_init_msg_list
                    ,p_commit                        => FND_API.G_FALSE
                    ,x_return_status                 => l_return_status
                    ,x_msg_count                     => x_msg_count
                    ,x_msg_data                      => l_return_msg
                    ,x_is_versioned                  => l_is_versioned
                    ,x_valueSetId                    => l_value_set_id);



                -- check the return status
                IF (Nvl(l_return_status,G_RET_STS_SUCCESS) = G_RET_STS_SUCCESS )
                THEN

                  l_process_status:= G_PROCESS_RECORD;
                  l_return_status :=  G_RET_STS_SUCCESS;

                ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                  l_return_status := G_RET_STS_ERROR;
                  l_process_status:= G_ERROR_RECORD;
                  /*p_value_set_val_tl_tbl(j).process_status :=G_ERROR_RECORD;
                  p_value_set_val_tl_tbl(j).value_set_id    :=l_value_set_id;
                  p_value_set_val_tl_tbl(j).value_set_name  :=l_value_set_name;
                  p_value_set_val_tl_tbl(j).flex_value_id   :=l_flex_value_id;
                  p_value_set_val_tl_tbl(j).flex_value      :=l_flex_value;
                  p_value_set_val_tl_tbl(j).transaction_type:=l_transaction_type;*/


		              G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                  G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS_VAL;
                  G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                  G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                  G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                  G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB';
                  G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                  G_TOKEN_TBL(4).Token_Value  :=  'Update_Value_Set_Val';


                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                   => 'EGO_ENTITY_API_FAILED'
                    ,p_application_id                => G_App_Short_Name
                    ,p_token_tbl                     => G_TOKEN_TBL
                    ,p_message_type                  => G_RET_STS_ERROR
                    ,p_row_identifier                => l_transaction_id
                    ,p_entity_code                   => G_ENTITY_VS_VAL
                    ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );


                ELSE
                  --Dbms_Output.put_line(' unexpected error in  EGO_EXT_FWK_PUB.Update_Value_Set_Val '||l_return_msg||SQLERRM);
                  write_debug(G_PKG_Name,l_api_name,' : Unexpected exception ' );
                  x_return_status :=  G_RET_STS_UNEXP_ERROR;
                  x_return_msg    :=  l_return_msg;
                  RETURN;

                END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN


              /*ELSE
                -- Setting TL table process status to that of Value table.
                /*p_value_set_val_tl_tbl(j).process_status := l_process_status;
                p_value_set_val_tl_tbl(j).value_set_id    :=l_value_set_id;
                p_value_set_val_tl_tbl(j).value_set_name  :=l_value_set_name;
                p_value_set_val_tl_tbl(j).flex_value_id   :=l_flex_value_id;
                p_value_set_val_tl_tbl(j).flex_value      :=l_flex_value;
                p_value_set_val_tl_tbl(j).transaction_type:=l_transaction_type;*/


              END IF; -- END IF l_process_status = G_PROCESS_RECORD  THEN


              IF l_process_status = G_PROCESS_RECORD  THEN



                --IF l_version_seq_id IS NOT NULL THEN
                IF (p_value_set_val_tl_tbl(j).flex_value=l_flex_value
                        OR p_value_set_val_tl_tbl(j).flex_value_id=l_flex_value_id ) THEN

                  --IF p_value_set_val_tl_tbl(j).flex_value=l_flex_value THEN
                  IF l_version_seq_id IS NOT NULL THEN

                    -- Write a code to verify that no record exist with given flex_value and version_seq_id

                    IF p_value_set_val_tl_tbl(j).process_status = G_PROCESS_RECORD AND l_process_status =G_PROCESS_RECORD THEN

                      -- Check if value already exist
                      FOR i IN Cur_Value_Ver_Exist(l_value_set_id,l_flex_value_id,G_OUT_VERSION_SEQ_ID)
                      LOOP
                        l_val_ver_exist := i.exist;
                      END LOOP; -- END FOR i IN Cur_Value_Ver_Exist

                      -- Check if translatable value exist
                      FOR i IN Cur_Trans_Value_Ver_Exist(--l_value_set_id,
                                                          l_flex_value_id,G_OUT_VERSION_SEQ_ID,l_language)
                      LOOP

                          l_trans_val_ver_exist := i.exist;

                      END LOOP; -- END FOR i IN Cur_Value_Ver_Exist


                      IF l_val_ver_exist IS NULL THEN

                          --Dbms_Output.put_line(' Value record not exist. Insert record ');

                          INSERT INTO EGO_FLEX_VALUE_VERSION_B
                                  (FLEX_VALUE_SET_ID,FLEX_VALUE_ID,VERSION_SEQ_ID,SEQUENCE
                                  ,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
                          VALUES  (l_VALUE_SET_ID,l_FLEX_VALUE_ID,G_OUT_VERSION_SEQ_ID, l_disp_sequence,
                                  G_Party_Id,SYSDATE,G_Party_Id ,SYSDATE,G_Login_Id);

                      END IF; -- END IF l_val_ver_exist IS NULL THEN



                      IF l_trans_val_ver_exist IS NULL THEN

                          --Dbms_Output.put_line(' Trans record not exist. Insert record ');

                          -- Write a code to verify that no record exist with given flex_value and version_seq_id
                          INSERT INTO EGO_FLEX_VALUE_VERSION_TL
                                  ( FLEX_VALUE_ID,VERSION_SEQ_ID,LAST_UPDATE_DATE,LAST_UPDATED_BY,
	                                  CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,DESCRIPTION,FLEX_VALUE_MEANING,LANGUAGE,SOURCE_LANG)
                          VALUES  ( l_FLEX_VALUE_ID,G_OUT_VERSION_SEQ_ID,SYSDATE,G_Party_Id, SYSDATE,G_Party_Id,G_Login_Id,
                                  l_description, l_flex_value_meaning,l_language,l_source_lang) ;

                      END IF; -- END IF l_trans_val_ver_exist IS NULL THEN


                      -- Set return status to success at the end.
                      l_process_status:= G_SUCCESS_RECORD;
                      /*p_value_set_val_tl_tbl(j).process_status  :=G_SUCCESS_RECORD;
                      p_value_set_val_tl_tbl(j).value_set_id    :=l_value_set_id;
                      p_value_set_val_tl_tbl(j).value_set_name  :=l_value_set_name;
                      p_value_set_val_tl_tbl(j).flex_value_id   :=l_flex_value_id;
                      p_value_set_val_tl_tbl(j).flex_value      :=l_flex_value;
                      p_value_set_val_tl_tbl(j).transaction_type:=l_transaction_type; */


                      --l_version_seq_id  :=  G_OUT_VERSION_SEQ_ID;


                    END IF;-- END IF p_value_set_val_tl_tbl(j).process_status = G_PROCESS_RECORD THEN


                  ELSE

                    IF l_return_status = G_RET_STS_SUCCESS THEN

                      l_process_status:= G_SUCCESS_RECORD;

                      /*p_value_set_val_tl_tbl(j).process_status :=G_SUCCESS_RECORD;
                      p_value_set_val_tl_tbl(j).value_set_id    :=l_value_set_id;
                      p_value_set_val_tl_tbl(j).value_set_name  :=l_value_set_name;
                      p_value_set_val_tl_tbl(j).flex_value_id   :=l_flex_value_id;
                      p_value_set_val_tl_tbl(j).flex_value      :=l_flex_value;
                      p_value_set_val_tl_tbl(j).transaction_type:=l_transaction_type;*/


                    END IF;


                  END IF; -- END IF version_seq_id IS NOT NULL THEN


                END IF; -- END IF p_value_set_val_tl_tbl(j).flex_value=l_flex_value THEN

              END IF; -- END IF l_process_status = G_PROCESS_RECORD  THEN

          END IF; -- END IF l_transaction_type=G_CREATE THEN





          --Dbms_Output.put_line(' COMPLETION OF PROCESSING p_value_set_val_tbl(i).flex_value = '||p_value_set_val_tbl(i).flex_value||' process_status = '||L_process_status);
          --Dbms_Output.put_line(' l_value_set_id = '||l_value_set_id);
          IF p_value_set_val_tl_tbl(j).process_status = G_PROCESS_RECORD THEN

              -- Bug 9701510
              IF ( p_value_set_val_tl_tbl(j).flex_value= l_flex_value --p_value_set_val_tbl(i).flex_value
                    OR p_value_set_val_tl_tbl(j).flex_value_id= l_flex_value_id ) THEN --p_value_set_val_tbl(i).flex_value_id ) THEN

                  IF p_value_set_val_tl_tbl(j).transaction_type =l_transaction_type THEN


                      -- Check if this is a versioned value set, If so then please process values for a corresponding vesion.
                      /*IF l_version_seq_id IS NOT NULL THEN

                          IF p_value_set_val_tl_tbl(j).version_seq_id=l_version_seq_id THEN

                              --Dbms_Output.put_line(' TL Table data for version Value ='||p_value_set_val_tl_tbl(j).flex_value||' l_process_status = '||l_process_status);

                              p_value_set_val_tl_tbl(j).process_status := l_process_status;
                              p_value_set_val_tl_tbl(j).value_set_id    :=l_value_set_id;
                              p_value_set_val_tl_tbl(j).value_set_name  :=l_value_set_name;
                              p_value_set_val_tl_tbl(j).flex_value_id   :=l_flex_value_id;
                              p_value_set_val_tl_tbl(j).flex_value      :=l_flex_value;

                          END IF;-- End IF p_value_set_val_tl_tbl(j).version_seq_id=l_version_seq_id THEN

                      ELSE*/

                      IF l_version_seq_id IS NULL THEN

                          --Dbms_Output.put_line(' TL Table data for version Value ='||p_value_set_val_tl_tbl(j).flex_value||'process status = '||l_process_status);
                          p_value_set_val_tl_tbl(j).process_status := l_process_status;
                          p_value_set_val_tl_tbl(j).value_set_id    :=l_value_set_id;
                          p_value_set_val_tl_tbl(j).value_set_name  :=l_value_set_name;
                          p_value_set_val_tl_tbl(j).flex_value_id   :=l_flex_value_id;
                          p_value_set_val_tl_tbl(j).flex_value      :=l_date_val_old_int_name;

                          IF l_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE) THEN

                              p_value_set_val_tl_tbl(j).flex_value         :=l_date_val_old_int_name;


                          END IF;




                      END IF; -- END IF l_version_seq_id IS NOT NULL THEN

                  END IF; -- END IF p_value_set_val_tl_tbl(j).transaction_type =l_transaction_type THEN

              END IF;-- End IF p_value_set_val_tl_tbl(j).flex_value=l_flex_value THEN

          END IF ;-- END IF p_value_set_val_tl_tbl(j).process_status = G_PROCESS_RECORD THEN










          -- Re- Initializing Values.
          l_language                :=  NULL;
          l_source_lang	            :=  NULL;
          l_flex_value_meaning      :=  NULL;
          l_description             :=  NULL;


        END LOOP; -- END FOR j IN p_value_set_val_tl_tbl.first..p_value_set_val_tl_tbl.last



        IF l_version_seq_id IS NOT NULL THEN

            --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Deciding if records need to be rollback. ');
            -- Rollback to SAVEPOINT
            --IF G_VAL_TRANS_TYPE = G_CREATE THEN

                IF NOT l_current_lang_exist THEN

                    write_debug(G_PKG_Name,l_api_name,' ROLLBACK TO VALUE_VERSION_CREATE. ' );
                    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' ROLLBACK TO VALUE_VERSION_CREATE. ' );
                    ROLLBACK TO VALUE_VERSION_CREATE;



                    --Log error
                    l_process_status              := G_ERROR_RECORD;
                    l_return_status               := G_RET_STS_ERROR;
                    l_last_updated_by             := g_user_id;
                    l_last_update_date            := SYSDATE;
                    l_last_update_login           := g_login_id;

                    l_error_message_name          := 'EGO_BASE_LANG_REC_REQ';


                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                   => l_error_message_name
                      ,p_application_id                => G_App_Short_Name
                      ,p_token_tbl                     => l_token_table
                      ,p_message_type                  => G_RET_STS_ERROR
                      ,p_row_identifier                => l_transaction_id
                      ,p_entity_code                   => l_entity_code
                      ,p_table_name                    => l_table_name);





                     --Dbms_Output.put_line(' VS Name : '||l_value_set_name||' Id '||l_value_set_id||' flex = '||l_flex_value||' val Id =' ||l_flex_value_id);


                    FOR Tl_Rec IN p_value_set_val_tl_tbl.first..p_value_set_val_tl_tbl.last
                    LOOP
                          --Dbms_Output.put_line('  p_value_set_val_tl_tbl(Tl_Rec).flex_value =' ||p_value_set_val_tl_tbl(Tl_Rec).flex_value);
                          --Dbms_Output.put_line(' Process status = '||p_value_set_val_tl_tbl(Tl_Rec).process_status );

                          IF p_value_set_val_tl_tbl(Tl_Rec).process_status = G_PROCESS_RECORD THEN
                                                                             -- Bug 9701510
                              IF ( p_value_set_val_tl_tbl(Tl_Rec).flex_value= l_flex_value --p_value_set_val_tbl(i).flex_value
                                    OR p_value_set_val_tl_tbl(Tl_Rec).flex_value_id= l_flex_value_id ) THEN --p_value_set_val_tbl(i).flex_value_id ) THEN


                                  IF p_value_set_val_tl_tbl(Tl_Rec).transaction_type =l_transaction_type THEN


                                      -- Check if this is a versioned value set, If so then please process values for a corresponding vesion.
                                      IF l_version_seq_id IS NOT NULL THEN

                                          IF p_value_set_val_tl_tbl(Tl_Rec).version_seq_id=l_version_seq_id THEN

                                              p_value_set_val_tl_tbl(Tl_Rec).process_status := G_ERROR_RECORD;
                                              p_value_set_val_tl_tbl(Tl_Rec).value_set_id    :=l_value_set_id;
                                              p_value_set_val_tl_tbl(Tl_Rec).value_set_name  :=l_value_set_name;
                                              p_value_set_val_tl_tbl(Tl_Rec).flex_value_id   :=l_flex_value_id;
                                              p_value_set_val_tl_tbl(Tl_Rec).flex_value      :=l_date_val_old_int_name;

                                              IF l_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE) THEN

                                                  p_value_set_val_tl_tbl(Tl_Rec).flex_value         :=l_date_val_old_int_name;


                                              END IF;




                                              l_return_status               := G_RET_STS_ERROR;
                                              l_error_message_name          := 'EGO_BASE_LANG_REC_REQ';


                                              ERROR_HANDLER.Add_Error_Message(
                                                 p_message_name                   => l_error_message_name
                                                ,p_application_id                => G_App_Short_Name
                                                ,p_token_tbl                     => l_token_table
                                                ,p_message_type                  => G_RET_STS_ERROR
                                                ,p_row_identifier                => p_value_set_val_tl_tbl(Tl_Rec).transaction_id
                                                ,p_entity_code                   => G_ENTITY_VS_VER
                                                ,p_table_name                    => G_ENTITY_VAL_TL_HEADER_TAB);



                                          END IF;-- End IF p_value_set_val_tl_tbl(j).version_seq_id=l_version_seq_id THEN


                                      END IF; -- END IF l_version_seq_id IS NOT NULL THEN

                                  END IF; -- END IF p_value_set_val_tl_tbl(j).transaction_type =l_transaction_type THEN

                              END IF;-- End IF p_value_set_val_tl_tbl(j).flex_value=l_flex_value THEN


                          END IF ;-- END IF p_value_set_val_tl_tbl(j).process_status = G_PROCESS_RECORD THEN



                    END LOOP;



                ELSE

                    FOR Tl_Rec IN p_value_set_val_tl_tbl.first..p_value_set_val_tl_tbl.last
                    LOOP


                        --Dbms_Output.put_line(' IN TL Loop : COMPLETION OF PROCESSING p_value_set_val_tbl(i).flex_value = '||p_value_set_val_tbl(i).flex_value||' process_status = '||L_process_status);
                        --Dbms_Output.put_line(' l_value_set_id = '|| l_value_set_id);
                        IF p_value_set_val_tl_tbl(Tl_Rec).process_status = G_PROCESS_RECORD THEN
                                                                            -- Bug 9701510
                            IF ( p_value_set_val_tl_tbl(Tl_Rec).flex_value= l_flex_value --p_value_set_val_tbl(i).flex_value
                                  OR p_value_set_val_tl_tbl(Tl_Rec).flex_value_id= l_flex_value_id ) THEN --p_value_set_val_tbl(i).flex_value_id ) THEN

                                IF p_value_set_val_tl_tbl(Tl_Rec).transaction_type =l_transaction_type THEN


                                    -- Check if this is a versioned value set, If so then please process values for a corresponding vesion.
                                    IF l_version_seq_id IS NOT NULL THEN

                                        IF p_value_set_val_tl_tbl(Tl_Rec).version_seq_id=l_version_seq_id THEN

                                            --Dbms_Output.put_line(' TL Table data for version Value ='||p_value_set_val_tl_tbl(Tl_Rec).flex_value||' l_process_status = '||l_process_status);

                                            p_value_set_val_tl_tbl(Tl_Rec).process_status := l_process_status;
                                            p_value_set_val_tl_tbl(Tl_Rec).value_set_id    :=l_value_set_id;
                                            p_value_set_val_tl_tbl(Tl_Rec).value_set_name  :=l_value_set_name;
                                            p_value_set_val_tl_tbl(Tl_Rec).flex_value_id   :=l_flex_value_id;
                                            p_value_set_val_tl_tbl(Tl_Rec).flex_value      :=l_flex_value;


                                            IF l_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE) THEN

                                                p_value_set_val_tl_tbl(Tl_Rec).flex_value         :=l_date_val_old_int_name;

                                            END IF;



                                        END IF;-- End IF p_value_set_val_tl_tbl(j).version_seq_id=l_version_seq_id THEN


                                    END IF; -- END IF l_version_seq_id IS NOT NULL THEN

                                END IF; -- END IF p_value_set_val_tl_tbl(j).transaction_type =l_transaction_type THEN

                            END IF;-- End IF p_value_set_val_tl_tbl(j).flex_value=l_flex_value THEN

                        END IF ;-- END IF p_value_set_val_tl_tbl(j).process_status = G_PROCESS_RECORD THEN


                    END LOOP;


                END IF; -- END IF NOT l_current_lang_exist THEN

            --END IF;--


        END IF; -- IF l_version_seq_id IS NOT NULL THEN











        -- Code to take care of version related tables...
        --Dbms_Output.put_line(' PUTTING VAR INTO PL/SQL TABLE VS ID : = '|| l_value_set_id);

        --Dbms_Output.put_line(' l_process_status = '||l_process_status||'l_value_set_name = '||l_value_set_name||' l_flex_value = '||l_flex_value);

        -- Updating value back in pl/sql table.
        p_value_set_val_tbl(i).value_set_name			      :=	l_value_set_name;
        p_value_set_val_tbl(i).value_set_id            	:=	l_value_set_id;

        p_value_set_val_tbl(i).flex_value             	:=	l_flex_value;

        IF l_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE) THEN

            p_value_set_val_tbl(i).flex_value   :=l_date_val_old_int_name;

        END IF;





        p_value_set_val_tbl(i).flex_value_id            :=	l_flex_value_id;
        p_value_set_val_tbl(i).disp_sequence            :=	l_disp_sequence;

        --p_value_set_val_tbl(i).version_seq_id			      :=	l_version_seq_id;

        p_value_set_val_tbl(i).start_active_date		    :=	l_start_active_date;
        p_value_set_val_tbl(i).end_active_date		  	  :=	l_end_active_date;
        p_value_set_val_tbl(i).enabled_flag            	:=	l_enabled_flag;

        -- transactions related columns
        p_value_set_val_tbl(i).transaction_type			    :=	G_VAL_TRANS_TYPE;
        --p_value_set_val_tbl(i).transaction_id       	  :=	l_transaction_id;

        -- process related columns
        p_value_set_val_tbl(i).process_status			      :=	l_process_status;
        p_value_set_val_tbl(i).set_process_id      		  :=	l_set_process_id;

        -- who columns for concurrent program
        p_value_set_val_tbl(i).request_id          		  :=	l_request_id;
        p_value_set_val_tbl(i).program_application_id 	:=	l_program_application_id;
        p_value_set_val_tbl(i).program_id             	:=	l_program_id;
        p_value_set_val_tbl(i).program_update_date      :=  l_program_update_date;

        -- who columns
        p_value_set_val_tbl(i).last_update_date    		  :=	l_last_update_date;
        p_value_set_val_tbl(i).last_updated_by     		  :=	l_last_updated_by;
        p_value_set_val_tbl(i).creation_date       		  :=	l_creation_date;
        p_value_set_val_tbl(i).created_by          		  :=	l_created_by;
        p_value_set_val_tbl(i).last_update_login		    := 	l_last_update_login;




        -- Re- Initializing Values.
        l_value_set_name          :=  NULL;
        l_value_set_id            :=  NULL;
        l_flex_value	            :=  NULL;
        l_date_val_old_int_name   :=  NULL;
        l_flex_value_id           :=  NULL;

        l_disp_sequence           :=  NULL;
        l_enabled_flag			      :=  NULL;
        l_version_seq_id          :=  NULL;
        l_start_active_date       :=  NULL;
        l_end_active_date         :=  NULL;

        l_transaction_type        :=  NULL;
        l_transaction_id          :=  NULL;

        l_request_id              :=  NULL;
        l_program_application_id  :=  NULL;
        l_program_id              :=  NULL;
        l_program_update_date     :=  NULL;

        l_process_status          :=  NULL;
        l_set_process_id          :=  NULL;

        l_last_update_date        :=  NULL;
        l_last_updated_by         :=  NULL;
        l_creation_date           :=  NULL;
        l_created_by              :=  NULL;
        l_last_update_login       :=  NULL;

        l_seq_exist               :=  NULL;
        G_VAL_TRANS_TYPE          :=  NULL;
        l_current_lang_exist      :=  FALSE;

    END LOOP; --END FOR i IN p_value_set_val_tbl.first..p_value_set_val_tbl.last



    -- Set return status
    IF Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS AND  x_return_status <>G_RET_STS_ERROR THEN

      x_return_status :=  G_RET_STS_SUCCESS;
      l_return_status    := G_RET_STS_SUCCESS;

    END IF;


    IF l_return_status =G_RET_STS_ERROR THEN

      x_return_status :=  G_RET_STS_ERROR;

    END IF;



    IF p_commit THEN
      write_debug(G_PKG_Name,l_api_name,' Issue a commit ' );
      COMMIT;
    END IF;


    write_debug(G_PKG_Name,l_api_name,' End of API ego_vs_bulkload_pvt.Process_Value_Set_Value ' );
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API ego_vs_bulkload_pvt.Process_Value_Set_Value ' );


EXCEPTION
  WHEN OTHERS THEN
    write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );


    x_return_status := G_RET_STS_UNEXP_ERROR;
    x_return_msg    := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	RETURN;

END Process_Value_Set_Value;


-- Procedure to process value set
PROCEDURE Process_Isolate_Value (
           p_api_version            IN              NUMBER,
           p_value_set_val_tbl      IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Value_Tbl,
           p_value_set_val_tl_tbl   IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Value_Tl_Tbl,
           p_set_process_id         IN              NUMBER,
           p_commit                 IN              BOOLEAN DEFAULT FALSE,
           x_return_status          OUT NOCOPY      VARCHAR2,
           x_msg_count              OUT NOCOPY      NUMBER,
           x_return_msg             OUT NOCOPY      VARCHAR2)

IS


    l_api_name                VARCHAR2(30):='Process_Isolate_Value';
    l_api_version             NUMBER  := 1.0;
    l_owner                   NUMBER  := G_User_Id;
--    l_owner_name            VARCHAR2(40):='ANONYMOUS';

    l_value_set_name          FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE; -- VARCHAR2(60);
    l_value_set_id            FND_FLEX_VALUES.FLEX_VALUE_SET_ID%TYPE;

    l_flex_value              fnd_flex_values.flex_value%TYPE;
    l_flex_value_id           fnd_flex_values.flex_value_id%TYPE;
    l_version_seq_id          NUMBER;
    --l_sequence                 NUMBER;
    l_start_active_date       DATE;
    l_end_active_date         DATE;
    l_vers_start_date         DATE;
    l_vers_end_date           DATE;
    l_enabled_flag            VARCHAR2(10);

    l_transaction_type        VARCHAR2(10);
    l_process_status          NUMBER;
    l_set_process_id          NUMBER;

    l_request_id              NUMBER;
    l_program_update_date     DATE;
    l_program_application_id  NUMBER;
    l_program_id              NUMBER;


    l_last_update_date        DATE;
    l_last_updated_by         NUMBER(15);
    l_creation_date           DATE;
    l_created_by              NUMBER(15);
    l_last_update_login       NUMBER(15);


    l_val_version_seq_id      NUMBER;
    l_language		            VARCHAR2(10);
    l_description             VARCHAR2(500);
    l_source_lang		          VARCHAR2(10);
    l_flex_value_meaning      VARCHAR2(500);
    l_transaction_id	        NUMBER;
    l_disp_sequence           NUMBER;
    l_init_msg_list           VARCHAR2(100);
    --l_commit
    l_value_exist             NUMBER;
    l_target_vers_id          NUMBER;
    l_is_versioned            VARCHAR2(20):=NULL;
    l_api_mode                NUMBER   :=  G_FLOW_TYPE;
    l_validation_code         VARCHAR2(10);
    l_format_code             VARCHAR2(10);
    l_token_table             ERROR_HANDLER.Token_Tbl_Type;
    l_application_id          NUMBER;

    l_return_status           VARCHAR2(1) := NULL;

    -- Local variable for Error handling
    l_error_message_name      VARCHAR2(240);
    l_entity_code             VARCHAR2(30) :=  G_ENTITY_VS_VAL;
    l_table_name              VARCHAR2(240):=  G_ENTITY_VAL_HEADER_TAB;

    l_val_ver_exist			      NUMBER;
    l_trans_val_ver_exist     NUMBER;
    l_seq_exist               NUMBER  :=  NULL;

    l_return_msg	            VARCHAR2(1000);


    l_vs_maximum_size         NUMBER  :=  NULL;
    l_val_int_name_size       NUMBER  :=  NULL;
    l_val_disp_name_size      NUMBER  :=  NULL;





  CURSOR Cur_Validation (cp_value_set_id    IN    NUMBER )
  IS
    SELECT  validation_type, format_type,maximum_size
    FROM  fnd_flex_value_sets fvs,
          fnd_flex_values fval
    WHERE fvs.flex_Value_set_id = fval.flex_Value_set_id;


  -- Cursor to get display sequence.
  CURSOR c_get_disp_sequence (cp_flex_value_id  IN  NUMBER)
  IS
  SELECT disp_sequence
  FROM ego_vs_values_disp_order
  WHERE value_set_value_id = cp_flex_value_id;


  -- Cursor to validate sequnce.
  CURSOR Cur_Seq_Validation ( cp_value_set_id  NUMBER,
                              cp_value_id      NUMBER,
                              cp_disp_sequence NUMBER)
  IS
  SELECT 1 AS Seq_exist
  FROM  Ego_VS_Values_Disp_Order
  WHERE disp_sequence = cp_disp_sequence
    AND value_set_id = cp_value_set_id
    AND ( value_set_value_id <> cp_value_id
          OR cp_value_id IS NULL);



BEGIN

    write_debug(G_PKG_Name,l_api_name,' Start of API. ' );
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API. ' );


    -- Get Application Id
    --G_Application_Id  := Get_Application_Id();

    ERROR_HANDLER.Set_Bo_Identifier(G_BO_IDENTIFIER_VS);


    --==============================
    -- Process values, only values passed
    --==============================
    IF p_value_set_val_tbl.Count>0 THEN


      FOR i IN p_value_set_val_tbl.first..p_value_set_val_tbl.last
      LOOP

        --Assigning value per record
        l_value_set_name        :=  p_value_set_val_tbl(i).value_set_name;

        l_value_set_id          :=  p_value_set_val_tbl(i).value_set_id;
        l_flex_value            :=  p_value_set_val_tbl(i).flex_value;
        l_flex_value_id         :=  p_value_set_val_tbl(i).flex_value_id;
        l_version_seq_id        :=  p_value_set_val_tbl(i).version_seq_id;
        l_disp_sequence         :=  p_value_set_val_tbl(i).disp_sequence;
        l_start_active_date     :=  p_value_set_val_tbl(i).start_active_date;
        l_end_active_date       :=  p_value_set_val_tbl(i).end_active_date;
        l_enabled_flag          :=  p_value_set_val_tbl(i).enabled_flag;

        l_transaction_type      :=  p_value_set_val_tbl(i).transaction_type;
        l_transaction_id        :=  p_value_set_val_tbl(i).transaction_id;


        l_process_status        :=  p_value_set_val_tbl(i).process_status;
        l_set_process_id        :=  p_value_set_val_tbl(i).set_process_id;


        l_request_id              :=  p_value_set_val_tbl(i).request_id;
        l_program_update_date     :=  p_value_set_val_tbl(i).program_update_date;
        l_program_application_id  :=  p_value_set_val_tbl(i).program_application_id;
        l_program_id              :=  p_value_set_val_tbl(i).program_id;



        l_last_update_date      :=  p_value_set_val_tbl(i).last_update_date;
        l_last_updated_by       :=  p_value_set_val_tbl(i).last_updated_by;
        l_creation_date         :=  p_value_set_val_tbl(i).creation_date;
        l_created_by            :=  p_value_set_val_tbl(i).created_by;
        l_last_update_login     :=  p_value_set_val_tbl(i).last_update_login;


        write_debug(G_PKG_Name,l_api_name,'  Start of Loop to get values : value  = '||l_flex_value||' and Value Id = '||l_flex_value_id);


        IF l_value_set_id IS NOT NULL THEN

          Convert_Id_To_Name (l_value_set_id ,G_Value_Set,NULL,l_value_set_name);

          IF l_value_set_id IS NULL THEN

            l_error_message_name          := 'EGO_VSET_INVALID_ID';
            -- Set process_status to 3
            l_process_status    := g_error_record;
            l_return_status     := G_RET_STS_ERROR;
            l_last_updated_by   := g_user_id;
            l_last_update_date  := SYSDATE;
            l_last_update_login := g_login_id;



            ERROR_HANDLER.Add_Error_Message(
              p_message_name                   => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

          END IF; -- END IF l_value_set_id IS NULL THEN



        END IF;-- END IF l_value_set_id IS NOT NULL THEN



        IF ( l_value_set_name IS NOT NULL AND l_value_set_id IS NULL ) THEN

          Convert_Name_To_Id (l_value_set_name,G_Value_Set,NULL,l_value_set_id);
        END IF; -- END IF ( l_value_set_name IS NOT NULL AND l_value_set_id IS NULL ) THEN


        -- Check if validation type for value set is not NONE type.
        FOR j IN Cur_Validation(l_value_set_id)
        LOOP
          l_validation_code :=  j.validation_type;
          l_format_code     :=  j.format_type;
          l_vs_maximum_size :=  j.maximum_size;
        END LOOP;





        IF l_flex_value_id IS NOT NULL THEN

          Convert_Id_To_Name (l_flex_value_id,G_Value,l_value_set_id,l_flex_value);

          IF l_flex_value_id IS NULL THEN

            l_error_message_name          := 'EGO_VSET_VAL_INVALID_ID';
            -- Set process_status to 3
            l_process_status    := g_error_record;
            l_return_status     := G_RET_STS_ERROR;
            l_last_updated_by   := g_user_id;
            l_last_update_date  := SYSDATE;
            l_last_update_login := g_login_id;



            ERROR_HANDLER.Add_Error_Message(
              p_message_name                   => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

          END IF; -- END IF l_value_set_id IS NULL THEN



        END IF;-- END IF l_flex_value_id IS NOT NULL THEN



        IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN


          -- Bug 9701510
          -- For Date and DateTime VS, Convert value to DB Date format.
          IF l_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE) THEN



              Validate_User_Preferred_Date (l_flex_value,
                                            l_format_code,
                                            l_transaction_id,
                                            l_return_status,
                                            l_return_msg);



              -- check the return status
              IF (l_return_status =G_RET_STS_UNEXP_ERROR )
              THEN

                write_debug(G_PKG_Name,l_api_name,' Unexpected error occured in Validate_User_Preferred_Date API l_return_msg ='||l_return_msg);

                x_return_status :=  G_RET_STS_UNEXP_ERROR;
                x_return_msg    :=  l_return_msg;
                RETURN;

              ELSIF (l_return_status =G_RET_STS_ERROR ) THEN


                write_debug(G_PKG_Name,l_api_name,' Err_Msg-TID='  ||l_transaction_id||'-(VS,VS Id, Value)=('
                                                                      ||l_value_set_name||','||l_value_set_id||','||l_flex_value||')'||' Validation of value failed. ');


                l_process_status := G_ERROR_RECORD;


              END IF; -- END IF (l_return_status =G_RET_STS_UNEXP_ERROR )

              Convert_Value_To_DbDate (l_flex_value);

          END IF;
          -- Bug 9701510


          Convert_Name_To_Id (l_flex_value,G_Value,l_value_set_id,l_flex_value_id);

        END IF; -- END IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN



          -- Check if required value has been passed.
        IF (l_value_set_name IS NULL AND l_value_set_id IS NULL )  THEN

            l_process_status              := G_ERROR_RECORD;
            l_return_status               := G_RET_STS_ERROR;
            l_last_updated_by             := g_user_id;
            l_last_update_date            := SYSDATE;
            l_last_update_login           := g_login_id;



            l_error_message_name          := 'EGO_VALUE_SET_REQUIRED_FIELD';
            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
            l_token_table(1).TOKEN_VALUE  := l_value_set_name;

            l_token_table(2).TOKEN_NAME   := 'VALUE_SET_ID';
            l_token_table(2).TOKEN_VALUE  := l_value_set_name;


            ERROR_HANDLER.Add_Error_Message(
              p_message_name                   => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => G_ENTITY_VS_VAL
              ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB);

        END IF;-- END IF (l_value_set_name IS NULL AND l_value_set_id IS NULL )  THEN


        -- Check if required value has been passed.
        IF (l_flex_value IS NULL AND l_flex_value_id IS NULL )  THEN

            l_process_status              := G_ERROR_RECORD;
            l_return_status               := G_RET_STS_ERROR;
            l_last_updated_by             := g_user_id;
            l_last_update_date            := SYSDATE;
            l_last_update_login           := g_login_id;


            l_error_message_name          := 'EGO_VALUE_REQUIRED_FIELD';
            l_token_table(1).TOKEN_NAME   := 'FLEX_VALUE';
            l_token_table(1).TOKEN_VALUE  := l_flex_value;

            l_token_table(2).TOKEN_NAME   := 'FLEX_VALUE_ID';
            l_token_table(2).TOKEN_VALUE  := l_flex_value_id;


            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => G_ENTITY_VS_VAL
              ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB);

            l_token_table.DELETE;

            RETURN;

        END IF;-- END IF (l_value_set_name IS NULL AND l_value_set_id IS NULL )  THEN





        --Check for transaction type and update it correctly
        IF l_transaction_type  =G_SYNC THEN

          IF l_flex_value_id IS NOT NULL THEN

            l_transaction_type  :=G_UPDATE;

          ELSE

            l_transaction_type  :=G_CREATE;

          END IF;

        END IF; -- END IF l_transaction_type  =G_SYNC THEN




       --IF l_flex_value_id IS NOT NULL THEN
          -- Code to verify if disp_sequence is not duplicate.
          FOR j IN Cur_Seq_Validation (l_value_set_id, l_flex_value_id,l_disp_sequence)
          LOOP

            l_seq_exist := j.Seq_exist;

          END LOOP;


          IF l_seq_exist IS NOT NULL THEN


            l_process_status              := G_ERROR_RECORD;
            l_return_status               := G_RET_STS_ERROR;
            l_last_updated_by             := g_user_id;
            l_last_update_date            := SYSDATE;
            l_last_update_login           := g_login_id;

            l_error_message_name          := 'EGO_EF_VAL_SEQ_ERR';

            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => G_ENTITY_VS_VAL
              ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );


          END IF; -- END IF l_validation_code IN (G_NONE_VALIDATION_CODE,G_TABLE_VALIDATION_CODE) THEN

        --END IF ; -- END IF l_flex_value_id IS NOT NULL THEN



        IF l_transaction_type  =G_CREATE AND l_flex_value_id IS NOT NULL AND l_version_seq_id IS NULL THEN


            -- Set process_status to 3
          l_process_status              := G_ERROR_RECORD;
          l_return_status               := G_RET_STS_ERROR;
          l_last_updated_by             := g_user_id;
          l_last_update_date            := SYSDATE;
          l_last_update_login           := g_login_id;


          l_error_message_name          := 'EGO_EF_VAL_INT_NAME_EXIST';

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                   => l_error_message_name
            ,p_application_id                => G_App_Short_Name
            ,p_token_tbl                     => l_token_table
            ,p_message_type                  => G_RET_STS_ERROR
            ,p_row_identifier                => l_transaction_id
            ,p_entity_code                   => G_ENTITY_VS_VAL
            ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB);


        END IF ; -- END IF l_transaction_type  :=G_CREATE AND l_value_set_id IS NOT NULL THEN


        -- Bug 9701510
        /*-- Check if validation type for value set is not NONE type.
        FOR j IN Cur_Validation(l_value_set_id)
        LOOP
          l_validation_code :=  j.validation_type;
          l_format_code     :=  j.format_type;
          l_vs_maximum_size :=  j.maximum_size;
        END LOOP;*/
        -- Bug 9701510

        IF l_validation_code IN (G_NONE_VALIDATION_CODE,G_TABLE_VALIDATION_CODE) THEN

          l_process_status              := G_ERROR_RECORD;
          l_return_status               := G_RET_STS_ERROR;
          l_last_updated_by             := g_user_id;
          l_last_update_date            := SYSDATE;
          l_last_update_login           := g_login_id;



          l_error_message_name          := 'EGO_VALUE_VALIDATION_ERROR';
          l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
          l_token_table(1).TOKEN_VALUE  := l_value_set_name;

          ERROR_HANDLER.Add_Error_Message(
             p_message_name                  => l_error_message_name
            ,p_application_id                => G_App_Short_Name
            ,p_token_tbl                     => l_token_table
            ,p_message_type                  => G_RET_STS_ERROR
            ,p_row_identifier                => l_transaction_id
            ,p_entity_code                   => G_ENTITY_VS_VAL
            ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );

        END IF; -- END IF l_validation_code IN (G_NONE_VALIDATION_CODE,G_TABLE_VALIDATION_CODE) THEN





        -- Bug 9702841
        -- Validate maximum size validation for VS
        IF  l_flex_value IS NOT NULL THEN
            IF l_format_code IN (G_NUMBER_DATA_TYPE,G_CHAR_DATA_TYPE) THEN

                    l_val_int_name_size   := Length(l_flex_value);
                    -- Log error
                    IF  l_val_int_name_size > l_vs_maximum_size THEN

                          l_error_message_name          := 'EGO_VS_MAXSIZE_VALUE_VAL';

                          -- Set process_status to 3
                          l_process_status    := g_error_record;
                          l_return_status     := G_RET_STS_ERROR;
                          l_last_updated_by   := g_user_id;
                          l_last_update_date  := SYSDATE;
                          l_last_update_login := g_login_id;


                          ERROR_HANDLER.Add_Error_Message(
                            p_message_name                   => l_error_message_name
                            ,p_application_id                => G_App_Short_Name
                            ,p_token_tbl                     => l_token_table
                            ,p_message_type                  => G_RET_STS_ERROR
                            ,p_row_identifier                => l_transaction_id
                            ,p_entity_code                   => l_entity_code
                            ,p_table_name                    => l_table_name
                          );


                    END IF;

            END IF;

        END IF;




        --bug 9702828
        -- Check if user passes end date lesser than sysdate
        IF l_end_active_date IS NOT NULL AND  l_end_active_date<> G_NULL_DATE THEN

            IF l_end_active_date < SYSDATE THEN

                l_error_message_name          := 'EGO_ENDDATE_LT_CURRDATE';

                -- Set process_status to 3
                l_process_status    := g_error_record;
                l_return_status     := G_RET_STS_ERROR;
                l_last_updated_by   := g_user_id;
                l_last_update_date  := SYSDATE;
                l_last_update_login := g_login_id;


                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                   => l_error_message_name
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => l_token_table
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => l_table_name);

            END IF;

        END IF;






        -- Error out record if transaction type is not UPDATE.
        -- Only update mode is supported for isolated records in interface tables.
        IF l_transaction_type <> G_UPDATE  THEN

            l_process_status              := G_ERROR_RECORD;
            l_return_status               := G_RET_STS_ERROR;
            l_last_updated_by             := g_user_id;
            l_last_update_date            := SYSDATE;
            l_last_update_login           := g_login_id;



            l_error_message_name          := 'EGO_VAL_TRANS_DISP_ERR';

            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => G_ENTITY_VS_VAL
              ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );


        END IF; -- END IF l_transaction_type <> G_UPDATE




        IF l_transaction_type =G_UPDATE THEN

          --Find value of desc and s

          Get_Key_Value_Columns
              ( p_value_set_id      => l_value_set_id,
                p_value_id          => l_flex_value_id,
                x_display_name      => l_flex_value_meaning,
                x_disp_sequence     => l_disp_sequence,
                x_start_date_active => l_start_active_date,
                x_end_date_active   => l_end_active_date,
                x_description       => l_description,
                x_enabled_flag      => l_enabled_flag,
                x_return_status     => l_return_status,
                x_return_msg        => l_return_msg);



          IF l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL OR l_enabled_flag IS NULL THEN

              l_error_message_name          := 'EGO_VAL_KEY_REQ_ERR';

              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name
              );


              -- Set process_status to 3
            l_process_status              := G_ERROR_RECORD;
            l_return_status               := G_RET_STS_ERROR;
            l_last_updated_by             := g_user_id;
            l_last_update_date            := SYSDATE;
            l_last_update_login           := g_login_id;


          END IF; -- END IF l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL THEN




          --bug 9702828
          -- Check if user passes end date lesser than sysdate
          IF l_end_active_date IS NOT NULL AND  l_end_active_date<> G_NULL_DATE THEN


              IF l_start_active_date IS NOT NULL AND  l_start_active_date<> G_NULL_DATE THEN


                  IF l_start_active_date >l_end_active_date THEN

                      l_error_message_name          := 'EGO_START_DATE_GT_END_DATE';

                      -- Set process_status to 3
                      l_process_status    := g_error_record;
                      l_return_status     := G_RET_STS_ERROR;
                      l_last_updated_by   := g_user_id;
                      l_last_update_date  := SYSDATE;
                      l_last_update_login := g_login_id;


                      ERROR_HANDLER.Add_Error_Message(
                        p_message_name                   => l_error_message_name
                        ,p_application_id                => G_App_Short_Name
                        ,p_token_tbl                     => l_token_table
                        ,p_message_type                  => G_RET_STS_ERROR
                        ,p_row_identifier                => l_transaction_id
                        ,p_entity_code                   => l_entity_code
                        ,p_table_name                    => l_table_name);


                  END IF;

              END IF;

          END IF;




          IF l_process_status = G_PROCESS_RECORD  THEN


            EGO_EXT_FWK_PUB.Update_Value_Set_Val
              (
                p_api_version                   => p_api_version
                ,p_value_set_name                => l_value_set_name
                ,p_internal_name                 => l_flex_value
                ,p_display_name                  => l_flex_value_meaning
                ,p_description                   => CASE l_description
                                                      WHEN G_NULL_CHAR THEN NULL
                                                      ELSE l_description
                                                    END --l_description
                ,p_sequence                      => l_disp_sequence
                ,p_start_date                    => CASE l_start_active_date
                                                      WHEN G_NULL_DATE THEN NULL
                                                      ELSE l_start_active_date
                                                    END
                ,p_end_date                      => CASE l_end_active_date
                                                      WHEN G_NULL_DATE THEN NULL
                                                      ELSE l_end_active_date
                                                    END
                ,p_enabled                       => l_enabled_flag
                ,p_owner                         => l_owner
                ,p_init_msg_list                 => l_init_msg_list
                ,p_commit                        => FND_API.G_FALSE
                ,x_return_status                 => l_return_status
                ,x_msg_count                     => x_msg_count
                ,x_msg_data                      => x_return_msg
                ,x_is_versioned                  => l_is_versioned
                ,x_valueSetId                    => l_value_set_id);



            -- check the return status
            IF (Nvl(l_return_status,G_RET_STS_SUCCESS) = G_RET_STS_SUCCESS )
            THEN

              l_process_status:= G_SUCCESS_RECORD;
              l_return_status :=  G_RET_STS_SUCCESS;

            ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

              l_return_status := G_RET_STS_ERROR;
              l_process_status:= G_ERROR_RECORD;


		          G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
              G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS_VAL;
              G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
              G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
              G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
              G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB';
              G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
              G_TOKEN_TBL(4).Token_Value  :=  'Update_Value_Set_Val';


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => 'EGO_ENTITY_API_FAILED'
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => G_TOKEN_TBL
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => G_ENTITY_VS_VAL
                ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );


            ELSE

              x_return_status :=  G_RET_STS_UNEXP_ERROR;
              x_return_msg    :=  l_return_msg;
              RETURN;

            END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN


          END IF; -- END IF l_process_status = G_PROCESS_RECORD  THEN


        END IF;-- END IF l_transaction_type =G_UPDATE THEN



        --Dbms_Output.put_line(' VS ID : '||l_value_set_id);
        -- Updating value back in pl/sql table.
        p_value_set_val_tbl(i).value_set_name			      :=	l_value_set_name;
        p_value_set_val_tbl(i).value_set_id            	:=	l_value_set_id;

        p_value_set_val_tbl(i).flex_value             	:=	l_flex_value;
        p_value_set_val_tbl(i).flex_value_id            :=	l_flex_value_id;
        p_value_set_val_tbl(i).disp_sequence            :=	l_disp_sequence;

        --p_value_set_val_tbl(i).version_seq_id			      :=	l_version_seq_id;

        p_value_set_val_tbl(i).start_active_date		    :=	l_start_active_date;
        p_value_set_val_tbl(i).end_active_date		  	  :=	l_end_active_date;
        p_value_set_val_tbl(i).enabled_flag            	:=	l_enabled_flag;

        -- transactions related columns
        p_value_set_val_tbl(i).transaction_type			    :=	l_transaction_type;
        --p_value_set_val_tbl(i).transaction_id       	  :=	l_transaction_id;

        -- process related columns
        p_value_set_val_tbl(i).process_status			      :=	l_process_status;
        p_value_set_val_tbl(i).set_process_id      		  :=	l_set_process_id;

        -- who columns for concurrent program
        p_value_set_val_tbl(i).request_id          		  :=	l_request_id;
        p_value_set_val_tbl(i).program_application_id 	:=	l_program_application_id;
        p_value_set_val_tbl(i).program_id             	:=	l_program_id;
        p_value_set_val_tbl(i).program_update_date      :=  l_program_update_date;

        -- who columns
        p_value_set_val_tbl(i).last_update_date    		  :=	l_last_update_date;
        p_value_set_val_tbl(i).last_updated_by     		  :=	l_last_updated_by;
        p_value_set_val_tbl(i).creation_date       		  :=	l_creation_date;
        p_value_set_val_tbl(i).created_by          		  :=	l_created_by;
        p_value_set_val_tbl(i).last_update_login		    := 	l_last_update_login;




        -- Re- Initializing Values.
        l_value_set_name          :=  NULL;
        l_value_set_id            :=  NULL;
        l_flex_value	            :=  NULL;
        l_flex_value_id           :=  NULL;

        l_disp_sequence           :=  NULL;
        l_enabled_flag			      :=  NULL;
        l_version_seq_id          :=  NULL;
        l_start_active_date       :=  NULL;
        l_end_active_date         :=  NULL;

        l_description 			      :=  NULL;
        l_source_lang             :=  NULL;
        l_flex_value_meaning      :=  NULL;

        l_transaction_type        :=  NULL;
        l_transaction_id          :=  NULL;

        l_request_id              :=  NULL;
        l_program_application_id  :=  NULL;
        l_program_id              :=  NULL;
        l_program_update_date     :=  NULL;

        l_process_status          :=  NULL;
        l_set_process_id          :=  NULL;

        l_last_update_date        :=  NULL;
        l_last_updated_by         :=  NULL;
        l_creation_date           :=  NULL;
        l_created_by              :=  NULL;
        l_last_update_login       :=  NULL;

        l_seq_exist               :=  NULL;




      END LOOP; -- END FOR i IN p_value_set_val_tbl.first..p_value_set_val_tbl.last


    END IF; -- END IF p_value_set_val_tbl.Count>0 THEN












    --==============================
    -- Process translated values, If only translated values passed
    --==============================

    IF p_value_set_val_tl_tbl.Count>0 THEN



      FOR i IN p_value_set_val_tl_tbl.first..p_value_set_val_tl_tbl.last
      LOOP

        --Assigning value per record
        l_value_set_name        :=  p_value_set_val_tl_tbl(i).value_set_name;
        l_value_set_id          :=  p_value_set_val_tl_tbl(i).value_set_id;
        l_flex_value            :=  p_value_set_val_tl_tbl(i).flex_value;
        l_flex_value_id         :=  p_value_set_val_tl_tbl(i).flex_value_id;
        l_version_seq_id        :=  p_value_set_val_tl_tbl(i).version_seq_id;

        l_language              :=  p_value_set_val_tl_tbl(i)."LANGUAGE";
        l_description           :=  p_value_set_val_tl_tbl(i).description;
        l_source_lang           :=  p_value_set_val_tl_tbl(i).source_lang;
        l_flex_value_meaning    :=  p_value_set_val_tl_tbl(i).flex_value_meaning;


        l_transaction_type      :=  p_value_set_val_tl_tbl(i).transaction_type;
        l_transaction_id        :=  p_value_set_val_tl_tbl(i).transaction_id;

        l_process_status        :=  p_value_set_val_tl_tbl(i).process_status;
        l_set_process_id        :=  p_value_set_val_tl_tbl(i).set_process_id;

        l_request_id            :=  p_value_set_val_tl_tbl(i).request_id;
        l_program_update_date   :=  p_value_set_val_tl_tbl(i).program_update_date;
        l_program_application_id  :=  p_value_set_val_tl_tbl(i).program_application_id;
        l_program_id            :=  p_value_set_val_tl_tbl(i).program_id;

        l_last_update_date      :=  p_value_set_val_tl_tbl(i).last_update_date;
        l_last_updated_by       :=  p_value_set_val_tl_tbl(i).last_updated_by;
        l_creation_date         :=  p_value_set_val_tl_tbl(i).creation_date;
        l_created_by            :=  p_value_set_val_tl_tbl(i).created_by;
        l_last_update_login     :=  p_value_set_val_tl_tbl(i).last_update_login;


        IF l_value_set_id IS NOT NULL THEN

          Convert_Id_To_Name (l_value_set_id ,G_Value_Set,NULL,l_value_set_name);

          IF l_value_set_id IS NULL THEN

            l_error_message_name          := 'EGO_VSET_INVALID_ID';
            -- Set process_status to 3
            l_process_status    := g_error_record;
            l_return_status     := G_RET_STS_ERROR;
            l_last_updated_by   := g_user_id;
            l_last_update_date  := SYSDATE;
            l_last_update_login := g_login_id;



            ERROR_HANDLER.Add_Error_Message(
              p_message_name                   => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

          END IF; -- END IF l_value_set_id IS NULL THEN




        END IF;-- END IF l_value_set_id IS NOT NULL THEN



        IF ( l_value_set_name IS NOT NULL AND l_value_set_id IS NULL ) THEN

          Convert_Name_To_Id (l_value_set_name,G_Value_Set,NULL,l_value_set_id);
        END IF; -- END IF ( l_value_set_name IS NOT NULL AND l_value_set_id IS NULL ) THEN



        -- Bug 9701510
        -- Check if validation type for value set is not NONE type.
        FOR j IN Cur_Validation(l_value_set_id)
        LOOP
            l_validation_code :=  j.validation_type;
            l_format_code     :=  j.format_type;
            l_vs_maximum_size :=  j.maximum_size;
        END LOOP;
        -- Bug 9701510


        IF l_flex_value_id IS NOT NULL THEN

          Convert_Id_To_Name (l_flex_value_id,G_Value,l_value_set_id,l_flex_value);

          IF l_flex_value_id IS NULL THEN

            l_error_message_name          := 'EGO_VSET_VAL_INVALID_ID';
            -- Set process_status to 3
            l_process_status    := g_error_record;
            l_return_status     := G_RET_STS_ERROR;
            l_last_updated_by   := g_user_id;
            l_last_update_date  := SYSDATE;
            l_last_update_login := g_login_id;



            ERROR_HANDLER.Add_Error_Message(
              p_message_name                   => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => l_table_name
            );

          END IF; -- END IF l_value_set_id IS NULL THEN




        END IF;-- END IF l_flex_value_id IS NOT NULL THEN



        IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN

            -- Bug 9701510
            IF l_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE) THEN



                Validate_User_Preferred_Date (l_flex_value,
                                              l_format_code,
                                              l_transaction_id,
                                              l_return_status,
                                              l_return_msg);



                -- check the return status
                IF (l_return_status =G_RET_STS_UNEXP_ERROR )
                THEN

                  write_debug(G_PKG_Name,l_api_name,' Unexpected error occured in Validate_User_Preferred_Date API l_return_msg ='||l_return_msg);

                  x_return_status :=  G_RET_STS_UNEXP_ERROR;
                  x_return_msg    :=  l_return_msg;
                  RETURN;

                ELSIF (l_return_status =G_RET_STS_ERROR ) THEN


                  write_debug(G_PKG_Name,l_api_name,' Err_Msg-TID='  ||l_transaction_id||'-(VS,VS Id, Value)=('
                                                                        ||l_value_set_name||','||l_value_set_id||','||l_flex_value||')'||' Validation of value failed. ');


                  l_process_status := G_ERROR_RECORD;


                END IF; -- END IF (l_return_status =G_RET_STS_UNEXP_ERROR )



                Convert_Value_To_DbDate (l_flex_value);

            END IF;
            -- Bug 9701510


            Convert_Name_To_Id (l_flex_value,G_Value,l_value_set_id,l_flex_value_id);

        END IF; -- END IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN





          -- Check if required value has been passed.
        IF (l_value_set_name IS NULL AND l_value_set_id IS NULL )  THEN

            l_process_status              := G_ERROR_RECORD;
            l_return_status               := G_RET_STS_ERROR;
            l_last_updated_by             := g_user_id;
            l_last_update_date            := SYSDATE;
            l_last_update_login           := g_login_id;



            l_error_message_name          := 'EGO_VALUE_SET_REQUIRED_FIELD';
            l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
            l_token_table(1).TOKEN_VALUE  := l_value_set_name;

            l_token_table(2).TOKEN_NAME   := 'VALUE_SET_ID';
            l_token_table(2).TOKEN_VALUE  := l_value_set_name;


            ERROR_HANDLER.Add_Error_Message(
              p_message_name                   => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => G_ENTITY_VS_VAL
              ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB);

        END IF;-- END IF (l_value_set_name IS NULL AND l_value_set_id IS NULL )  THEN


        -- Check if required value has been passed.
        IF (l_flex_value IS NULL AND l_flex_value_id IS NULL )  THEN

            l_process_status              := G_ERROR_RECORD;
            l_return_status               := G_RET_STS_ERROR;
            l_last_updated_by             := g_user_id;
            l_last_update_date            := SYSDATE;
            l_last_update_login           := g_login_id;


            l_error_message_name          := 'EGO_VALUE_REQUIRED_FIELD';
            l_token_table(1).TOKEN_NAME   := 'FLEX_VALUE';
            l_token_table(1).TOKEN_VALUE  := l_flex_value;

            l_token_table(2).TOKEN_NAME   := 'FLEX_VALUE_ID';
            l_token_table(2).TOKEN_VALUE  := l_flex_value_id;


            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => l_error_message_name
              ,p_application_id                => G_App_Short_Name
              ,p_token_tbl                     => l_token_table
              ,p_message_type                  => G_RET_STS_ERROR
              ,p_row_identifier                => l_transaction_id
              ,p_entity_code                   => G_ENTITY_VS_VAL
              ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB);

            l_token_table.DELETE;

            RETURN;

        END IF;-- END IF (l_value_set_name IS NULL AND l_value_set_id IS NULL )  THEN





        --Check for transaction type and update it correctly
        IF l_transaction_type  =G_SYNC THEN

          IF l_flex_value_id IS NOT NULL THEN

            l_transaction_type  :=G_UPDATE;

          ELSE

            l_transaction_type  :=G_CREATE;

          END IF;

        END IF; -- END IF l_transaction_type  =G_SYNC THEN




        IF l_transaction_type  =G_CREATE AND l_flex_value_id IS NOT NULL AND l_version_seq_id IS NULL THEN


            -- Set process_status to 3
          l_process_status              := G_ERROR_RECORD;
          l_return_status               := G_RET_STS_ERROR;
          l_last_updated_by             := g_user_id;
          l_last_update_date            := SYSDATE;
          l_last_update_login           := g_login_id;


          l_error_message_name          := 'EGO_EF_VAL_INT_NAME_EXIST';

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                   => l_error_message_name
            ,p_application_id                => G_App_Short_Name
            ,p_token_tbl                     => l_token_table
            ,p_message_type                  => G_RET_STS_ERROR
            ,p_row_identifier                => l_transaction_id
            ,p_entity_code                   => G_ENTITY_VS_VAL
            ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB);


        END IF ; -- END IF l_transaction_type  :=G_CREATE AND l_value_set_id IS NOT NULL THEN


        -- Bug 9701510
        /*-- Check if validation type for value set is not NONE type.
        FOR j IN Cur_Validation(l_value_set_id)
        LOOP
            l_validation_code :=  j.validation_type;
            l_format_code     :=  j.format_type;
            l_vs_maximum_size :=  j.maximum_size;
        END LOOP;*/
        -- Bug 9701510


        IF l_validation_code IN (G_NONE_VALIDATION_CODE,G_TABLE_VALIDATION_CODE) THEN

          l_process_status              := G_ERROR_RECORD;
          l_return_status               := G_RET_STS_ERROR;
          l_last_updated_by             := g_user_id;
          l_last_update_date            := SYSDATE;
          l_last_update_login           := g_login_id;



          l_error_message_name          := 'EGO_VALUE_VALIDATION_ERROR';
          l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
          l_token_table(1).TOKEN_VALUE  := l_value_set_name;

          ERROR_HANDLER.Add_Error_Message(
             p_message_name                  => l_error_message_name
            ,p_application_id                => G_App_Short_Name
            ,p_token_tbl                     => l_token_table
            ,p_message_type                  => G_RET_STS_ERROR
            ,p_row_identifier                => l_transaction_id
            ,p_entity_code                   => G_ENTITY_VS_VAL
            ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );

        END IF; -- END IF l_validation_code IN (G_NONE_VALIDATION_CODE,G_TABLE_VALIDATION_CODE) THEN



        -- Error out record if transaction type is not UPDATE.
        -- Only update mode is supported for isolated records in interface tables.
        IF l_transaction_type <> G_UPDATE THEN

          l_process_status              := G_ERROR_RECORD;
          l_return_status               := G_RET_STS_ERROR;
          l_last_updated_by             := g_user_id;
          l_last_update_date            := SYSDATE;
          l_last_update_login           := g_login_id;



          l_error_message_name          := 'EGO_VAL_TRANS_DISP_ERR';

          ERROR_HANDLER.Add_Error_Message(
             p_message_name                  => l_error_message_name
            ,p_application_id                => G_App_Short_Name
            ,p_token_tbl                     => l_token_table
            ,p_message_type                  => G_RET_STS_ERROR
            ,p_row_identifier                => l_transaction_id
            ,p_entity_code                   => G_ENTITY_VS_VAL
            ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );


        END IF; -- END IF l_transaction_type <> G_UPDATE



        -- Bug 9702841
        -- Validate maximum size validation for VS
        IF l_flex_value_meaning IS NOT NULL THEN
            IF l_format_code IN (G_NUMBER_DATA_TYPE,G_CHAR_DATA_TYPE) THEN

                    l_val_disp_name_size   := Length(l_flex_value_meaning);
                    -- Log error
                    IF  l_val_disp_name_size > l_vs_maximum_size THEN

                          l_error_message_name          := 'EGO_VS_MAXSIZE_VALUE_VAL';

                          -- Set process_status to 3
                          l_process_status    := g_error_record;
                          l_return_status     := G_RET_STS_ERROR;
                          l_last_updated_by   := g_user_id;
                          l_last_update_date  := SYSDATE;
                          l_last_update_login := g_login_id;


                          ERROR_HANDLER.Add_Error_Message(
                            p_message_name                   => l_error_message_name
                            ,p_application_id                => G_App_Short_Name
                            ,p_token_tbl                     => l_token_table
                            ,p_message_type                  => G_RET_STS_ERROR
                            ,p_row_identifier                => l_transaction_id
                            ,p_entity_code                   => l_entity_code
                            ,p_table_name                    => l_table_name
                          );


                    END IF;

            END IF;

        END IF;






        IF l_transaction_type =G_UPDATE THEN

          --Find value of desc and s

          Get_Key_Value_Columns
              ( p_value_set_id      => l_value_set_id,
                p_value_id          => l_flex_value_id,
                x_display_name      => l_flex_value_meaning,
                x_disp_sequence     => l_disp_sequence,
                x_start_date_active => l_start_active_date,
                x_end_date_active   => l_end_active_date,
                x_description       => l_description,
                x_enabled_flag      => l_enabled_flag,
                x_return_status     => l_return_status,
                x_return_msg        => l_return_msg);



          IF l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL OR l_enabled_flag IS NULL THEN

              l_error_message_name          := 'EGO_VAL_KEY_REQ_ERR';
              --Dbms_Output.put_line( ' UP:   l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL THEN ');

              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name
              );


              -- Set process_status to 3
            l_process_status              := G_ERROR_RECORD;
            l_return_status               := G_RET_STS_ERROR;
            l_last_updated_by             := g_user_id;
            l_last_update_date            := SYSDATE;
            l_last_update_login           := g_login_id;


          END IF; -- END IF l_flex_value_meaning IS NULL OR  l_disp_sequence IS NULL THEN




          IF l_process_status = G_PROCESS_RECORD  THEN


            EGO_EXT_FWK_PUB.Update_Value_Set_Val
              (
                p_api_version                   => p_api_version
                ,p_value_set_name                => l_value_set_name
                ,p_internal_name                 => l_flex_value
                ,p_display_name                  => l_flex_value_meaning
                ,p_description                   => CASE l_description
                                                      WHEN G_NULL_CHAR THEN NULL
                                                      ELSE l_description
                                                    END --l_description
                ,p_sequence                      => l_disp_sequence
                ,p_start_date                    => CASE l_start_active_date
                                                      WHEN G_NULL_DATE THEN NULL
                                                      ELSE l_start_active_date
                                                    END
                ,p_end_date                      => CASE l_end_active_date
                                                      WHEN G_NULL_DATE THEN NULL
                                                      ELSE l_end_active_date
                                                    END
                ,p_enabled                       => l_enabled_flag
                ,p_owner                         => l_owner
                ,p_init_msg_list                 => l_init_msg_list
                ,p_commit                        => FND_API.G_FALSE
                ,x_return_status                 => l_return_status
                ,x_msg_count                     => x_msg_count
                ,x_msg_data                      => x_return_msg
                ,x_is_versioned                  => l_is_versioned
                ,x_valueSetId                    => l_value_set_id);



            -- check the return status
            IF (Nvl(l_return_status,G_RET_STS_SUCCESS) = G_RET_STS_SUCCESS )
            THEN

              l_process_status:= G_SUCCESS_RECORD;
              l_return_status :=  G_RET_STS_SUCCESS;

            ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

              l_return_status := G_RET_STS_ERROR;
              l_process_status:= G_ERROR_RECORD;


		          G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
              G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS_VAL;
              G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
              G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
              G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
              G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB';
              G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
              G_TOKEN_TBL(4).Token_Value  :=  'Update_Value_Set_Val';


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => 'EGO_ENTITY_API_FAILED'
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => G_TOKEN_TBL
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => G_ENTITY_VS_VAL
                ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB );


            ELSE

              x_return_status :=  G_RET_STS_UNEXP_ERROR;
              x_return_msg    :=  l_return_msg;
              RETURN;

            END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN


          END IF; -- END IF l_process_status = G_PROCESS_RECORD  THEN


        END IF;-- END IF l_transaction_type =G_UPDATE THEN




        -- Updating value back in pl/sql table.
        p_value_set_val_tl_tbl(i).value_set_name			      :=	l_value_set_name;
        p_value_set_val_tl_tbl(i).value_set_id            	:=	l_value_set_id;
        p_value_set_val_tl_tbl(i).flex_value             	  :=	l_flex_value;
        p_value_set_val_tl_tbl(i).flex_value_id             :=	l_flex_value_id;
        --p_value_set_val_tl_tbl(i).version_seq_id			      :=	l_version_seq_id;

        p_value_set_val_tl_tbl(i)."LANGUAGE"		            :=	l_language;
        p_value_set_val_tl_tbl(i).description     		  	  :=	l_description;
        p_value_set_val_tl_tbl(i).source_lang              	:=	l_source_lang;
        p_value_set_val_tl_tbl(i).flex_value_meaning       	:=	l_flex_value_meaning;

        -- transactions related columns
        p_value_set_val_tl_tbl(i).transaction_type			    :=	l_transaction_type;
        --p_value_set_val_tl_tbl(i).transaction_id       	    :=	l_transaction_id;

        -- process related columns
        p_value_set_val_tl_tbl(i).process_status			      :=	l_process_status;
        p_value_set_val_tl_tbl(i).set_process_id      		  :=	l_set_process_id;

        -- who columns for concurrent program
        p_value_set_val_tl_tbl(i).request_id          		  :=	l_request_id;
        p_value_set_val_tl_tbl(i).program_application_id 	  :=	l_program_application_id;
        p_value_set_val_tl_tbl(i).program_id             	  :=	l_program_id;
        p_value_set_val_tl_tbl(i).program_update_date       :=  l_program_update_date;

        -- who columns
        p_value_set_val_tl_tbl(i).last_update_date    		  :=	l_last_update_date;
        p_value_set_val_tl_tbl(i).last_updated_by     		  :=	l_last_updated_by;
        p_value_set_val_tl_tbl(i).creation_date       		  :=	l_creation_date;
        p_value_set_val_tl_tbl(i).created_by          		  :=	l_created_by;
        p_value_set_val_tl_tbl(i).last_update_login		      := 	l_last_update_login;




        -- Re- Initializing Values.
        l_value_set_name          :=  NULL;
        l_value_set_id            :=  NULL;
        l_flex_value	            :=  NULL;
        l_flex_value_id           :=  NULL;

        l_language                :=  NULL;
        l_description 			      :=  NULL;
        l_version_seq_id          :=  NULL;
        l_source_lang             :=  NULL;
        l_flex_value_meaning      :=  NULL;
        l_start_active_date       :=  NULL;
        l_end_active_date         :=  NULL;
        l_enabled_flag            :=  NULL;

        l_transaction_type        :=  NULL;
        l_transaction_id          :=  NULL;

        l_request_id              :=  NULL;
        l_program_application_id  :=  NULL;
        l_program_id              :=  NULL;
        l_program_update_date     :=  NULL;

        l_process_status          :=  NULL;
        l_set_process_id          :=  NULL;

        l_last_update_date        :=  NULL;
        l_last_updated_by         :=  NULL;
        l_creation_date           :=  NULL;
        l_created_by              :=  NULL;
        l_last_update_login       :=  NULL;

        l_seq_exist               :=  NULL;




      END LOOP; -- END FOR i IN p_value_set_val_tbl.first..p_value_set_val_tbl.last



    END IF; -- END IF p_value_set_val_tl_tbl.Count>0 THEN






    -- Set return status
    IF Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS AND  x_return_status <>G_RET_STS_ERROR THEN

      x_return_status     :=  G_RET_STS_SUCCESS;
      l_return_status     := G_RET_STS_SUCCESS;

    END IF;


    IF l_return_status =G_RET_STS_ERROR THEN

      x_return_status :=  G_RET_STS_ERROR;

    END IF;



    IF p_commit THEN
      write_debug(G_PKG_Name,l_api_name,' Issue a commit ' );
      COMMIT;
    END IF;


    write_debug(G_PKG_Name,l_api_name,' End of API  ' );
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API  ' );


EXCEPTION
  WHEN OTHERS THEN

    write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );


    x_return_status := G_RET_STS_UNEXP_ERROR;
    x_return_msg    := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	RETURN;

END Process_Isolate_Value;






-- Procedure to process child value set
PROCEDURE Process_Child_Value_Set (
           p_api_version      IN              NUMBER,
           p_value_set_tbl    IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Tbl,
           p_valueset_val_tab IN  OUT NOCOPY  Ego_Metadata_Pub.Value_Set_Value_Tbl,
           p_set_process_id   IN              NUMBER,
           p_commit           IN              BOOLEAN DEFAULT FALSE,
           x_return_status    OUT NOCOPY      VARCHAR2,
           x_msg_count        OUT NOCOPY      NUMBER,
           x_return_msg         OUT NOCOPY      VARCHAR2)

IS

    l_api_name               VARCHAR2(30):='Process_Child_Value_Set';
    l_api_version            NUMBER := 1.0;
    l_owner                  NUMBER := G_User_Id;
--    l_owner_name             VARCHAR2(40):='ANONYMOUS';

    l_value_set_name         FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE; -- VARCHAR2(60);
    l_value_set_id           FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_ID%TYPE;
    l_description            FND_FLEX_VALUE_SETS.description%TYPE;

    l_longlist_flag         VARCHAR2(1);
    l_format_code            VARCHAR2(1);
    l_validation_code        VARCHAR2(1);

    l_parent_value_set_name  FND_FLEX_VALUE_SETS.FLEX_VALUE_SET_NAME%TYPE; -- VARCHAR2(60);
    l_version_seq_id         NUMBER(10,0);
    l_start_active_date      DATE;
    l_end_active_date        DATE;

    l_maximum_size           FND_FLEX_VALUE_SETS.MAXIMUM_SIZE%TYPE; --NUMBER;
    l_maximum_value          FND_FLEX_VALUE_SETS.MAXIMUM_VALUE%TYPE;
    l_minimum_value          FND_FLEX_VALUE_SETS.MINIMUM_VALUE%TYPE;

    l_transaction_type       VARCHAR2(10);
    l_transaction_id	       NUMBER;

    l_process_status         NUMBER;
    l_request_id             NUMBER;
    l_set_process_id         NUMBER;
    l_program_update_date    DATE;
    l_program_application_id NUMBER;
    l_program_id             NUMBER;

    l_last_update_date       DATE;
    l_last_updated_by        NUMBER(15);
    l_creation_date          DATE;
    l_created_by             NUMBER(15);
    l_last_update_login      NUMBER(15);

    l_versioned_vs           VARCHAR2(10):= 'False'; -- Parameter to check if vs is versioned.

    l_child_vs_value_ids     EGO_EXT_FWK_PUB.EGO_VALUE_SET_VALUE_IDS := NULL;
    --l_child_vs_value         VALUE_SET_VALUE_Name_Tbl := NULL;
    l_child_vs_id            NUMBER;
    l_parent_vs_id           NUMBER;
    l_valid_parent           NUMBER :=NULL;
    l_parent_valid_type      VARCHAR2(1) :=NULL ;
    idx                      NUMBER :=1;
    l_valid_seq              NUMBER;

    l_return_status          VARCHAR2(1) := NULL;


    /* Local variable to be used in error handling mechanism*/
    l_entity_code            VARCHAR2(40) :=  G_ENTITY_CHILD_VS;
    l_table_name             VARCHAR2(240):=  G_ENTITY_VS_HEADER_TAB;

    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_application_id         NUMBER :=  G_Application_Id;
    l_error_message_name     VARCHAR2(500);
    l_return_msg	           VARCHAR2(1000);
    --l_error_row_identifier   NUMBER;

    --l_process_status         NUMBER:=NULL;


    CURSOR cur_value_id(cp_value_set_name VARCHAR2,
                        cp_flex_value VARCHAR2)
    IS
    SELECT flex_value_id
    FROM fnd_flex_value_sets vs, fnd_flex_values val
    WHERE vs.flex_value_set_id= val.flex_value_set_id
      AND vs.flex_value_set_name= cp_value_set_name
      AND flex_value=cp_flex_value;

    -- Cursor to get value_set_id for a passed in value set name
    CURSOR  cur_value_set_id(cp_value_set_name  VARCHAR2) IS
      SELECT flex_value_set_id
      FROM fnd_flex_value_sets
      WHERE flex_value_set_name = cp_value_set_name;



    --Cursor to verify if parent_value_set_name already exist, in case of Update API.
    CURSOR  cur_valid_parent( cp_value_set_id  NUMBER,
                              cp_parent_vs_id  NUMBER) IS
      SELECT 1 AS valid_parent
      FROM Ego_Value_Set_Ext
      WHERE value_set_id = cp_value_set_id
        AND parent_value_set_id = cp_parent_vs_id;


     -- Cursor to get parent vs validation code
    CURSOR  cur_parent_vs_validation (cp_value_set_id  NUMBER) IS
      SELECT validation_type
      FROM fnd_flex_value_sets
      WHERE flex_value_set_id = cp_value_set_id;



    -- Cursor to validate sequnce.
    CURSOR Cur_Valid_Sequence ( cp_value_set_id  NUMBER,
                                cp_value_id      NUMBER)
    IS
    SELECT disp_sequence
    FROM  Ego_VS_Values_Disp_Order
    WHERE value_set_id = cp_value_set_id
      AND value_set_value_id = cp_value_id;




BEGIN


    write_debug(G_PKG_Name,l_api_name,' Start of API.  ' );
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Start of API.  ' );



    l_child_vs_value_ids   := EGO_EXT_FWK_PUB.EGO_VALUE_SET_VALUE_IDS();
    -- Get Application Id
    --G_Application_Id  := Get_Application_Id();

    ERROR_HANDLER.Set_Bo_Identifier(G_BO_IDENTIFIER_VS);





    FOR i IN p_value_set_tbl.first..p_value_set_tbl.last
    LOOP

        --SAVEPOINT CREATE_CHILD_VS;


        --Assigning value per record
        l_value_set_name        :=  p_value_set_tbl(i).value_set_name;
        l_value_set_id          :=  p_value_set_tbl(i).value_set_id;
        l_description           :=  p_value_set_tbl(i).description;
        l_format_code           :=  p_value_set_tbl(i).format_type;
        l_longlist_flag         :=  p_value_set_tbl(i).longlist_flag;
        l_validation_code       :=  p_value_set_tbl(i).validation_type;
        l_parent_value_set_name :=  p_value_set_tbl(i).parent_value_set_name;
        l_version_seq_id        :=  p_value_set_tbl(i).version_seq_id;
        l_start_active_date     :=  p_value_set_tbl(i).start_active_date;
        l_end_active_date       :=  p_value_set_tbl(i).end_active_date;
        l_maximum_size          :=  p_value_set_tbl(i).maximum_size;
        l_minimum_value         :=  p_value_set_tbl(i).minimum_value;
        l_maximum_value         :=  p_value_set_tbl(i).maximum_value;

        -- Transaction related columns
        l_transaction_type      :=  p_value_set_tbl(i).transaction_type;
        l_transaction_id        :=  p_value_set_tbl(i).transaction_id;


        l_process_status        :=  p_value_set_tbl(i).process_status;
        l_set_process_id        :=  p_value_set_tbl(i).set_process_id;

        -- Conc prog who columns
        l_request_id            :=  p_value_set_tbl(i).request_id;
        l_program_update_date     :=  p_value_set_tbl(i).program_update_date;
        l_program_application_id  :=  p_value_set_tbl(i).program_application_id;
        l_program_id              :=  p_value_set_tbl(i).program_id;

        -- Who columns
        l_last_update_date      :=  p_value_set_tbl(i).last_update_date;
        l_last_updated_by       :=  p_value_set_tbl(i).last_updated_by;
        l_creation_date         :=  p_value_set_tbl(i).creation_date;
        l_created_by            :=  p_value_set_tbl(i).created_by;
        l_last_update_login     :=  p_value_set_tbl(i).last_update_login;


        -- If value set name is passed then get value_set_id for update mode
        /*IF l_value_set_id IS NULL AND  l_value_set_name IS NOT NULL THEN
          FOR j IN cur_value_set_id(l_value_set_name)
          LOOP
            l_value_set_id:= j.flex_value_set_id;
          END LOOP;
        END IF;--END IF l_value_set_id IS NULL AND  l_value_set_name IS NOT NULL THEN
        */





        IF l_value_set_id IS NOT NULL THEN

            -- Get Value Set Name
            Convert_Id_To_Name (l_value_set_id ,G_Value_Set,NULL,l_value_set_name);

            --
            IF l_value_set_id IS NULL THEN

              l_error_message_name          := 'EGO_VSET_INVALID_ID';

              -- Set process_status to 3
              l_process_status    := g_error_record;
              l_return_status     := G_RET_STS_ERROR;
              l_last_updated_by   := g_user_id;
              l_last_update_date  := SYSDATE;
              l_last_update_login := g_login_id;



              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => l_table_name
              );

            END IF; -- END IF l_value_set_id IS NULL THEN


        END IF;-- END IF l_value_set_id IS NOT NULL THEN



        -- Get Id for a passed in name
        IF ( l_value_set_name IS NOT NULL AND l_value_set_id IS NULL ) THEN
          -- Get value Set Id
          Convert_Name_To_Id (l_value_set_name,G_Value_Set,NULL,l_value_set_id);
        END IF; -- END IF ( l_value_set_name IS NOT NULL AND l_value_set_id IS NULL ) THEN




        -- Get parent value set id
        IF l_parent_value_set_name IS NOT NULL THEN

          FOR j IN cur_value_set_id(l_parent_value_set_name)
          LOOP
            l_parent_vs_id:= j.flex_value_set_id;
          END LOOP;


          IF l_parent_vs_id IS NOT NULL THEN


            FOR j IN cur_parent_vs_validation(l_parent_vs_id)
            LOOP
              l_parent_valid_type := j.validation_type;
            END LOOP;


          END IF; --END IF l_parent_vs_id IS NOT NULL THEN

        END IF;--END IF l_parent_value_set_name IS NOT NULL THEN


        IF l_parent_vs_id IS NULL THEN

              l_process_status              := G_ERROR_RECORD;
              l_return_status               := G_RET_STS_ERROR;
              l_error_message_name          := 'EGO_CHILD_VS_INVALID_PARENT';
              -- Set process_status to 3
              l_process_status              := g_error_record;
              l_last_updated_by             := g_user_id;
              l_last_update_date            := SYSDATE;
              l_last_update_login           := g_login_id;




              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => G_ENTITY_CHILD_VS
                ,p_table_name                    => G_ENTITY_VS_HEADER_TAB
              );




        END IF; -- END IF l_parent_vs_id IS NULL THEN


        IF l_parent_valid_type NOT IN (G_TRANS_IND_VALIDATION_CODE,G_INDEPENDENT_VALIDATION_CODE) THEN


              l_process_status              := G_ERROR_RECORD;
              l_return_status               := G_RET_STS_ERROR;
              l_error_message_name          := 'EGO_VSET_PARENT_VALIDATION_ERR';
              -- Set process_status to 3
              l_process_status              := g_error_record;
              l_last_updated_by             := g_user_id;
              l_last_update_date            := SYSDATE;
              l_last_update_login           := g_login_id;




              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => G_ENTITY_CHILD_VS
                ,p_table_name                    => G_ENTITY_VS_HEADER_TAB
              );



        END IF; -- END IF l_parent_valid_type NOT IN (G_TRANS_IND_VALIDATION_CODE,G_INDEPENDENT_VALIDATION_CODE) THEN











        --Check for transaction type and update it correctly
        IF l_transaction_type  =G_SYNC THEN

          -- If value set name already exist then transactiono type is Create else it is Update
          IF l_value_set_id IS NULL
          THEN
            l_transaction_type  :=G_CREATE;
          ELSE
            l_transaction_type  :=G_UPDATE;
          END IF;

        END IF;




        write_debug(G_PKG_Name,l_api_name,' Verifying validation code :  '||l_validation_code||' Transaction type is = '||l_transaction_type||' value Set Name is = '||l_value_set_name );

        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' l_parent_vs_id = '||l_parent_vs_id) ;

        -- Do certain validation
        IF l_parent_vs_id IS NOT NULL AND l_transaction_type= G_UPDATE THEN

            FOR i IN cur_valid_parent (l_value_set_id, l_parent_vs_id)
            LOOP

              l_valid_parent  := i.valid_parent;

            END LOOP;

            IF l_valid_parent IS NULL THEN

              --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  Invalid validation code '||' l_transaction_id = '||l_transaction_id);

              l_process_status              := G_ERROR_RECORD;
              l_return_status               := G_RET_STS_ERROR;
              l_error_message_name          := 'EGO_CHILD_VS_INVALID_PARENT';


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => G_ENTITY_CHILD_VS
                ,p_table_name                    => G_ENTITY_VS_HEADER_TAB
              );

              -- Set process_status to 3
              l_process_status    := g_error_record;
              l_last_updated_by   := g_user_id;
              l_last_update_date  := SYSDATE;
              l_last_update_login := g_login_id;

            END IF ; -- END IF l_valid_parent IS NULL THEN

        END IF;  -- END IF l_parent_vs_id IS NOT NULL AND l_transaction_type= G_UPDATE THEN




        -- If child VS is passed in update mode
        IF l_transaction_type = G_UPDATE THEN

            --Get value of require field if they are null
            Get_Key_VS_Columns   (p_value_set_id        => l_value_set_id,
                                  p_transaction_id      => l_transaction_id,
                                  x_maximum_size        => l_maximum_size,
                                  x_maximum_value       => l_maximum_value,
                                  x_minimum_value       => l_minimum_value,
                                  x_description         => l_description,
                                  x_longlist_flag       => l_longlist_flag,
                                  x_format_code         => l_format_code,
                                  x_validation_code     => l_validation_code,
                                  x_return_status       => l_return_status,
                                  x_return_msg          => l_return_msg
                                );



            -- check the return status
            IF (Nvl(l_return_status,G_RET_STS_SUCCESS)  =G_RET_STS_SUCCESS ) THEN

                l_process_status:= G_PROCESS_RECORD;

            ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                            ||l_value_set_name||','||l_value_set_id||')'||' Child Value Set : Get_Key_VS_Columns API failed. ');


                x_return_status := l_return_status;
                l_process_status:= G_ERROR_RECORD;

                G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_VS;
                G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                G_TOKEN_TBL(3).Token_Value  :=  'EGO_VS_BULKLOAD_PVT';
                G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                G_TOKEN_TBL(4).Token_Value  :=  'Get_Key_VS_Columns';


                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                   => 'EGO_ENTITY_API_FAILED'
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => G_TOKEN_TBL
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => G_ENTITY_CHILD_VS
                  ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

            ELSE

                write_debug(G_PKG_Name,l_api_name,' : Unexpected exceptioon ' );
                x_return_status :=  G_RET_STS_UNEXP_ERROR;
                x_return_msg    :=  l_return_msg;
                RETURN;

            END IF;  -- END IF (l_return_status =G_RET_STS_SUCCESS ) THEN


        END IF;



        Validate_Child_Value_Set (
                                  l_value_set_name,
                                  l_value_set_id,
                                  l_validation_code,
                                  l_longlist_flag,
                                  l_format_code,
                                  l_version_seq_id,
                                  l_transaction_id,
                                  l_return_status,
                                  l_return_msg);





       -- check the return status
        IF (l_return_status =G_RET_STS_UNEXP_ERROR )
        THEN

            x_return_status :=  G_RET_STS_UNEXP_ERROR;
            x_return_msg    :=  l_return_msg;
            RETURN;

        ELSIF (l_return_status =G_RET_STS_ERROR ) THEN

            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID='  ||l_transaction_id||'-(VS,VS Id)=('
                                                                  ||l_value_set_name||','||l_value_set_id||')'||' Child Value Set validation failed. ');
            l_process_status := G_ERROR_RECORD;

        END IF; -- END IF (l_return_status =G_RET_STS_UNEXP_ERROR )



        -- Process successful value set only.
        --IF l_process_status= G_PROCESS_RECORD THEN

          --Check for transaction type.
          IF l_transaction_type=G_CREATE THEN

            IF p_valueset_val_tab.Count>0 THEN

                write_debug(G_PKG_Name,l_api_name,' IN Create Mode Count of record is : '||p_valueset_val_tab.Count);
                --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  IN Create Mode Count of record is : '||p_valueset_val_tab.Count );


                -- Create a Varray containing values corresponding to a child value set

                FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last
                LOOP

                  IF p_valueset_val_tab(j).process_status = G_PROCESS_RECORD THEN


                    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Value = '||p_valueset_val_tab(j).flex_value||' Id '||p_valueset_val_tab(j).flex_value_id);
                    --IF p_valueset_val_tab(j).value_set_name= l_value_set_name THEN

                    -- Get Value,If Id is given
                    IF   ( p_valueset_val_tab(j).flex_value_id IS NOT NULL
                           AND ( p_valueset_val_tab(j).value_set_name= l_value_set_name
                           OR p_valueset_val_tab(j).value_set_id = l_value_set_id) ) THEN


                        IF l_process_status= G_ERROR_RECORD THEN

                            p_valueset_val_tab(j).process_status    := G_ERROR_RECORD;
                            p_valueset_val_tab(j).transaction_type  := l_transaction_type;
                            l_error_message_name          := 'EGO_CHILD_VS_CREATION_FAILED';

                            ERROR_HANDLER.Add_Error_Message(
                              p_message_name                   => l_error_message_name
                              ,p_application_id                => G_App_Short_Name
                              ,p_token_tbl                     => l_token_table
                              ,p_message_type                  => G_RET_STS_ERROR
                              ,p_row_identifier                => p_valueset_val_tab(j).transaction_id
                              ,p_entity_code                   => G_ENTITY_CHILD_VS
                              ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB
                            );

                        END IF; -- END IF l_process_status= G_ERROR_RECORD THEN

                        -- Get value name
                        Convert_Id_To_Name (p_valueset_val_tab(j).flex_value_id ,G_Value,l_parent_vs_id,p_valueset_val_tab(j).flex_value);


                        IF p_valueset_val_tab(j).flex_value_id IS NULL THEN

                          l_error_message_name          := 'EGO_VSET_VAL_INVALID_ID';
                          -- Set process_status to 3
                          l_process_status    := g_error_record;
                          p_valueset_val_tab(j).process_status := G_ERROR_RECORD;
                          l_return_status     := G_RET_STS_ERROR;
                          l_last_updated_by   := g_user_id;
                          l_last_update_date  := SYSDATE;
                          l_last_update_login := g_login_id;



                          ERROR_HANDLER.Add_Error_Message(
                            p_message_name                   => l_error_message_name
                            ,p_application_id                => G_App_Short_Name
                            ,p_token_tbl                     => l_token_table
                            ,p_message_type                  => G_RET_STS_ERROR
                            ,p_row_identifier                => l_transaction_id
                            ,p_entity_code                   => l_entity_code
                            ,p_table_name                    => l_table_name
                          );

                        END IF; -- END IF l_value_set_id IS NULL THEN




                      IF l_parent_vs_id IS NOT NULL AND p_valueset_val_tab(j).flex_value_id IS NULL THEN

                          FOR Cur_Seq IN Cur_Valid_Sequence (l_parent_vs_id, p_valueset_val_tab(j).flex_value_id)
                          LOOP
                              l_valid_seq := Cur_Seq.disp_sequence;

                          END LOOP;

                          IF l_valid_seq <>  p_valueset_val_tab(j).disp_sequence THEN

                              --Dbms_Output.put_line(' Invalid sequence error ');
                              l_process_status              := G_ERROR_RECORD;
                              l_return_status               := G_RET_STS_ERROR;
                              l_last_updated_by             := g_user_id;
                              l_last_update_date            := SYSDATE;
                              l_last_update_login           := g_login_id;

                              l_error_message_name          := 'EGO_VS_VAL_INVALID_SEQ';

                              ERROR_HANDLER.Add_Error_Message(
                                p_message_name                  => l_error_message_name
                                ,p_application_id                => G_App_Short_Name
                                ,p_token_tbl                     => l_token_table
                                ,p_message_type                  => G_RET_STS_ERROR
                                ,p_row_identifier                => l_transaction_id
                                ,p_entity_code                   => l_entity_code
                                ,p_table_name                    => l_table_name );



                          END IF;

                      END IF;







                    END IF;-- END IF l_flex_value_id IS NOT NULL THEN


                    -- get Value_id from a given value.
                    IF (p_valueset_val_tab(j).flex_value_id IS NULL
                          AND p_valueset_val_tab(j).flex_value IS NOT NULL
                          AND ( p_valueset_val_tab(j).value_set_name= l_value_set_name
                                OR p_valueset_val_tab(j).value_set_id = l_value_set_id) ) THEN



                        IF l_process_status= G_ERROR_RECORD THEN

                            p_valueset_val_tab(j).process_status    := G_ERROR_RECORD;
                            p_valueset_val_tab(j).transaction_type  := l_transaction_type;
                            l_error_message_name                    := 'EGO_CHILD_VS_CREATION_FAILED';

                            ERROR_HANDLER.Add_Error_Message(
                              p_message_name                   => l_error_message_name
                              ,p_application_id                => G_App_Short_Name
                              ,p_token_tbl                     => l_token_table
                              ,p_message_type                  => G_RET_STS_ERROR
                              ,p_row_identifier                => p_valueset_val_tab(j).transaction_id
                              ,p_entity_code                   => G_ENTITY_CHILD_VS
                              ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB
                            );


                        END IF; -- END IF l_process_status= G_ERROR_RECORD THEN




                        -- Bug 9701510
                        -- For Date and DateTime VS, Convert value to DB Date format.
                        IF l_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE) THEN



                            Validate_User_Preferred_Date (p_valueset_val_tab(j).flex_value,
                                                          l_format_code,
                                                          l_transaction_id,
                                                          l_return_status,
                                                          l_return_msg);


                            --Dbms_Output.put_line(' Call to Validate_User_Preferred_Date is done. Return status is : '||l_return_status);
                            -- check the return status
                            IF (l_return_status =G_RET_STS_UNEXP_ERROR )
                            THEN

                              write_debug(G_PKG_Name,l_api_name,' Unexpected error occured in Validate_User_Preferred_Date API l_return_msg ='||l_return_msg);

                              x_return_status :=  G_RET_STS_UNEXP_ERROR;
                              x_return_msg    :=  l_return_msg;
                              RETURN;

                            ELSIF (l_return_status =G_RET_STS_ERROR ) THEN


                              write_debug(G_PKG_Name,l_api_name,' Err_Msg-TID='  ||l_transaction_id||'-(VS,VS Id, Value)=('
                                                                                    ||l_value_set_name||','||l_value_set_id||','||p_valueset_val_tab(j).flex_value||')'||' Validation of value failed. ');


                              p_valueset_val_tab(j).process_status    := G_ERROR_RECORD;
                              p_valueset_val_tab(j).transaction_type  := l_transaction_type;


                            END IF; -- END IF (l_return_status =G_RET_STS_UNEXP_ERROR )



                            Convert_Value_To_DbDate (p_valueset_val_tab(j).flex_value);
                            --Dbms_Output.put_line(' After changing val to DB Val : '||p_valueset_val_tab(j).flex_value);

                        END IF;
                        -- Bug 9701510


                        -- Convert name to id
                        Convert_Name_To_Id (p_valueset_val_tab(j).flex_value,G_Value,l_parent_vs_id,p_valueset_val_tab(j).flex_value_id);


                    END IF; -- END IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN


                    IF l_process_status= G_PROCESS_RECORD THEN

                        IF (p_valueset_val_tab(j).flex_value_id IS NOT NULL ) THEN

                          --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Before building array '||p_valueset_val_tab(j).flex_value_id);

                          l_child_vs_value_ids.extend;

                          l_child_vs_value_ids(idx) := p_valueset_val_tab(j).flex_value_id;

                          idx :=  idx +1;

                          -- Set Status to success if it has been processed.
                          p_valueset_val_tab(j).process_status    := G_SUCCESS_RECORD;
                          p_valueset_val_tab(j).transaction_type  := l_transaction_type;

                          --Dbms_Output.put_line(' Building Values Array '||p_valueset_val_tab(j).flex_value_id);

                        END IF; -- END IF (p_valueset_val_tab(j).flex_value_id IS NOT NULL ) THEN

                    END IF; --IF l_process_status= G_PROCESS_RECORD THEN



                  END IF; -- END IF p_valueset_val_tab(j).process_status = G_PROCESS_RECORD THEN



                END LOOP; -- END FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last





                IF l_process_status = G_PROCESS_RECORD  THEN

                  -- Check if values exist correspond to a value set.
                  IF l_child_vs_value_ids.Count = 0 THEN
                    -- Log error
                    --Dbms_Output.put_line(' IN ERROR MODE ');

                    l_return_status               := G_RET_STS_ERROR;
                    l_process_status              := G_ERROR_RECORD;
                    l_error_message_name          := 'EGO_CHILD_VAL_REQUIRED';
                    l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
                    l_token_table(1).TOKEN_VALUE  := l_value_set_name;


                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                   => l_error_message_name
                      ,p_application_id                => G_App_Short_Name
                      ,p_token_tbl                     => l_token_table
                      ,p_message_type                  => G_RET_STS_ERROR
                      ,p_row_identifier                => l_transaction_id
                      ,p_entity_code                   => G_ENTITY_CHILD_VS
                      ,p_table_name                    => G_ENTITY_VS_HEADER_TAB
                    );

                  END IF; -- END IF l_child_vs_value_ids.Count = 0 THEN

                END IF; --IF l_process_status = G_PROCESS_RECORD  THEN







                -- Check for ValueSetType/Validation type is done as bulk check..
                -- Create a value set to keep sync with existing framework
                IF l_process_status = G_PROCESS_RECORD  THEN

                    --Dbms_Output.put_line(' Calling EGO_EXT_FWK_PUB.Create_Child_Value_Set API. Count of child values : '||l_child_vs_value_ids.Count);

                    EGO_EXT_FWK_PUB.Create_Child_Value_Set
                      (
                        p_api_version                   => l_api_version
                        ,p_value_set_name                => l_value_set_name
                        ,p_description                   => l_description
                        ,p_parent_vs_id                  => l_parent_vs_id
                        ,child_vs_value_ids              => l_child_vs_value_ids
                        ,p_owner                         => l_owner
                        ,p_init_msg_list                 => fnd_api.g_FALSE
                        ,p_commit                        => fnd_api.g_FALSE
                        ,x_child_vs_id                   => l_child_vs_id
                        ,x_return_status                 => l_return_status
                        ,x_msg_count                     => x_msg_count
                        ,x_msg_data                      => l_return_msg
                      );

                    write_debug(G_PKG_Name,l_api_name,' Creation of child VS is done. Return status is  '||l_return_status);
                    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Creation of child VS is done. Return status is  '||l_return_status);




                    -- check the return status
                    IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS ) THEN

                        l_process_status:= G_SUCCESS_RECORD;


                        -- Get Value_Set_Id from a given value Set name.
                        IF (l_value_set_id  IS NULL) THEN

                            Convert_Name_To_Id (l_value_set_name ,G_Value_Set,NULL,l_value_set_id);

                        END IF; -- END IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN

                        -- Assign value set id to successfully processed record.
                        FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last
                        LOOP

                            IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id IS NULL ) THEN

                              p_valueset_val_tab(j).value_set_id := l_value_set_id;

                            END IF;-- END IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id IS NULL ) THEN

                        END LOOP; -- END FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last






                    ELSIF (l_return_status = G_RET_STS_ERROR )
                    THEN

                        --x_return_status             := l_return_status;
                        l_process_status            := G_ERROR_RECORD;


                        -- Assign value set id to successfully processed record.
                        FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last
                        LOOP

                            IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id IS NULL ) THEN

                              p_valueset_val_tab(j).process_status := G_ERROR_RECORD;

                            END IF;-- END IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id IS NULL ) THEN

                        END LOOP; -- END FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last






		                    G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                        G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_CHILD_VS;
                        G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                        G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                        G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                        G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB';
                        G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                        G_TOKEN_TBL(4).Token_Value  :=  'Create_Child_Value_Set';


                        ERROR_HANDLER.Add_Error_Message (
                          p_message_name                   => 'EGO_ENTITY_API_FAILED'
                          ,p_application_id                => G_App_Short_Name
                          ,p_token_tbl                     => G_TOKEN_TBL
                          ,p_message_type                  => G_RET_STS_ERROR
                          ,p_row_identifier                => l_transaction_id
                          ,p_entity_code                   => G_ENTITY_CHILD_VS
                          ,p_table_name                    => G_ENTITY_VS_HEADER_TAB );

                    ELSE    -- case of unexpected error


                      -- Assign value set id to successfully processed record.
                        FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last
                        LOOP

                          IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id IS NULL ) THEN

                            p_valueset_val_tab(j).process_status := G_ERROR_RECORD;

                          END IF;-- END IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id IS NULL ) THEN

                        END LOOP; -- END FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last

                        x_return_status := G_RET_STS_UNEXP_ERROR;
                        x_return_msg    := l_return_msg;
                        RETURN;


                    END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN



                END IF;-- END IF l_process_status = G_PROCESS_RECORD  THEN



            ELSE

                -- Log error
                --Dbms_Output.put_line(' IN ERROR MODE ');

                l_return_status               := G_RET_STS_ERROR;
                l_process_status              := G_ERROR_RECORD;
                l_error_message_name          := 'EGO_CHILD_VAL_REQUIRED';
                l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
                l_token_table(1).TOKEN_VALUE  := l_value_set_name;


                ERROR_HANDLER.Add_Error_Message(
                  p_message_name                   => l_error_message_name
                  ,p_application_id                => G_App_Short_Name
                  ,p_token_tbl                     => l_token_table
                  ,p_message_type                  => G_RET_STS_ERROR
                  ,p_row_identifier                => l_transaction_id
                  ,p_entity_code                   => G_ENTITY_CHILD_VS
                  ,p_table_name                    => G_ENTITY_VS_HEADER_TAB
                );



            END IF; -- END IF p_valueset_val_tab.Count>0 THEN



          ELSIF l_transaction_type=G_UPDATE THEN
              -- In case of updating child value set, we do always expect all values associated to a child value set to be passed.
              -- Also other value will always get deleted
              -- Create a collection to contain values for a child value set

              -- Create a Varray containing values corresponding to a child value set
            IF p_valueset_val_tab.Count>0 THEN

              write_debug(G_PKG_Name,l_api_name,' IN Update Mode Count of record is : '||p_valueset_val_tab.Count);
              --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  IN Update Mode Count of record is : '||p_valueset_val_tab.Count );




              FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last
              LOOP

                --IF p_valueset_val_tab(j).value_set_name= l_value_set_name THEN
                IF p_valueset_val_tab(j).process_status = G_PROCESS_RECORD THEN


                  -- Get Value,If Id is given
                  IF ( p_valueset_val_tab(j).flex_value_id IS NOT NULL
                        AND ( p_valueset_val_tab(j).value_set_name= l_value_set_name
                              OR p_valueset_val_tab(j).value_set_id = l_value_set_id) ) THEN


                        IF l_process_status= G_ERROR_RECORD THEN


                            write_debug(G_PKG_Name,l_api_name,'Err_Msg-TID=' ||l_transaction_id||'-(VS,VS Id)=('
                                                        ||l_value_set_name||','||l_value_set_id||')'||' Child Value Set creation failed.');




                            p_valueset_val_tab(j).process_status    := G_ERROR_RECORD;
                            p_valueset_val_tab(j).transaction_type  := l_transaction_type;
                            l_error_message_name                    := 'EGO_CHILD_VS_CREATION_FAILED';

                            ERROR_HANDLER.Add_Error_Message(
                              p_message_name                   => l_error_message_name
                              ,p_application_id                => G_App_Short_Name
                              ,p_token_tbl                     => l_token_table
                              ,p_message_type                  => G_RET_STS_ERROR
                              ,p_row_identifier                => p_valueset_val_tab(j).transaction_id
                              ,p_entity_code                   => G_ENTITY_CHILD_VS
                              ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB
                            );

                        END IF; -- END IF l_process_status= G_ERROR_RECORD THEN



                        -- Get value name
                        Convert_Id_To_Name (p_valueset_val_tab(j).flex_value_id ,G_Value,l_parent_vs_id,p_valueset_val_tab(j).flex_value);


                        IF p_valueset_val_tab(j).flex_value_id IS NULL THEN

                          l_error_message_name          := 'EGO_VSET_VAL_INVALID_ID';
                          -- Set process_status to 3
                          l_process_status    := g_error_record;
                          l_return_status     := G_RET_STS_ERROR;
                          l_last_updated_by   := g_user_id;
                          l_last_update_date  := SYSDATE;
                          l_last_update_login := g_login_id;



                          ERROR_HANDLER.Add_Error_Message(
                            p_message_name                   => l_error_message_name
                            ,p_application_id                => G_App_Short_Name
                            ,p_token_tbl                     => l_token_table
                            ,p_message_type                  => G_RET_STS_ERROR
                            ,p_row_identifier                => l_transaction_id
                            ,p_entity_code                   => l_entity_code
                            ,p_table_name                    => l_table_name
                          );

                        END IF; -- END IF l_value_set_id IS NULL THEN



                  END IF;-- END IF l_flex_value_id IS NOT NULL THEN


                  -- get Value_id from a given value.
                  IF (p_valueset_val_tab(j).flex_value_id IS NULL AND p_valueset_val_tab(j).flex_value IS NOT NULL
                      AND ( p_valueset_val_tab(j).value_set_name= l_value_set_name OR p_valueset_val_tab(j).value_set_id = l_value_set_id) ) THEN



                        IF l_process_status= G_ERROR_RECORD THEN

                            p_valueset_val_tab(j).process_status    := G_ERROR_RECORD;
                            p_valueset_val_tab(j).transaction_type  := l_transaction_type;
                            l_error_message_name                    := 'EGO_CHILD_VS_CREATION_FAILED';

                            ERROR_HANDLER.Add_Error_Message(
                              p_message_name                   => l_error_message_name
                              ,p_application_id                => G_App_Short_Name
                              ,p_token_tbl                     => l_token_table
                              ,p_message_type                  => G_RET_STS_ERROR
                              ,p_row_identifier                => p_valueset_val_tab(j).transaction_id
                              ,p_entity_code                   => G_ENTITY_CHILD_VS
                              ,p_table_name                    => G_ENTITY_VAL_HEADER_TAB
                            );

                        END IF; -- END IF l_process_status= G_ERROR_RECORD THEN




                        -- Bug 9701510
                        -- For Date and DateTime VS, Convert value to DB Date format.
                        IF l_format_code IN (G_DATE_DATA_TYPE,G_DATE_TIME_DATA_TYPE) THEN

                            Validate_User_Preferred_Date (p_valueset_val_tab(j).flex_value,
                                                          l_format_code,
                                                          l_transaction_id,
                                                          l_return_status,
                                                          l_return_msg);


                            -- check the return status
                            IF (l_return_status =G_RET_STS_UNEXP_ERROR )
                            THEN

                              write_debug(G_PKG_Name,l_api_name,' Unexpected error occured in Validate_User_Preferred_Date API l_return_msg ='||l_return_msg);

                              x_return_status :=  G_RET_STS_UNEXP_ERROR;
                              x_return_msg    :=  l_return_msg;
                              RETURN;

                            ELSIF (l_return_status =G_RET_STS_ERROR ) THEN


                              write_debug(G_PKG_Name,l_api_name,' Err_Msg-TID='  ||l_transaction_id||'-(VS,VS Id, Value)=('
                                                                                    ||l_value_set_name||','||l_value_set_id||','||p_valueset_val_tab(j).flex_value||')'||' Validation of value failed. ');


                              p_valueset_val_tab(j).process_status    := G_ERROR_RECORD;
                              p_valueset_val_tab(j).transaction_type  := l_transaction_type;



                            END IF; -- END IF (l_return_status =G_RET_STS_UNEXP_ERROR )



                            Convert_Value_To_DbDate (p_valueset_val_tab(j).flex_value);


                        END IF;
                        -- Bug 9701510


                        Convert_Name_To_Id (p_valueset_val_tab(j).flex_value,G_Value,l_parent_vs_id,p_valueset_val_tab(j).flex_value_id);

                  END IF; -- END IF (l_flex_value_id IS NULL AND l_flex_value IS NOT NULL ) THEN



                  write_debug(G_PKG_Name,l_api_name,' Creating value Ids ARRAY ');
                  --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Creating value Ids ARRAY ');



                  IF l_process_status= G_PROCESS_RECORD THEN

                      IF (p_valueset_val_tab(j).flex_value_id IS NOT NULL ) THEN



                          l_child_vs_value_ids.extend;

                          l_child_vs_value_ids(idx) := p_valueset_val_tab(j).flex_value_id;

                          idx :=  idx +1;

                          -- Set Status to success if it has been processed.
                          p_valueset_val_tab(j).process_status    := G_SUCCESS_RECORD;
                          p_valueset_val_tab(j).transaction_type  := l_transaction_type;

                          --Dbms_Output.put_line(' Building Values Array '||p_valueset_val_tab(j).flex_value_id);

                      END IF; -- END IF (p_valueset_val_tab(j).flex_value_id IS NOT NULL ) THEN

                  END IF; -- END IF l_process_status= G_PROCESS_RECORD THEN



                END IF; -- END IF p_valueset_val_tab(j).process_status = G_PROCESS_RECORD THEN

                write_debug(G_PKG_Name,l_api_name,' Count of value Ids is : '||l_child_vs_value_ids.Count );
                --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Count of value Ids is : '||l_child_vs_value_ids.Count );


              END LOOP; -- END FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last




              IF l_process_status = G_PROCESS_RECORD  THEN

                  IF l_child_vs_value_ids.Count = 0 THEN

                    -- Log error

                    l_process_status              := G_ERROR_RECORD;
                    l_return_status               := G_RET_STS_ERROR;
                    l_error_message_name          := 'EGO_CHILD_VAL_REQUIRED';
                    l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
                    l_token_table(1).TOKEN_VALUE  := l_value_set_name;

                    l_token_table(2).TOKEN_NAME   := 'VALUE_SET_ID';
                    l_token_table(2).TOKEN_VALUE  := l_value_set_name;


                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                   => l_error_message_name
                      ,p_application_id                => G_App_Short_Name
                      ,p_token_tbl                     => l_token_table
                      ,p_message_type                  => G_RET_STS_ERROR
                      ,p_row_identifier                => l_transaction_id
                      ,p_entity_code                   => G_ENTITY_CHILD_VS
                      ,p_table_name                    => G_ENTITY_VS_HEADER_TAB
                    );

                  END IF; -- END IF l_child_vs_value_ids.Count = 0 THEN

              END IF; -- END IF l_process_status = G_PROCESS_RECORD  THEN


              write_debug(G_PKG_Name,l_api_name,' : calling  EGO_EXT_FWK_PUB.Update_Child_Value_Set API  ');
              --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' : calling  EGO_EXT_FWK_PUB.Update_Child_Value_Set API  ');

              --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' : Format Coed '||l_format_code||' Desc = '||l_description||' VS Id = '||l_value_set_id);

              IF l_process_status = G_PROCESS_RECORD  THEN

                  -- Call update API to update value set.
                  EGO_EXT_FWK_PUB.Update_Child_Value_Set
                    (
                      p_api_version                   => l_api_version
                      ,p_value_set_id                  => l_value_set_id
                      ,p_description                   => l_description
                      ,p_format_code                   => l_format_code
                      ,p_owner                         => G_USER_ID --l_owner
                      ,child_vs_value_ids              => l_child_vs_value_ids
                      ,p_init_msg_list                 => fnd_api.g_FALSE
                      ,p_commit                        => fnd_api.g_FALSE
                      ,x_return_status                 => l_return_status

                      ,x_msg_count                     => x_msg_count
                      ,x_msg_data                      => l_return_msg
                    );


                  --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Return status post call to EGO_EXT_FWK_PUB.Update_Child_Value_Set API  = '||l_return_status||' Msg is ; '||l_return_msg);

                  -- check the return status
                  IF (Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS ) THEN

                      l_process_status:= G_SUCCESS_RECORD;


                      -- Assign value set id to successfully processed record.
                      FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last
                      LOOP

                          IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id IS NULL ) THEN

                            p_valueset_val_tab(j).value_set_id := l_value_set_id;
                            p_valueset_val_tab(j).value_set_name := l_value_set_name;

                          END IF;-- END IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id IS NULL ) THEN

                      END LOOP; -- END FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last


                  ELSIF (l_return_status = G_RET_STS_ERROR ) THEN

                      l_process_status            := G_ERROR_RECORD;

                      -- Assign value set id to successfully processed record.
                      FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last
                      LOOP

                        IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id = l_value_set_id ) THEN

                          p_valueset_val_tab(j).process_status := G_ERROR_RECORD;

                        END IF;-- END IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id IS NULL ) THEN

                      END LOOP; -- END FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last




		                  G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                      G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_CHILD_VS;
                      G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                      G_TOKEN_TBL(2).Token_Value  :=  l_transaction_type;
                      G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                      G_TOKEN_TBL(3).Token_Value  :=  'EGO_EXT_FWK_PUB' ;
                      G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                      G_TOKEN_TBL(4).Token_Value  :=  'Update_Child_Value_Set';


                      ERROR_HANDLER.Add_Error_Message(
                        p_message_name                   => 'EGO_ENTITY_API_FAILED'
                        ,p_application_id                => G_App_Short_Name
                        ,p_token_tbl                     => G_TOKEN_TBL
                        ,p_message_type                  => G_RET_STS_ERROR
                        ,p_row_identifier                => l_transaction_id
                        ,p_entity_code                   => G_ENTITY_CHILD_VS
                        ,p_table_name                    => G_ENTITY_VS_HEADER_TAB
                      );


                  ELSE  -- Case of unexpected error


                      -- Assign value set id to successfully processed record.
                      FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last
                      LOOP

                        IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id =l_value_set_id ) THEN

                          p_valueset_val_tab(j).process_status := G_ERROR_RECORD;

                        END IF;-- END IF (  p_valueset_val_tab(j).process_status = G_SUCCESS_RECORD AND p_valueset_val_tab(j).value_set_id IS NULL ) THEN

                      END LOOP; -- END FOR j IN p_valueset_val_tab.first..p_valueset_val_tab.last



                      x_return_status :=  G_RET_STS_UNEXP_ERROR;
                      x_return_msg    :=  l_return_msg;
                      RETURN;

                  END IF;  -- END  IF l_return_status <> G_RET_STS_SUCCESS THEN


              END IF; -- END IF l_process_status = G_PROCESS_RECORD  THEN


              -- We do not support versioning for a child value set thus no code require for versioning

            ELSE  --IF p_valueset_val_tab IS NOT NULL THEN

              -- Log error
              --Dbms_Output.put_line(' IN ERROR MODE ');

              l_return_status               := G_RET_STS_ERROR;
              l_process_status              := G_ERROR_RECORD;
              l_error_message_name          := 'EGO_CHILD_VAL_REQUIRED';
              l_token_table(1).TOKEN_NAME   := 'VALUE_SET_NAME';
              l_token_table(1).TOKEN_VALUE  := l_value_set_name;


              ERROR_HANDLER.Add_Error_Message(
                p_message_name                   => l_error_message_name
                ,p_application_id                => G_App_Short_Name
                ,p_token_tbl                     => l_token_table
                ,p_message_type                  => G_RET_STS_ERROR
                ,p_row_identifier                => l_transaction_id
                ,p_entity_code                   => G_ENTITY_CHILD_VS
                ,p_table_name                    => G_ENTITY_VS_HEADER_TAB
                );



            END IF ;--IF p_valueset_val_tab IS NOT NULL THEN


          END IF; -- END IF transaction_type=G_CREATE

        --END IF;   -- END IF l_process_status= G_PROCESS_RECORD THEN


        WRITE_DEBUG(G_PKG_Name,l_api_name,' Assigning vvariables back topl/sql tables ');
        --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Assigning vvariables back topl/sql tables ');

        -- Assign Back all values to table.
        ---*************************--------

        p_value_set_tbl(i).value_set_name			          :=	l_value_set_name;
        p_value_set_tbl(i).value_set_id            	    :=	l_value_set_id;
        p_value_set_tbl(i).description				          :=	l_description;
        p_value_set_tbl(i).format_type				          :=	l_format_code;
        p_value_set_tbl(i).longlist_flag			          :=	l_longlist_flag;
        p_value_set_tbl(i).validation_type			        :=	l_validation_code;

        p_value_set_tbl(i).parent_value_set_name	      :=	l_parent_value_set_name;
        --p_value_set_tbl(i).version_seq_id			          :=	l_version_seq_id;
        p_value_set_tbl(i).start_active_date		        :=	l_start_active_date;
        p_value_set_tbl(i).end_active_date			        :=	l_end_active_date;
        p_value_set_tbl(i).maximum_size               	:=	l_maximum_size;
        p_value_set_tbl(i).minimum_value			          :=	l_maximum_value;
        p_value_set_tbl(i).maximum_value			          :=	l_minimum_value;

        -- transactions related columns
        p_value_set_tbl(i).transaction_type			        :=	l_transaction_type;
        --p_value_set_tbl(i).transaction_id       	      :=	l_transaction_id;

        -- process related columns
        p_value_set_tbl(i).process_status			          :=	l_process_status;
        p_value_set_tbl(i).set_process_id      		      :=	l_set_process_id;

        -- who columns for concurrent program
        p_value_set_tbl(i).request_id          		      :=	l_request_id;
        p_value_set_tbl(i).program_application_id       :=	l_program_application_id;
        p_value_set_tbl(i).program_id             	    :=	l_program_id;
        p_value_set_tbl(i).program_update_date          :=  l_program_update_date;

        -- who columns
        p_value_set_tbl(i).last_update_date    		      :=	l_last_update_date;
        p_value_set_tbl(i).last_updated_by     		      :=	l_last_updated_by;
        p_value_set_tbl(i).creation_date       		      :=	l_creation_date;
        p_value_set_tbl(i).created_by          		      :=	l_created_by;
        p_value_set_tbl(i).last_update_login		        := 	l_last_update_login;

        --------********************-------------


        -- Re-Initializing values
        l_value_set_name          :=  NULL;
        l_value_set_id            :=  NULL;
        l_description             :=  NULL;
        l_format_code             :=  NULL;
        l_longlist_flag           :=  NULL;
        l_validation_code         :=  NULL;
        l_parent_value_set_name   :=  NULL;
        l_version_seq_id          :=  NULL;
        --l_version_description     :=  NULL;

        l_start_active_date       :=  NULL;
        l_end_active_date         :=  NULL;
        l_maximum_size            :=  NULL;
        l_minimum_value           :=  NULL;
        l_maximum_value           :=  NULL;

        l_transaction_type        :=  NULL;
        l_transaction_id          :=  NULL;

        l_process_status          :=  NULL;
        l_set_process_id          :=  NULL;

        l_request_id              :=  NULL;
        l_program_application_id  :=  NULL;
        l_program_id              :=  NULL;
        l_program_update_date     :=  NULL;

        l_last_update_date        :=  NULL;
        l_last_updated_by         :=  NULL;
        l_creation_date           :=  NULL;
        l_created_by              :=  NULL;
        l_last_update_login       :=  NULL;

        l_parent_vs_id            :=  NULL;
        idx                       :=  1;
        l_valid_parent            :=  NULL;
        l_parent_valid_type       :=  NULL;

        --Dbms_Output.put_line(' Count of values after processing Value Set. '||l_child_vs_value_ids.Count );
        l_child_vs_value_ids.DELETE;
        --Dbms_Output.put_line(' Count of values after deleting records. '||l_child_vs_value_ids.Count );


    END LOOP; --END FOR i IN p_value_set_tbl.first..p_value_set_tbl.last


    -- Set return status
    IF Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_SUCCESS AND  x_return_status <>G_RET_STS_ERROR THEN

      x_return_status :=  G_RET_STS_SUCCESS;
      l_return_status    := G_RET_STS_SUCCESS;

    END IF;


    IF l_return_status =G_RET_STS_ERROR THEN

      x_return_status :=  G_RET_STS_ERROR;

    END IF;


    write_debug(G_PKG_Name,l_api_name,' API return status is  '||l_return_status);
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'  API return status is  '||l_return_status);



    IF p_commit THEN
      write_debug(G_PKG_Name,l_api_name,' Issue a commit ' );
      COMMIT;
    END IF;

    write_debug(G_PKG_Name,l_api_name,' End of API. ');
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' End of API. ');
EXCEPTION
  WHEN OTHERS THEN
    write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );

    x_return_status := G_RET_STS_UNEXP_ERROR;
    x_return_msg    := G_PKG_Name||'.'||l_api_name||'  - '||SubStr(SQLERRM,1,500);
   	RETURN;

END Process_Child_Value_Set;




PROCEDURE Delete_Processed_Value_Sets(  p_set_process_id   IN          NUMBER,
                                        x_return_status    OUT NOCOPY  VARCHAR2,
                                        x_return_msg       OUT NOCOPY  VARCHAR2)

IS

  l_api_name       VARCHAR2(100) := 'Delete_Processed_Value_Sets';

BEGIN

  write_debug(G_PKG_Name,l_api_name,'Start of API. ');
  --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'Start of API. ');

  DELETE FROM ego_flex_value_set_intf
  WHERE process_status = G_SUCCESS_RECORD
    AND (p_set_process_id IS NULL
          OR set_process_id =  p_set_process_id);

  write_debug(G_PKG_Name,l_api_name,'Deleted data from value Set Table ');
  --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'Deleted data from value Set Table ');

  DELETE FROM ego_flex_value_intf
  WHERE process_status = G_SUCCESS_RECORD
    AND (p_set_process_id IS NULL
          OR set_process_id =  p_set_process_id);

  write_debug(G_PKG_Name,l_api_name,' Deleted data from Value Table');
  --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' Deleted data from Value Table');

  DELETE FROM ego_flex_value_tl_intf
  WHERE process_status = G_SUCCESS_RECORD
    AND (p_set_process_id IS NULL
          OR set_process_id =  p_set_process_id);



  -- Set return status finally.
  IF x_return_status IS NULL
  THEN
    x_return_status    := G_RET_STS_SUCCESS;
  END IF;


  write_debug(G_PKG_Name,l_api_name,'End of Delete_Processed_Value_Sets');
  --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||'End of Delete_Processed_Value_Sets');




EXCEPTION
  WHEN OTHERS THEN
    write_debug(G_PKG_Name,l_api_name,' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
    --Dbms_Output.put_line(G_PKG_Name||'.'||l_api_name||' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
    x_return_status := G_RET_STS_UNEXP_ERROR;
    x_return_msg := 'ego_vs_bulkload_pvt.Delete_Processed_Value_Sets - '||SQLERRM;
   	RETURN;
END Delete_Processed_Value_Sets;


END ego_vs_bulkload_pvt;

/
