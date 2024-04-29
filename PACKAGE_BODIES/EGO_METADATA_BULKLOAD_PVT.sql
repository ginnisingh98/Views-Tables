--------------------------------------------------------
--  DDL for Package Body EGO_METADATA_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_METADATA_BULKLOAD_PVT" AS
/* $Header: EGOVMDBB.pls 120.0.12010000.6 2010/06/11 13:53:29 kjonnala noship $ */

/********************************************************************************
 --   Procedure     : SetGlobals
 --   Purpose       : Sets the WHO columns for the concurrent program.
 --   IN Parameters :
 --                   None
 --   OUT Parameters:
 --                   None
********************************************************************************/

PROCEDURE SetGlobals IS
BEGIN
  G_REQUEST_ID              := FND_GLOBAL.CONC_REQUEST_ID;
  G_PROGRAM_APPLICATION_ID   := FND_GLOBAL.PROG_APPL_ID;
  G_PROGRAM_ID               := FND_GLOBAL.CONC_PROGRAM_ID;
  G_USER_NAME               := FND_GLOBAL.USER_NAME;
  G_USER_ID                 := FND_GLOBAL.USER_ID;
  G_LOGIN_ID                := FND_GLOBAL.LOGIN_ID;
  G_DEBUG                   := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
END;


/********************************************************************************
 --   Procedure     : write_debug
 --   Purpose       : Writes the debug messages into concurrent program log
 --   IN Parameters :
 --                   p_msg - string to be written onto concurrent program log
 --   OUT Parameters:
 --                   None
********************************************************************************/

PROCEDURE Write_Debug (p_msg  IN  VARCHAR2) IS
 l_err_msg VARCHAR2(240);
BEGIN
  -- If Profile set to TRUE --
  IF (G_DEBUG = 1) THEN
    FND_FILE.put_line(FND_FILE.LOG, p_msg);
  END IF;

  EXCEPTION
   WHEN OTHERS THEN
    l_err_msg := SUBSTRB(SQLERRM, 1,240);
    FND_FILE.put_line(FND_FILE.LOG, 'LOGGING SQL ERROR => '||l_err_msg);
END Write_Debug;



/***********************************************************************************
 --   Procedure     : delete_processed_metadata
 --   Purpose       : Delete successfully processed records (process_status=7)
 --                   from the interface tables.
 --   IN Parameters :
 --                   p_set_process_id - set_process_id for the batch, can be null
 --   OUT Parameters:
 --                   x_return_status  - return status of the procedure
 --                                      'S' - success, 'E' - error
 --                                      'U' - unexpected error
*************************************************************************************/
PROCEDURE delete_processed_metadata(p_import_vs      IN VARCHAR2,
                                    p_import_ag      IN VARCHAR2,
                                    p_import_icc     IN VARCHAR2,
                                    p_set_process_id IN NUMBER,
                                    x_return_status  OUT NOCOPY VARCHAR2,
                                    x_return_msg     OUT NOCOPY VARCHAR2)
IS
    l_proc_name VARCHAR2(30) :=  'delete_processed_metadata';
