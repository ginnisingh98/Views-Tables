--------------------------------------------------------
--  DDL for Package Body AR_GTA_BATCH_NUMBER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_GTA_BATCH_NUMBER_UTIL" AS
  --$Header: ARGGBNUB.pls 120.0.12010000.3 2010/01/19 07:48:59 choli noship $
  --+=======================================================================+
  --|               Copyright (c) 1998 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     ARGBNUB.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|      This package is a collection of  the util procedure              |
  --|      or function for auto batch numbering.                            |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE    Create_Seq                                          |
  --|      PROCEDURE    Set_Nextval                                         |
  --|      FUNCTION     Next_Value                                          |
  --|      PROCEDURE    Drop_Seq                                            |
  --|      FUNCTION     Is_Number                                           |
  --|      FUNCTION     Verify_Next_Bacth_Number                            |
  --|      FUNCTION     Is_Exist                                            |
  --|      FUNCTION     Current_Value                                       |
  --|                                                                       |
  --| HISTORY                                                               |
  --|     20-APR-2005: Qiang Li  Created                                    |
  --|     19-Jan_2006: Qiang Li  Updated                                    |
  --|     19-Jun-2006: Qiang.Li  Fix bug 5291644                            |
  --|     27-Jun-2006: Qiang Li  Fix Bug 5291644                            |
  --+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Create_Seq                       Public
  --
  --  DESCRIPTION:
  --
  --      This procedure create a new sequence for a given operating unit
  --
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id for the new sequence
  --           p_next_value     the start value of the sequence
  --     Out:  x_return_status  the return value to indicate the status
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --           19-JAN-2006: qiang.li   Insert value into columns last_update_date
  --                                   last_updated_by,creation_date,created_by,
  --                                   last_update_login
  --===========================================================================

  PROCEDURE Create_Seq
  ( p_org_id        IN NUMBER
  , p_next_value    IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  )
  IS
  l_count          NUMBER;
  l_next_value     NUMBER;
  l_procedure_name VARCHAR2(30) := 'Create_Seq';
  l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
  l_proc_level     NUMBER := fnd_log.level_procedure;

  CURSOR c_chk_seq_exist IS
    SELECT
      COUNT(*)
    FROM ar_gta_batch_numbering
    WHERE org_id = p_org_id;

  BEGIN
    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.begin'
                    ,'enter procedure');
    END IF;

    OPEN c_chk_seq_exist;
    FETCH c_chk_seq_exist INTO l_count;
    CLOSE c_chk_seq_exist;

    IF l_count = 0
    THEN
      IF p_next_value IS NOT NULL
      THEN
        l_next_value := p_next_value;
      ELSE
        l_next_value := 1;
      END IF;

      INSERT INTO ar_gta_batch_numbering
      ( org_id
      , next_value
      , last_update_date
      , last_updated_by
      , creation_date
      , created_by
      , last_update_login
      )
      VALUES
      ( p_org_id
      , l_next_value
      , SYSDATE
      , fnd_global.LOGIN_ID()
      , SYSDATE
      , fnd_global.LOGIN_ID()
      , fnd_global.LOGIN_ID()
      );

      x_return_status := 'S';
    ELSIF l_count >= 1
    THEN
      x_return_status := 'F';
    END IF;

    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.end'
                    ,'end procedure');
    END IF;
  END Create_Seq;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Set_Nextval                       Public
  --
  --  DESCRIPTION:
  --
  --      This procedure set the sequence's next value for a given operating unit
  --
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id for the new sequence
  --           p_next_value     the start value of the sequence
  --     Out:  x_return_status  the return value to indicate the status
  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --           19-JAN-2006: qiang.li   Update columns last_update_date
  --                                   last_updated_by and last_update_login,
  --                                   when update next_value
  --
  --===========================================================================
  PROCEDURE Set_Nextval
  ( p_org_id        IN NUMBER
  , p_next_value    IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  )
  IS
  l_count          NUMBER;
  l_procedure_name VARCHAR2(30) := 'Set_Nextval';
  l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
  l_proc_level     NUMBER := fnd_log.level_procedure;

  CURSOR c_chk_seq_exist IS
    SELECT COUNT(*)
    FROM ar_gta_batch_numbering
    WHERE org_id = p_org_id;

  BEGIN
    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.begin'
                    ,'enter procedure');
    END IF;

    OPEN c_chk_seq_exist;
    FETCH c_chk_seq_exist INTO l_count;
    CLOSE c_chk_seq_exist;

    IF l_count = 1
    THEN
      UPDATE ar_gta_batch_numbering
      SET next_value = p_next_value
        , last_update_date = SYSDATE
        , last_updated_by = fnd_global.LOGIN_ID()
        , last_update_login = fnd_global.LOGIN_ID()
      WHERE  org_id = p_org_id;

      x_return_status := 'S';
    ELSE
      x_return_status := 'F';
    END IF;

    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.end'
                    ,'end procedure');
    END IF;
  END Set_Nextval;

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Next_Value                   Public
  --
  --  DESCRIPTION:
  --
  --      This function get the sequence's current value and then increase it
  --
  --  PARAMETERS:
  --      In:   p_org_id        Identifier of operating unit
  --
  --
  --  Return:   NUMBER
  --
  --  DESIGN REFERENCES:
  --      GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --           19-JAN-2006: qiang.li   Update columns last_update_date
  --                                   last_updated_by and last_update_login,
  --                                   when update next_value
  --===========================================================================
  FUNCTION Next_Value
  (p_org_id IN NUMBER
  )
  RETURN NUMBER
  IS
  PRAGMA AUTONOMOUS_TRANSACTION;

  l_batch_flag     VARCHAR2(1);
  l_next_val       NUMBER;
  l_procedure_name VARCHAR2(30) := 'next_value';
  l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
  l_proc_level     NUMBER := fnd_log.level_procedure;

  CURSOR c_autobatch IS
    SELECT auto_batch_numbering_flag
    FROM ar_gta_system_parameters
    WHERE org_id = p_org_id;

  CURSOR c_next_val IS
    SELECT next_value
    FROM ar_gta_batch_numbering
    WHERE org_id = p_org_id
    FOR UPDATE OF next_value NOWAIT;

  BEGIN
    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.begin'
                    ,'enter function');
    END IF;

    OPEN c_autobatch;
    FETCH c_autobatch INTO l_batch_flag;
    CLOSE c_autobatch;

    IF (l_batch_flag = 'M')
       OR (l_batch_flag IS NULL)
    THEN
      RETURN NULL;
    END IF;

    OPEN c_next_val;
    FETCH c_next_val INTO l_next_val;

    IF c_next_val%FOUND
    THEN
      UPDATE ar_gta_batch_numbering
      SET next_value = l_next_val + 1
        , last_update_date = SYSDATE
        , last_updated_by = fnd_global.LOGIN_ID()
        , last_update_login = fnd_global.LOGIN_ID()
      WHERE CURRENT OF c_next_val;

      COMMIT;
      CLOSE c_next_val;
      RETURN(l_next_val);
    ELSE
      CLOSE c_next_val;
      RETURN(0);
    END IF;

    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.end'
                    ,'end function');
    END IF;
  END Next_Value;
  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Drop_Seq                       Public
  --
  --  DESCRIPTION:
  --
  --      This procedure drop the sequence of a given operating unit
  --
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id for the new sequence
  --
  --     Out:  x_return_status  the return value to indicate the status
  --
  --  DESIGN REFERENCES:
  --        GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================
  PROCEDURE Drop_Seq
  ( p_org_id        IN NUMBER
  , x_return_status OUT NOCOPY VARCHAR2
  )
  IS
  l_count          NUMBER;
  l_procedure_name VARCHAR2(30) := 'next_value';
  l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
  l_proc_level     NUMBER := fnd_log.level_procedure;
  CURSOR c_chk_seq_exist IS
    SELECT COUNT(*)
    FROM   ar_gta_batch_numbering
    WHERE  org_id = p_org_id;
  BEGIN

    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.begin'
                    ,'enter procedure');
    END IF;

    OPEN c_chk_seq_exist;
    FETCH c_chk_seq_exist INTO l_count;
    CLOSE c_chk_seq_exist;

    IF l_count = 1
    THEN
      DELETE FROM ar_gta_batch_numbering
      WHERE  org_id = p_org_id;

      COMMIT;
      x_return_status := 'S';
    ELSE
      x_return_status := 'F';
    END IF;

    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.end'
                    ,'end procedure');
    END IF;
  END Drop_Seq;

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Is_Number                   Public
  --
  --  DESCRIPTION:
  --
  --      This function check the input value to see whether it is a number
  --
  --  PARAMETERS:
  --      In:   p_value        input value to check
  --
  --
  --  Return:   NUMBER
  --
  --  DESIGN REFERENCES:
  --      GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================
  FUNCTION Is_Number
  (p_value IN VARCHAR2
  )
  RETURN NUMBER
  IS
  l_number_value   NUMBER;
  l_procedure_name VARCHAR2(30) := 'next_value';
  l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
  l_proc_level     NUMBER := fnd_log.level_procedure;
  BEGIN

    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.begin'
                    ,'enter function');
    END IF;

    SELECT
      to_number(p_value)
    INTO
      l_number_value
    FROM
      dual;

    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.end'
                    ,'end function');
    END IF;

    RETURN(l_number_value);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN(-1);
  END Is_Number;

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Verify_Next_Batch_Bumber                   Public
  --
  --  DESCRIPTION:
  --
  --      This function verify the given next value for a operating unit to
  --      see whether the next value is bigger than the exist batch number
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id
  --           p_next_value     the next value to verify
  --  Return:   VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --           19-Jun-2006: Qiang.Li   Fix bug 5291644
  --           27-Jun-2006: Qiang.Li   Fix bug 5291644,next batch number can
  --                                   not equal to existing batch numbers
  --===========================================================================
  FUNCTION Verify_Next_Batch_Number
  ( p_org_id     IN NUMBER
  , p_next_value IN NUMBER
  )
  RETURN VARCHAR2
  IS
  l_count          NUMBER;
  l_procedure_name VARCHAR2(30) := 'next_value';
  l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
  l_proc_level     NUMBER := fnd_log.level_procedure;

  -- Fix bug 5291644
  -- next batch number must large than any existing batch number
  CURSOR c_gta_batch_number IS
    SELECT
      COUNT(*)
    FROM ar_gta_trx_headers_all
    WHERE org_id = p_org_id
      AND is_number(gta_batch_number) >= p_next_value
      AND instr(gta_batch_number,'-') <= 0;

  BEGIN
    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.begin'
                    ,'enter function');
    END IF;

    OPEN c_gta_batch_number;
    FETCH c_gta_batch_number INTO l_count;
    CLOSE c_gta_batch_number;

    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.end'
                    ,'end function');
    END IF;

    IF l_count > 0
    THEN
      RETURN('F');
    ELSE
      RETURN('P');
    END IF;
  END Verify_Next_Batch_Number;

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Is_Exist                   Public
  --
  --  DESCRIPTION:
  --
  --      This function is used to check whether the given org_id has a sequence
  --      in the database
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id
  --
  --  Return:   VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================
  FUNCTION Is_Exist
  (p_org_id IN NUMBER
  )
  RETURN VARCHAR2
  IS
  l_count          NUMBER;
  l_procedure_name VARCHAR2(30) := 'next_value';
  l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
  l_proc_level     NUMBER := fnd_log.level_procedure;
  CURSOR c_chk_seq_exist IS
    SELECT
      COUNT(*)
    FROM
      ar_gta_batch_numbering
    WHERE org_id = p_org_id;
  BEGIN
    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.begin'
                    ,'enter function');
    END IF;

    OPEN c_chk_seq_exist;
    FETCH c_chk_seq_exist INTO l_count;
    CLOSE c_chk_seq_exist;

    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.end'
                    ,'end function');
    END IF;

    IF l_count > 0
    THEN
      RETURN('Y');
    ELSE
      RETURN('N');
    END IF;
  END Is_Exist;

  --==========================================================================
  --  FUNCTION NAME:
  --
  --    Current_Value                   Public
  --
  --  DESCRIPTION:
  --
  --      This function is used to get the current value of a sequence
  --  PARAMETERS:
  --      In:  p_org_id         the operating unit id
  --
  --  Return:   VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      GTA-System-Options-Form-TD.doc
  --
  --  CHANGE HISTORY:
  --
  --           30-APR-2005: qiang.li   Created.
  --
  --===========================================================================
  FUNCTION Current_Value
  ( p_org_id IN NUMBER
  )
  RETURN NUMBER
  IS
  l_number         NUMBER := -1;
  l_procedure_name VARCHAR2(30) := 'next_value';
  l_dbg_level      NUMBER := fnd_log.g_current_runtime_level;
  l_proc_level     NUMBER := fnd_log.level_procedure;
  CURSOR c_seq IS
    SELECT
      next_value
    FROM
      ar_gta_batch_numbering
    WHERE org_id = p_org_id;
  BEGIN
    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.begin'
                    ,'enter function');
    END IF;

    OPEN c_seq;
    FETCH c_seq INTO l_number;
    CLOSE c_seq;

    --logging for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      fnd_log.STRING(l_proc_level
                    ,g_module_prefix || l_procedure_name || '.end'
                    ,'end function');
    END IF;

    RETURN l_number;

  END Current_Value;

END AR_GTA_BATCH_NUMBER_UTIL;

/
