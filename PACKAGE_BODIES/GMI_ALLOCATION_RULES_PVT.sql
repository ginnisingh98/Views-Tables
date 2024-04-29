--------------------------------------------------------
--  DDL for Package Body GMI_ALLOCATION_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMI_ALLOCATION_RULES_PVT" AS
/*  $Header: GMIVALRB.pls 120.0 2005/05/25 15:42:07 appldev noship $  */

/*  Global variables */
G_PKG_NAME  CONSTANT  VARCHAR2(30):='GMI_ALLOCATION_RULES_PVT';


/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Get_Allocation_Parms                                                 |
 |                                                                         |
 | USAGE                                                                   |
 |    Used to retrieve the allocation rules                                |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    This procedure is used to retrieve all details from op_alot_prm      |
 |                                                                         |
 | PARAMETERS                                                              |
 |    p_co_code     IN VARCHAR2(4)  - Customer Company Code                |
 |    p_cust_no     IN VARCHAR2(32) - Customer Number                      |
 |    p_alloc_class IN VARCHAR2(8)  - Allocation Class                     |
 |    x_op_alot_prm OUT NOCOPY RECORD      - Record containing op_alot_prm |
 |                                                                         |
 | HISTORY                                                                 |
 |    15-DEC-1999      K.Y.Hunt      Created
 +=========================================================================+
*/

-- HW BUG#:2643440, removed intitalization of G_MISS_XXX
-- from p_co_code,p_cust_no, p_alloc_class,p_of_cust_id,
-- p_ship_to_org_id,p_org_id.
PROCEDURE GET_ALLOCATION_PARMS
( p_co_code            IN  OP_CUST_MST.CO_CODE%TYPE default NULL
, p_cust_no            IN  OP_CUST_MST.CUST_NO%TYPE default NULL
, p_alloc_class        IN  IC_ITEM_MST.ALLOC_CLASS%TYPE default NULL
, p_of_cust_id         IN  NUMBER default NULL
, p_ship_to_org_id     IN  NUMBER default NULL
, p_org_id             IN  NUMBER default NULL
, x_return_status      OUT NOCOPY VARCHAR2
, x_op_alot_prm        OUT NOCOPY op_alot_prm%ROWTYPE
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
)
IS
l_api_name           CONSTANT VARCHAR2 (30) := 'GET_ALLOCATION_PARMS';
l_cust_id            OP_CUST_MST.CUST_ID%TYPE;
l_msg_count          NUMBER  :=0;
l_msg_data           VARCHAR2(2000);
l_return_status      VARCHAR2(1);
l_op_alot_prm        OP_ALOT_PRM%ROWTYPE;

CURSOR op_cust_mst_c1 is
SELECT cust_id
FROM op_cust_mst
WHERE co_code = p_co_code and cust_no = p_cust_no;

--BUG 1655007 - Ensure delete_marked rows are ignored
--===================================================
/*CURSOR op_alot_prm_c1 is
SELECT *
FROM op_alot_prm
WHERE cust_id=l_cust_id and alloc_class = p_alloc_class and delete_mark=0;

CURSOR op_alot_prm_c2 is
SELECT *
FROM op_alot_prm
WHERE cust_id IS NULL and alloc_class = p_alloc_class and delete_mark=0;
*/
/* bug 2245351, use generic of_cust_id, and mtl_org_id for the record
  cust_id is null is still supported
  sold_to_org_id would be the same value as cust_id
*/
CURSOR op_alot_prm_c1 is
SELECT *
FROM op_alot_prm
WHERE sold_to_org_id = p_of_cust_id
  --and ship_to_org_id = p_ship_to_org_id
  and org_id = p_org_id
  and alloc_class = p_alloc_class
  and delete_mark=0;
CURSOR op_alot_prm_c2 is
SELECT *
FROM op_alot_prm
WHERE sold_to_org_id IS NULL
  and org_id  is null
  and alloc_class = p_alloc_class
  and delete_mark=0;

