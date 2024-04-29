--------------------------------------------------------
--  DDL for Package Body CS_SR_RES_CODE_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_RES_CODE_MAPPING_PKG" AS
/* $Header: csxrscdb.pls 120.0 2005/12/12 16:12:29 smisra noship $ */

PROCEDURE VALIDATE_RESOLUTION_CODE
( p_api_version   	IN 	NUMBER,
  p_init_msg_list 	IN 	VARCHAR2,
  p_rescode_criteria_rec  IN CS_SR_RES_CODE_MAPPING_PKG.rescode_search_rec,
  p_resolution_code   IN  VARCHAR2,
  x_return_status  OUT NOCOPY    VARCHAR2,
  x_msg_count      OUT NOCOPY     NUMBER,
  x_msg_data       OUT NOCOPY    VARCHAR2
) IS

 l_api_version     CONSTANT NUMBER := 1.0;
 l_api_name        CONSTANT VARCHAR2(30) := 'VALIDATE_RESOLUTION_CODE';
 l_errname varchar2(60);
 l_errmsg varchar2(2000);
 l_errstack varchar2(4000);

 l_resolution_code_meaning VARCHAR2(80);
 l_resolution_code VARCHAR2(30);
 l_problem_code VARCHAR2(30);
 l_incident_type_id NUMBER;
 l_inventory_item_id NUMBER;
 l_organization_id NUMBER;
 l_category_id NUMBER;
 l_category_set_id NUMBER;

 l_start_date_active DATE;
 l_end_date_active DATE;

 /* This cursor checks if the resolution code is an active resolution code or not.
   If it is NOT an active resolution code, we stop validation immeadiately
   Else, we continue with the rest of the resolution code validation  */
CURSOR cs_sr_active_rc_csr IS
    select meaning from
    cs_lookups cslkup
    where
        cslkup.lookup_type='REQUEST_RESOLUTION_CODE' and
        cslkup.lookup_code = l_resolution_code and
        (cslkup.start_date_active is null or trunc(cslkup.start_date_active) <= trunc(sysdate)) and
        (cslkup.end_date_active is null or trunc(cslkup.end_date_active) >= trunc(sysdate));


/* This cursor checks if the resolution code is in the unmapped resolution code list
   We also make sure that even if a resolution code mapping is found, it has to be
   an active resolution code mapping. Else, we assume that the resolution code mapping
   can be disregarded */
CURSOR cs_sr_unmapped_rc_csr IS
    select meaning from
    cs_lookups cslkup
    where
        cslkup.lookup_type='REQUEST_RESOLUTION_CODE' and
        cslkup.lookup_code = l_resolution_code and
        not exists
    	( select 'X' from
          cs_sr_res_code_mapping_detail cstl
    	  where
          cstl.resolution_code = cslkup.lookup_code  and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
          (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
          (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate)));


/*
  The following cursors will check if the resolution code is mapped to one of the following search criteria :
1)  Service Request Type
2)  Product
3)  Product Category (All product categories that belong to the product category set held by the CS_SR_DEFAULT_CATEGORY_SET profile option)
4)  Problem Code
5)  Service Request Type + Product
6)  Service Request Type + All product categories that belong to the product category set held by the CS_SR_DEFAULT_CATEGORY_SET profile option
7)  Service Request Type + Problem Code
8)  Product + Problem Code
9)  Problem Code + All product categories that belong to the product category set held by the CS_SR_DEFAULT_CATEGORY_SET profile option
10)  Service Request Type + Problem Code + Product
11)  Service Request Type + Problem Code + All product categories that belong to the product category set held by the CS_SR_DEFAULT_CATEGORY_SET profile option
*/
CURSOR cs_sr_rc_catset_srtype IS
select meaning
from
     cs_lookups cslkup
where
       cslkup.lookup_type='REQUEST_RESOLUTION_CODE' and
       cslkup.lookup_code = l_resolution_code and
       exists
  	  ( select 'X' from
        cs_sr_res_code_mapping_detail cstl
 	    where
 	    cstl.resolution_code = cslkup.lookup_code and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
       (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
       (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate))
	    and
       (
          ( cstl.incident_type_id  = l_incident_type_id and
		    cstl.inventory_item_id is null and
            cstl.category_id is null and
            cstl.problem_code is null)
          or
          ( cstl.incident_type_id = l_incident_type_id and
     		 cstl.inventory_item_id = l_inventory_item_id and
             cstl.organization_id = l_organization_id and
             cstl.category_id is null and
             cstl.problem_code is null)
            or
		   ( cstl.incident_type_id = l_incident_type_id and
		     cstl.inventory_item_id is null and
             exists (select category_id from mtl_item_categories cmtlc
                     where
                     cmtlc.category_id = cstl.category_id and
                     category_set_id = l_category_set_id and /* value from profile CS_SR_DEFAULT_CATEGORY_SET */
                     cmtlc.inventory_item_id = l_inventory_item_id and
                     cmtlc.organization_id = l_organization_id) and
                     cstl.problem_code is null)
           or
		  ( cstl.incident_type_id = l_incident_type_id and
            cstl.inventory_item_id is null and
            cstl.category_id is null and
            cstl.problem_code =  l_problem_code)
          or
 	     ( cstl.incident_type_id = l_incident_type_id and
		   cstl.problem_code = l_problem_code and
           cstl.inventory_item_id = l_inventory_item_id and
           cstl.organization_id = l_organization_id and
           cstl.category_id is null)
          or
	    ( cstl.incident_type_id = l_incident_type_id and
		  cstl.problem_code = l_problem_code and
          exists (select category_id from mtl_item_categories cmtlc
                  where
                  cmtlc.category_id = cstl.category_id and
                  cmtlc.category_set_id = l_category_set_id and /* value from profile CS_SR_DEFAULT_CATEGORY_SET */
                  cmtlc.inventory_item_id = l_inventory_item_id and
                  cmtlc.organization_id = l_organization_id) and
                  cstl.inventory_item_id is null)
        )                             /* end of various combinations of search criteria */
    ) ;             /*  end of the exists condition */



CURSOR cs_sr_rc_catset_prod IS
select meaning
from
     cs_lookups cslkup
where
       cslkup.lookup_type='REQUEST_RESOLUTION_CODE' and
       cslkup.lookup_code = l_resolution_code and
       exists
  	  ( select 'X' from
        cs_sr_res_code_mapping_detail cstl
 	    where
 	    cstl.resolution_code = cslkup.lookup_code and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
       (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
       (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate))
	    and
       (
          ( cstl.incident_type_id is null and
	        cstl.inventory_item_id = l_inventory_item_id and
            cstl.organization_id = l_organization_id and
            cstl.category_id is null and
            cstl.problem_code is null)
          or
	      ( cstl.incident_type_id is null and
            cstl.inventory_item_id = l_inventory_item_id and
            cstl.organization_id = l_organization_id and
            cstl.category_id is null and
            cstl.problem_code = l_problem_code)
        )           /* end of various combinations of search criteria */
    ) ;             /*  end of the exists condition */



CURSOR cs_sr_rc_catset_prodcat IS
select meaning
from
     cs_lookups cslkup