BEGIN
    Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entered delete_processed_metadata() ');

    x_return_status :=G_RET_STS_SUCCESS;

     /* Delete Successfully processed records (process_status=7) for each of the entities */
      IF (p_import_vs='Y') THEN

        Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Call EGO_VS_BULKLOAD_PVT.delete_processed_value_sets()');
        EGO_VS_BULKLOAD_PVT.delete_processed_value_sets(p_set_process_id, x_return_status,x_return_msg);
        Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Returned from EGO_VS_BULKLOAD_PVT.delete_processed_value_sets() with return_status: '||x_return_status);

      END IF;

    IF Nvl(x_return_status,G_RET_STS_SUCCESS) <> G_RET_STS_UNEXP_ERROR THEN
      IF (p_import_ag='Y') THEN

        Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Call EGO_AG_BULKLOAD_PVT.delete_processed_attr_groups() ');
        EGO_AG_BULKLOAD_PVT.delete_processed_attr_groups(p_set_process_id, x_return_status,x_return_msg);
       Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Returned from EGO_AG_BULKLOAD_PVT.delete_processed_attr_groups() with return_status: '||x_return_status);

      END IF;
    END IF;

    IF Nvl(x_return_status,G_RET_STS_SUCCESS) <> G_RET_STS_UNEXP_ERROR THEN
     IF (p_import_icc='Y') THEN

        Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Call EGO_ICC_BULKLOAD_PVT.delete_processed_icc() ');
        EGO_ICC_BULKLOAD_PVT.delete_processed_icc(p_set_process_id, x_return_status,x_return_msg);
        Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Returned from EGO_ICC_BULKLOAD_PVT.delete_processed_icc() with return_status: '||x_return_status);

        EGO_TA_BULKLOAD_PVT.delete_processed_trans_attrs(p_set_process_id, x_return_status,x_return_msg);
        Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Returned from  EGO_TA_BULKLOAD_PVT.delete_processed_trans_attrs() with return_status: '||x_return_status);

        EGO_PAGES_BULKLOAD_PVT.delete_processed_pages(p_set_process_id, x_return_status,x_return_msg);
        Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Returned from EGO_PAGES_BULKLOAD_PVT.delete_processed_pages() with return_status: '||x_return_status);

        EGO_FUNCTIONS_BULKLOAD_PVT.delete_processed_functions(p_set_process_id, x_return_status,x_return_msg);
        Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Returned from EGO_FUNCTIONS_BULKLOAD_PVT.delete_processed_functions() with return_status: '||x_return_status);

     END IF;
   END IF;


    IF Nvl(x_return_status,G_RET_STS_SUCCESS) <> G_RET_STS_UNEXP_ERROR THEN
    Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Commit deleted data ');
    /* if all records got successfully deleted then commit*/
        COMMIT;
    END IF;

   Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exit from delete_processed_metadata()');
EXCEPTION
WHEN OTHERS THEN
         x_return_status := G_RET_STS_UNEXP_ERROR;
         x_return_msg    := G_PKG_NAME||'.'||l_proc_name||'->'||'Exception occurred ->'||SQLERRM;
END delete_processed_metadata;


/*************************************************************************************************
 --   Procedure     :  import_metadata
 --   Purpose       :  Main method called by the concurrent program EGOIMDCP executable
 --                    Co-ordinates the import of all metadata entities.
 --   IN Parameters :
 --                    p_import_vs  - indicates whether valuesets should be imported or not
 --                    p_import_ag  - indicates whether attribute groups should be imported or not
 --                    p_import_icc - indicates whether Item Catalog Categories should be imported
 --                                   or not
 --                    p_set_process_id - batch_id/set_processed_id for grouping the records to be
 --                                       processed together in a batch.
 --                    p_del_proc_recs  - indicates whether successfully imported records
 --                                      (process_status=7) should be deleted or not
 --                                      from the interface tables.
 --
 --   OUT Parameters:
 --                    errbuf       - error msg to be returned back to concurrent program
 --                                   incase of any failure.
 --                    retcode      - return code to be passed to concurrent program
 --                                   0 - SUCCESS, 1- WARNING , 2- ERROR
 **************************************************************************************************/

PROCEDURE import_metadata( errbuf  OUT  NOCOPY VARCHAR2,
                           retcode OUT  NOCOPY NUMBER,
                           p_import_vs      IN VARCHAR2,
                           p_import_ag      IN VARCHAR2,
                           p_import_icc     IN VARCHAR2,
                           p_set_process_id IN NUMBER,
                           p_del_proc_recs  IN VARCHAR2
                           )
IS
    l_proc_name VARCHAR2(30) :=  'import_metadata';

    l_token_table            ERROR_HANDLER.Token_Tbl_Type;

    l_error_message_name     VARCHAR2(240);
    l_error_row_identifier   NUMBER;

    l_return_status           VARCHAR2(1);
    l_return_msg              VARCHAR2(2000);

