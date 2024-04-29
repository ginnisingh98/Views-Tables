--------------------------------------------------------
--  DDL for Package Body GMF_VALIDATIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_VALIDATIONS_PVT" AS
/* $Header: GMFVVALB.pls 120.4.12000000.2 2007/05/02 12:11:29 pmarada ship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFPVALS.pls                                        |
--| Package Name       : GMF_Validations_PVT                                 |
--| API name           : GMF_Validations_PVT                                 |
--| Type               : Public                                              |
--| Pre-reqs           : N/A                                                 |
--| Function           : This package contains generic validations functions |
--|                      and procedures for masters.                         |
--| Parameters         : N/A                                                 |
--|                                                                          |
--| Current Vers       : 1.0                                                 |
--| Previous Vers      : None                                                |
--| Initial Vers       : None                                                |
--|                                                                          |
--| Contents                                                                 |
--|     FUNCTION Validate_Calendar_Code                                      |
--|     PROCEDURE Validate_Calendar_Code                                     |
--|     FUNCTION Validate_Period_Code                                        |
--|     FUNCTION Validate_Cost_Mthd_Code                                     |
--|     PROCEDURE Validate_Cost_Mthd_Code                                    |
--|     FUNCTION Validate_Cost_Analysis_Code                                 |
--|     FUNCTION Validate_Company_Code                                       |
--|     FUNCTION Validate_Orgn_Code                                          |
--|     FUNCTION Validate_Whse_Code                                          |
--|     FUNCTION Validate_Item_Id                                            |
--|     PROCEDURE Validate_Item_Id                                           |
--|     FUNCTION Validate_Item_No                                            |
--|     PROCEDURE Validate_Item_No                                           |
--|     FUNCTION Fecth_Item_Id                                               |
--|     FUNCTION Validate_Itemcost_Class                                     |
--|     FUNCTION Validate_Cost_Cmpntcls_Id                                   |
--|     PROCEDURE Validate_Cost_Cmpntcls_Id                                  |
--|     FUNCTION Validate_Cost_Cmpntcls_Code                                 |
--|     PROCEDURE Validate_Cost_Cmpntcls_Code                                |
--|     FUNCTION Fetch_Cmpntcls_Id                                           |
--|     FUNCTION Validate_Gl_Class                                           |
--|     FUNCTION Validate_Fmeff_Id                                           |
--|     FUNCTION Validate_Resources                                          |
--|     PROCEDURE Validate_Resources                                         |
--|     FUNCTION Validate_Alloc_Id                                           |
--|     FUNCTION Validate_Alloc_Code                                         |
--|     FUNCTION Validate_Text_Code                                          |
--|     FUNCTION Validate_Basis_Account_Key                                  |
--|     FUNCTION Validate_Usage_um                                           |
--|                                                                          |
--| Notes                                                                    |
--|     All the foreign key validations to masters will be added             |
--|                                                                          |
--| HISTORY                                                                  |
--|    27/Feb/2001  Uday Moogala  Created  Bug# 1418689                      |
--|    30-OCT-2002  RajaSekhar    Bug#2641405 Added NOCOPY hint.             |
--|    27/10/2003 Uday Moogla - Log error if lot cost method is passed.      |
--|                                                                          |
--+==========================================================================+
-- End of comments

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Calendar_Code                                             |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Calendar  Code                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Calendar Code exists in           |
--|       on cm_cldr_hdr                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_calendar_code IN VARCHAR2(4) - Calendar Method Code              |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Calendar Code exists                                    |
--|       FALSE - If Calendar Code does not exists                           |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Calendar_Code
(
  p_calendar_code IN cm_cldr_hdr.Calendar_Code%TYPE
)
  RETURN BOOLEAN
IS
  CURSOR cur_cm_cldr_hdr
  IS
    SELECT
      calendar_code
    FROM
      cm_cldr_hdr
    WHERE
        calendar_code = p_calendar_code
    AND delete_mark    = 0;

  l_calendar_code cm_cldr_hdr.Calendar_Code%TYPE ;

BEGIN

  OPEN cur_cm_cldr_hdr;
  FETCH cur_cm_cldr_hdr INTO l_calendar_code;
  IF (cur_cm_cldr_hdr%NOTFOUND)
  THEN
    CLOSE cur_cm_cldr_hdr;
    RETURN FALSE;
  ELSE
    CLOSE cur_cm_cldr_hdr;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Calendar_Code;

-- Func start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Calendar_Code                                             |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Calendar Code                                            |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Calendar Code exists in           |
--|       on cm_cldr_hdr and returns co_code and cost method                 |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_calendar_code IN VARCHAR2(4) - Calendar Method Code              |
--|                                                                          |
--|  RETURNS                                                                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE Validate_Calendar_Code
(
  p_calendar_code    IN  cm_cldr_hdr.Calendar_Code%TYPE
, x_co_code          OUT NOCOPY cm_cldr_hdr.co_code%TYPE
, x_cost_mthd_code   OUT NOCOPY cm_cldr_hdr.cost_mthd_code%TYPE
)
IS
  CURSOR cur_cm_cldr_hdr
  IS
    SELECT
      co_code, cost_mthd_code
    FROM
      cm_cldr_hdr
    WHERE
        calendar_code = p_calendar_code
    AND delete_mark    = 0;

BEGIN

  OPEN cur_cm_cldr_hdr;
  FETCH cur_cm_cldr_hdr INTO x_co_code, x_cost_mthd_code;
  CLOSE cur_cm_cldr_hdr;
/*
  IF (cur_cm_cldr_hdr%NOTFOUND)
  THEN
    CLOSE cur_cm_cldr_hdr;
    RETURN FALSE;
  ELSE
    CLOSE cur_cm_cldr_hdr;
    RETURN TRUE;
  END IF;
*/
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Calendar_Code;

-- Func start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Period_Code                                               |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Period Code                                              |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Period Code exists in             |
--|       on cm_cldr_dtl                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_calendar_code IN VARCHAR2(4) - Calendar Method Code              |
--|       p_period_code   IN VARCHAR2(4) - Period Code                       |
--|                                                                          |
--|  RETURNS                                                                 |
--|       period_status -                                                    |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE Validate_Period_Code
(
  p_Calendar_Code  IN  cm_cldr_hdr.Calendar_Code%TYPE,
  p_Period_Code    IN  cm_cldr_dtl.Period_Code%TYPE,
  x_Period_Status  OUT NOCOPY cm_cldr_dtl.period_status%TYPE
)
IS
  CURSOR cur_cm_cldr_dtl
  IS
    SELECT
      period_status
    FROM
      cm_cldr_dtl
    WHERE
        calendar_code 	= p_calendar_code
    AND period_code 	= p_period_code
    AND delete_mark    	= 0;

BEGIN

  OPEN cur_cm_cldr_dtl;
  FETCH cur_cm_cldr_dtl INTO x_period_status;
  CLOSE cur_cm_cldr_dtl;
/*
  IF (cur_cm_cldr_dtl%NOTFOUND)
  THEN
    CLOSE cur_cm_cldr_dtl;
    RETURN FALSE;
  ELSE
    CLOSE cur_cm_cldr_dtl;
    RETURN TRUE;
  END IF;
*/
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Period_Code;
--

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_cost_mthd_code                                            |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates cost_mthd_code                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the cost Method Code exists           |
--|       on cm_mthd_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_cost_mthd_code IN VARCHAR2(4) - Cost Method Code                 |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Cost Method contains a valid value                      |
--|       FALSE - If Cost Method contains an invalid value                   |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|       27/10/2003 Uday Moogla - Log error if lot cost method is passed.   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_cost_mthd_code (
	p_cost_mthd_code IN ic_item_mst.cost_mthd_code%TYPE
	)
  RETURN BOOLEAN
IS
  CURSOR cur_cm_mthd_mst
  IS
    SELECT
      cost_mthd_code, lot_actual_cost
    FROM
      cm_mthd_mst
    WHERE
        cm_mthd_mst.cost_mthd_code = p_cost_mthd_code
    AND cm_mthd_mst.delete_mark    = 0;

  l_cost_mthd_code ic_item_mst.cost_mthd_code%TYPE;
  l_lot_actual_cost cm_mthd_mst.lot_actual_cost%TYPE;

BEGIN

  OPEN cur_cm_mthd_mst;
  FETCH cur_cm_mthd_mst INTO l_cost_mthd_code, l_lot_actual_cost;
  IF (cur_cm_mthd_mst%NOTFOUND)
  THEN
    CLOSE cur_cm_mthd_mst;
    RETURN FALSE;
  ELSE
    CLOSE cur_cm_mthd_mst;
    IF l_lot_actual_cost = 1 THEN
      FND_MESSAGE.SET_NAME('GMF','GMF_API_LOTCOST_MTHD_UNSUPP');
      FND_MESSAGE.SET_TOKEN('COST_MTHD_CODE',p_cost_mthd_code);
      FND_MSG_PUB.Add;
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_cost_mthd_code;

-- Func start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_cost_mthd_code                                            |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates cost_mthd_code                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the cost Method Code exists           |
--|       on cm_mthd_mst and returns cost_type, rmcalc_type and prodcalc_type|
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_cost_mthd_code IN VARCHAR2(4) - Cost Method Code                 |
--|       x_cost_type      OUT NUMBER     - Cost Type                        |
--|       x_rmcalc_type    OUT NUMBER                                        |
--|       x_prodcalc_type  OUT NUMBER                                        |
--|                                                                          |
--|  RETURNS                                                                 |
--|       x_cost_type      OUT NUMBER     - Cost Type                        |
--|       x_rmcalc_type    OUT NUMBER                                        |
--|       x_prodcalc_type  OUT NUMBER                                        |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|       27/10/2003 Uday Moogla - Log error if lot cost method is passed.   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE Validate_cost_mthd_code
(
p_cost_mthd_code IN  cm_mthd_mst.cost_mthd_code%TYPE,
x_cost_type      OUT NOCOPY cm_mthd_mst.cost_type%TYPE,
x_rmcalc_type    OUT NOCOPY cm_mthd_mst.rmcalc_type%TYPE,
x_prodcalc_type  OUT NOCOPY cm_mthd_mst.prodcalc_type%TYPE
)
IS
  CURSOR cur_cm_mthd_mst
  IS
    SELECT
      cost_type, rmcalc_type, prodcalc_type, lot_actual_cost
    FROM
      cm_mthd_mst
    WHERE
        cm_mthd_mst.cost_mthd_code = p_cost_mthd_code
    AND cm_mthd_mst.delete_mark    = 0;

  l_cost_mthd_code ic_item_mst.cost_mthd_code%TYPE;
  l_lot_actual_cost cm_mthd_mst.lot_actual_cost%TYPE;

