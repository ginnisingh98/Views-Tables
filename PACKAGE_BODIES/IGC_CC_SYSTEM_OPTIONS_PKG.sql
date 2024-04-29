--------------------------------------------------------
--  DDL for Package Body IGC_CC_SYSTEM_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_SYSTEM_OPTIONS_PKG" AS
/*$Header: IGCSYSPB.pls 120.0.12000000.1 2007/10/25 04:56:08 mbremkum noship $*/

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_SYSTEM_OPTIONS_PKG';

  -- The flag determines whether to print debug information or not.
  g_debug_flag        VARCHAR2(1) := 'N' ;

 -- Variables for ATG Central Logging

 l_debug_level number := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
 l_state_level number := FND_LOG.LEVEL_STATEMENT;
 l_proc_level  number := FND_LOG.LEVEL_PROCEDURE;
 l_event_level number := FND_LOG.LEVEL_EVENT;
 l_excep_level number := FND_LOG.LEVEL_EXCEPTION;
 l_error_level number := FND_LOG.LEVEL_ERROR;
 l_unexp_level number := FND_LOG.LEVEL_UNEXPECTED;
 l_path VARCHAR2(255) := 'IGC.PLSQL.IGCSYSPB.IGC_CC_SYSTEM_OPTIONS_PKG';

/*=======================================================================+
 |                       PROCEDURE Insert_Row                            |
 +=======================================================================*/
PROCEDURE Insert_Row
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_row_id                    IN OUT NOCOPY VARCHAR2,
  p_org_id                                  NUMBER,
  p_cc_num_method                           VARCHAR2,
  p_cc_num_datatype                         VARCHAR2,
  p_cc_next_num                             NUMBER,
  p_cc_prefix                               VARCHAR2,
  p_default_rate_type                       VARCHAR2,
  p_enforce_vendor_hold_flag                VARCHAR2,
  p_last_update_date                        DATE,
  p_last_updated_by                         NUMBER,
  p_last_update_login                       NUMBER,
  p_created_by                              NUMBER,
  p_creation_date                           DATE
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Insert_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  CURSOR cur_sys_options IS
  SELECT ROWID
  FROM   IGC_CC_SYSTEM_OPTIONS_ALL
  WHERE  org_id = p_org_id;

BEGIN

  SAVEPOINT Insert_Row_Pvt;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO IGC_CC_SYSTEM_OPTIONS_ALL
   (
     org_id,
     cc_num_method,
     cc_num_datatype,
     cc_next_num,
     cc_prefix,
     default_rate_type,
     enforce_vendor_hold_flag,
     last_update_date,
     last_updated_by,
     last_update_login,
     creation_date,
     created_by
   )
  VALUES
   (
      p_org_id,
      p_cc_num_method,
      p_cc_num_datatype,
      p_cc_next_num,
      p_cc_prefix,
      p_default_rate_type,
      p_enforce_vendor_hold_flag,
      p_last_update_date,
      p_last_updated_by,
      p_last_update_login,
      p_creation_date,
      p_created_by
   );

  OPEN cur_sys_options;
  FETCH cur_sys_options INTO p_row_id;
  IF (cur_sys_options%NOTFOUND) THEN
    CLOSE cur_sys_options;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE cur_sys_options;


  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Insert_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Insert_Row;


/*==========================================================================+
 |                       PROCEDURE Lock_Row                                 |
 +==========================================================================*/
PROCEDURE Lock_Row
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_row_id                    IN OUT NOCOPY VARCHAR2,
  p_org_id                                  NUMBER,
  p_cc_num_method                           VARCHAR2,
  p_cc_num_datatype                         VARCHAR2,
  p_cc_next_num                             NUMBER,
  p_cc_prefix                               VARCHAR2,
  p_default_rate_type                       VARCHAR2,
  p_enforce_vendor_hold_flag                VARCHAR2,
  p_row_locked                OUT NOCOPY    VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Lock_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  Counter NUMBER;

  CURSOR cur_sys_options IS
  SELECT *
  FROM   IGC_CC_SYSTEM_OPTIONS_ALL
  WHERE  ROWID = p_row_id
  FOR UPDATE NOWAIT;

  Recinfo   cur_sys_options%ROWTYPE;