BEGIN

   retcode := G_CONC_RETCODE_SUCCESS; /* return code for concurrent program set to success by default*/
   l_return_status := G_RET_STS_SUCCESS; /*return code of each api set to success by default */

   /* Dump information on parmeters passed into the concurrent log file irrespective of whether debug is turned on or not */
   FND_FILE.put_line (FND_FILE.log, ' ');
   FND_FILE.put_line (FND_FILE.log, 'EGO Import Metadata');
   FND_FILE.put_line (FND_FILE.log, '--------------------------------------------------------------------------------');
   FND_FILE.put_line (FND_FILE.log, 'Argument 1 (Import Value Sets)               = '||p_import_vs);
   FND_FILE.put_line (FND_FILE.log, 'Argument 2 (Import Attribute Groups)         = '||p_import_ag);
   FND_FILE.put_line (FND_FILE.log, 'Argument 3 (Import Item Catalog Cateogories) = '||p_import_icc);
   FND_FILE.put_line (FND_FILE.log, 'Argument 4 (Batch Id (Null for All) )        = '||p_set_process_id);
   FND_FILE.put_line (FND_FILE.log, 'Argument 5 (Delete Processed Records)        = '||p_del_proc_recs);
   FND_FILE.put_line (FND_FILE.log, '--------------------------------------------------------------------------------');
   FND_FILE.put_line (FND_FILE.log, ' ');

   Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Entered Import Metadata (EGOIMDCP) concurrent program');
                     --======================--
                     -- WHO COLUMNS SET-UP    --
                     --======================--
      SetGlobals();
      FND_FILE.put_line (FND_FILE.log, 'Profile INV Debug Trace  = '||G_DEBUG);
      IF (G_DEBUG <= 0) THEN
      FND_FILE.put_line (FND_FILE.log, 'Profile INV Debug Trace is not set, so debug messages will not be printed.');
      END IF;
      Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Setup Global variables');

                     --======================--
                     -- ERROR_HANDLER SET-UP --
                     --======================--

      ERROR_HANDLER.Initialize();
      Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Initialized Error Handler');

     /* Based on Concurrent Program's parameters, call the individual entity's import APIs. */

          /* Process Value Sets*/
          IF (p_import_vs='Y') THEN
              Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Call ego_vs_bulkload_pvt.import_value_set_intf()');
              ego_vs_bulkload_pvt.import_value_set_intf(p_set_process_id, l_return_status,l_return_msg);
              Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Returned back from ego_vs_bulkload_pvt.import_value_set_intf() with return status: '||l_return_status);
          END IF;

      IF Nvl(l_return_status,G_RET_STS_SUCCESS) <> G_RET_STS_UNEXP_ERROR THEN /* If VS got imported without any unexpected errors or import_vs = 'N'*/
          /* Process Attribute Groups*/
          IF (p_import_ag='Y') THEN
              Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Call ego_ag_bulkload_pvt.import_ag_intf()');
              ego_ag_bulkload_pvt.import_ag_intf(p_set_process_id, l_return_status,l_return_msg);
              Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Returned back from ego_ag_bulkload_pvt.import_ag_intf() with return status: '||l_return_status);
          END IF;
      END IF; /* l_return_status <> G_RET_STS_UNEXP_ERROR */

      IF Nvl(l_return_status,G_RET_STS_SUCCESS) <> G_RET_STS_UNEXP_ERROR THEN
      /* If VS,AG got imported without any unexpected errors or (import_vs = 'N' and import_ag='N')*/
          /* Process Item Catalog Categories*/
          IF (p_import_icc='Y') THEN
              Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Call ego_icc_bulkload_pvt.import_icc_intf()');
              ego_icc_bulkload_pvt.import_icc_intf(p_set_process_id, l_return_status,l_return_msg);
             Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Returned back from ego_icc_bulkload_pvt.import_icc_intf() with return status: '||l_return_status);
          END IF;
      END IF; /* l_return_status <> G_RET_STS_UNEXP_ERROR */

      IF Nvl(l_return_status,G_RET_STS_SUCCESS) = G_RET_STS_UNEXP_ERROR THEN
      /* if VS or AG or ICC import failed with unexpected errors*/
         FND_FILE.put_line (FND_FILE.log, G_PKG_NAME||'.'||l_proc_name||'->'||'Exceptions occured during Import Metadata program');
         FND_FILE.put_line (FND_FILE.log, l_return_msg);
         ERRBUF  := l_return_msg;
         RETCODE := G_CONC_RETCODE_ERROR;
      END IF;


      -------------------------------------------------------------------
      -- Finally, we log any errors that we've accumulated throughout  --
      -- the processing of our concurrent program. These errors will   --
      -- logged both into mtl_interface_errors table and               --
      -- concurrent program log file.                                  --
      -------------------------------------------------------------------
     Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Calling Log_Error Procedure');
      ERROR_HANDLER.Log_Error(
        p_write_err_to_inttable         => 'Y'
       ,p_write_err_to_conclog          => 'Y'
       );


      IF Nvl(l_return_status,G_RET_STS_SUCCESS) <> G_RET_STS_UNEXP_ERROR THEN
      /* If VS,AG,ICC got imported without any unexpected errors
          or (import_vs = 'N' and import_ag='N' and import_icc='N')*/
          /* Delete successfully processed records if Delete Processed Records parameter is set*/
          IF (p_del_proc_recs = 'Y') THEN
          Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||' inside If condition for p_del_proc_recs=Y');

            IF (p_import_vs='Y' OR p_import_ag='Y' OR p_import_icc='Y') THEN
              Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Call delete_processed_metadata() ');
                delete_processed_metadata(p_import_vs, p_import_ag,p_import_icc,p_set_process_id, l_return_status,l_return_msg);
              Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'returned from delete_processed_metadata() with return status: '||l_return_status);

                IF Nvl(l_return_status,G_RET_STS_SUCCESS) =G_RET_STS_UNEXP_ERROR THEN
                    FND_FILE.put_line (FND_FILE.log, G_PKG_NAME||'.'||l_proc_name||'->'||'Exceptions occured during Import Metadata program');
                    FND_FILE.put_line (FND_FILE.log, l_return_msg);
                    ERRBUF  := l_return_msg;
                    RETCODE := G_CONC_RETCODE_ERROR;
                END IF; /* end of if l_return_status =G_RET_STS_UNEXP_ERROR*/

            END IF; /* end of if (p_import_vs='Y' OR p_import_ag='Y' OR p_import_icc='Y')*/
          END IF;   /*end of if p_del_proc_recs = 'Y' */
      END IF;       /* end of if l_return_status <> G_RET_STS_UNEXP_ERROR */


    Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Exit Import Metadata (EGOIMDCP) concurrent program');