BEGIN

  OPEN cur_cm_mthd_mst;
  FETCH cur_cm_mthd_mst INTO x_cost_type, x_rmcalc_type, x_prodcalc_type, l_lot_actual_cost ;
  CLOSE cur_cm_mthd_mst;

  IF l_lot_actual_cost = 1 THEN
    FND_MESSAGE.SET_NAME('GMF','GMF_API_LOTCOST_MTHD_UNSUPP');
    FND_MESSAGE.SET_TOKEN('COST_MTHD_CODE',p_cost_mthd_code);
    FND_MSG_PUB.Add;
    x_cost_type     := NULL;
    x_rmcalc_type   := NULL;
    x_prodcalc_type := NULL;
  END IF;
/*
  IF (cur_cm_mthd_mst%NOTFOUND)
  THEN
    CLOSE cur_cm_mthd_mst;
    RETURN FALSE;
  ELSE
    CLOSE cur_cm_mthd_mst;
    RETURN TRUE;
  END IF;
*/
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_cost_mthd_code;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Analysis_Code                                             |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Cost Analysis Code                                       |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Cost Analysis Code exists         |
--|       on cm_alys_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_Cost_Analysis_Code IN VARCHAR2(4) - Cost Analysis Code           |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Cost Analysis Code contains a valid value               |
--|       FALSE - If Cost Analysis Code contains an invalid value            |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Analysis_Code
(
  p_Cost_Analysis_Code  IN cm_alys_mst.Cost_Analysis_Code%TYPE
)
  RETURN BOOLEAN
IS
  CURSOR  Cur_analysis_code
  IS
    SELECT
	cost_analysis_code
    FROM
	cm_alys_mst
    WHERE
	cost_analysis_code = p_Cost_Analysis_Code
    AND delete_mark = 0;

  l_Cost_Analysis_Code	cm_alys_mst.Cost_Analysis_Code%TYPE ;

BEGIN

  OPEN Cur_analysis_code;
  FETCH Cur_analysis_code INTO l_Cost_Analysis_Code;
  IF (Cur_analysis_code%NOTFOUND)
  THEN
    CLOSE Cur_analysis_code;
    RETURN FALSE;
  ELSE
    CLOSE Cur_analysis_code;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Analysis_Code;
--

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Company_Code                                              |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Company Code                                             |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Company Code exists               |
--|       on sy_orgn_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_Company_Code IN VARCHAR2(4) - Company Code                       |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Company Code contains a valid value                     |
--|       FALSE - If Company Code contains an invalid value                  |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Company_Code
(
  p_Company_Code  IN sy_orgn_mst.Co_Code%TYPE
)
  RETURN BOOLEAN
IS
  CURSOR  Cur_company_code
  IS
    SELECT
        co_code
    FROM
        sy_orgn_mst
    WHERE
        co_code 	= p_Company_Code
    AND orgn_code 	= co_code
    AND delete_mark	= 0;

  l_Company_Code  sy_orgn_mst.Co_Code%TYPE ;

BEGIN

  OPEN Cur_company_code;
  FETCH Cur_company_code INTO l_Company_Code;
  IF (Cur_company_code%NOTFOUND)
  THEN
    CLOSE Cur_company_code;
    RETURN FALSE;
  ELSE
    CLOSE Cur_company_code;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Company_Code;
--

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Orgn_Code                                                 |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Organization Code                                        |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Orgn Code exists on sy_orgn_mst   |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_orgn_code IN VARCHAR2(4) - Orgn Code                             |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Orgn Code contains a valid value                        |
--|       FALSE - If Orgn Code contains an invalid value                     |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Orgn_Code
( p_Orgn_Code  IN sy_orgn_mst.Orgn_Code%TYPE
)
RETURN BOOLEAN
IS
  CURSOR  Cur_orgn_code
  IS
    SELECT
        orgn_code
    FROM
        sy_orgn_mst
    WHERE
    	orgn_code       = p_orgn_code
    AND delete_mark     = 0;

  l_orgn_code  sy_orgn_mst.orgn_code%TYPE ;

BEGIN

  OPEN Cur_orgn_code;
  FETCH Cur_orgn_code INTO l_orgn_code;
  IF (Cur_orgn_code%NOTFOUND)
  THEN
    CLOSE Cur_orgn_code;
    RETURN FALSE;
  ELSE
    CLOSE Cur_orgn_code;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Orgn_Code ;
--

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Whse_Code                                                 |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Warehouse Code                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Whse Code exists on ic_whse_mst   |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_whse_code IN VARCHAR2(4) - Whse Code                             |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Whse Code contains a valid value                        |
--|       FALSE - If Whse Code contains an invalid value                     |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Whse_Code
(
  p_whse_code  IN ic_whse_mst.whse_code%TYPE
)
RETURN BOOLEAN
IS
  CURSOR  Cur_whse_code
  IS
    SELECT
        whse_code
    FROM
        ic_whse_mst
    WHERE
        whse_code       = p_whse_code
    AND delete_mark     = 0;

  l_whse_code  ic_whse_mst.whse_code%TYPE ;

BEGIN

  OPEN Cur_whse_code;
  FETCH Cur_whse_code INTO l_whse_code;
  IF (Cur_whse_code%NOTFOUND)
  THEN
    CLOSE Cur_whse_code;
    RETURN FALSE;
  ELSE
    CLOSE Cur_whse_code;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Whse_Code;
--

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Item_Id                                                   |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Item ID                                                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Item ID exists on ic_whse_mst     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_id IN VARCHAR2(4) - Item ID                                 |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Item ID contains a valid value                          |
--|       FALSE - If Item ID contains an invalid value                       |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Item_Id
(
  p_Item_Id  IN ic_item_mst.Item_Id%TYPE
)
  RETURN BOOLEAN
IS
  CURSOR  Cur_Item_Id
  IS
    SELECT
        Item_Id
    FROM
        ic_item_mst
    WHERE
        Item_Id       = p_Item_Id
    AND delete_mark   = 0
    AND inactive_ind  = 0 ;

  l_Item_Id  ic_item_mst.Item_Id%TYPE ;

BEGIN

  OPEN Cur_Item_Id;
  FETCH Cur_Item_Id INTO l_Item_Id;
  IF (Cur_Item_Id%NOTFOUND)
  THEN
    CLOSE Cur_Item_Id;
    RETURN FALSE;
  ELSE
    CLOSE Cur_Item_Id;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Item_Id;
--

-- Func start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Item_Id                                                   |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Item ID                                                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Item ID exists in ic_item_mst     |
--|       and returns item_um                                                |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_id IN VARCHAR2(4) - Item ID                                 |
--|                                                                          |
--|  RETURNS                                                                 |
--|       Item_UM - If Item ID is valid                                      |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE Validate_Item_Id
(
  p_Item_Id  IN ic_item_mst.Item_Id%TYPE
, x_Item_UM  OUT NOCOPY ic_item_mst.Item_UM%TYPE
)
IS
  CURSOR  Cur_Item_UM
  IS
    SELECT
           Item_UM
    FROM
           ic_item_mst
    WHERE
           Item_Id       = p_Item_Id
    AND    delete_mark   = 0
    AND    inactive_ind  = 0 ;

BEGIN

  OPEN  Cur_Item_UM;
  FETCH Cur_Item_UM INTO x_Item_UM;
  CLOSE Cur_Item_UM;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Item_Id;
--

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Item_No                                                   |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Item No                                                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Item No exists on ic_whse_mst     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_No IN VARCHAR2(4) - Item No                                 |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Item No contains a valid value                          |
--|       FALSE - If Item No contains an invalid value                       |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Item_No
( p_Item_No  IN ic_item_mst.Item_No%TYPE
)
  RETURN NUMBER
IS
  CURSOR  Cur_Item_Id
  IS
    SELECT
        Item_Id
    FROM
        ic_item_mst
    WHERE
        Item_No       = p_Item_No
    AND delete_mark   = 0
    AND inactive_ind  = 0 ;

  l_Item_Id  ic_item_mst.Item_Id%TYPE ;

BEGIN

  OPEN Cur_Item_Id;
  FETCH Cur_Item_Id INTO l_Item_Id;
  IF (Cur_Item_Id%NOTFOUND)
  THEN
    CLOSE Cur_Item_Id;
  ELSE
    CLOSE Cur_Item_Id;
  END IF;

  RETURN l_Item_Id;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Item_No;
--

-- Func start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Item_No                                                   |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Item No                                                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Item No exists on ic_item_mst     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_No IN VARCHAR2(4) - Item No                                 |
--|                                                                          |
--|  RETURNS                                                                 |
--|       Item_Id - If Item No is valid                                      |
--|       Item_UM - If Item No is valid                                      |
--|                                                                          |
--|  HISTORY                                                                 |
--|       27/02/2001 Uday Moogla - Created                                   |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE Validate_Item_No
(
  p_Item_No  IN  ic_item_mst.Item_No%TYPE
, x_Item_Id  OUT NOCOPY ic_item_mst.Item_Id%TYPE
, x_Item_UM  OUT NOCOPY ic_item_mst.Item_UM%TYPE
)
IS
  CURSOR  Cur_Item
  IS
    SELECT
        Item_Id, Item_UM
    FROM
        ic_item_mst
    WHERE
        Item_No       = p_Item_No
    AND delete_mark   = 0
    AND inactive_ind  = 0 ;