where
       cslkup.lookup_type='REQUEST_RESOLUTION_CODE' and
       cslkup.lookup_code = l_resolution_code and
       exists
  	  ( select 'X' from
        cs_sr_res_code_mapping_detail cstl
 	    where
 	    cstl.resolution_code = cslkup.lookup_code and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
       (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
       (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate))
	    and
       (
         ( cstl.incident_type_id is null and
		    cstl.inventory_item_id is null and
            exists (select category_id from mtl_item_categories cmtlc
                    where
                    cmtlc.category_id = cstl.category_id and
                    cmtlc.category_set_id = l_category_set_id and /* value from profile CS_SR_DEFAULT_CATEGORY_SET */
                    cmtlc.inventory_item_id = l_inventory_item_id and
                    cmtlc.organization_id = l_organization_id) and
                    cstl.problem_code is null)
         or
	     ( cstl.incident_type_id is null and
           cstl.inventory_item_id is null and
           exists (select category_id from mtl_item_categories cmtlc
                   where
                   cmtlc.category_id = cstl.category_id and
                   category_set_id = l_category_set_id and /* value from profile CS_SR_DEFAULT_CATEGORY_SET */
                   cmtlc.inventory_item_id = l_inventory_item_id) and
                   cstl.problem_code = l_problem_code)
        )                             /* end of various combinations of search criteria */
    ) ;             /*  end of the exists condition */



CURSOR cs_sr_rc_catset_probc IS
select meaning
from
     cs_lookups cslkup
where
       cslkup.lookup_type='REQUEST_RESOLUTION_CODE' and
       cslkup.lookup_code = l_resolution_code and
       exists
  	  ( select 'X' from
        cs_sr_res_code_mapping_detail cstl
 	    where
 	    cstl.resolution_code = cslkup.lookup_code and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
       (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
       (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate))
	    and
       (
           ( cstl.incident_type_id is null and
	         cstl.inventory_item_id is null and
             cstl.category_id is null  and
             cstl.problem_code = l_problem_code)
        )                             /* end of various combinations of search criteria */
    ) ;             /*  end of the exists condition */


/*
The following cursors will check if the resolution code is mapped to one of the following search criteria :
1)  Service Request Type
2)  Product
3)  Product Category
4)  Problem Code
5)  Service Request Type + Product
6)  Service Request Type + Product Category
7)  Service Request Type + Problem Code
8)  Product + Problem Code
9)  Problem Code + Product Category
10)  Service Request Type + Problem Code + Product
11)  Service Request Type + Problem Code + Product Category
*/

CURSOR cs_sr_rc_cat_srtype IS
select meaning
from
     cs_lookups cslkup
where
       cslkup.lookup_type='REQUEST_RESOLUTION_CODE' and
       cslkup.lookup_code = l_resolution_code and
       exists
  	  ( select 'X' from
        cs_sr_res_code_mapping_detail cstl
 	    where
 	    cstl.resolution_code = cslkup.lookup_code and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
       (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
       (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate))
	    and
       (
          ( cstl.incident_type_id  = l_incident_type_id and
		    cstl.inventory_item_id is null and
            cstl.category_id is null and
            cstl.problem_code is null)
          or
           ( cstl.incident_type_id = l_incident_type_id and
   	         cstl.inventory_item_id = l_inventory_item_id and
             cstl.organization_id = l_organization_id and
             cstl.category_id is null and
             cstl.problem_code is null)
            or
		   ( cstl.incident_type_id = l_incident_type_id and
		     cstl.inventory_item_id is null and
             cstl.category_id = l_category_id and
             cstl.problem_code is null)
           or
		  ( cstl.incident_type_id = l_incident_type_id and
            cstl.inventory_item_id is null and
            cstl.category_id is null and
            cstl.problem_code =  l_problem_code)
          or
 	     ( cstl.incident_type_id = l_incident_type_id and
		   cstl.problem_code = l_problem_code and
           cstl.inventory_item_id = l_inventory_item_id and
           cstl.organization_id = l_organization_id and
           cstl.category_id is null)
          or
	    ( cstl.incident_type_id = l_incident_type_id and
		  cstl.problem_code = l_problem_code and
          cstl.category_id = l_category_id and
          cstl.inventory_item_id is null)
        )                             /* end of various combinations of search criteria */
    ) ;             /*  end of the exists condition */



CURSOR cs_sr_rc_cat_prodcat IS
select meaning
from
     cs_lookups cslkup
where
       cslkup.lookup_type='REQUEST_RESOLUTION_CODE' and
       cslkup.lookup_code = l_resolution_code and
       exists
  	  ( select 'X' from
        cs_sr_res_code_mapping_detail cstl
 	    where
 	    cstl.resolution_code = cslkup.lookup_code and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
       (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
       (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate))
	    and
       (
          ( cstl.incident_type_id is null and
		    cstl.inventory_item_id is null and
            cstl.category_id = l_category_id and
            cstl.problem_code is null)
           or
	     ( cstl.incident_type_id is null and
           cstl.inventory_item_id is null and
           cstl.category_id = l_category_id and
           cstl.problem_code = l_problem_code)
        )                             /* end of various combinations of search criteria */
    ) ;             /*  end of the exists condition */


BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF fnd_api.to_boolean (p_init_msg_list)
 THEN
     fnd_msg_pub.initialize;
 END IF;


 l_incident_type_id := nvl(p_rescode_criteria_rec.service_request_type_id,0);
 l_category_id := nvl(p_rescode_criteria_rec.product_category_id,0);
 l_inventory_item_id := nvl(p_rescode_criteria_rec.inventory_item_id,0);
 l_organization_id := nvl(p_rescode_criteria_rec.organization_id,0);
 l_problem_code := nvl(p_rescode_criteria_rec.problem_code,' ');
 l_resolution_code := p_resolution_code;
 l_category_set_id := FND_PROFILE.value('CS_SR_DEFAULT_CATEGORY_SET');


/* Roopa - Begin - fix for bug 3335668 */
/* Changed the initialized value from 'null' to 0 or ' ' value */
 IF (l_incident_type_id = FND_API.G_MISS_NUM) THEN
        l_incident_type_id := 0;
 END IF;
 IF (l_category_id = FND_API.G_MISS_NUM) THEN
        l_category_id := 0;
 END IF;
  IF (l_inventory_item_id = FND_API.G_MISS_NUM) THEN
        l_inventory_item_id := 0;
 END IF;
  IF (l_organization_id = FND_API.G_MISS_NUM) THEN
        l_organization_id := 0;
 END IF;
 IF (l_problem_code = FND_API.G_MISS_CHAR) THEN
        l_problem_code := ' ';
 END IF;
 IF (l_category_set_id = FND_API.G_MISS_NUM) THEN
        l_category_set_id := 0;
 END IF;
 IF (l_resolution_code = FND_API.G_MISS_CHAR) THEN
     RAISE FND_API.G_EXC_ERROR;
 END IF;
/* Roopa - End - fix for bug 3335668 */

 IF (l_inventory_item_id <> 0 and l_organization_id = 0) THEN
    l_organization_id := FND_PROFILE.value('CS_INV_VALIDATION_ORG');
 END IF;

 /* Validation Checks on the resolution code:
   #1) Check if the resolution code exists in the unmapped resolution code list or
   #2) Check if the resolution code is mapped to any combination of :
        sr type
        sr type and product
        sr type and prod category
        sr type and problem code
        sr type, prod and prob code
        sr type, prod cat and prob code
   #3) Check if the resolution code is mapped to any combination of :
        product
        product and problem code
   #4) Check if the resolution code is mapped to any combination of :
        product category
        product category and problem code
   #5) Check if the resolution code is mapped to any combination of :
        problem code
   #6) Check if the resolution code is mapped to any combination of :
        sr type
        sr type and product
        sr type and prod category
        sr type and problem code
        sr type, prod and prob code
        sr type, prod cat and prob code
        (where prod category = all product categories that belong to the
         product category set held in the CS_SR_DEFAULT_CATEGORY_SET profile option
   #7) Check if the resolution code is mapped to any combination of :
        product
        product and problem code
   #8) Check if the resolution code is mapped to any combination of :
        product category
        product category and problem code
        (where prod category = all product categories that belong to the
         product category set held in the CS_SR_DEFAULT_CATEGORY_SET profile option
   #9) Check if the resolution code is mapped to any combination of :
        problem code
   #10) Check if the resolution code is an active resolution code or not. Since this is
       the most basic check, it will be executed before the other validation checks
*/