BEGIN

  SAVEPOINT Lock_Row_Pvt;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  p_row_locked    := FND_API.G_TRUE;

  OPEN cur_sys_options;

  FETCH cur_sys_options INTO Recinfo;
  IF (cur_sys_options%NOTFOUND) THEN
    CLOSE cur_sys_options;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE cur_sys_options;

  IF (          (       (Recinfo.org_id = p_org_id)
                     OR (       (Recinfo.org_id IS NULL)
                            AND (p_org_id IS NULL)))
            AND (       (Recinfo.cc_num_method = p_cc_num_method)
                     OR (       (Recinfo.cc_num_method IS NULL)
                            AND (p_cc_num_method IS NULL)))
            AND (       (Recinfo.cc_num_datatype = p_cc_num_datatype)
                     OR (       (Recinfo.cc_num_datatype IS NULL)
                            AND (p_cc_num_datatype IS NULL)))
            AND (       (Recinfo.cc_next_num = p_cc_next_num)
                     OR (       (Recinfo.cc_next_num IS NULL)
                            AND (p_cc_next_num IS NULL)))
            AND (       (Recinfo.cc_prefix = p_cc_prefix)
                     OR (       (Recinfo.cc_prefix IS NULL)
                            AND (p_cc_prefix IS NULL)))
            AND (       (Recinfo.default_rate_type = p_default_rate_type)
                     OR (       (Recinfo.default_rate_type IS NULL)
                            AND (p_default_rate_type IS NULL)))
            AND (       (Recinfo.enforce_vendor_hold_flag = p_enforce_vendor_hold_flag)
                     OR (       (Recinfo.enforce_vendor_hold_flag IS NULL)
                            AND (p_enforce_vendor_hold_flag IS NULL)))
      ) THEN
    Null;
  ELSE
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN APP_EXCEPTION.RECORD_LOCK_EXCEPTION THEN

    ROLLBACK TO Lock_Row_Pvt;
    p_row_locked := FND_API.G_FALSE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Lock_Row_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Lock_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Lock_Row;


/*==========================================================================+
 |                       PROCEDURE Update_Row                               |
 +==========================================================================*/
PROCEDURE Update_Row
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_row_id                    IN OUT NOCOPY VARCHAR2,
  p_org_id                                  NUMBER,
  p_cc_num_method                           VARCHAR2,
  p_cc_num_datatype                         VARCHAR2,
  p_cc_next_num                             NUMBER,
  p_cc_prefix                               VARCHAR2,
  p_default_rate_type                       VARCHAR2,
  p_enforce_vendor_hold_flag                VARCHAR2,
  p_last_update_date                        DATE,
  p_last_updated_by                         NUMBER,
  p_last_update_login                       NUMBER
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Update_Row';
  l_api_version         CONSTANT NUMBER         :=  1.0;

BEGIN

  SAVEPOINT Update_Row_Pvt;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  UPDATE IGC_CC_SYSTEM_OPTIONS_ALL
  SET
    org_id                    = p_org_id,
    cc_num_method             = p_cc_num_method,
    cc_num_datatype           = p_cc_num_datatype,
    cc_next_num               = p_cc_next_num,
    cc_prefix                 = p_cc_prefix,
    default_rate_type         = p_default_rate_type,
    enforce_vendor_hold_flag  = p_enforce_vendor_hold_flag,
    last_update_date          = p_last_update_date,
    last_updated_by           = p_last_updated_by,
    last_update_login         = p_last_update_login
  WHERE ROWID = p_row_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Update_Row_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Update_Row;
/* ----------------------------------------------------------------------- */

/*==========================================================================+
 |                       PROCEDURE Delete_Row                               |
 +==========================================================================*/
PROCEDURE Delete_Row
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_row_id                    IN            VARCHAR2
)
IS

  l_api_name                CONSTANT VARCHAR2(30)   := 'Delete_Row';
  l_api_version             CONSTANT NUMBER         :=  1.0;

BEGIN

  SAVEPOINT Delete_Row_Pvt;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Deleting the record in igc_cc_system_options_all.

  DELETE FROM IGC_CC_SYSTEM_OPTIONS_ALL
  WHERE  ROWID = p_row_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END IF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Delete_Row_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Delete_Row_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Delete_Row;
/* ----------------------------------------------------------------------- */

/*==========================================================================+
 |                       PROCEDURE Check_Unique                             |
 +==========================================================================*/
PROCEDURE Check_Unique
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_row_id                    IN OUT NOCOPY VARCHAR2,
  p_org_id		                              NUMBER,
  p_return_value              IN OUT NOCOPY VARCHAR2
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Check_Unique';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  l_tmp                 VARCHAR2(1);

  CURSOR c IS
    SELECT '1'
    FROM   igc_cc_system_options_all
    WHERE  org_id = p_org_id
      AND  (
             p_row_id IS NULL
             OR
             rowid <> p_row_id
           );