BEGIN

  OPEN Cur_Item;
  FETCH Cur_Item INTO x_Item_Id, x_Item_UM ;
  CLOSE Cur_Item;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Item_No;
--

--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_itemcost_class                                            |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates itemcost_class                                           |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Item Cost Class exists            |
--|       on ic_cost_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_itemcost_class class IN VARCHAR2(8) - Item Cost Class            |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Item Cost Class contains a valid value                  |
--|       FALSE - If Item Cost Class contains an invalid value               |
--|                                                                          |
--|  HISTORY                                                                 |
--|       11/13/1998 Mike Godfrey - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_itemcost_class
(
  p_itemcost_class IN ic_item_mst.itemcost_class%TYPE
)
  RETURN BOOLEAN
IS
/* ANTHIYAG Bug#4906488
  CURSOR Cur_itemcost_class
  IS
  SELECT
	itemcost_class
  FROM
	ic_cost_cls
  WHERE
	itemcost_class = p_itemcost_class
  AND 	delete_mark    = 0;

  l_itemcost_class 	ic_cost_cls.itemcost_class%TYPE;
*/
BEGIN
/* ANTHIYAG Bug#4906488
  OPEN Cur_itemcost_class;
  FETCH Cur_itemcost_class INTO l_itemcost_class;
  IF (Cur_itemcost_class%NOTFOUND) THEN
    CLOSE Cur_itemcost_class;
    RETURN FALSE;
  ELSE
    CLOSE Cur_itemcost_class;
    RETURN TRUE;
  END IF;
*/
RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_itemcost_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Cost_Cmpntcls_Id                                          |
--|                                                                          |
--|  USAGE                                                                   |
--| 	  Validates Cost Component Class ID                                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Cost Component Class Id exists    |
--|       on cm_cmpt_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_Cost_Cmpntcls_Id IN NUMBER(10) -- Cost Component Class Id        |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - if the Cost_Cmpntcls_Id exists                             |
--|       FALSE - if the Cost_Cmpntcls_Id does not exist                     |
--|                                                                          |
--|  HISTORY                                                                 |
--|       02/28/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Cost_Cmpntcls_Id
( p_Cost_Cmpntcls_Id  IN cm_cmpt_mst.Cost_Cmpntcls_Id%TYPE
)
RETURN BOOLEAN
IS
  CURSOR Cur_Cost_Cmpntcls_Id
  IS
    SELECT
         Cost_Cmpntcls_Id
    FROM
         cm_cmpt_mst
    WHERE
         Cost_Cmpntcls_Id = p_Cost_Cmpntcls_Id
    AND  delete_mark = 0 ;

  l_Cost_Cmpntcls_Id     cm_cmpt_mst.Cost_Cmpntcls_Id%TYPE ;

BEGIN

  OPEN  Cur_Cost_Cmpntcls_Id;
  FETCH Cur_Cost_Cmpntcls_Id INTO l_Cost_Cmpntcls_Id;
  IF (Cur_Cost_Cmpntcls_Id%NOTFOUND)
  THEN
    CLOSE Cur_Cost_Cmpntcls_Id;
    RETURN FALSE;
  ELSE
    CLOSE Cur_Cost_Cmpntcls_Id;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Cost_Cmpntcls_Id;


-- Func start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Cost_Cmpntcls_Id                                          |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Cost Component Class ID                                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Cost Component Class Id exists    |
--|       on cm_cmpt_mst and returns usage_ind                               |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_Cost_Cmpntcls_Id IN NUMBER(10) -- Cost Component Class Id        |
--|                                                                          |
--|  RETURNS                                                                 |
--|       Usage_Ind - Components Usage Indicator                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|       02/28/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE Validate_Cost_Cmpntcls_Id
( p_Cost_Cmpntcls_Id  IN  cm_cmpt_mst.Cost_Cmpntcls_Id%TYPE,
  x_Cost_Cmpntcls_Id  OUT NOCOPY cm_cmpt_mst.Cost_Cmpntcls_Code%TYPE,
  x_usage_ind         OUT NOCOPY cm_cmpt_mst.usage_ind%TYPE
)
IS
  CURSOR Cur_Cost_Cmpntcls_Id
  IS
    SELECT
         cost_cmpntcls_code, usage_ind
    FROM
         cm_cmpt_mst
    WHERE
         Cost_Cmpntcls_Id = p_Cost_Cmpntcls_Id
    AND  delete_mark = 0 ;

BEGIN

  OPEN  Cur_Cost_Cmpntcls_Id;
  FETCH Cur_Cost_Cmpntcls_Id INTO x_Cost_Cmpntcls_Id, x_usage_ind;
  CLOSE Cur_Cost_Cmpntcls_Id;
/*
  IF (Cur_Cost_Cmpntcls_Id%NOTFOUND)
  THEN
    CLOSE Cur_Cost_Cmpntcls_Id;
    RETURN FALSE;
  ELSE
    CLOSE Cur_Cost_Cmpntcls_Id;
    RETURN TRUE;
  END IF;
*/
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Cost_Cmpntcls_Id;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Cost_Cmpntcls_Code                                        |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Cost Component Class Code                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Cost Component Class Code exists  |
--|       on cm_cmpt_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_Cost_Cmpntcls_Code IN NUMBER(10) -- Cost Component Class Code    |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - if the Cost_Cmpntcls_Code exists                           |
--|       FALSE - if the Cost_Cmpntcls_Code does not exist                   |
--|                                                                          |
--|  HISTORY                                                                 |
--|       02/28/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Cost_Cmpntcls_Code
( p_Cost_Cmpntcls_Code  IN cm_cmpt_mst.Cost_Cmpntcls_Code%TYPE
)
RETURN NUMBER
IS
  CURSOR Cur_Cost_Cmpntcls_Id
  IS
    SELECT
         Cost_Cmpntcls_Id
    FROM
         cm_cmpt_mst
    WHERE
         Cost_Cmpntcls_Code = p_Cost_Cmpntcls_Code
    AND  delete_mark        = 0 ;

  l_Cost_Cmpntcls_Id     cm_cmpt_mst.Cost_Cmpntcls_Id%TYPE ;

BEGIN

  OPEN  Cur_Cost_Cmpntcls_Id;
  FETCH Cur_Cost_Cmpntcls_Id INTO l_Cost_Cmpntcls_Id;
  IF (Cur_Cost_Cmpntcls_Id%NOTFOUND)
  THEN
    CLOSE Cur_Cost_Cmpntcls_Id;
  ELSE
    CLOSE Cur_Cost_Cmpntcls_Id;
  END IF;

  RETURN l_Cost_Cmpntcls_Id ;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Cost_Cmpntcls_Code;
--

-- Func start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Cost_Cmpntcls_Code                                        |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Cost Component Class Code                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Cost Component Class Code exists  |
--|       on cm_cmpt_mst and returns Component Class Id and Usage Indicator. |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_Cost_Cmpntcls_Code IN NUMBER(10) -- Cost Component Class Code    |
--|                                                                          |
--|  RETURNS                                                                 |
--|       Cost_Cmpntcls_Id                                                   |
--|       Usage_Ind                                                          |
--|                                                                          |
--|  HISTORY                                                                 |
--|       02/28/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE Validate_Cost_Cmpntcls_Code
( p_Cost_Cmpntcls_Code  IN  cm_cmpt_mst.Cost_Cmpntcls_Code%TYPE,
  x_Cost_Cmpntcls_Id     OUT NOCOPY cm_cmpt_mst.Cost_Cmpntcls_Id%TYPE,
  x_Usage_Ind           OUT NOCOPY cm_cmpt_mst.Usage_Ind%TYPE
)
IS
  CURSOR Cur_Cost_Cmpntcls_Id
  IS
    SELECT
         Cost_Cmpntcls_Id, Usage_Ind
    FROM
         cm_cmpt_mst
    WHERE
         Cost_Cmpntcls_Code = p_Cost_Cmpntcls_Code
    AND  delete_mark        = 0 ;

BEGIN

  OPEN  Cur_Cost_Cmpntcls_Id;
  FETCH Cur_Cost_Cmpntcls_Id INTO x_Cost_Cmpntcls_Id, x_Usage_Ind;
  CLOSE Cur_Cost_Cmpntcls_Id;
/*
  IF (Cur_Cost_Cmpntcls_Id%NOTFOUND)
  THEN
    CLOSE Cur_Cost_Cmpntcls_Id;
  ELSE
    CLOSE Cur_Cost_Cmpntcls_Id;
  END IF;

  RETURN l_Cost_Cmpntcls_Id ;
*/
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Cost_Cmpntcls_Code;
--

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_gl_class                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates gl_class                                                 |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the GL Class code exists              |
--|       on ic_gled_cls                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_gl_class IN VARCHAR2(8) - GL Class                               |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If GL Class Code contains a valid value                    |
--|       FALSE - If GL Class Code contains an invalid value                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       02/28/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments
FUNCTION Validate_gl_class
(
  p_gl_class IN ic_gled_cls.icgl_class%TYPE
)
  RETURN BOOLEAN
IS
/* ANTHIYAG Bug#4906488
  CURSOR Cur_gl_class
  IS
    SELECT
	 icgl_class
    FROM
	 ic_gled_cls
    WHERE
	ic_gled_cls.icgl_class  = p_gl_class
    AND ic_gled_cls.delete_mark = 0;

  l_gl_class ic_gled_cls.icgl_class%TYPE;
*/

