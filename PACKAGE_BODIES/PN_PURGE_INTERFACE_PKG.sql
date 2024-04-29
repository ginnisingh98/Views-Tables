--------------------------------------------------------
--  DDL for Package Body PN_PURGE_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PN_PURGE_INTERFACE_PKG" AS
  -- $Header: PNVPURGB.pls 120.0 2005/05/29 12:32:12 appldev noship $

  l_Debug  VarChar2(1)  := 'N';

-------------------------------------------------------------------
-- PROCEDURE  Purge_CAD
-------------------------------------------------------------------
PROCEDURE  PURGE_CAD ( errbuf           OUT NOCOPY  VARCHAR2,
                       retcode          OUT NOCOPY  NUMBER,
                       function_flag         VARCHAR2,
                       p_batch_name          VARCHAR2)  IS

BEGIN

  fnd_file.put_names('PNVPURGE.log', 'PNVPURGE.out', '/sqlcom/out');

  if (l_Debug = 'Y') Then

   fnd_message.set_name ('PN','PN_BATCH_NAME');
   fnd_message.set_token ('NAME',p_batch_name);
   pnp_debug_pkg.put_log_msg(fnd_message.get);

   fnd_message.set_name ('PN','PN_VPURG_FN_FLAG');
   fnd_message.set_token ('FLAG',function_flag);
   pnp_debug_pkg.put_log_msg(fnd_message.get);

  End If;

  IF (function_flag = 'L') then
    BEGIN
      delete_locations(p_batch_name);
    EXCEPTION
      when OTHERS then
        APP_EXCEPTION.raise_exception;
    END;

  ELSIF (function_flag = 'S') then
    BEGIN
      delete_space_allocations(p_batch_name);
    EXCEPTION
      when OTHERS then
        APP_EXCEPTION.raise_exception;
    END;

  ELSIF  (function_flag = 'A') then
    BEGIN
      delete_locations(p_batch_name);
      pnp_debug_pkg.put_log_msg('=======================================================');
      delete_space_allocations(p_batch_name);
    EXCEPTION
      when OTHERS then
        APP_EXCEPTION.raise_exception;
    END;

  END IF;

END  PURGE_CAD;


-----------------------------------------------------------------------
-- Procedure  Delete_Locations
-----------------------------------------------------------------------
PROCEDURE  Delete_Locations ( p_Batch_Name  VARCHAR2)  IS

  l_Count  Number;

BEGIN
IF P_BATCH_NAME is not null then      /* IF and ELSIF has been added for the BUG#1850937 */
  Select Count(*)
  Into   l_Count
  From   PN_LOCATIONS_ITF
  Where  Batch_Name  =  p_Batch_Name ;
 ELSIF P_BATCH_NAME IS NULL then
  Select Count(*)
  Into   l_Count
  From   PN_LOCATIONS_ITF;
END IF;


  If (l_Debug = 'Y') Then
    pnp_debug_pkg.log('About to Delete from PN_LOCATIONS_ITF ...');
  End If;
IF P_BATCH_NAME is not null then    /* IF and ELSIF has been added for the BUG#1850937 */
  Delete From PN_LOCATIONS_ITF
  Where  Batch_Name  =  p_Batch_Name ;
ELSIF P_BATCH_NAME IS NULL then
  Delete From PN_LOCATIONS_ITF;
END IF;

  pnp_debug_pkg.log('Table: PN_LOCATIONS_ITF');

  fnd_message.set_name ('PN','PN_BATCH_NAME');
  fnd_message.set_token ('NAME',p_batch_name);
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  fnd_message.set_name ('PN','PN_VPURG_ROWS_DEL');
  fnd_message.set_token ('NUM',l_Count);
  pnp_debug_pkg.put_log_msg(fnd_message.get);

EXCEPTION
  When Others Then
    Raise;

END delete_locations;


-----------------------------------------------------------------------
-- Procedure  Delete_Space_Allocations
-----------------------------------------------------------------------
PROCEDURE  Delete_Space_Allocations ( p_Batch_Name  VARCHAR2)  IS

  l_Count  Number;

BEGIN
IF P_BATCH_NAME is not null then    /* IF and ELSIF has been added for the BUG#1850937 */
  Select Count(*)
  Into   l_Count
  From   PN_EMP_SPACE_ASSIGN_ITF
  Where  Batch_Name  =  p_Batch_Name ;
ELSIF P_BATCH_NAME IS NULL then
  Select Count(*)
  Into   l_Count
  From   PN_EMP_SPACE_ASSIGN_ITF;
END IF;
  If (l_Debug = 'Y') Then
    pnp_debug_pkg.log('About to Delete from PN_EMP_SPACE_ASSIGN_ITF ...');
  End If;

IF P_BATCH_NAME is not null then    /* IF and ELSIF has been added for the BUG#1850937 */
  Delete From PN_EMP_SPACE_ASSIGN_ITF
  Where  Batch_Name  =  p_Batch_Name ;
ELSIF P_BATCH_NAME is null then
   Delete From PN_EMP_SPACE_ASSIGN_ITF;
END IF;

  pnp_debug_pkg.log('Table: PN_EMP_SPACE_ASSIGN_ITF');
  fnd_message.set_name ('PN','PN_BATCH_NAME');
  fnd_message.set_token ('NAME',p_batch_name);
  pnp_debug_pkg.put_log_msg(fnd_message.get);

  fnd_message.set_name ('PN','PN_VPURG_ROWS_DEL');
  fnd_message.set_token ('NUM',l_Count);
  pnp_debug_pkg.put_log_msg(fnd_message.get);

EXCEPTION
  When Others Then
    Raise;

END  Delete_Space_Allocations ;



-----------------------------------------------------------------------
-- End of Package
-----------------------------------------------------------------------
END PN_PURGE_INTERFACE_PKG;

/