BEGIN

  SAVEPOINT Check_Unique_Pvt ;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Checking the igc_cc_number_methods table for uniqueness.
  OPEN c;
  FETCH c INTO l_tmp;

  -- p_Return_Value specifies whether unique value exists or not.
  IF l_tmp IS NULL THEN
    p_Return_Value := 'FALSE';
  ELSE
    p_Return_Value := 'TRUE';
  END IF;

  CLOSE c;

  IF FND_API.To_Boolean ( p_commit ) THEN
    COMMIT WORK;
  END iF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Check_Unique_Pvt ;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Check_Unique_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

  WHEN OTHERS THEN

    ROLLBACK TO Check_Unique_Pvt ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Check_Unique;



/*==========================================================================+
 |                       PROCEDURE Create_Auto_CC_Num                       |
 +==========================================================================*/

PROCEDURE Create_Auto_CC_Num
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_org_id                    IN            igc_cc_headers.org_id%TYPE,
  p_sob_id                    IN            igc_cc_headers.set_of_books_id%TYPE,
  x_cc_num                    OUT NOCOPY    igc_cc_headers.cc_num%TYPE
) IS
PRAGMA AUTONOMOUS_TRANSACTION; -- Added for bug 3329666

  l_api_name            CONSTANT VARCHAR2(30)   := 'Create_Auto_CC_Num';
  l_api_version         CONSTANT NUMBER         :=  1.0;

  -- mh: define variables
  x_cc_prefix            igc_cc_system_options_all.cc_prefix%TYPE;
  x_cc_num_exists        NUMBER;
  x_po_num_exists        NUMBER;
  -- sb: x_cc_next_num should be a number
  --  x_cc_next_num          igc_cc_headers.cc_num%TYPE;
  x_cc_next_num          igc_cc_system_options_all.cc_next_num%TYPE;
  -- sb: end

  -- mh: define cursor to get cc_prefix and cc_num from igc_cc_number_methods
  CURSOR c_cc_num(l_org_id NUMBER) IS
  SELECT cc_prefix, cc_next_num
  FROM   igc_cc_system_options_all
  WHERE  org_id = l_org_id
  FOR UPDATE NOWAIT; -- Added for bug 3329666

  -- sb: define exceptions
  e_no_number_setup EXCEPTION;
  e_no_prefix_setup EXCEPTION;
  -- sb: end

  l_cbc_po_enable     VARCHAR2(1);
  e_row_locked        EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_row_locked, -54);

BEGIN

--  SAVEPOINT Create_Auto_CC_Num_Pvt;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- sb: x_cc_num is not a number, so set to null not 0
  -- x_cc_num        := 0;
  x_cc_num := '';
  -- sb: end
  x_cc_num_exists := 0;
  x_po_num_exists := 0;

-- ---------------------------------------------------------------
-- mh start 1: get cc_prefix and cc_num from numbering table
--             loop
--               concatenate to get the new cc number
--               check if this number already exists in CC or PO
--               if yes increase cc_num by 1, check again
--               if no, update igc_cc_number_methods.cc_num to cc_num+1
--             end loop
--             return the new cc number
-- ---------------------------------------------------------------
   BEGIN
      OPEN c_cc_num(p_org_id);
      FETCH c_cc_num INTO x_cc_prefix, x_cc_next_num;

      IF (c_cc_num%NOTFOUND) THEN
         CLOSE c_cc_num;
         RAISE e_no_number_setup;
      END IF;
   EXCEPTION -- Added for bug 3329666
   WHEN  e_row_locked
   THEN
          fnd_message.set_name('IGC','IGC_CC_NUM_LOCK');
          fnd_msg_pub.add;
          IF( FND_LOG.TEST(FND_LOG.LEVEL_ERROR,
              'IGC.PLSQL.Igc_Cc_Numbers_Pkg.Create_Auto_CC_Num.Lock1'))
          THEN
             if (l_error_level >= l_debug_level) then
              FND_LOG.MESSAGE(l_error_level,
                              'IGC.PLSQL.Igc_Cc_Numbers_Pkg.Create_Auto_CC_Num.Lock1'
                               , FALSE);
             end if;
          END IF;
          ROLLBACK;
          fnd_msg_pub.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
          RETURN;
   END ;

   -- sb: need to close the cursor
   IF (c_cc_num%ISOPEN) THEN
      CLOSE c_cc_num;
   END IF;