BEGIN
/* ANTHIYAG Bug#4906488
  OPEN Cur_gl_class;
  FETCH Cur_gl_class INTO l_gl_class;
  IF (Cur_gl_class%NOTFOUND)
  THEN
    CLOSE Cur_gl_class;
    RETURN FALSE;
  ELSE
    CLOSE Cur_gl_class;
    RETURN TRUE;
  END IF;
*/
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_gl_class;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Fmeff_Id                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Fmeff_Id                                                 |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Effectivity Id exists             |
--|       on fm_form_eff                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_fneff_id IN VARCHAR2(8) -  Effectivity Id                        |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Effectivity Id contains a valid value                   |
--|       FALSE - If Effectivity Id contains an invalid value                |
--|                                                                          |
--|  HISTORY                                                                 |
--|       02/28/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Fmeff_Id
(
  p_Fmeff_Id  IN fm_form_eff.Fmeff_Id%TYPE
)
  RETURN BOOLEAN
IS
  CURSOR Cur_fmeff_id
  IS
    SELECT
         fmeff_id
    FROM
         fm_form_eff
    WHERE
        fmeff_id  = p_fmeff_id
    AND delete_mark = 0;

  l_fmeff_id fm_form_eff.fmeff_id%TYPE;

BEGIN

  OPEN Cur_fmeff_id;
  FETCH Cur_fmeff_id INTO l_fmeff_id;
  IF (Cur_fmeff_id%NOTFOUND)
  THEN
    CLOSE Cur_fmeff_id;
    RETURN FALSE;
  ELSE
    CLOSE Cur_fmeff_id;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Fmeff_Id;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Resources                                                 |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Resources                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Resources exists                  |
--|       on cr_rsrc_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_Resources IN VARCHAR2(8) -  Effectivity Id                       |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Resources contains a valid value                        |
--|       FALSE - If Resources contains an invalid value                     |
--|                                                                          |
--|  HISTORY                                                                 |
--|       02/28/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Resources
(
  p_Resources  IN cr_rsrc_mst.Resources%TYPE
)
  RETURN BOOLEAN
IS
  CURSOR Cur_resources
  IS
    SELECT
         resources
    FROM
         cr_rsrc_mst
    WHERE
        resources  = p_Resources
    AND delete_mark = 0;

  l_Resources cr_rsrc_mst.Resources%TYPE ;

BEGIN

  OPEN Cur_resources;
  FETCH Cur_resources INTO l_Resources;
  IF (Cur_resources%NOTFOUND)
  THEN
    CLOSE Cur_resources;
    RETURN FALSE;
  ELSE
    CLOSE Cur_resources;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Resources;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Resources                                                 |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Resources                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Resources exists                  |
--|       on cr_rsrc_mst and returns usage UOM                               |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_Resources   IN  VARCHAR2(8) -  Resources                         |
--|       x_resource_um OUT VARCHAR2(8) -  Usage UOM                         |
--|                                                                          |
--|  RETURNS                                                                 |
--|       Resource UOM  - If Resources is valid                              |
--|                                                                          |
--|  HISTORY                                                                 |
--|       04/12/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE Validate_Resources
(
  p_Resources        IN  cr_rsrc_mst.Resources%TYPE
, x_resource_um      OUT NOCOPY cr_rsrc_mst.std_usage_um%TYPE
, x_resource_um_type OUT NOCOPY sy_uoms_mst.um_type%TYPE
)
IS
  CURSOR Cur_resources
  IS
    SELECT
         rm.std_usage_um, um.um_type
    FROM
         sy_uoms_mst um, cr_rsrc_mst rm
    WHERE
        rm.resources  = p_Resources
    AND um.um_code    = rm.std_usage_um
    AND rm.delete_mark = 0;

BEGIN

  OPEN Cur_resources;
  FETCH Cur_resources INTO x_resource_um, x_resource_um_type;
  CLOSE Cur_resources;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Resources;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Alloc_Id                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Allocation Id                                            |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Allocation Id exists              |
--|       on cr_rsrc_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_alloc_id IN NUMBER(10) -  Allocation Id                          |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Allocation Id contains a valid value                    |
--|       FALSE - If Allocation Id contains an invalid value                 |
--|                                                                          |
--|  HISTORY                                                                 |
--|       02/28/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Alloc_Id
( p_Alloc_Id  IN gl_aloc_mst.Alloc_Id%TYPE
)
RETURN BOOLEAN
IS
  CURSOR Cur_Alloc_Id
  IS
    SELECT
         Alloc_Id
    FROM
         gl_aloc_mst
    WHERE
        Alloc_Id  = p_Alloc_Id
    AND delete_mark = 0;

  l_Alloc_Id 	gl_aloc_mst.Alloc_Id%TYPE ;

BEGIN
  OPEN Cur_Alloc_Id;
  FETCH Cur_Alloc_Id INTO l_Alloc_Id;
  IF (Cur_Alloc_Id%NOTFOUND)
  THEN
    CLOSE Cur_Alloc_Id;
    RETURN FALSE;
  ELSE
    CLOSE Cur_Alloc_Id;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Alloc_Id;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Fetch_Alloc_Id                                                     |
--|                                                                          |
--|  USAGE                                                                   |
--|       Used to get allocation id for a given alloc_code and co_code       |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       Fetches allocation id for a given alloc_code and co_code           |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_alloc_Code IN NUMBER(10) -  Allocation Code                      |
--|       Co_Code      IN NUMBER(10) -  Company Code                         |
--|                                                                          |
--|  RETURNS                                                                 |
--|	  Allocation Id                                                      |
--|                                                                          |
--|  HISTORY                                                                 |
--|       02/28/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Fetch_Alloc_Id
( p_Alloc_Code  IN gl_aloc_mst.Alloc_Code%TYPE,
  p_co_code     IN sy_orgn_mst.co_code%TYPE
)
RETURN NUMBER
IS
  CURSOR Cur_Alloc_Id
  IS
    SELECT
         Alloc_id
    FROM
         gl_aloc_mst
    WHERE
        Alloc_Code	= p_Alloc_Code
    AND	Co_Code		= p_Co_Code
    AND delete_mark 	= 0;

  l_Alloc_id    gl_aloc_mst.Alloc_id%TYPE := '' ;

BEGIN

  OPEN Cur_Alloc_Id;
  FETCH Cur_Alloc_Id INTO l_Alloc_Id;
  IF (Cur_Alloc_Id%NOTFOUND)
  THEN
    CLOSE Cur_Alloc_Id;
    RETURN l_Alloc_Id;
  ELSE
    CLOSE Cur_Alloc_Id;
    RETURN l_Alloc_Id;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Fetch_Alloc_Id ;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Basis_account_key                                         |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Basis Account Key                                        |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Basis Account exists              |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_Basis_account_key IN VARCHAR2(10)                                |
--|                                                                          |
--|  RETURNS                                                                 |
--|	   0 - Valid Basis Account Key                                       |
--|	  -1 - Invalid Accounting Unit No                                    |
--|	  -2 - Invalid Account No                                            |
--|                                                                          |
--|  HISTORY                                                                 |
--|       02/28/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE Validate_Basis_account_key
( p_Basis_account_key   IN  gl_aloc_bas.Basis_account_key%TYPE
  , p_co_code		IN  sy_orgn_mst.co_code%TYPE
  , p_basis_description OUT NOCOPY VARCHAR2
  , p_return_status     OUT NOCOPY NUMBER
)
IS

    CURSOR Cur_get_seg_deli(p_co_code VARCHAR2) IS
      SELECT segment_delimiter
      FROM   gl_plcy_mst
      WHERE  co_code = p_co_code
           AND delete_mark = 0;

    CURSOR Cur_get_seg_cnttyp(p_co_code VARCHAR2,
                              ptype NUMBER) IS
      SELECT COUNT(*)
      FROM   gl_plcy_seg
      WHERE  co_code = p_co_code
       AND   type = decode(ptype, '', type, ptype)
       AND   delete_mark = 0;

    l_segment_delimiter gl_plcy_mst.segment_delimiter%TYPE;
    l_acct_no      	gl_acct_mst.acct_no%TYPE;
    l_acct_id      	gl_acct_mst.acct_id%TYPE;
    l_acctg_unit	gl_accu_mst.acctg_unit_no%TYPE ;
    l_acctg_unit_id	gl_accu_mst.acctg_unit_id%TYPE ;
    l_cnt_acctg_unit	NUMBER(10);
    l_cnt_seg		NUMBER(10);

    l_segments_tab	 gmf_get_mappings.my_opm_seg_values; -- to store segments
    l_accu_desc          gl_aloc_bas.basis_account_desc%TYPE ;
    l_acct_desc          gl_aloc_bas.basis_account_desc%TYPE ;

BEGIN

    l_segments_tab := gmf_get_mappings.get_opm_segment_values(p_Basis_account_key, p_co_code, 2);

     -- Fetch Segment delimiter
    OPEN Cur_get_seg_deli(p_co_code);
    FETCH Cur_get_seg_deli INTO l_segment_delimiter;
    CLOSE Cur_get_seg_deli;

    -- Get Count of Accounting Units segments
    OPEN Cur_get_seg_cnttyp(p_co_code,0);
    FETCH Cur_get_seg_cnttyp INTO l_cnt_acctg_unit;
    CLOSE Cur_get_seg_cnttyp;

    -- Get # of segments
    OPEN Cur_get_seg_cnttyp(p_co_code,'');
    FETCH Cur_get_seg_cnttyp INTO l_cnt_seg;
    CLOSE Cur_get_seg_cnttyp;

    --
    -- getting account unit by concatinating individual segments based on
    -- count on segment types
    -- Accouting units always occur first
    --
    FOR i in 1..l_cnt_acctg_unit
    LOOP
      l_acctg_unit := l_acctg_unit || l_segments_tab(i) ;
      IF i < l_cnt_acctg_unit THEN	-- to avoid end delimiter.
        l_acctg_unit := l_acctg_unit || l_segment_delimiter ;
      END IF;
    END LOOP ;

    -- getting account by concatinating individual segments based on
    -- count on segment types
    FOR i in (l_cnt_acctg_unit+1)..l_cnt_seg
    LOOP
      l_acct_no := l_acct_no || l_segments_tab(i) ;
      IF i < l_cnt_seg THEN
        l_acct_no := l_acct_no || l_segment_delimiter ;
      END IF;
    END LOOP ;

    SELECT acctg_unit_desc
      INTO l_accu_desc
      FROM gl_accu_mst
     WHERE acctg_unit_no = l_acctg_unit
       AND co_code = p_co_code
       AND delete_mark = 0 ;

    SELECT acct_desc
      INTO l_acct_desc
      FROM gl_acct_mst
     WHERE acct_no = l_acct_no
       AND co_code = p_co_code
       AND delete_mark = 0 ;

    p_basis_description := substrb(l_accu_desc || ' ' || l_acct_desc,1,70) ;
    p_return_status     := 0 ;

    EXCEPTION
        WHEN OTHERS THEN
            IF ( l_accu_desc IS NULL )
            THEN
                p_return_status := -1 ;       /* error in acctg_unit_no */
            ELSE
                p_return_status := -2 ;       /* error in acct_no */
            END IF;