EXCEPTION
WHEN OTHERS THEN
         FND_FILE.put_line (FND_FILE.log, G_PKG_NAME||'.'||l_proc_name||'->'||'Exceptions occured during Import Metadata program');
         FND_FILE.put_line (FND_FILE.log, SQLERRM);
         ERRBUF  := SQLERRM;
         RETCODE := G_CONC_RETCODE_ERROR;
END import_metadata;


PROCEDURE Get_Lock_Info (   p_object_name       IN  VARCHAR2
                           ,p_pk1_value         IN  VARCHAR2 DEFAULT NULL
                           ,p_pk2_value         IN  VARCHAR2 DEFAULT NULL
                           ,p_pk3_value         IN  VARCHAR2 DEFAULT NULL
                           ,p_pk4_value         IN  VARCHAR2 DEFAULT NULL
                           ,p_pk5_value         IN  VARCHAR2 DEFAULT NULL
                           ,x_locking_party_id  OUT NOCOPY   NUMBER
                           ,x_lock_flag         OUT NOCOPY   VARCHAR2
                           ,x_return_msg        OUT NOCOPY   VARCHAR2
                           ,x_return_status     OUT NOCOPY   VARCHAR2
                       )
IS
  l_proc_name       VARCHAR2(30) := 'Get_Lock_Info';
  l_token_table     ERROR_HANDLER.Token_Tbl_Type;
  l_appl_name       VARCHAR2(3) := 'EGO';
  l_entity_code     VARCHAR2(30) := NULL ;
  l_table_name      VARCHAR2(30) := NULL ;


   CURSOR cur_get_lock_info
   IS
   SELECT a.*
   FROM   EGO_OBJECT_LOCK a
   WHERE  a.object_name = p_object_name
   AND    NVL(a.pk1_value, chr(0)) = NVL(p_pk1_value, chr(0))
   AND    NVL(a.pk2_value, chr(0)) = NVL(p_pk2_value, chr(0))
   AND    NVL(a.pk3_value, chr(0)) = NVL(p_pk3_value, chr(0))
   AND    NVL(a.pk4_value, chr(0)) = NVL(p_pk4_value, chr(0))
   AND    NVL(a.pk5_value, chr(0)) = NVL(p_pk5_value, chr(0))
   AND    a.lock_id = (
                             SELECT   max(a.lock_id)
                               FROM   EGO_OBJECT_LOCK a
                               WHERE  a.object_name = p_object_name
                               AND    NVL(a.pk1_value, chr(0)) = NVL(p_pk1_value, chr(0))
                               AND    NVL(a.pk2_value, chr(0)) = NVL(p_pk2_value, chr(0))
                               AND    NVL(a.pk3_value, chr(0)) = NVL(p_pk3_value, chr(0))
                               AND    NVL(a.pk4_value, chr(0)) = NVL(p_pk4_value, chr(0))
                               AND    NVL(a.pk5_value, chr(0)) = NVL(p_pk5_value, chr(0))
                     )
                     ;