BEGIN

 /* OPEN op_cust_mst_c1;
  FETCH op_cust_mst_c1 INTO l_cust_id;

  IF (op_cust_mst_c1%NOTFOUND)
  THEN
    CLOSE op_cust_mst_c1;
    FND_MESSAGE.SET_NAME('GML','OP_API_INVALID_CUSTOMER');
    FND_MESSAGE.SET_TOKEN('CUST_NO',p_cust_no);
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  ELSE
    CLOSE op_cust_mst_c1;
  END IF;
*/
  /*Attempt to locate allocation parms specific to this customer
  =============================================================*/
  GMI_reservation_Util.PrintLn('p_org_id '||p_org_id);
  GMI_reservation_Util.PrintLn('p_of_cust_id '||p_of_cust_id);
  GMI_reservation_Util.PrintLn('p_ship_to_org_id '||p_ship_to_org_id);
  GMI_reservation_Util.PrintLn('p_alloc_class '||p_alloc_class);
  OPEN op_alot_prm_c1;
  FETCH op_alot_prm_c1 INTO x_op_alot_prm;

  /* No allocation rule located specific to our customer so look for a
  set of rules global across ALL customers
  ==================================================================*/
  IF (op_alot_prm_c1%NOTFOUND)
  THEN
    CLOSE op_alot_prm_c1;
    OPEN op_alot_prm_c2;
  /* dbms_output.put_line('generic fetch'); */
    FETCH op_alot_prm_c2 INTO x_op_alot_prm;
    IF (op_alot_prm_c2%NOTFOUND)
    THEN
      /* No rules defined on the database so set them from profile values */
      /* =================================================================*/
      GMI_ALLOCATION_RULES_PVT.GET_DEFAULT_PARMS
                              (x_op_alot_prm => l_op_alot_prm);
      x_op_alot_prm := l_op_alot_prm;
      GMI_reservation_Util.PrintLn('no rules in op_alot_prm, use default ');
    ELSE
      GMI_reservation_Util.PrintLn('op_alot_prm is found for all cust ');
    END IF;
    CLOSE op_alot_prm_c2;
  ELSE
    GMI_reservation_Util.PrintLn('op_alot_prm is found for cust '||p_of_cust_id);
    CLOSE op_alot_prm_c1;
  END IF;

/* EXCEPTION HANDLING
====================*/

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded => FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg (  G_PKG_NAME
                               , l_api_name
                              );

      FND_MSG_PUB.Count_AND_GET (  p_encoded=> FND_API.G_FALSE
                                 , p_count => x_msg_count
                                 , p_data  => x_msg_data
                                );

END Get_allocation_parms;
/* +=========================================================================+
 | PROCEDURE NAME                                                          |
 |    Get_Default_Parms                                                    |
 |                                                                         |
 | DESCRIPTION                                                             |
 |    Used to set default allocation rules based on system profile values  |
 |                                                                         |
 | PARAMETERS                                                              |
 |    x_op_alot_prm OUT NOCOPY RECORD      - Record containing allocation rules   |
 |                                                                         |
 | HISTORY                                                                 |
 |    15-DEC-1999      K.Y.Hunt      Created                               |
 +=========================================================================+
*/
PROCEDURE GET_DEFAULT_PARMS
( x_op_alot_prm        OUT NOCOPY op_alot_prm%ROWTYPE)
IS
l_api_name             CONSTANT VARCHAR2 (30) := 'GET_DEFAULT_PARMS';

BEGIN
  oe_debug_pub.add('No specific allocation rules defined so use defaults',1);
  x_op_alot_prm.alloc_method  := FND_PROFILE.VALUE('IC$ALLOC_METHOD');
  x_op_alot_prm.shelf_days    := FND_PROFILE.VALUE('IC$SHELF_DAYS');
  x_op_alot_prm.alloc_horizon := FND_PROFILE.VALUE('IC$ALLOC_HORIZON');
  x_op_alot_prm.alloc_type    := FND_PROFILE.VALUE('IC$ALLOC_TYPE');
  x_op_alot_prm.lot_qty       := FND_PROFILE.VALUE('IC$LOT_QTY');
  x_op_alot_prm.partial_ind   := FND_PROFILE.VALUE('OP$PARTIAL_ALLOC');
  x_op_alot_prm.prefqc_grade  := NULL;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END Get_default_parms;

END GMI_ALLOCATION_RULES_PVT;

/