END Validate_Basis_account_key ;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Usage_Um                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Usage UOM                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Usage UOM exists                  |
--|       in sy_uoms_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_usage_um  IN VARCHAR2(10) -  Usage UOM                           |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Usage UOM contains a valid value                        |
--|       FALSE - If Usage UOM contains an invalid value                     |
--|                                                                          |
--|  HISTORY                                                                 |
--|       02/28/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Usage_Um
( p_Usage_Um   IN sy_uoms_mst.Um_Code%TYPE
)
RETURN BOOLEAN
IS
  CURSOR Cur_Usage_Um
  IS
    SELECT
         Um_Code
    FROM
         sy_uoms_mst
    WHERE
        Um_Code   = p_Usage_Um ;

  l_Um_Code	sy_uoms_mst.Um_Code%TYPE ;

BEGIN

  OPEN Cur_Usage_Um;
  FETCH Cur_Usage_Um INTO l_Um_Code;
  IF (Cur_Usage_Um%NOTFOUND)
  THEN
    CLOSE Cur_Usage_Um;
    RETURN FALSE;
  ELSE
    CLOSE Cur_Usage_Um;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Usage_Um ;

-- Func start of comments
--+==========================================================================+
--|  PROCEDURE NAME                                                          |
--|       Validate_Usage_Um                                                  |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates Usage UOM                                                |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the Usage UOM exists                  |
--|       in sy_uoms_mst and return UOM Type                                 |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_usage_um  IN VARCHAR2(10) -  Usage UOM                           |
--|       x_um_type   IN VARCHAR2(10) -  UOM Type                            |
--|                                                                          |
--|  RETURNS                                                                 |
--|       Um_Type - If Usage UOM contains a valid value                      |
--|                                                                          |
--|  HISTORY                                                                 |
--|       04/12/2001 Uday Moogala - Created                                  |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

PROCEDURE Validate_Usage_Um
(
  p_Usage_Um   IN sy_uoms_mst.Um_Code%TYPE
, x_Um_Type    OUT NOCOPY sy_uoms_mst.Um_Type%TYPE
)
IS
  CURSOR Cur_Usage_Um
  IS
    SELECT
         Um_Type
    FROM
         sy_uoms_mst
    WHERE
        Um_Code   = p_Usage_Um ;

BEGIN

  OPEN Cur_Usage_Um;
  FETCH Cur_Usage_Um INTO x_Um_Type;
  CLOSE Cur_Usage_Um;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END Validate_Usage_Um ;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_lot_cost_mthd_code                                        |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates lot cost_mthd_code                                       |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the lot cost Method Code exists       |
--|       on cm_mthd_mst                                                     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_cost_mthd_code IN VARCHAR2(4) - Lot Cost Method Code             |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If Cost Method contains a valid value                      |
--|       FALSE - If Cost Method contains an invalid value                   |
--|                                                                          |
--|  HISTORY                                                                 |
--|       07-Apr-2004  Dinesh Vadivel - Created                              |
--|      								     |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_lot_cost_mthd_code
(
p_cost_mthd_code IN ic_item_mst.cost_mthd_code%TYPE
)
RETURN BOOLEAN
IS
  CURSOR cur_cm_mthd_mst
  IS
  SELECT	cost_mthd_code
  FROM		cm_mthd_mst
  WHERE		cm_mthd_mst.cost_mthd_code = p_cost_mthd_code
  AND		cm_mthd_mst.delete_mark    = 0
  AND		lot_actual_cost = 1;

  l_cost_mthd_code ic_item_mst.cost_mthd_code%TYPE;

BEGIN

  OPEN cur_cm_mthd_mst;
  FETCH cur_cm_mthd_mst INTO l_cost_mthd_code;
  IF (cur_cm_mthd_mst%NOTFOUND)
  THEN
    CLOSE cur_cm_mthd_mst;
    RETURN FALSE;
  ELSE
    CLOSE cur_cm_mthd_mst;
    RETURN TRUE;
  END IF;
EXCEPTION
    WHEN OTHERS THEN
      RAISE;
END Validate_lot_cost_mthd_code;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_lot_id		                                     |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates lot Id		                                     |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates the lot and returns Lot ID from ic_lots_mst|
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_id	IN	ic_item_mst.item_id%TYPE - Item Id	     |
--|       p_lot_no	IN	ic_lots_mst.lot_no%TYPE - Lot No	     |
--|	  p_sublot_no	IN	ic_lots_mst.sublot_no%TYPE -Sublot No        |
--|									     |
--|  RETURNS                                                                 |
--|       Lot Id                NUMBER					     |
--|                                                                          |
--|  HISTORY                                                                 |
--|       15-Apr-2004  Anand Thiyagarajan - Created                          |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION VALIDATE_LOT_ID
(
p_item_id 		IN		ic_item_mst.item_id%TYPE
, p_lot_no		IN		ic_lots_mst.lot_no%TYPE
, p_sublot_no		IN		ic_lots_mst.sublot_no%TYPE
)
RETURN NUMBER
IS
  l_lot_id		ic_lots_mst.lot_id%TYPE;
BEGIN

  BEGIN
    SELECT	lot_id
    INTO	l_lot_id
    FROM   	ic_lots_mst
    WHERE	item_id = p_item_id
    AND		lot_no = p_lot_no
    AND		sublot_no = p_sublot_no
    AND		ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_lot_id := NULL;
  END;

  RETURN ( l_lot_id );

END VALIDATE_LOT_ID;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_lot_id		                                     |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates lot Id		                                     |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the lot ID exists in ic_lots_mst	     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_id	IN	ic_item_mst.item_id%TYPE - Item Id	     |
--|       p_lot_id	IN	ic_lots_mst.lot_ID%TYPE - Lot Id	     |
--|									     |
--|  RETURNS                                                                 |
--|       TRUE		-	If Lot Exists in ic_lots_mst		     |
--|       FALSE		-	If Lot Doesnt Exist in ic_lots_mst	     |
--|                                                                          |
--|  HISTORY                                                                 |
--|       15-Apr-2004  Anand Thiyagarajan - Created                          |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION VALIDATE_LOT_ID
(
p_item_id 		IN		ic_item_mst.item_id%TYPE
, p_lot_id        	IN		ic_lots_mst.lot_id%TYPE
)
RETURN BOOLEAN
IS
  l_cnt			NUMBER;
BEGIN

  BEGIN
	SELECT	1
	INTO	l_cnt
	FROM	ic_lots_mst
	WHERE	item_id = p_item_id
        AND	lot_id = p_lot_id
	AND	ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_cnt := 0;
  END;

  IF l_cnt > 0 THEN
    RETURN (TRUE);
  ELSE
    RETURN (FALSE);
  END IF;

END VALIDATE_LOT_ID;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_lot_No		                                     |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates lot No		                                     |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the lot No exists in ic_lots_mst	     |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_item_id	IN	ic_item_mst.item_id%TYPE - Item Id	     |
--|       p_lot_no	IN	ic_lots_mst.lot_no%TYPE - Lot No	     |
--|       p_sublot_no	IN	ic_lots_mst.lot_no%TYPE - sublot No	     |
--|									     |
--|  RETURNS                                                                 |
--|       TRUE		-	If Lot Exists in ic_lots_mst		     |
--|       FALSE		-	If Lot Doesnt Exist in ic_lots_mst	     |
--|                                                                          |
--|  HISTORY                                                                 |
--|       15-Apr-2004  Anand Thiyagarajan - Created                          |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION VALIDATE_LOT_NO
(
p_item_id 		IN		ic_item_mst.item_id%TYPE
, p_lot_no        	IN		ic_lots_mst.lot_no%TYPE
, p_sublot_no        	IN		ic_lots_mst.sublot_no%TYPE
)
RETURN BOOLEAN
IS
  l_cnt			NUMBER;
BEGIN

  BEGIN
	SELECT	1
	INTO	l_cnt
	FROM	ic_lots_mst
        WHERE	item_id = p_item_id
        AND	lot_no = p_lot_no
	AND	sublot_no = p_sublot_no
	AND	ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_cnt := 0;
  END;
  IF l_cnt > 0 THEN
    RETURN (TRUE);
  ELSE
    RETURN (FALSE);
  END IF;

END VALIDATE_LOT_NO;