BEGIN
  Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Start');
  x_return_status := G_RET_STS_SUCCESS;




  IF p_object_name = G_VALUE_SET  THEN

      l_entity_code     := G_ENTITY_VS_VER;
      l_table_name      := G_ENTITY_VS_HEADER_TAB;

  ELSE

      l_entity_code     := G_ENTITY_ICC_VER;
      l_table_name      := G_ENTITY_ICC_HEADER_TAB;

  END IF;




  IF ( p_pk1_value IS NULL AND
      p_pk2_value IS NULL AND
      p_pk3_value IS NULL AND
      p_pk4_value IS NULL AND
      p_pk5_value IS NULL )
      OR p_object_name IS NULL OR length(trim(p_object_name)) = 0
      THEN

         x_return_status := G_RET_STS_ERROR;
         l_token_table(1).token_name := 'ENTITY';
         l_token_table(1).token_value :=  'LOCK';

         ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_REQ_COLMS_MISSING'
           ,p_application_id                => l_appl_name
           --,p_row_identifier                => transaction_id
           ,p_token_tbl                     => l_token_table
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => l_table_name
         );
         l_token_table.delete;
         RETURN;
  END IF;


  FOR rec_cur_get_lock_info IN cur_get_lock_info
  LOOP
    x_locking_party_id := rec_cur_get_lock_info.locking_party_id;
    x_lock_flag := rec_cur_get_lock_info.lock_flag;
    --x_lock_id   := rec_cur_get_lock_info.lock_id;
    EXIT;
  END LOOP;


  Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End');
EXCEPTION
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg    := G_PKG_NAME||'.'||l_proc_name||'->'||'Exception occurred ->'||SQLERRM;
END Get_Lock_Info;




PROCEDURE Lock_Unlock_Object  ( p_object_name   IN  VARCHAR2
                               ,p_pk1_value     IN  VARCHAR2 DEFAULT NULL
                               ,p_pk2_value     IN  VARCHAR2 DEFAULT NULL
                               ,p_pk3_value     IN  VARCHAR2 DEFAULT NULL
                               ,p_pk4_value     IN  VARCHAR2 DEFAULT NULL
                               ,p_pk5_value     IN  VARCHAR2 DEFAULT NULL
                               ,p_party_id      IN  NUMBER
                               ,p_lock_flag     IN  BOOLEAN
                               ,x_return_msg    OUT NOCOPY   VARCHAR2
                               ,x_return_status OUT NOCOPY   VARCHAR2
                          )
IS
  l_proc_name       VARCHAR2(30) := 'Lock_Unlock_Object';
  l_token_table     ERROR_HANDLER.Token_Tbl_Type;
  l_sysdate         DATE := SYSDATE;
  l_appl_name       VARCHAR2(3) := 'EGO';
  l_entity_code     VARCHAR2(30) := NULL ;
  l_table_name      VARCHAR2(30) := NULL ;