/* Validation Check #10 */
 OPEN cs_sr_active_rc_csr;
 FETCH cs_sr_active_rc_csr into l_resolution_code_meaning;
 IF (cs_sr_active_rc_csr%NOTFOUND) THEN
     RAISE FND_API.G_EXC_ERROR;
 END IF;


/* Validation Check #1 */
 OPEN cs_sr_unmapped_rc_csr;
 FETCH cs_sr_unmapped_rc_csr INTO l_resolution_code_meaning;
 IF (cs_sr_unmapped_rc_csr%NOTFOUND) THEN
 /*
    Now, check if the product_category_id input parameter contained some value

    If yes,
        **) open cs_sr_rc_cat_srtype cursor - this cursor checks all mappings containing the
                                                    sr type and/or prod and/or prod category and/or problem code
        **) If the above cursor did not find a hit, then, open cs_sr_rc_catset_prod cursor
                                                 -- this cursor checks mappings containing the product(inventory item)
                                                     and/or problem code
        **) If the above cursor did not find a hit, then, open cs_sr_rc_cat_prodcat cursor
                                                 -- this cursor checks mappings containing the product category
                                                    and/or problem code
        **) If the above cursor did not find a hit, then, open cs_sr_rc_catset_probc cursor
                                                 -- this cursor checks mappings containing the problem code
     Else,
        **) open cs_sr_rc_catset_srtype cursor - this cursor checks all mappings containing the
                                                    sr type and/or prod and/or prod category and/or problem code
                                                     where prod category = all categories belonging to category set held
                                                     in CS_SR_DEFAULT_CATEGORY_SET profile option;
        **) If the above cursor did not find a hit, then, open cs_sr_rc_catset_prod cursor
                                                 -- this cursor checks mappings containing the product(inventory item)
                                                     and/or problem code
        **) If the above cursor did not find a hit, then, open cs_sr_rc_catset_prodcat cursor
                                                 -- this cursor checks mappings containing the product category
                                                    and/or problem code
                                                    where prod category = all categories belonging to category set held
                                                    in CS_SR_DEFAULT_CATEGORY_SET profile option;
        **) If the above cursor did not find a hit, then, open cs_sr_rc_catset_probc cursor
                                                 -- this cursor checks mappings containing the problem code
 */
/* Roopa - Begin - fix for bug 3335668 */
/* Replaced the following IF for the commented IF condition */
      IF (l_category_id <> 0) THEN
/*
      IF (l_category_id is not null OR
          l_category_id <> FND_API.G_MISS_NUM) THEN
*/
/* Roopa - End - fix for bug 3335668 */

/* Validation Check #2 */
         OPEN cs_sr_rc_cat_srtype;
         FETCH cs_sr_rc_cat_srtype into l_resolution_code_meaning;

         IF (cs_sr_rc_cat_srtype%NOTFOUND) THEN
/* Validation Check #3 */
            OPEN cs_sr_rc_catset_prod;
            FETCH cs_sr_rc_catset_prod into l_resolution_code_meaning;

             IF (cs_sr_rc_catset_prod%NOTFOUND) THEN
/* Validation Check #4 */
                OPEN cs_sr_rc_cat_prodcat;
                FETCH cs_sr_rc_cat_prodcat into l_resolution_code_meaning;
                 IF (cs_sr_rc_cat_prodcat%NOTFOUND) THEN
/* Validation Check #5 */
                    OPEN cs_sr_rc_catset_probc;
                    FETCH cs_sr_rc_catset_probc into l_resolution_code_meaning;
                    IF (cs_sr_rc_catset_probc%NOTFOUND) THEN
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;
                 END IF;
             END IF;
          END IF;

      ELSE
/* Validation Check #6 */
         OPEN cs_sr_rc_catset_srtype;
         FETCH cs_sr_rc_catset_srtype into l_resolution_code_meaning;

         IF (cs_sr_rc_catset_srtype%NOTFOUND) THEN
/* Validation Check #7 */
            OPEN cs_sr_rc_catset_prod;
            FETCH cs_sr_rc_catset_prod into l_resolution_code_meaning;

             IF (cs_sr_rc_catset_prod%NOTFOUND) THEN
/* Validation Check #8 */
                OPEN cs_sr_rc_catset_prodcat;
                FETCH cs_sr_rc_catset_prodcat into l_resolution_code_meaning;
                 IF (cs_sr_rc_catset_prodcat%NOTFOUND) THEN