/* ANTHIYAG Added for Release 12.0 Start */

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   validate_legal_entity_id                                                           *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Legal Entity                                                             *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Legal Entity Id exists                            *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_legal_entity_id             IN          xle_entity_profiles.legal_entity_id%TYPE *
  *                                                                                      *
  * RETURNS                                                                              *
  *   TRUE    - If Legal Entity Exists                                                   *
  *   FALSE   - If Legal Entity Doesnt Exist                                             *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION validate_legal_entity_id
  (
  p_legal_entity_id             IN          xle_entity_profiles.legal_entity_id%TYPE
  )
  RETURN BOOLEAN
  IS

    /**********
    * Cursors *
    **********/

    CURSOR      Cur_legal_entity
    IS
    SELECT      legal_entity_id
    FROM        xle_entity_profiles
    WHERE       legal_entity_id = p_legal_entity_id;

    /******************
    * Local Variables *
    ******************/

    l_legal_entity_id           xle_entity_profiles.legal_entity_id%TYPE ;

  BEGIN
    OPEN  Cur_legal_entity;
    FETCH Cur_legal_entity INTO l_legal_entity_id;
    IF    Cur_legal_entity%NOTFOUND
    THEN
      CLOSE   Cur_legal_entity;
      RETURN FALSE;
    ELSE
      CLOSE Cur_legal_entity;
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END validate_legal_entity_id;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_Cost_type_id                                                              *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Cost Type Id                                                             *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Cost Type Id exists                               *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE            *
  *                                                                                      *
  * RETURNS                                                                              *
  *   TRUE    - If cost Type Exists                                                      *
  *   FALSE   - If Cost Type Doesnt Exist                                                *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_Cost_type_id
  (
  p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE
  )
  RETURN BOOLEAN
  IS

    /**********
    * Cursors *
    **********/

    CURSOR      Cur_cost_type
    IS
    SELECT      cost_type_id
    FROM        cm_mthd_mst
    WHERE       cost_type_id = p_cost_type_id;

    /******************
    * Local Variables *
    ******************/

    l_cost_type_id            cm_mthd_mst.cost_Type_id%TYPE;

  BEGIN
    OPEN  Cur_cost_type;
    FETCH Cur_cost_type INTO l_cost_type_id;
    IF    Cur_cost_type%NOTFOUND
    THEN
      CLOSE   Cur_cost_type;
      RETURN FALSE;
    ELSE
      CLOSE Cur_cost_type;
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_Cost_type_id;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_Cost_type_id                                                              *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Cost Type Id                                                             *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Cost Type Id exists                               *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE            *
  *   p_Type                        IN          VARCHAR2                                 *
  *                                                                                      *
  * RETURNS                                                                              *
  *   TRUE    - If cost Type Exists                                                      *
  *   FALSE   - If Cost Type Doesnt Exist                                                *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_Cost_type_id
  (
  p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE,
  p_Type                        IN          VARCHAR2
  )
  RETURN BOOLEAN
  IS

    /**********
    * Cursors *
    **********/

    CURSOR      Cur_cost_type
    IS
    SELECT      cost_type_id
    FROM        cm_mthd_mst
    WHERE       cost_type_id = p_cost_type_id
    AND         (cost_type = decode(p_type, 'A', 1, 'S', 0, 'L', 6,'AS', 0) or cost_type = decode(p_type, 'A', 1, 'S', 0, 'L', 6, 'AS', 1));

    /******************
    * Local Variables *
    ******************/

    l_cost_type_id            cm_mthd_mst.cost_Type_id%TYPE;

  BEGIN
    OPEN  Cur_cost_type;
    FETCH Cur_cost_type INTO l_cost_type_id;
    IF    Cur_cost_type%NOTFOUND
    THEN
      CLOSE   Cur_cost_type;
      RETURN FALSE;
    ELSE
      CLOSE Cur_cost_type;
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_Cost_type_id;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_Cost_type_code                                                            *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Cost Method Code                                                         *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Cost Method Code exists                           *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_cost_mthd_code              IN          cm_mthd_mst.cost_mthd_code%TYPE          *
  *                                                                                      *
  * RETURNS                                                                              *
  *   Cost Type Id                                                                       *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/

  FUNCTION Validate_cost_type_code
  (
  p_cost_mthd_code              IN          cm_mthd_mst.cost_mthd_code%TYPE
  )
  RETURN NUMBER
  IS
    /**********
    * Cursors *
    **********/

    CURSOR      Cur_cost_type
    IS
    SELECT      cost_type_id
    FROM        cm_mthd_mst
    WHERE       cost_mthd_code = p_cost_mthd_code;

    /******************
    * Local Variables *
    ******************/

    l_cost_type_id            cm_mthd_mst.cost_Type_id%TYPE;

  BEGIN
    OPEN  Cur_cost_type;
    FETCH Cur_cost_type INTO l_cost_type_id;
    IF    Cur_cost_type%NOTFOUND
    THEN
      CLOSE   Cur_cost_type;
      RETURN NULL;
    ELSE
      CLOSE Cur_cost_type;
      RETURN l_cost_type_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_Cost_type_Code;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_Cost_type_code                                                            *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Cost Method Code                                                         *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Cost Method Code exists                           *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_cost_mthd_code              IN          cm_mthd_mst.cost_mthd_code%TYPE          *
  *   p_Type                        IN          VARCHAR2                                 *
  *                                                                                      *
  * RETURNS                                                                              *
  *   Cost Type Id                                                                       *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_cost_type_code
  (
  p_cost_mthd_code              IN          cm_mthd_mst.cost_mthd_code%TYPE,
  p_Type                        IN          VARCHAR2
  )
  RETURN NUMBER
  IS
    /**********
    * Cursors *
    **********/

    CURSOR      Cur_cost_type
    IS
    SELECT      cost_type_id
    FROM        cm_mthd_mst
    WHERE       cost_mthd_code = p_cost_mthd_code
    AND         (cost_type = decode(p_type, 'A', 1, 'S', 0, 'L', 6,'AS', 0) or cost_type = decode(p_type, 'A', 1, 'S', 0, 'L', 6, 'AS', 1));

    /******************
    * Local Variables *
    ******************/

    l_cost_type_id            cm_mthd_mst.cost_Type_id%TYPE;

  BEGIN
    OPEN  Cur_cost_type;
    FETCH Cur_cost_type INTO l_cost_type_id;
    IF    Cur_cost_type%NOTFOUND
    THEN
      CLOSE   Cur_cost_type;
      RETURN NULL;
    ELSE
      CLOSE Cur_cost_type;
      RETURN l_cost_type_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_Cost_type_Code;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   validate_period_id                                                                 *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Period                                                                   *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Period Id exists                                  *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_period_id                   IN          gmf_period_statuses.period_id%TYPE       *
  *                                                                                      *
  * RETURNS                                                                              *
  *   TRUE    - If Period Exists                                                         *
  *   FALSE   - If Period Doesnt Exist                                                   *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_period_id
  (
  p_period_id                   IN          gmf_period_statuses.period_id%TYPE
  )
  RETURN BOOLEAN
  IS

    /**********
    * Cursors *
    **********/

    CURSOR      Cur_period
    IS
    SELECT      period_id
    FROM        gmf_period_statuses
    WHERE       period_id = p_period_id;

    /******************
    * Local Variables *
    ******************/

    l_period_id            gmf_period_statuses.period_id%TYPE;

  BEGIN
    OPEN  Cur_period;
    FETCH Cur_period INTO l_period_id;
    IF    Cur_period%NOTFOUND
    THEN
      CLOSE   Cur_period;
      RETURN FALSE;
    ELSE
      CLOSE Cur_period;
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_period_id;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   validate_period_id                                                                 *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Period                                                                   *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Period Id exists                                  *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_period_id                   IN          gmf_period_statuses.period_id%TYPE       *
  *                                                                                      *
  * RETURNS                                                                              *
  *   TRUE    - If Period Exists                                                         *
  *   FALSE   - If Period Doesnt Exist                                                   *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_period_id
  (
  p_period_id                   IN          gmf_period_statuses.period_id%TYPE,
  p_cost_type_id                OUT NOCOPY  gmf_period_statuses.cost_type_id%TYPE
  )
  RETURN BOOLEAN
  IS

    /**********
    * Cursors *
    **********/

    CURSOR      Cur_period
    IS
    SELECT      period_id, cost_type_id
    FROM        gmf_period_statuses
    WHERE       period_id = p_period_id;

    /******************
    * Local Variables *
    ******************/

    l_period_id            gmf_period_statuses.period_id%TYPE;

  BEGIN
    OPEN  Cur_period;
    FETCH Cur_period INTO l_period_id, p_cost_type_id;
    IF    Cur_period%NOTFOUND
    THEN
      CLOSE   Cur_period;
      RETURN FALSE;
    ELSE
      CLOSE Cur_period;
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_period_id;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_period_code                                                               *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Period Code                                                              *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Period Code exists                                *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_organization_id             IN          mtl_organizations.organization_id%TYPE   *
  *   p_calendar_code               IN          cm_cldr_hdr_b.calendar_code%TYPE         *
  *   p_period_code                 IN          cm_cldr_dtl.period_code%TYPE             *
  *   p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE            *
  *                                                                                      *
  * RETURNS                                                                              *
  *   Period Id                                                                          *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_period_code
  (
  p_organization_id             IN          mtl_organizations.organization_id%TYPE,
  p_calendar_code               IN          cm_cldr_hdr_b.calendar_code%TYPE,
  p_period_code                 IN          cm_cldr_dtl.period_code%TYPE,
  p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE
  )
  RETURN NUMBER
  IS

    /**********
    * Cursors *
    **********/

    CURSOR      Cur_period
    IS
    SELECT      period_id
    FROM        gmf_period_statuses a,
                org_organization_definitions b
    WHERE       b.organization_id = p_organization_id
    AND         b.legal_entity = a.legal_entity_id
    AND         a.calendar_code = p_calendar_code
    AND         a.period_code = p_period_code
    AND         a.cost_type_id = p_cost_type_id;

    /******************
    * Local Variables *
    ******************/

    l_period_id            gmf_period_statuses.period_id%TYPE;

  BEGIN
    OPEN  Cur_period;
    FETCH Cur_period INTO l_period_id;
    IF    Cur_period%NOTFOUND
    THEN
      CLOSE   Cur_period;
      RETURN NULL;
    ELSE
      CLOSE Cur_period;
      RETURN l_period_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_period_code;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   validate_organization_id                                                           *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Organization                                                             *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Organization Id exists                            *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_organization_id             IN          mtl_organizations.organization_id%TYPE   *
  *                                                                                      *
  * RETURNS                                                                              *
  *   TRUE    - If Organization Exists                                                   *
  *   FALSE   - If Organization Doesnt Exist                                             *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_organization_id
  (
  p_organization_id             IN          mtl_organizations.organization_id%TYPE
  )
  RETURN BOOLEAN
  IS

    /**********
    * Cursors *
    **********/

    CURSOR      Cur_organization
    IS
    SELECT      organization_id
    FROM        mtl_parameters
    WHERE       organization_id = p_organization_id
    AND         process_enabled_flag = 'Y';

    /******************
    * Local Variables *
    ******************/

    l_organization_id            mtl_organizations.organization_id%TYPE;

  BEGIN
    OPEN  Cur_organization;
    FETCH Cur_organization INTO l_organization_id;
    IF    Cur_organization%NOTFOUND
    THEN
      CLOSE   Cur_organization;
      RETURN FALSE;
    ELSE
      CLOSE Cur_organization;
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_organization_id;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_Organization_code                                                         *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Organization Code                                                        *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Organization Code exists                          *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_organization_code           IN          mtl_organizations.organization_code%TYPE *
  *                                                                                      *
  * RETURNS                                                                              *
  *   Organization Id                                                                    *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_Organization_code
  (
  p_organization_code           IN          mtl_parameters.organization_code%TYPE
  )
  RETURN NUMBER
  IS

    /**********
    * Cursors *
    **********/

    CURSOR      Cur_organization
    IS
    SELECT      organization_id
    FROM        mtl_parameters
    WHERE       organization_code = p_organization_code;

    /******************
    * Local Variables *
    ******************/

    l_organization_id            mtl_organizations.organization_id%TYPE;

  BEGIN
    OPEN  Cur_organization;
    FETCH Cur_organization INTO l_organization_id;
    IF    Cur_organization%NOTFOUND
    THEN
      CLOSE   Cur_organization;
      RETURN NULL;
    ELSE
      CLOSE Cur_organization;
      RETURN l_organization_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_Organization_code;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_inventory_item_id                                                         *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Inventory Item Id                                                        *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Inventory Item Id exists                          *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_inventory_item_id           IN          mtl_system_items_b.inventory_item_id%TYPE*
  *   p_organization_id             IN          mtl_organizations.organization_id%TYPE   *
  *                                                                                      *
  * RETURNS                                                                              *
  *   TRUE    - If Item Exists                                                           *
  *   FALSE   - If Item Doesnt Exist                                                     *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_inventory_item_id
  (
  p_inventory_item_id           IN          mtl_system_items_b.inventory_item_id%TYPE,
  p_organization_id             IN          mtl_organizations.organization_id%TYPE
  )
  RETURN BOOLEAN
  IS

    /**********
    * Cursors *
    **********/

    CURSOR      Cur_item
    IS
    SELECT      inventory_item_id
    FROM        mtl_system_items_b
    WHERE       inventory_item_id = p_inventory_item_id
    AND         organization_id = p_organization_id;

    /******************
    * Local Variables *
    ******************/

    l_inventory_item_id             mtl_system_items_b.inventory_item_id%TYPE;

  BEGIN
    OPEN  Cur_item;
    FETCH Cur_item INTO l_inventory_item_id;
    IF    Cur_item%NOTFOUND
    THEN
      CLOSE   Cur_item;
      RETURN FALSE;
    ELSE
      CLOSE Cur_item;
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_inventory_item_id;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_item_number                                                               *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Item Number                                                              *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Item Number exists                                *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_organization_id             IN          mtl_organizations.organization_id%TYPE   *
  *   p_item_number                 IN          mtl_item_flexfields.item_number%TYPE     *
  *                                                                                      *
  * RETURNS                                                                              *
  *   Inventory Item Id                                                                  *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_item_number
  (
  p_item_number                 IN          mtl_item_flexfields.item_number%TYPE,
  p_organization_id             IN          mtl_organizations.organization_id%TYPE
  )
  RETURN NUMBER
  IS

    /**********
    * Cursors *
    **********/

    CURSOR      Cur_item
    IS
    SELECT      inventory_item_id
    FROM        mtl_item_flexfields
    WHERE       item_number = p_item_number
    AND         organization_id = p_organization_id;

    /******************
    * Local Variables *
    ******************/

    l_inventory_item_id             mtl_system_items_b.inventory_item_id%TYPE;

  BEGIN
    OPEN  Cur_item;
    FETCH Cur_item INTO l_inventory_item_id;
    IF    Cur_item%NOTFOUND
    THEN
      CLOSE   Cur_item;
      RETURN NULL;
    ELSE
      CLOSE Cur_item;
      RETURN l_inventory_item_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_item_number;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_lot_number                                                                *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Lot Number                                                               *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Lot Number exists                                 *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_inventory_item_id           IN          mtl_system_items_b.inventory_item_id%TYPE*
  *   p_organization_id             IN          mtl_organizations.organization_id%TYPE   *
  *   p_lot_number                  in          mtl_lot_numbers.lot_number%TYPE          *
  *                                                                                      *
  * RETURNS                                                                              *
  *   TRUE    - If Lot Exists                                                            *
  *   FALSE   - If Lot Doesnt Exist                                                      *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_Lot_Number
  (
  p_lot_number                  IN          mtl_lot_numbers.lot_number%TYPE,
  p_inventory_item_id           IN          mtl_system_items_b.inventory_item_id%TYPE,
  p_organization_id             IN          mtl_organizations.organization_id%TYPE
  )
  RETURN BOOLEAN
  IS

    /**********
    * Cursors *
    **********/

    CURSOR      Cur_lot_number
    IS
    SELECT      lot_number
    FROM        mtl_lot_numbers
    WHERE       inventory_item_id = p_inventory_item_id
    AND         organization_id = p_organization_id
    AND         lot_number = p_lot_number;

    /******************
    * Local Variables *
    ******************/

    l_lot_number              mtl_lot_numbers.lot_number%TYPE;

  BEGIN
    OPEN  Cur_lot_number;
    FETCH Cur_lot_number INTO l_lot_number;
    IF    Cur_lot_number%NOTFOUND
    THEN
      CLOSE   Cur_lot_number;
      RETURN FALSE;
    ELSE
      CLOSE Cur_lot_number;
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_Lot_Number;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_lot_Cost_type_id                                                          *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Lot Cost Type Id                                                         *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Lot Cost Type Id exists                           *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE            *
  *                                                                                      *
  * RETURNS                                                                              *
  *   TRUE    - If Lot Cost Type Exists                                                  *
  *   FALSE   - If Lot Cost Type Doesnt Exist                                            *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_Lot_Cost_type_id
  (
  p_cost_type_id                IN          cm_mthd_mst.cost_type_id%TYPE
  )
  RETURN BOOLEAN
  IS

    /**********
    * Cursors *
    **********/
    CURSOR        cur_cm_mthd_mst
    IS
    SELECT	      cost_type_id
    FROM		      cm_mthd_mst
    WHERE		      cm_mthd_mst.cost_type_id = p_cost_type_id
    AND		        cm_mthd_mst.delete_mark    = 0
    AND		        cost_type = 6;

    l_cost_type_id    cm_mthd_mst.cost_type_id%TYPE;

  BEGIN
    OPEN  cur_cm_mthd_mst;
    FETCH cur_cm_mthd_mst INTO l_cost_type_id;
    IF cur_cm_mthd_mst%NOTFOUND
    THEN
      CLOSE cur_cm_mthd_mst;
      RETURN FALSE;
    ELSE
      CLOSE cur_cm_mthd_mst;
      RETURN TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_Lot_Cost_type_id;

  /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_Lot_Cost_Type                                                       *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates Lot Cost Method Code                                                     *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function validates that the Lot Cost Method Code exists                       *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_cost_mthd_code              IN          cm_mthd_mst.cost_mthd_code%TYPE          *
  *                                                                                      *
  * RETURNS                                                                              *
  *   Lot Cost Type Id                                                                   *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Anand Thiyagarajan - Created                                          *
  ***************************************************************************************/
  FUNCTION Validate_Lot_Cost_Type
  (
  p_cost_mthd_code              IN          cm_mthd_mst.cost_mthd_code%TYPE
  )
  RETURN NUMBER
  IS

    /**********
    * Cursors *
    **********/
    CURSOR        cur_cm_mthd_mst
    IS
    SELECT	      cost_type_id
    FROM		      cm_mthd_mst
    WHERE		      cm_mthd_mst.cost_mthd_code = p_cost_mthd_code
    AND		        cm_mthd_mst.delete_mark    = 0
    AND		        cost_type = 6;

    l_cost_type_id        cm_mthd_mst.cost_type_id%TYPE;

  BEGIN
    OPEN  cur_cm_mthd_mst;
    FETCH cur_cm_mthd_mst INTO l_cost_type_id;
    IF cur_cm_mthd_mst%NOTFOUND
    THEN
      CLOSE cur_cm_mthd_mst;
      RETURN NULL;
    ELSE
      CLOSE cur_cm_mthd_mst;
      RETURN l_cost_type_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Validate_Lot_Cost_Type;


 /***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Fetch_alloc_id                                                                     *
  *                                                                                      *
  * USAGE                                                                                *
  *   gets teh alloc id                                                                  *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function gets the alloc id using alloc code and le id                         *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_Alloc_Code  IN gl_aloc_mst.Alloc_Code%TYPE                                       *
  *   p_le_id     IN xle_entity_profiles.legal_entity_id%TYPE                            *
  *                                                                                      *
  * RETURNS                                                                              *
  *   Alloc Id                                                                           *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Jahnavi Boppana   - Created                                           *
  ***************************************************************************************/