BEGIN
  Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'Start');
  x_return_status := G_RET_STS_SUCCESS;


  G_USER_ID := FND_GLOBAL.USER_ID;
  G_LOGIN_ID := FND_GLOBAL.LOGIN_ID;




  IF p_object_name = G_VALUE_SET  THEN

      l_entity_code     := G_ENTITY_VS_VER;
      l_table_name      := G_ENTITY_VS_HEADER_TAB;

  ELSE

      l_entity_code     := G_ENTITY_ICC_VER;
      l_table_name      := G_ENTITY_ICC_HEADER_TAB;

  END IF;





  IF ( p_pk1_value IS NULL AND
      p_pk2_value IS NULL AND
      p_pk3_value IS NULL AND
      p_pk4_value IS NULL AND
      p_pk5_value IS NULL )
      OR p_object_name IS NULL OR length(trim(p_object_name)) = 0
      THEN

         x_return_status := G_RET_STS_ERROR;
         l_token_table(1).token_name := 'ENTITY';
         l_token_table(1).token_value :=  'LOCK';

         ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_REQ_COLMS_MISSING'
           ,p_application_id                => l_appl_name
           --,p_row_identifier                => transaction_id
           ,p_token_tbl                     => l_token_table
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => l_table_name
         );
         l_token_table.delete;
         RETURN;
  END IF;



  IF p_lock_flag THEN
    ---
    --- Lock the object
    ---
           INSERT INTO  EGO_OBJECT_LOCK
                ( lock_id,
                  object_name,
                  pk1_value,
                  pk2_value,
                  pk3_value,
                  pk4_value,
                  pk5_value,
                  locking_party_id,
                  lock_flag,
                  created_by,
                  creation_date,
                  last_updated_by,
                  last_update_date,
                  last_update_login)
          VALUES   ( EGO_OBJECT_LOCK_S.NEXTVAL,
                     p_object_name,
                     p_pk1_value,
                     p_pk2_value,
                     p_pk3_value,
                     p_pk4_value,
                     p_pk5_value,
                     p_party_id,
                     'U',            --- unlocked record is inserted
                     G_USER_ID,
                     l_sysdate,
                     G_USER_ID,
                     l_sysdate,
                     G_LOGIN_ID);
  ELSE
    ---
    --- Unlock the object
    ---
    UPDATE EGO_OBJECT_LOCK l
    SET  l.lock_flag = 'U'
       , l.last_updated_by = g_user_id
       , l.last_update_date  = l_sysdate
       , l.last_update_login = g_login_id
    WHERE l.object_name = p_object_name
    AND    NVL(l.pk1_value, chr(0)) = NVL(p_pk1_value, chr(0))
    AND    NVL(l.pk2_value, chr(0)) = NVL(p_pk2_value, chr(0))
    AND    NVL(l.pk3_value, chr(0)) = NVL(p_pk3_value, chr(0))
    AND    NVL(l.pk4_value, chr(0)) = NVL(p_pk4_value, chr(0))
    AND    NVL(l.pk5_value, chr(0)) = NVL(p_pk5_value, chr(0))
    AND    l.lock_id = ( SELECT   max(a.lock_id)
                       FROM   EGO_OBJECT_LOCK a
                       WHERE  a.object_name = p_object_name
                       AND    NVL(a.pk1_value, chr(0)) = NVL(p_pk1_value, chr(0))
                       AND    NVL(a.pk2_value, chr(0)) = NVL(p_pk2_value, chr(0))
                       AND    NVL(a.pk3_value, chr(0)) = NVL(p_pk3_value, chr(0))
                       AND    NVL(a.pk4_value, chr(0)) = NVL(p_pk4_value, chr(0))
                       AND    NVL(a.pk5_value, chr(0)) = NVL(p_pk5_value, chr(0))
                     )
                     ;
  END IF;

  Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||'End');
EXCEPTION
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg    := G_PKG_NAME||'.'||l_proc_name||'->'||'Exception occurred ->'||SQLERRM;
END Lock_Unlock_Object;

/*************************************************************************************************
 --   Procedure     :  Get_Party_Name
 --   Purpose       :  Procedure which gets the party name given the party_id
 --   IN Parameters :
 --                    p_party_id - id of the party

 --   OUT Parameters:
 --                   p_party_name - name of the party
 **************************************************************************************************/

  PROCEDURE  Get_Party_Name ( p_party_id    IN          NUMBER,
                              x_party_name  OUT NOCOPY  VARCHAR2 )


  IS
      l_proc_name VARCHAR2(30) :='Get_Party_Name';
      l_Party_Name     VARCHAR2(100)  := NULL;
      l_api_name       VARCHAR2(100)  := 'Get_Party_Name';

  BEGIN

     Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||' Start of API ');


      -- Get Party_Name
      SELECT Party_Name
        INTO l_Party_Name
      FROM HZ_PARTIES
      WHERE party_Id= p_party_id;


      x_party_name := l_Party_Name;

      Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||' End of API G_Party_Name = '||l_Party_Name);

  EXCEPTION
      WHEN OTHERS THEN
	Write_Debug(G_PKG_NAME||'.'||l_proc_name||'->'||' In Exception of API. Error : '||SubStr(SQLERRM,1,500) );
            x_party_name  :=  NULL;
  END Get_Party_Name;


END EGO_METADATA_BULKLOAD_PVT;

/