/* Validation Check #9 */
                    OPEN cs_sr_rc_catset_probc;
                    FETCH cs_sr_rc_catset_probc into l_resolution_code_meaning;
                    IF (cs_sr_rc_catset_probc%NOTFOUND) THEN
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;
                 END IF;
             END IF;
          END IF;
     END IF;
 END IF;

 IF cs_sr_unmapped_rc_csr%isopen THEN
        CLOSE cs_sr_unmapped_rc_csr;
 END IF;
 IF cs_sr_rc_cat_srtype%isopen THEN
           CLOSE cs_sr_rc_cat_srtype;
 END IF;
 IF cs_sr_rc_catset_prod%isopen THEN
           CLOSE cs_sr_rc_catset_prod;
 END IF;
 IF cs_sr_rc_cat_prodcat%isopen THEN
           CLOSE cs_sr_rc_cat_prodcat;
 END IF;
 IF cs_sr_rc_catset_probc%isopen THEN
           CLOSE cs_sr_rc_catset_probc;
 END IF;
 IF cs_sr_rc_catset_srtype%isopen THEN
           CLOSE cs_sr_rc_catset_srtype;
 END IF;
 IF cs_sr_rc_catset_prodcat%isopen THEN
           CLOSE cs_sr_rc_catset_prodcat;
 END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
 IF cs_sr_unmapped_rc_csr%isopen THEN
        CLOSE cs_sr_unmapped_rc_csr;
 END IF;
 IF cs_sr_rc_cat_srtype%isopen THEN
           CLOSE cs_sr_rc_cat_srtype;
 END IF;
 IF cs_sr_rc_catset_prod%isopen THEN
           CLOSE cs_sr_rc_catset_prod;
 END IF;
 IF cs_sr_rc_cat_prodcat%isopen THEN
           CLOSE cs_sr_rc_cat_prodcat;
 END IF;
 IF cs_sr_rc_catset_probc%isopen THEN
           CLOSE cs_sr_rc_catset_probc;
 END IF;
 IF cs_sr_rc_catset_srtype%isopen THEN
           CLOSE cs_sr_rc_catset_srtype;
 END IF;
 IF cs_sr_rc_catset_prodcat%isopen THEN
           CLOSE cs_sr_rc_catset_prodcat;
 END IF;

    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
 IF cs_sr_unmapped_rc_csr%isopen THEN
        CLOSE cs_sr_unmapped_rc_csr;
 END IF;
 IF cs_sr_rc_cat_srtype%isopen THEN
           CLOSE cs_sr_rc_cat_srtype;
 END IF;
 IF cs_sr_rc_catset_prod%isopen THEN
           CLOSE cs_sr_rc_catset_prod;
 END IF;
 IF cs_sr_rc_cat_prodcat%isopen THEN
           CLOSE cs_sr_rc_cat_prodcat;
 END IF;
 IF cs_sr_rc_catset_probc%isopen THEN
           CLOSE cs_sr_rc_catset_probc;
 END IF;
 IF cs_sr_rc_catset_srtype%isopen THEN
           CLOSE cs_sr_rc_catset_srtype;
 END IF;
 IF cs_sr_rc_catset_prodcat%isopen THEN
           CLOSE cs_sr_rc_catset_prodcat;
 END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
 IF cs_sr_unmapped_rc_csr%isopen THEN
        CLOSE cs_sr_unmapped_rc_csr;
 END IF;
 IF cs_sr_rc_cat_srtype%isopen THEN
           CLOSE cs_sr_rc_cat_srtype;
 END IF;
 IF cs_sr_rc_catset_prod%isopen THEN
           CLOSE cs_sr_rc_catset_prod;
 END IF;
 IF cs_sr_rc_cat_prodcat%isopen THEN
           CLOSE cs_sr_rc_cat_prodcat;
 END IF;
 IF cs_sr_rc_catset_probc%isopen THEN
           CLOSE cs_sr_rc_catset_probc;
 END IF;
 IF cs_sr_rc_catset_srtype%isopen THEN
           CLOSE cs_sr_rc_catset_srtype;
 END IF;
 IF cs_sr_rc_catset_prodcat%isopen THEN
           CLOSE cs_sr_rc_catset_prodcat;
 END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg('CS_SR_RES_CODE_MAPPING_PKG', l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
END; -- End of procedure VALIDATE_RESOLUTION_CODE()



PROCEDURE CREATE_MAPPING_RULES
( p_api_version			  IN         NUMBER,
  p_init_msg_list		  IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_commit			      IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_rescode_map_criteria_rec IN rescode_map_criteria_rec,
  p_resolution_codes_tbl        IN resolution_codes_tbl_type,
  x_return_status		  OUT NOCOPY VARCHAR2,
  x_msg_count			  OUT NOCOPY NUMBER,
  x_msg_data			  OUT NOCOPY VARCHAR2,
  x_resolution_map_id        OUT NOCOPY NUMBER
) IS

 l_api_version     CONSTANT NUMBER := 1.0;
 l_api_name        CONSTANT VARCHAR2(30) := 'CREATE_MAPPING_RULES';
 l_errname varchar2(60);
 l_errmsg varchar2(2000);
 l_errstack varchar2(4000);
 l_msg_count NUMBER;
 l_return_status              VARCHAR2(1);

 l_product_category_set VARCHAR2(240);
 l_problem_code VARCHAR2(30);
 l_resolution_code VARCHAR2(30);

 l_service_request_type_id NUMBER;
 l_inventory_item_id NUMBER;
 l_organization_id NUMBER;
 l_product_category_id NUMBER;
 l_resolution_map_id NUMBER;
 l_resolution_map_detail_id NUMBER;

 l_start_date_active DATE;
 l_end_date_active DATE;

 l_current_date                DATE           :=sysdate;
 l_created_by                  NUMBER         :=fnd_global.user_id;
 l_login                       NUMBER         :=fnd_global.login_id;
 l_row_id                       VARCHAR2(100);
 l_temp NUMBER;

 l_res_code_index             BINARY_INTEGER;

 CURSOR c_sr_criteria_exists_csr IS
    SELECT resolution_map_id,start_date_active, end_date_active from cs_sr_res_code_mapping
    WHERE incident_type_id = l_service_request_type_id
    AND   category_id = l_product_category_id
    AND   inventory_item_id = l_inventory_item_id
    AND   organization_id = l_organization_id
    AND   problem_code = l_resolution_code
    AND   (start_date_active is null or trunc(start_date_active) <= trunc(sysdate)) and
          (end_date_active is null or trunc(end_date_active) >= trunc(sysdate));

 c_sr_criteria_exists_rec c_sr_criteria_exists_csr%ROWTYPE;

 CURSOR c_sr_prod_cat_valid_csr IS
    SELECT  category_id from mtl_category_set_valid_cats
    WHERE category_set_id = to_number(l_product_category_set)
    AND category_id = l_product_category_id;

 CURSOR c_sr_resolution_code_valid_csr IS
    SELECT lookup_code from cs_lookups
    WHERE lookup_code = l_resolution_code
    AND   lookup_type = 'REQUEST_RESOLUTION_CODE'and
          (start_date_active is null or
           trunc(start_date_active) <= trunc(sysdate)) and
          (end_date_active is null or
           trunc(end_date_active) >= trunc(sysdate));

 CURSOR c_sr_res_code_map_exists_csr IS
    SELECT resolution_map_detail_id,start_date_active, end_date_active from cs_sr_res_code_mapping_detail
    WHERE resolution_map_id = l_resolution_map_id
    AND   resolution_code = l_resolution_code
    AND   (start_date_active is null or trunc(start_date_active) <= trunc(sysdate)) and
          (end_date_active is null or trunc(end_date_active) >= trunc(sysdate));

 c_sr_res_code_map_exists_rec c_sr_res_code_map_exists_csr%ROWTYPE;

BEGIN

      SAVEPOINT create_mapping_rules;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

/* First, we create the search criteria
   Then, we create the  resolution code mappings to this search criteria */

/* The following validation checks will be executed on the search criteria:
    #1) the product categroy and product cannot be part of the same search criteria
    #2) all search criteria attributes should NOT be null in the search criteria
    #3) Organization Id cannot be null if product is not null
    #4) the search criteria should not already be present in the cs_sr_res_code_mapping table
    #5) the product category of the new search criteria, if passed, should belong to the default category set
       whose value is held in the profile option - CS_SR_DEFAULT_CATEGORY_SET
    #6) the start date of the new search criteria should NOT be greater than the end date
*/

/* Validation check #1 */
      IF ( p_rescode_map_criteria_rec.product_category_id is not null and
           p_rescode_map_criteria_rec.inventory_item_id is not null) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

/* Validation check #2 */
      IF (p_rescode_map_criteria_rec.product_category_id is null and
          p_rescode_map_criteria_rec.inventory_item_id is null and
          p_rescode_map_criteria_rec.service_request_type_id is null and
          p_rescode_map_criteria_rec.problem_code is null) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

/* Validation check #3 */
      IF (p_rescode_map_criteria_rec.inventory_item_id is not null and
          p_rescode_map_criteria_rec.organization_id is null) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;


      l_start_date_active := nvl(p_rescode_map_criteria_rec.start_date_active, sysdate);
      l_end_date_active := nvl(p_rescode_map_criteria_rec.end_date_active, sysdate);

      l_product_category_id := nvl(p_rescode_map_criteria_rec.product_category_id,0);
      l_inventory_item_id   := nvl(p_rescode_map_criteria_rec.inventory_item_id,0);
      l_organization_id := nvl(p_rescode_map_criteria_rec.organization_id,0);
      l_service_request_type_id := nvl(p_rescode_map_criteria_rec.service_request_type_id,0);
      l_problem_code := nvl(p_rescode_map_criteria_rec.problem_code,'');

/* Validation check #4 */
      OPEN c_sr_criteria_exists_csr;
      FETCH c_sr_criteria_exists_csr into c_sr_criteria_exists_rec;
      IF (c_sr_criteria_exists_csr%FOUND) THEN
                  RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE c_sr_criteria_exists_csr;

/* Validation check #5 */
      IF(l_product_category_id <> 0 AND
         FND_PROFILE.Value('CS_SR_DEFAULT_CATEGORY_SET') is not null) THEN
/* If the input category does not belong to the default category set, throw an exception */
        l_product_category_set :=  FND_PROFILE.Value('CS_SR_DEFAULT_CATEGORY_SET');
        OPEN c_sr_prod_cat_valid_csr;
        FETCH c_sr_prod_cat_valid_csr into l_temp;
        IF (c_sr_prod_cat_valid_csr%NOTFOUND) THEN
                  RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        CLOSE c_sr_prod_cat_valid_csr;
      END IF;


/* Validation check #6 */
/* start date cannot be greater then end date */
      IF(l_start_date_active is not null AND l_end_date_active is not null AND
         l_start_date_active >= l_end_date_active) THEN
              RAISE fnd_api.g_exc_unexpected_error;
      END IF;

/* All validations have passed for the search criteria. Hence we can create a search criteria record in
   cs_sr_res_code_MAPPING table */
CS_SR_RESOLUTION_CODE_MAP_PKG.INSERT_ROW (
  PX_RESOLUTION_MAP_ID => l_resolution_map_id,
  P_INCIDENT_TYPE_ID => l_service_request_type_id,
  P_INVENTORY_ITEM_ID => l_inventory_item_id,
  P_ORGANIZATION_ID => l_organization_id,
  P_CATEGORY_ID => l_product_category_id,
  P_PROBLEM_CODE => l_problem_code,
  P_START_DATE_ACTIVE => l_start_date_active,
  P_END_DATE_ACTIVE => l_end_date_active,
  P_OBJECT_VERSION_NUMBER => null,
  P_ATTRIBUTE1 => null,
  P_ATTRIBUTE2 => null,
  P_ATTRIBUTE3 => null,
  P_ATTRIBUTE4 => null,
  P_ATTRIBUTE5 => null,
  P_ATTRIBUTE6 => null,
  P_ATTRIBUTE7 => null,
  P_ATTRIBUTE8 => null,
  P_ATTRIBUTE9 => null,
  P_ATTRIBUTE10 => null,
  P_ATTRIBUTE11 => null,
  P_ATTRIBUTE12 => null,
  P_ATTRIBUTE13 => null,
  P_ATTRIBUTE14 => null,
  P_ATTRIBUTE15 => null,
  P_ATTRIBUTE_CATEGORY => null,
  P_CREATION_DATE => l_current_date,
  P_CREATED_BY => l_created_by,
  P_LAST_UPDATE_DATE => l_current_date,
  P_LAST_UPDATED_BY => l_created_by,
  P_LAST_UPDATE_LOGIN => l_login,
  X_RETURN_STATUS	=> l_return_status,
  X_MSG_COUNT		=> l_msg_count,
  X_MSG_DATA		=> l_errmsg
  );
     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

/* Now, we need to create the actual resolution code -> search criteria mapping details in
   CS_SR_RES_CODE_MAPPING_DETAIL table */

/* First, the following validation checks :
    #1) the resolution code should be a CS lookup code with lookup type = 'REQUEST_RESOLUTION_CODE'
    #2) the resolution code mapping should not already be present. Though this is creation API, it is
       still possible that the same resolution code is passed twice in the prob code mapping table parameter
    #3) the start date of the resolution code mapping should NOT be greater than the mapping end date
*/
     l_res_code_index := p_resolution_codes_tbl.FIRST;
     WHILE l_res_code_index IS NOT NULL LOOP

       IF ((p_resolution_codes_tbl(l_res_code_index).resolution_code IS NOT NULL) AND
           (p_resolution_codes_tbl(l_res_code_index).resolution_code <> FND_API.G_MISS_CHAR)) THEN

            l_resolution_code := p_resolution_codes_tbl(l_res_code_index).resolution_code;
            l_start_date_active := p_resolution_codes_tbl(l_res_code_index).start_date_active;
            l_end_date_active := p_resolution_codes_tbl(l_res_code_index).end_date_active;

/* Validation check #1 */
            OPEN c_sr_resolution_code_valid_csr;
            FETCH c_sr_resolution_code_valid_csr INTO l_resolution_code;
            IF(c_sr_resolution_code_valid_csr%NOTFOUND) THEN
                  RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            CLOSE c_sr_resolution_code_valid_csr;


/* Validation check #2 */
          OPEN c_sr_res_code_map_exists_csr;
          FETCH c_sr_res_code_map_exists_csr into c_sr_res_code_map_exists_rec;
          IF(c_sr_res_code_map_exists_csr%FOUND) THEN
                  RAISE fnd_api.g_exc_unexpected_error;
          END IF;
          CLOSE c_sr_res_code_map_exists_csr;

/* Validation check #3 */
/* start date cannot be greater then end date */
      IF(l_start_date_active is not null AND l_end_date_active is not null AND
         l_start_date_active >= l_end_date_active) THEN
              RAISE fnd_api.g_exc_unexpected_error;
      END IF;

/* We can create the resolution code mapping in cs_sr_res_code_MAPPING_DETAIL table now */
CS_SR_RES_CODE_MAP_DETAIL_PKG.INSERT_ROW (
  PX_RESOLUTION_MAP_DETAIL_ID => l_resolution_map_detail_id,
  P_RESOLUTION_MAP_ID => l_resolution_map_id,
  P_INCIDENT_TYPE_ID => l_service_request_type_id,
  P_INVENTORY_ITEM_ID => l_inventory_item_id,
  P_ORGANIZATION_ID => l_organization_id,
  P_CATEGORY_ID => l_product_category_id,
  P_PROBLEM_CODE => l_problem_code,
  P_MAP_START_DATE_ACTIVE => l_start_date_active,
  P_MAP_END_DATE_ACTIVE => l_end_date_active,
  P_RESOLUTION_CODE => l_problem_code,
  P_START_DATE_ACTIVE => l_start_date_active,
  P_END_DATE_ACTIVE => l_end_date_active,
  P_OBJECT_VERSION_NUMBER => null,
  P_ATTRIBUTE1 =>  null,
  P_ATTRIBUTE2 =>  null,
  P_ATTRIBUTE3 =>  null,
  P_ATTRIBUTE4 =>  null,
  P_ATTRIBUTE5 =>  null,
  P_ATTRIBUTE6 =>  null,
  P_ATTRIBUTE7 =>  null,
  P_ATTRIBUTE8 =>  null,
  P_ATTRIBUTE9 =>  null,
  P_ATTRIBUTE10 =>  null,
  P_ATTRIBUTE11 =>  null,
  P_ATTRIBUTE12 =>  null,
  P_ATTRIBUTE13 =>  null,
  P_ATTRIBUTE14 =>  null,
  P_ATTRIBUTE15 =>  null,
  P_ATTRIBUTE_CATEGORY =>  null,
  P_CREATION_DATE => l_current_date,
  P_CREATED_BY => l_created_by,
  P_LAST_UPDATE_DATE => l_current_date,
  P_LAST_UPDATED_BY => l_created_by,
  P_LAST_UPDATE_LOGIN => l_login,
  X_RETURN_STATUS => l_return_status,
  X_MSG_COUNT => l_msg_count,
  X_MSG_DATA => l_errmsg
  );

       END IF;
       l_res_code_index := p_resolution_codes_tbl.NEXT(l_res_code_index);

     END LOOP;
     x_resolution_map_id := l_resolution_map_id;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     IF c_sr_criteria_exists_csr%isopen THEN
        CLOSE c_sr_criteria_exists_csr;
     END IF;
     IF c_sr_prod_cat_valid_csr%isopen THEN
        CLOSE c_sr_prod_cat_valid_csr;
     END IF;
     IF c_sr_resolution_code_valid_csr%isopen THEN
        CLOSE c_sr_resolution_code_valid_csr;
     END IF;
     IF c_sr_res_code_map_exists_csr%isopen THEN
        CLOSE c_sr_res_code_map_exists_csr;
     END IF;

    ROLLBACK TO create_mapping_rules;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF c_sr_criteria_exists_csr%isopen THEN
        CLOSE c_sr_criteria_exists_csr;
     END IF;
     IF c_sr_prod_cat_valid_csr%isopen THEN
        CLOSE c_sr_prod_cat_valid_csr;
     END IF;
     IF c_sr_resolution_code_valid_csr%isopen THEN
        CLOSE c_sr_resolution_code_valid_csr;
     END IF;
     IF c_sr_res_code_map_exists_csr%isopen THEN
        CLOSE c_sr_res_code_map_exists_csr;
     END IF;

    ROLLBACK TO create_mapping_rules;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
     IF c_sr_criteria_exists_csr%isopen THEN
        CLOSE c_sr_criteria_exists_csr;
     END IF;
     IF c_sr_prod_cat_valid_csr%isopen THEN
        CLOSE c_sr_prod_cat_valid_csr;
     END IF;
     IF c_sr_resolution_code_valid_csr%isopen THEN
        CLOSE c_sr_resolution_code_valid_csr;
     END IF;
     IF c_sr_res_code_map_exists_csr%isopen THEN
        CLOSE c_sr_res_code_map_exists_csr;
     END IF;

    ROLLBACK TO create_mapping_rules;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg('CS_SR_RES_CODE_MAPPING_PKG', l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
        p_data  => x_msg_data
      );


END;



PROCEDURE UPDATE_MAPPING_RULES
( p_api_version			  IN         NUMBER,
  p_init_msg_list		  IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_commit			      IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_rescode_map_criteria_rec  IN rescode_map_criteria_rec,
  p_resolution_codes_tbl         IN resolution_codes_tbl_type,
  x_return_status		  OUT NOCOPY VARCHAR2,
  x_msg_count			  OUT NOCOPY NUMBER,
  x_msg_data			  OUT NOCOPY VARCHAR2
) IS

 l_api_version     CONSTANT NUMBER := 1.0;
 l_api_name        CONSTANT VARCHAR2(30) := 'UPDATE_MAPPING_RULES';
 l_errname varchar2(60);
 l_errmsg varchar2(2000);
 l_errstack varchar2(4000);
 l_msg_count NUMBER;
 l_return_status              VARCHAR2(1);

 l_resolution_map_id NUMBER;
 l_resolution_map_detail_id NUMBER;
 l_resolution_code VARCHAR2(30);
 l_problem_code VARCHAR2(30);

 l_service_request_type_id NUMBER;
 l_inventory_item_id NUMBER;
 l_organization_id NUMBER;
 l_product_category_id NUMBER;

 l_start_date_active DATE;
 l_end_date_active DATE;

 l_current_date                DATE           :=sysdate;
 l_created_by                  NUMBER         :=fnd_global.user_id;
 l_login                       NUMBER         :=fnd_global.login_id;
 l_row_id                       VARCHAR2(100);

 l_res_code_index             BINARY_INTEGER;


 CURSOR cs_sr_resmapid_crit_csr IS
    SELECT incident_type_id,category_id,inventory_item_id,problem_code,organization_id
    FROM CS_SR_RES_CODE_MAPPING
    WHERE resolution_map_id = l_resolution_map_id
    AND   (start_date_active is null or trunc(start_date_active) <= trunc(sysdate)) and
          (end_date_active is null or trunc(end_date_active) >= trunc(sysdate));

 cs_sr_resmapid_crit_rec cs_sr_resmapid_crit_csr%ROWTYPE;



 CURSOR cs_sr_resmapid_exists_csr IS
    SELECT resolution_map_id,incident_type_id,category_id,inventory_item_id,problem_code,organization_id
    FROM CS_SR_RES_CODE_MAPPING
    WHERE resolution_map_id <> l_resolution_map_id AND
          incident_type_id = l_service_request_type_id AND
          category_id = l_product_category_id AND
          inventory_item_id = l_inventory_item_id AND
          organization_id = l_organization_id AND
          problem_code = l_problem_code AND
          (start_date_active is null or
           trunc(start_date_active) <= trunc(sysdate)) and
          (end_date_active is null or
           trunc(end_date_active) >= trunc(sysdate));


CURSOR cs_sr_res_code_valid_csr IS
    SELECT lookup_code from cs_lookups a
    WHERE lookup_code = l_resolution_code
    AND   lookup_type = 'REQUEST_RESOLUTION_CODE' and
          (start_date_active is null or
           trunc(start_date_active) <= trunc(sysdate)) and
          (end_date_active is null or
           trunc(end_date_active) >= trunc(sysdate));

CURSOR cs_sr_rescode_mapped_csr IS
     SELECT resolution_code,start_date_active,end_date_active from CS_SR_RES_CODE_MAPPING_DETAIL
      WHERE resolution_map_id = l_resolution_map_id and
            resolution_map_detail_id <> l_resolution_map_detail_id and
            resolution_code = l_resolution_code and
            (start_date_active is null or
             trunc(start_date_active) <= trunc(sysdate)) and
            (end_date_active is null or
             trunc(end_date_active) >= trunc(sysdate));

cs_sr_rescode_mapped_rec cs_sr_rescode_mapped_csr%ROWTYPE;


BEGIN

      SAVEPOINT update_mapping_rules;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      l_resolution_map_id := p_rescode_map_criteria_rec.resolution_map_id;
      l_start_date_active := p_rescode_map_criteria_rec.start_date_active;
      l_end_date_active   := p_rescode_map_criteria_rec.end_date_active;
      l_service_request_type_id := nvl(p_rescode_map_criteria_rec.service_request_type_id, 0);
      l_product_category_id := nvl(p_rescode_map_criteria_rec.product_category_id, 0);
      l_inventory_item_id := nvl(p_rescode_map_criteria_rec.inventory_item_id, 0);
      l_organization_id := nvl(p_rescode_map_criteria_rec.organization_id,0);
      l_problem_code := nvl(p_rescode_map_criteria_rec.problem_code,'');

/* Validation checks are :
    #1) resolution map id should not be null
    #2) All search attributes should not be null
    #3) product and product category cannot be part of the same search criteria
    #4) end date of the search criteria should not be lesser than start date
    #5) a search criteria should not exist which is exactly similar to the current search criteria
    #6) problem code being mapped to the search criteria should be an active CS lookup code of lookup type = 'REQUEST_RESOLUTION_CODE'
    #7) a duplicate resolution code mapping should not already exists for the current search criteria
*/


/* Validation check #1 */
    IF (l_resolution_map_id is null) THEN
          RAISE fnd_api.g_exc_unexpected_error;
    END IF;


/* Validation check #2 */
    IF (l_service_request_type_id = 0 AND
        l_product_category_id = 0 AND
        l_inventory_item_id = 0) THEN
          RAISE fnd_api.g_exc_unexpected_error;
    END IF;

/* Validation check #3 */
    IF (l_product_category_id <> 0 AND
        l_inventory_item_id <> 0) THEN
          RAISE fnd_api.g_exc_unexpected_error;
    END IF;


/* Validation check #4 */
    IF (l_start_date_active is not null AND
        l_end_date_active is not null AND
        l_start_date_active >= l_end_date_active) THEN
          RAISE fnd_api.g_exc_unexpected_error;
    END IF;

/* Validation check #5 */
      OPEN   cs_sr_resmapid_exists_csr;
      IF(cs_sr_resmapid_exists_csr%FOUND) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE  cs_sr_resmapid_exists_csr;


     l_res_code_index := p_resolution_codes_tbl.FIRST;
     WHILE l_res_code_index IS NOT NULL LOOP

       IF ((p_resolution_codes_tbl(l_res_code_index).resolution_code IS NOT NULL) AND
           (p_resolution_codes_tbl(l_res_code_index).resolution_code <> FND_API.G_MISS_CHAR)) THEN

            l_resolution_code := p_resolution_codes_tbl(l_res_code_index).resolution_code;
            l_start_date_active := p_resolution_codes_tbl(l_res_code_index).start_date_active;
            l_end_date_active := p_resolution_codes_tbl(l_res_code_index).end_date_active;
            l_resolution_map_detail_id := p_resolution_codes_tbl(l_res_code_index).resolution_map_detail_id;


/* Validation check #6 */
            OPEN cs_sr_res_code_valid_csr;
            IF(cs_sr_res_code_valid_csr%NOTFOUND) THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            CLOSE cs_sr_res_code_valid_csr;

/* Validation check #7 */
            OPEN cs_sr_rescode_mapped_csr;
            FETCH cs_sr_rescode_mapped_csr into cs_sr_rescode_mapped_rec;
            IF(cs_sr_rescode_mapped_csr%FOUND) THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            CLOSE cs_sr_rescode_mapped_csr;

       END IF;


            IF(p_resolution_codes_tbl(l_res_code_index).resolution_map_detail_id is null) THEN

CS_SR_RES_CODE_MAP_DETAIL_PKG.INSERT_ROW (
  PX_RESOLUTION_MAP_DETAIL_ID => l_resolution_map_detail_id,
  P_RESOLUTION_MAP_ID => l_resolution_map_id,
  P_INCIDENT_TYPE_ID => l_service_request_type_id,
  P_INVENTORY_ITEM_ID => l_inventory_item_id,
  P_ORGANIZATION_ID => l_organization_id,
  P_CATEGORY_ID => l_product_category_id,
  P_PROBLEM_CODE => l_problem_code,
  P_MAP_START_DATE_ACTIVE => l_start_date_active,
  P_MAP_END_DATE_ACTIVE => l_end_date_active,
  P_RESOLUTION_CODE => l_resolution_code,
  P_START_DATE_ACTIVE => l_start_date_active,
  P_END_DATE_ACTIVE => l_end_date_active,
  P_OBJECT_VERSION_NUMBER => null,
  P_ATTRIBUTE1 =>  null,
  P_ATTRIBUTE2 =>  null,
  P_ATTRIBUTE3 =>  null,
  P_ATTRIBUTE4 =>  null,
  P_ATTRIBUTE5 =>  null,
  P_ATTRIBUTE6 =>  null,
  P_ATTRIBUTE7 =>  null,
  P_ATTRIBUTE8 =>  null,
  P_ATTRIBUTE9 =>  null,
  P_ATTRIBUTE10 =>  null,
  P_ATTRIBUTE11 =>  null,
  P_ATTRIBUTE12 =>  null,
  P_ATTRIBUTE13 =>  null,
  P_ATTRIBUTE14 =>  null,
  P_ATTRIBUTE15 =>  null,
  P_ATTRIBUTE_CATEGORY =>  null,
  P_CREATION_DATE => l_current_date,
  P_CREATED_BY => l_created_by,
  P_LAST_UPDATE_DATE => l_current_date,
  P_LAST_UPDATED_BY => l_created_by,
  P_LAST_UPDATE_LOGIN => l_login,
  X_RETURN_STATUS => l_return_status,
  X_MSG_COUNT => l_msg_count,
  X_MSG_DATA => l_errmsg
  );
  ELSE

CS_SR_RES_CODE_MAP_DETAIL_PKG.UPDATE_ROW (
  P_RESOLUTION_MAP_DETAIL_ID => l_resolution_map_detail_id,
  P_RESOLUTION_MAP_ID => l_resolution_map_id,
  P_INCIDENT_TYPE_ID => l_service_request_type_id,
  P_INVENTORY_ITEM_ID => l_inventory_item_id,
  P_ORGANIZATION_ID => l_organization_id,
  P_CATEGORY_ID => l_product_category_id,
  P_PROBLEM_CODE => l_problem_code,
  P_MAP_START_DATE_ACTIVE => l_start_date_active,
  P_MAP_END_DATE_ACTIVE => l_end_date_active,
  P_RESOLUTION_CODE => l_resolution_code,
  P_START_DATE_ACTIVE => l_start_date_active,
  P_END_DATE_ACTIVE => l_end_date_active,
  P_OBJECT_VERSION_NUMBER => null,
  P_ATTRIBUTE1 =>  null,
  P_ATTRIBUTE2 =>  null,
  P_ATTRIBUTE3 =>  null,
  P_ATTRIBUTE4 =>  null,
  P_ATTRIBUTE5 =>  null,
  P_ATTRIBUTE6 =>  null,
  P_ATTRIBUTE7 =>  null,
  P_ATTRIBUTE8 =>  null,
  P_ATTRIBUTE9 =>  null,
  P_ATTRIBUTE10 =>  null,
  P_ATTRIBUTE11 =>  null,
  P_ATTRIBUTE12 =>  null,
  P_ATTRIBUTE13 =>  null,
  P_ATTRIBUTE14 =>  null,
  P_ATTRIBUTE15 =>  null,
  P_ATTRIBUTE_CATEGORY =>  null,
  P_LAST_UPDATE_DATE => l_current_date,
  P_LAST_UPDATED_BY => l_created_by,
  P_LAST_UPDATE_LOGIN => l_login,
  X_RETURN_STATUS => l_return_status,
  X_MSG_COUNT => l_msg_count,
  X_MSG_DATA => l_errmsg
  );
        END IF;
        IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      l_res_code_index := p_resolution_codes_tbl.NEXT(l_res_code_index);
      END LOOP;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF cs_sr_resmapid_exists_csr%isopen THEN
        CLOSE cs_sr_resmapid_exists_csr;
     END IF;
     IF cs_sr_res_code_valid_csr%isopen THEN
        CLOSE cs_sr_res_code_valid_csr;
     END IF;
     IF cs_sr_rescode_mapped_csr%isopen THEN
        CLOSE cs_sr_rescode_mapped_csr;
     END IF;
     ROLLBACK TO update_mapping_rules;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
        p_data  => x_msg_data
     );
    WHEN OTHERS THEN
     IF cs_sr_resmapid_exists_csr%isopen THEN
        CLOSE cs_sr_resmapid_exists_csr;
     END IF;
     IF cs_sr_res_code_valid_csr%isopen THEN
        CLOSE cs_sr_res_code_valid_csr;
     END IF;
     IF cs_sr_rescode_mapped_csr%isopen THEN
        CLOSE cs_sr_rescode_mapped_csr;
     END IF;
     ROLLBACK TO update_mapping_rules;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
        p_data  => x_msg_data
     );