FUNCTION Fetch_Alloc_Id
(
  p_Alloc_Code  IN gl_aloc_mst.Alloc_Code%TYPE
, p_le_id     IN xle_entity_profiles.legal_entity_id%TYPE
)
RETURN NUMBER
   IS
     CURSOR Cur_Alloc_Id
     IS
       SELECT
            Alloc_id
       FROM
            gl_aloc_mst
       WHERE
           Alloc_Code	= p_Alloc_Code
       AND	legal_entity_id 	= p_le_id
       AND delete_mark 	= 0;

     l_Alloc_id    gl_aloc_mst.Alloc_id%TYPE := '' ;

BEGIN

     OPEN Cur_Alloc_Id;
     FETCH Cur_Alloc_Id INTO l_Alloc_Id;
     IF (Cur_Alloc_Id%NOTFOUND)
     THEN
       CLOSE Cur_Alloc_Id;
       RETURN NULL;
     ELSE
       CLOSE Cur_Alloc_Id;
       RETURN l_Alloc_Id;
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;

End Fetch_Alloc_Id ;


/***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_Basis_account_key                                                         *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates the Basis_account_key                                                    *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *   This function returns the account id for teh account key                           *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_Basis_account_key   IN  gl_aloc_bas.Basis_account_key%TYPE                       *
  *   p_le_id     IN xle_entity_profiles.legal_entity_id%TYPE                            *
  *                                                                                      *
  * RETURNS                                                                              *
  *   Account Id                                                                         *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Jahnavi Boppana   - Created                                           *
  ***************************************************************************************/