/* Commented we are no longer using cc_prefix. But left it in
here just in case we change our minds again.
Bidisha S, 16 Sept 2002
   -- sb: need to add check to ensure prefix exists
   IF (x_cc_prefix is null) THEN
      -- Bidisha S, raise the exception only if cbc po is enabled
      SELECT Nvl(cbc_po_enable, 'N')
      INTO   l_cbc_po_enable
      FROM   igc_cc_bc_enable
      WHERE  set_of_books_id = p_sob_id;

      IF l_cbc_po_enable = 'Y'
      THEN
          RAISE e_no_prefix_setup;
      END IF;
   END IF;
   -- sb: end

*/

   -- keep looping until a number that is unique across both CC and
   -- PO is generated

   LOOP

      -- create the cc number
      -- also, need to do a to_char on x_cc_next_num

      IF (x_cc_prefix IS NOT NULL) THEN
          x_cc_num := x_cc_prefix||to_char(x_cc_next_num);
      ELSE
         x_cc_num := x_cc_next_num;
      END IF;


      -- validate number is unique across both CC and PO
      SELECT count(*)
      INTO   x_cc_num_exists
      FROM   igc_cc_headers
      WHERE  cc_num = x_cc_num;

      SELECT count(*)
      INTO   x_po_num_exists
      FROM   po_headers
      WHERE  segment1 = x_cc_num;

      IF ((x_cc_num_exists > 0) OR (x_po_num_exists > 0)) THEN
         -- sb: logic is wrong here.  It should be
         -- incrementing x_cc_next_num NOT x_cc_num

         --x_cc_num := x_cc_num + 1;
           x_cc_next_num := x_cc_next_num + 1;
         -- sb: end

      ELSE
         -- ---------------------------------------------------------------
         -- Update the numbering scheme first for the org_id given
         -- ---------------------------------------------------------------
         UPDATE igc_cc_system_options_all
         SET    cc_next_num = x_cc_next_num + 1
         WHERE  org_id = p_org_id;
         -- ---------------------------------------------------------------
         -- Make sure that ONLY one row has been updated.
         -- ---------------------------------------------------------------
         IF (SQL%ROWCOUNT <> 1) THEN

            ROLLBACK;
            -- sb: x_cc_num is not a number, so set to null not 0
            --x_cc_num := 0;
            x_cc_num := '';
            -- sb: end

         END IF;
         -- exit from loop
         EXIT;
      END IF;
   END LOOP;

-- ---------------------------------------------------------------
-- mh end 1
-- ---------------------------------------------------------------
-- ----------------------------------------------------------------
-- If the CC Number was generated successfully then commit if
-- the caller has indicated to do so.
-- ----------------------------------------------------------------

  COMMIT;

  RETURN;

EXCEPTION

  -- sb: define the exceptions
  WHEN e_no_number_setup THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_message.set_name('IGC','IGC_NO_NUMBERING_SETUP');
     fnd_msg_pub.add;
     fnd_msg_pub.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
     ROLLBACK; -- Added for bug 3329666

  WHEN e_no_prefix_setup THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     fnd_message.set_name('IGC','IGC_CC_PREFIX_REQD');
     fnd_msg_pub.add;
     fnd_msg_pub.count_and_get(p_count => x_msg_count,
                               p_data  => x_msg_data);
  -- sb: end
     ROLLBACK; -- Added for bug 3329666

  WHEN FND_API.G_EXC_ERROR THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );
    ROLLBACK; -- Added for bug 3329666

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

    ROLLBACK; -- Added for bug 3329666

  WHEN OTHERS THEN

    ROLLBACK ;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Create_Auto_CC_Num;


/*==========================================================================+
 |                       PROCEDURE  Validate_Numeric_CC_Num                   |
 +==========================================================================*/
PROCEDURE Validate_Numeric_CC_Num
(
  p_api_version               IN            NUMBER,
  p_init_msg_list             IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                    IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level          IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status             OUT NOCOPY    VARCHAR2,
  x_msg_count                 OUT NOCOPY    NUMBER,
  x_msg_data                  OUT NOCOPY    VARCHAR2,
  p_cc_num                    IN            igc_cc_headers.cc_num%TYPE
)
IS

  l_api_name            CONSTANT VARCHAR2(30)   := 'Validate_Numeric_CC_Num';
  l_api_version         CONSTANT NUMBER         :=  1.0;
  l_temp_num            NUMBER;

BEGIN

  SAVEPOINT Validate_Numeric_CC_Num_Pvt;

  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- --------------------------------------------------------------------
-- Create seperate block for exception to be caught seperately
-- --------------------------------------------------------------------
  BEGIN
     l_temp_num := TO_NUMBER (p_cc_num);

     EXCEPTION

        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
  END;

  IF FND_API.To_Boolean ( p_commit ) THEN
     COMMIT WORK;
  END IF;

  RETURN;

EXCEPTION
   WHEN OTHERS THEN
    ROLLBACK TO Validate_Numeric_CC_Num_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME,
                                l_api_name);
    END if;

    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END Validate_Numeric_CC_Num;
/* ----------------------------------------------------------------------- */

END IGC_CC_SYSTEM_OPTIONS_PKG;

/