END;


PROCEDURE PROPAGATE_MAP_CRITERIA_DATES
( p_api_version			  IN         NUMBER,
  p_init_msg_list		  IN         VARCHAR2 	:= FND_API.G_FALSE,
  x_return_status		  OUT NOCOPY VARCHAR2,
  x_msg_count			  OUT NOCOPY NUMBER,
  x_msg_data			  OUT NOCOPY VARCHAR2
) IS

 l_api_version     CONSTANT NUMBER := 1.0;
 l_api_name        CONSTANT VARCHAR2(30) := 'PROPAGATE_MAP_CRITERIA_DATES';
 l_errname varchar2(60);
 l_errmsg varchar2(2000);
 l_errstack varchar2(4000);
 l_msg_count NUMBER;
 l_return_status              VARCHAR2(1);

 l_resolution_map_id NUMBER;
 l_resolution_map_detail_id NUMBER;
 l_resolution_code VARCHAR2(30);
 l_problem_code VARCHAR2(30);

 l_service_request_type_id NUMBER;
 l_inventory_item_id NUMBER;
 l_organization_id NUMBER;
 l_product_category_id NUMBER;

 l_start_date_active DATE;
 l_end_date_active DATE;

 l_current_date                DATE           :=sysdate;
 l_created_by                  NUMBER         :=fnd_global.user_id;
 l_login                       NUMBER         :=fnd_global.login_id;
 l_row_id                       VARCHAR2(100);

 l_res_code_index             BINARY_INTEGER;

 CURSOR cs_sr_resmapid_crit_csr IS
    SELECT resolution_map_id, start_date_active, end_date_active
    FROM CS_SR_RES_CODE_MAPPING;
 cs_sr_resmapid_crit_rec cs_sr_resmapid_crit_csr%ROWTYPE;


 CURSOR cs_sr_resmapid_rules_csr IS
    SELECT resolution_map_id, resolution_map_detail_id,
           map_start_date_active, map_end_date_active,
           start_date_active, end_date_active,
           incident_type_id, inventory_item_id, organization_id,
           category_id, problem_code, resolution_code
    FROM CS_SR_RES_CODE_MAPPING_DETAIL
    WHERE
        resolution_map_id = l_resolution_map_id;
 cs_sr_resmapid_rules_rec cs_sr_resmapid_rules_csr%ROWTYPE;