FUNCTION Validate_Basis_account_key
(
  p_Basis_account_key   IN  gl_aloc_bas.Basis_account_key%TYPE
, p_le_id     IN xle_entity_profiles.legal_entity_id%TYPE
)
RETURN NUMBER
 IS

   CURSOR Cur_chart_of_accounts_id
     IS
       SELECT chart_of_accounts_id
       FROM  gmf_legal_entities
       WHERE legal_entity_id = p_le_id ;

   l_account_id gl_aloc_bas.Basis_account_id%TYPE;
   l_chart_of_accounts_id gmf_legal_entities.chart_of_accounts_id%TYPE;

  BEGIN

     OPEN Cur_chart_of_accounts_id;
     FETCH Cur_chart_of_accounts_id INTO l_chart_of_accounts_id;
     IF (Cur_chart_of_accounts_id%NOTFOUND)
     THEN
       CLOSE Cur_chart_of_accounts_id;
       RETURN NULL;
     ELSE
       CLOSE Cur_chart_of_accounts_id;
       l_account_id := fnd_flex_ext.get_ccid(application_short_name  	=> 'SQLGL',
                                               key_flex_code            => 'GL#',
                                               structure_number         => l_chart_of_accounts_id,
                                               validation_date          => SYSDATE,
                                               concatenated_segments    =>  p_Basis_account_key);
       IF l_account_id = 0 THEN
          RETURN NULL;
       ELSE
          RETURN l_account_id;
       END IF;

     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;

End Validate_Basis_account_key ;

/***************************************************************************************
  * FUNCTION NAME                                                                        *
  *   Validate_account_id                                                                *
  *                                                                                      *
  * USAGE                                                                                *
  *   Validates the account id                                                           *
  *                                                                                      *
  * DESCRIPTION                                                                          *
  *        Validates the account id                                                      *
  *                                                                                      *
  * PARAMETERS                                                                           *
  *   p_Basis_account_key   IN  gl_aloc_bas.Basis_account_key%TYPE                       *
  *   p_le_id     IN xle_entity_profiles.legal_entity_id%TYPE                            *
  *                                                                                      *
  * RETURNS                                                                              *
  *   TRUE/FALSE                                                                       *
  *                                                                                      *
  * HISTORY                                                                              *
  *   20-Oct-2005  Jahnavi Boppana   - Created                                           *
  ***************************************************************************************/

FUNCTION Validate_ACCOUNT_ID
(
  p_Basis_account_id  IN  gl_aloc_bas.Basis_account_id%TYPE
, p_le_id     IN xle_entity_profiles.legal_entity_id%TYPE
)
RETURN BOOLEAN
   IS

   CURSOR Cur_accounts_id
     IS
       SELECT code_combination_id
       FROM gl_code_combinations_kfv glc, gmf_legal_entities gle
       WHERE gle.legal_entity_id = p_le_id
             AND glc.code_combination_id = p_Basis_account_id
             AND gle.chart_of_accounts_id = glc.chart_of_accounts_id ;

   l_account_id gl_aloc_bas.Basis_account_id%TYPE;

  BEGIN

     OPEN Cur_accounts_id;
     FETCH Cur_accounts_id INTO l_account_id;
     IF (Cur_accounts_id%NOTFOUND)
     THEN
       CLOSE Cur_accounts_id;
       RETURN FALSE;
     ELSE
       CLOSE Cur_accounts_id;
       RETURN TRUE;
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;

End Validate_ACCOUNT_ID ;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Usage_Uom                                                 |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates UOM                                                      |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the UOM codes exists                  |
--|       on mtl_units_of_measure                                            |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    P_usgae_uom IN mtl_units_of_measure.uom_code%TYPE -  UOM code         |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If UOM code is valid value                                 |
--|       FALSE - If UOM codeis an invalid value                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|  20-Oct-2005 Prasad Marada  - Created for UOM Code validation            |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_Usage_Uom
(
  P_usgae_uom IN mtl_units_of_measure.uom_code%TYPE
) RETURN BOOLEAN
IS

  CURSOR Cur_uom IS
    SELECT  uom_code
    FROM mtl_units_of_measure
    WHERE uom_code = P_usgae_uom;

  l_usgae_uom mtl_units_of_measure.uom_code%TYPE ;

BEGIN

  OPEN Cur_uom;
  FETCH Cur_uom INTO l_usgae_uom;
  IF (Cur_uom%NOTFOUND)
  THEN
    CLOSE Cur_uom;
    RETURN FALSE;
  ELSE
    CLOSE Cur_uom;
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Validate_Usage_Uom;

-- Func start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       Validate_Validate_same_class_Uom                                   |
--|                                                                          |
--|  USAGE                                                                   |
--|       Validates UOM                                                      |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|       This function validates that the UOM codes exists                  |
--|       on mtl_units_of_measure for the item's class                       |
--|                                                                          |
--|  PARAMETERS                                                              |
--|    P_usgae_uom IN mtl_units_of_measure.uom_code%TYPE -  UOM code         |
--|                                                                          |
--|  RETURNS                                                                 |
--|       TRUE  - If UOM code is valid value                                 |
--|       FALSE - If UOM codeis an invalid value                             |
--|                                                                          |
--|  HISTORY                                                                 |
--|  10-Oct-2006 Anand Thiyagarajan  - Created for UOM Code validation       |
--|                                                                          |
--+==========================================================================+
-- Func end of comments

FUNCTION Validate_same_class_Uom
(
  P_uom_code IN mtl_units_of_measure.uom_code%TYPE,
  p_inventory_item_id IN mtl_system_items_b.inventory_item_id%TYPE,
  p_organization_id IN mtl_system_items_b.organization_id%TYPE
) RETURN BOOLEAN
IS

  CURSOR Cur_uom
  IS
  SELECT          c.uom_code
  FROM            mtl_system_items_b a,
                  mtl_units_of_measure b,
                  mtl_units_of_measure c
  WHERE           a.inventory_item_id = p_inventory_item_id
  AND             a.organization_id = p_organization_id
  AND             a.primary_uom_code = b.uom_code
  AND             b.uom_class = c.uom_class
  AND             c.uom_code= P_uom_code;

  l_uom_code      mtl_units_of_measure.uom_code%TYPE;
BEGIN

  OPEN Cur_uom;
  FETCH Cur_uom INTO l_uom_code;
  IF (Cur_uom%NOTFOUND)
  THEN
    CLOSE Cur_uom;
    RETURN FALSE;
  ELSE
    CLOSE Cur_uom;
    RETURN TRUE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Validate_same_class_Uom;

-- Procedure start of comments
--+==========================================================================+
--|  FUNCTION NAME                                                           |
--|       validate_usage_uom                                                 |
--|                                                                          |
--|  USAGE                                                                   |
--|       Returns UOM Class                                                  |
--|                                                                          |
--|  DESCRIPTION                                                             |
--|     This procedure returns the UOM class for the UOM code                |
--|                                                                          |
--|  PARAMETERS                                                              |
--|       p_usage_uom   IN  mtl_units_of_measure.uom_code%TYPE UOM Code      |
--|       p_usage_uom_class OUT mtl_units_of_measure.uom_class%TYPE          |
--|                                                                          |
--|  RETURNS                                                                 |
--|       Return UOM class                                                   |
--|                                                                          |
--|  HISTORY                                                                 |
--|  20-Oct-2005 Prasad Marada - Created to return the UOM class             |
--|                                                                          |
--+==========================================================================+
-- Procedure end of comments

PROCEDURE validate_usage_uom (
   p_usage_uom IN   mtl_units_of_measure.uom_code%TYPE,
   p_usage_uom_class OUT NOCOPY mtl_units_of_measure.uom_class%TYPE
 ) IS

  CURSOR cur_uom IS
  SELECT uom_class
  FROM mtl_units_of_measure
  WHERE uom_code = p_usage_uom;

BEGIN
  OPEN cur_uom;
  FETCH cur_uom INTO p_usage_uom_class;
  CLOSE cur_uom ;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END validate_usage_uom ;


PROCEDURE Validate_Resource
(
  p_Resources          IN  cr_rsrc_mst.Resources%TYPE
, x_resource_uom       OUT NOCOPY cr_rsrc_mst.std_usage_uom%TYPE
, x_resource_uom_class OUT NOCOPY mtl_units_of_measure.uom_class%TYPE
)
IS
  CURSOR Cur_resources
  IS
    SELECT
         rm.std_usage_uom, uom.uom_class
    FROM
         mtl_units_of_measure uom, cr_rsrc_mst rm
    WHERE
        rm.resources  = p_Resources
    AND uom.uom_code  = rm.std_usage_uom
    AND rm.delete_mark = 0;

BEGIN

  OPEN Cur_resources;
  FETCH Cur_resources INTO x_resource_uom, x_resource_uom_class;
  CLOSE Cur_resources;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

End Validate_Resource;

/* ANTHIYAG Added for Release 12.0 End */

END GMF_validations_PVT;

/