BEGIN
      SAVEPOINT propagate_map_criteria_dates;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      OPEN cs_sr_resmapid_crit_csr;
      LOOP

          FETCH cs_sr_resmapid_crit_csr into cs_sr_resmapid_crit_rec;
          EXIT WHEN cs_sr_resmapid_crit_csr%NOTFOUND;

          l_resolution_map_id := cs_sr_resmapid_crit_rec.resolution_map_id;
          OPEN cs_sr_resmapid_rules_csr;
          FETCH cs_sr_resmapid_rules_csr INTO cs_sr_resmapid_rules_rec;
          CLOSE cs_sr_resmapid_rules_csr;

          IF(cs_sr_resmapid_crit_rec.start_date_active is not null AND
             nvl(cs_sr_resmapid_rules_rec.map_start_date_active, cs_sr_resmapid_crit_rec.start_date_active+1) <> cs_sr_resmapid_crit_rec.start_date_active) THEN

            update CS_SR_RES_CODE_MAPPING_DETAIL
            set
                map_start_date_active = cs_sr_resmapid_crit_rec.start_date_active,
                map_end_date_active = cs_sr_resmapid_crit_rec.end_date_active
            where
                resolution_map_id = l_resolution_map_id;
          ELSIF (cs_sr_resmapid_crit_rec.start_date_active is null AND
                 cs_sr_resmapid_crit_rec.end_date_active is not null AND
                 nvl(cs_sr_resmapid_rules_rec.map_end_date_active, cs_sr_resmapid_crit_rec.end_date_active+1) <> cs_sr_resmapid_crit_rec.end_date_active) THEN

            update CS_SR_RES_CODE_MAPPING_DETAIL
            set
                map_start_date_active = cs_sr_resmapid_crit_rec.start_date_active,
                map_end_date_active = cs_sr_resmapid_crit_rec.end_date_active
            where
                resolution_map_id = l_resolution_map_id;

 /*
            CS_SR_RES_CODE_MAP_DETAIL_PKG.UPDATE_ROW (
              P_RESOLUTION_MAP_DETAIL_ID => cs_sr_resmapid_rules_rec.resolution_map_detail_id,
              P_RESOLUTION_MAP_ID => l_resolution_map_id,
              P_INCIDENT_TYPE_ID => cs_sr_resmapid_rules_rec.incident_type_id,
              P_INVENTORY_ITEM_ID => cs_sr_resmapid_rules_rec.inventory_item_id,
              P_ORGANIZATION_ID => cs_sr_resmapid_rules_rec.organization_id,
              P_CATEGORY_ID => cs_sr_resmapid_rules_rec.category_id,
              P_PROBLEM_CODE => cs_sr_resmapid_rules_rec.problem_code,
              P_MAP_START_DATE_ACTIVE => cs_sr_resmapid_crit_rec.start_date_active,
              P_MAP_END_DATE_ACTIVE => cs_sr_resmapid_crit_rec.end_date_active,
              P_RESOLUTION_CODE => cs_sr_resmapid_rules_rec.resolution_code,
              P_START_DATE_ACTIVE => cs_sr_resmapid_rules_rec.start_date_active,
              P_END_DATE_ACTIVE => cs_sr_resmapid_rules_rec.end_date_active,
              P_OBJECT_VERSION_NUMBER => null,
              P_ATTRIBUTE1 =>  null,
              P_ATTRIBUTE2 =>  null,
              P_ATTRIBUTE3 =>  null,
              P_ATTRIBUTE4 =>  null,
              P_ATTRIBUTE5 =>  null,
              P_ATTRIBUTE6 =>  null,
              P_ATTRIBUTE7 =>  null,
              P_ATTRIBUTE8 =>  null,
              P_ATTRIBUTE9 =>  null,
              P_ATTRIBUTE10 =>  null,
              P_ATTRIBUTE11 =>  null,
              P_ATTRIBUTE12 =>  null,
              P_ATTRIBUTE13 =>  null,
              P_ATTRIBUTE14 =>  null,
              P_ATTRIBUTE15 =>  null,
              P_ATTRIBUTE_CATEGORY =>  null,
              P_LAST_UPDATE_DATE => l_current_date,
              P_LAST_UPDATED_BY => l_created_by,
              P_LAST_UPDATE_LOGIN => l_login,
              X_RETURN_STATUS => l_return_status,
              X_MSG_COUNT => l_msg_count,
              X_MSG_DATA => l_errmsg
            );

           IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE fnd_api.g_exc_unexpected_error;
           END IF;
*/
        END IF;
      END LOOP;
      CLOSE cs_sr_resmapid_crit_csr;
      commit;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF cs_sr_resmapid_crit_csr%isopen THEN
        CLOSE cs_sr_resmapid_crit_csr;
     END IF;
     IF cs_sr_resmapid_rules_csr%isopen THEN
        CLOSE cs_sr_resmapid_rules_csr;
     END IF;
     ROLLBACK TO propagate_map_criteria_dates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
        p_data  => x_msg_data
     );
    WHEN OTHERS THEN
     IF cs_sr_resmapid_crit_csr%isopen THEN
        CLOSE cs_sr_resmapid_crit_csr;
     END IF;
     IF cs_sr_resmapid_rules_csr%isopen THEN
        CLOSE cs_sr_resmapid_rules_csr;
     END IF;
     ROLLBACK TO propagate_map_criteria_dates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
        p_data  => x_msg_data
     );



END;




   -- Enter further code below as specified in the Package spec.
END; -- Package Body CS_SR_RES_CODE_MAPPING_PKG

/
