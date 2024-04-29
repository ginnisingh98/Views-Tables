--------------------------------------------------------
--  DDL for Package Body CS_SR_PROB_CODE_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_PROB_CODE_MAPPING_PKG" AS
/* $Header: csxpbcdb.pls 120.0 2005/12/12 16:13:25 smisra noship $ */

PROCEDURE VALIDATE_PROBLEM_CODE
(  p_api_version   	IN 	NUMBER,
   p_init_msg_list 	IN 	VARCHAR2,
   p_probcode_criteria_rec  IN CS_SR_PROB_CODE_MAPPING_PKG.probcode_search_rec,
   p_problem_code    IN  VARCHAR2,
   x_return_status                 OUT NOCOPY    VARCHAR2,
   x_msg_count                     OUT NOCOPY     NUMBER,
   x_msg_data                      OUT NOCOPY    VARCHAR2
)IS

 l_api_version     CONSTANT NUMBER := 1.0;
 l_api_name        CONSTANT VARCHAR2(30) := 'VALIDATE_PROBLEM_CODE';
 l_errname varchar2(60);
 l_errmsg varchar2(2000);
 l_errstack varchar2(4000);

 l_problem_code_meaning VARCHAR2(80);
 l_problem_code VARCHAR2(30);
 l_service_request_type_id NUMBER;
 l_inventory_item_id NUMBER;
 l_product_category_id NUMBER;
 l_organization_id NUMBER;
 l_category_set_id NUMBER;

 l_start_date_active DATE;
 l_end_date_active DATE;


/* This cursor checks if the problem code is an active problem code or not.
   If it is NOT an active problem code, we stop validation immeadiately
   Else, we continue with the rest of the problem code validation  */
CURSOR cs_sr_active_pc_csr IS
    select meaning from
    cs_lookups cslkup
    where
        cslkup.lookup_type='REQUEST_PROBLEM_CODE' and
        cslkup.lookup_code = l_problem_code and
        (cslkup.start_date_active is null or trunc(cslkup.start_date_active) <= trunc(sysdate)) and
        (cslkup.end_date_active is null or trunc(cslkup.end_date_active) >= trunc(sysdate));



/* This cursor checks if the problem code is in the unmapped problem code list
   We also make sure that even if a problem code mapping is found, it has to be
   an active problem code mapping. Else, we assume that the problem code mapping
   can be disregarded */
CURSOR cs_sr_unmapped_pc_csr IS
    select meaning from
    cs_lookups cslkup
    where
        cslkup.lookup_type='REQUEST_PROBLEM_CODE' and
        cslkup.lookup_code = l_problem_code and
        not exists
    	( select 'X' from
          cs_sr_prob_code_mapping_detail cstl
    	  where
          cstl.problem_code = cslkup.lookup_code  and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
          (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
          (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate)));


/*
  The following set of cursors will check if the problem code is mapped to one of the following search criteria :
    1)  Service Request Type
    2)  Product
    3)  Product Category (All product categories that belong to the product category set held by
        the CS_SR_DEFAULT_CATEGORY_SET profile option)
    4)  Service Request Type + Product
    5)  Service Request Type + All product categories that belong to the product category set held by the
        CS_SR_DEFAULT_CATEGORY_SET profile option

   We also make sure that even if a problem code mapping is found, it has to be
   an active problem code mapping. Else, we assume that the problem code mapping
   can be disregarded
*/

CURSOR cs_sr_pc_catset_with_srtype IS
select meaning
from
     cs_lookups cslkup
where
       cslkup.lookup_type='REQUEST_PROBLEM_CODE' and
       cslkup.lookup_code = l_problem_code and
       exists
     	( select 'X' from
          cs_sr_prob_code_mapping_detail cstl
    	  where
      	  cstl.problem_code = cslkup.lookup_code and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
          (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
          (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate))
 		  and
          (
           (cstl.incident_type_id  = l_service_request_type_id and
		    cstl.inventory_item_id is null and
            cstl.category_id is null)
          or
	      (cstl.incident_type_id = l_service_request_type_id and
           cstl.inventory_item_id = l_inventory_item_id and
           cstl.organization_id = l_organization_id and
           cstl.category_id is null)
          or
 	      (cstl.incident_type_id = l_service_request_type_id and
           cstl.inventory_item_id is null and
           exists (select category_id from mtl_item_categories cmtlc
                   where
                   cmtlc.category_id = cstl.category_id and
                   category_set_id = l_category_set_id and
                   cmtlc.inventory_item_id = l_inventory_item_id and
                   cmtlc.organization_id = l_organization_id))

           )
	  );



CURSOR cs_sr_pc_catset_with_prod IS
select meaning
from
     cs_lookups cslkup
where
       cslkup.lookup_type='REQUEST_PROBLEM_CODE' and
       cslkup.lookup_code = l_problem_code and
       exists
     	( select 'X' from
          cs_sr_prob_code_mapping_detail cstl
    	  where
      	  cstl.problem_code = cslkup.lookup_code and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
          (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
          (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate))
 		  and
          (
          (cstl.incident_type_id is null and
           cstl.inventory_item_id = l_inventory_item_id and
           cstl.organization_id = l_organization_id and
           cstl.category_id is null)
          or
          (cstl.incident_type_id is null  and
           cstl.inventory_item_id is null and
           exists (select category_id from mtl_item_categories cmtlc
                   where
                   cmtlc.category_id = cstl.category_id and
                   category_set_id = l_category_set_id and /* value from profile CS_SR_DEFAULT_CATEGORY_SET */
                   cmtlc.inventory_item_id = l_inventory_item_id and
                   cmtlc.organization_id = l_organization_id))


           )
	  );


/*
The following set of cursors will check if the problem code is mapped to one of the following search criteria :
1)  Service Request Type
2)  Product
3)  Product Category - this cursor will be executed only if a product category value  is passed in as a input parameter
4)  Service Request Type + Product
5)  Service Request Type + Product Category

   We also make sure that even if a problem code mapping is found, it has to be
   an active problem code mapping. Else, we assume that the problem code mapping
   can be disregarded
*/

CURSOR cs_sr_pc_cat_with_srtype IS
select meaning
from
     cs_lookups cslkup
where
       cslkup.lookup_type='REQUEST_PROBLEM_CODE' and
       cslkup.lookup_code = l_problem_code and
       exists
       ( select 'X' from
         cs_sr_prob_code_mapping_detail cstl
  	     where
 	     cstl.problem_code = cslkup.lookup_code  and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
         (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
         (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate))
         and
         (
          (cstl.incident_type_id  = l_service_request_type_id and
		   cstl.inventory_item_id is null and
           cstl.category_id is null)
         or
	      (cstl.incident_type_id = l_service_request_type_id and
           cstl.inventory_item_id = l_inventory_item_id and
           cstl.organization_id = l_organization_id and
           cstl.category_id is null)
         or
	      (cstl.incident_type_id = l_service_request_type_id and
           cstl.inventory_item_id is null and
           cstl.category_id = l_product_category_id)
         )
	   );


CURSOR cs_sr_pc_cat_with_prod IS
select meaning
from
     cs_lookups cslkup
where
       cslkup.lookup_type='REQUEST_PROBLEM_CODE' and
       cslkup.lookup_code = l_problem_code and
       exists
       ( select 'X' from
         cs_sr_prob_code_mapping_detail cstl
  	     where
 	     cstl.problem_code = cslkup.lookup_code  and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
         (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
         (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate))
         and
         (
          cstl.incident_type_id is null  and
          cstl.inventory_item_id = l_inventory_item_id and
          cstl.organization_id = l_organization_id and
          cstl.category_id is null
         )
  	    ) ;


CURSOR cs_sr_pc_cat_with_prodcat IS
select meaning
from
     cs_lookups cslkup
where
       cslkup.lookup_type='REQUEST_PROBLEM_CODE' and
       cslkup.lookup_code = l_problem_code and
       exists
       ( select 'X' from
         cs_sr_prob_code_mapping_detail cstl
  	     where
 	     cstl.problem_code = cslkup.lookup_code  and
          (cstl.map_start_date_active is null or trunc(cstl.map_start_date_active) <= trunc(sysdate)) and
          (cstl.map_end_date_active is null or trunc(cstl.map_end_date_active) >= trunc(sysdate)) and
         (cstl.start_date_active is null or trunc(cstl.start_date_active) <= trunc(sysdate)) and
         (cstl.end_date_active is null or trunc(cstl.end_date_active) >= trunc(sysdate))
         and
         (
          cstl.incident_type_id is null  and
          cstl.inventory_item_id is null and
          cstl.organization_id is null and
          cstl.category_id = l_product_category_id
         )
  	    ) ;


BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 IF fnd_api.to_boolean (p_init_msg_list)
 THEN
     fnd_msg_pub.initialize;
 END IF;


 l_service_request_type_id := nvl(p_probcode_criteria_rec.service_request_type_id,0);
 l_product_category_id := nvl(p_probcode_criteria_rec.product_category_id,0);
 l_inventory_item_id := nvl(p_probcode_criteria_rec.inventory_item_id,0);
 l_organization_id := nvl(p_probcode_criteria_rec.organization_id,0);
 l_problem_code := p_problem_code;
 l_category_set_id := FND_PROFILE.value('CS_SR_DEFAULT_CATEGORY_SET');

 IF (l_service_request_type_id = FND_API.G_MISS_NUM) THEN
        l_service_request_type_id := 0;
 END IF;
 IF (l_product_category_id = FND_API.G_MISS_NUM) THEN
        l_product_category_id := 0;
 END IF;
  IF (l_inventory_item_id = FND_API.G_MISS_NUM) THEN
        l_inventory_item_id := 0;
 END IF;
  IF (l_organization_id = FND_API.G_MISS_NUM) THEN
        l_organization_id := 0;
 END IF;
 IF (l_problem_code = FND_API.G_MISS_CHAR) THEN
     RAISE FND_API.G_EXC_ERROR;
 END IF;

  IF (l_inventory_item_id <> 0 and l_organization_id = 0) THEN
    l_organization_id := FND_PROFILE.value('CS_INV_VALIDATION_ORG');
  END IF;

/* Validation Checks on the problem code:
   #1) Check if the problem code exists in the unmapped problem code list or
   #2) Check if the problem code is mapped to any combination of :
        sr type
        sr type and product
        sr type and prod category
   #3) Check if the problem code is mapped to any combination of :
        product
   #4) Check if the problem code is mapped to any combination of :
        product category
   #5) Check if the problem code is mapped to any combination of :
        sr type
        sr type and product
        sr type and prod category
        (where prod category = all product categories that belong to the
         product category set held in the CS_SR_DEFAULT_CATEGORY_SET profile option
   #6) Check if the problem code is mapped to any combination of :
        product
        product category
        (where prod category = all product categories that belong to the
         product category set held in the CS_SR_DEFAULT_CATEGORY_SET profile option
   #7) Check if the problem code is an active problem code or not. Since this is
       the most basic check, it will be executed before the other validation checks
*/

/* Validation Check #7 */
 OPEN cs_sr_active_pc_csr;
 FETCH cs_sr_active_pc_csr into l_problem_code_meaning;
 IF (cs_sr_active_pc_csr%NOTFOUND) THEN
     RAISE FND_API.G_EXC_ERROR;
 END IF;

/* Validation Check #1 */
 OPEN cs_sr_unmapped_pc_csr;
 FETCH cs_sr_unmapped_pc_csr into l_problem_code_meaning;
 IF (cs_sr_unmapped_pc_csr%NOTFOUND) THEN
 /*
    Now, check if the product_category_id input parameter contained some value

    If yes,
        **) open cs_sr_pc_cat_with_srtype cursor - this cursor checks all mappings containing the
                                                  sr type and/or prod and/or prod category
        **) If the above cursor did not find a hit, then, open cs_sr_pc_cat_with_prod cursor
                                                 -- this cursor checks mappings containing the product(inventory item)
     Else,
        **) open cs_sr_pc_catset_with_srtype cursor - this cursor checks all mappings containing the
                                                     sr type and/or prod and/or prod category
                                                     where prod category = all categories belonging to category set held
                                                     in CS_SR_DEFAULT_CATEGORY_SET profile option;
        **) If the above cursor did not find a hit, then, open cs_sr_pc_catset_with_prod cursor
                                                 -- this cursor checks mappings containing the product(inventory item)
        **) If the above cursor did not find a hit, then, open cs_sr_pc_catset_with_prodcat cursor
                                                 -- this cursor checks mappings containing the product category

 */

/* Roopa - Begin - fix for bug 3335668 */
/* Replaced the following IF for the commented IF condition */
      IF (l_product_category_id <> 0) THEN
/* Roopa - End - fix for bug 3335668 */
/* Validation Check #2 */
         OPEN cs_sr_pc_cat_with_srtype;
         FETCH cs_sr_pc_cat_with_srtype into l_problem_code_meaning;

         IF (cs_sr_pc_cat_with_srtype%NOTFOUND) THEN
/* Validation Check #3 */
            OPEN cs_sr_pc_cat_with_prod;
            FETCH cs_sr_pc_cat_with_prod into l_problem_code_meaning;

             IF (cs_sr_pc_cat_with_prod%NOTFOUND) THEN
/* Validation Check #4 */
                OPEN cs_sr_pc_cat_with_prodcat;
                FETCH cs_sr_pc_cat_with_prodcat into l_problem_code_meaning;
                 IF (cs_sr_pc_cat_with_prodcat%NOTFOUND) THEN
                  RAISE FND_API.G_EXC_ERROR;
                 END IF;
             END IF;

          END IF;

      ELSE
/* Validation Check #5 */
         OPEN cs_sr_pc_catset_with_srtype;
         FETCH cs_sr_pc_catset_with_srtype into l_problem_code_meaning;

         IF (cs_sr_pc_catset_with_srtype%NOTFOUND) THEN
/* Validation Check #6 */
            OPEN cs_sr_pc_catset_with_prod;
            FETCH cs_sr_pc_catset_with_prod into l_problem_code_meaning;
             IF (cs_sr_pc_catset_with_prod%NOTFOUND) THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;
          END IF;

     END IF;
 END IF;
 IF cs_sr_unmapped_pc_csr%isopen THEN
        CLOSE cs_sr_unmapped_pc_csr;
 END IF;
 IF cs_sr_pc_cat_with_srtype%isopen THEN
           CLOSE cs_sr_pc_cat_with_srtype;
 END IF;
 IF cs_sr_pc_cat_with_prod%isopen THEN
           CLOSE cs_sr_pc_cat_with_prod;
 END IF;
 IF cs_sr_pc_cat_with_prodcat%isopen THEN
           CLOSE cs_sr_pc_cat_with_prodcat;
 END IF;
 IF cs_sr_pc_catset_with_srtype%isopen THEN
           CLOSE cs_sr_pc_catset_with_srtype;
 END IF;
 IF cs_sr_pc_catset_with_prod%isopen THEN
           CLOSE cs_sr_pc_catset_with_prod;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      IF cs_sr_unmapped_pc_csr%isopen THEN
        CLOSE cs_sr_unmapped_pc_csr;
      END IF;
      IF cs_sr_pc_cat_with_srtype%isopen THEN
           CLOSE cs_sr_pc_cat_with_srtype;
      END IF;
      IF cs_sr_pc_cat_with_prod%isopen THEN
           CLOSE cs_sr_pc_cat_with_prod;
      END IF;
      IF cs_sr_pc_cat_with_prodcat%isopen THEN
           CLOSE cs_sr_pc_cat_with_prodcat;
      END IF;
      IF cs_sr_pc_catset_with_srtype%isopen THEN
           CLOSE cs_sr_pc_catset_with_srtype;
      END IF;
      IF cs_sr_pc_catset_with_prod%isopen THEN
           CLOSE cs_sr_pc_catset_with_prod;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF cs_sr_unmapped_pc_csr%isopen THEN
        CLOSE cs_sr_unmapped_pc_csr;
      END IF;
      IF cs_sr_pc_cat_with_srtype%isopen THEN
           CLOSE cs_sr_pc_cat_with_srtype;
      END IF;
      IF cs_sr_pc_cat_with_prod%isopen THEN
           CLOSE cs_sr_pc_cat_with_prod;
      END IF;
      IF cs_sr_pc_cat_with_prodcat%isopen THEN
           CLOSE cs_sr_pc_cat_with_prodcat;
      END IF;
      IF cs_sr_pc_catset_with_srtype%isopen THEN
           CLOSE cs_sr_pc_catset_with_srtype;
      END IF;
      IF cs_sr_pc_catset_with_prod%isopen THEN
           CLOSE cs_sr_pc_catset_with_prod;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
      IF cs_sr_unmapped_pc_csr%isopen THEN
        CLOSE cs_sr_unmapped_pc_csr;
      END IF;
      IF cs_sr_pc_cat_with_srtype%isopen THEN
           CLOSE cs_sr_pc_cat_with_srtype;
      END IF;
      IF cs_sr_pc_cat_with_prod%isopen THEN
           CLOSE cs_sr_pc_cat_with_prod;
      END IF;
      IF cs_sr_pc_cat_with_prodcat%isopen THEN
           CLOSE cs_sr_pc_cat_with_prodcat;
      END IF;
      IF cs_sr_pc_catset_with_srtype%isopen THEN
           CLOSE cs_sr_pc_catset_with_srtype;
      END IF;
      IF cs_sr_pc_catset_with_prod%isopen THEN
           CLOSE cs_sr_pc_catset_with_prod;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg('CS_SR_PROB_CODE_MAPPING_PKG', l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END VALIDATE_PROBLEM_CODE; -- End of procedure VALIDATE_PROBLEM_CODE()




PROCEDURE CREATE_MAPPING_RULES
( p_api_version			  IN         NUMBER,
  p_init_msg_list		  IN         VARCHAR2,
  p_commit			      IN         VARCHAR2,
  p_probcode_map_criteria_rec IN probcode_map_criteria_rec,
  p_problem_codes_tbl            IN problem_codes_tbl_type,
  x_return_status		  OUT NOCOPY VARCHAR2,
  x_msg_count			  OUT NOCOPY NUMBER,
  x_msg_data			  OUT NOCOPY VARCHAR2,
  x_problem_map_id        OUT NOCOPY NUMBER
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

 l_service_request_type_id NUMBER;
 l_inventory_item_id NUMBER;
 l_organization_id NUMBER;
 l_product_category_id NUMBER;
 l_problem_map_id NUMBER;
 l_problem_map_detail_id NUMBER;

 l_start_date_active DATE;
 l_end_date_active DATE;

 l_current_date                DATE           :=sysdate;
 l_created_by                  NUMBER         :=fnd_global.user_id;
 l_login                       NUMBER         :=fnd_global.login_id;
 l_row_id                       VARCHAR2(100);
 l_temp NUMBER;

 l_prob_code_index             BINARY_INTEGER;

 CURSOR c_sr_criteria_exists_csr IS
    SELECT problem_map_id,start_date_active, end_date_active from cs_sr_prob_code_mapping
    WHERE incident_type_id = l_service_request_type_id
    AND   category_id = l_product_category_id
    AND   inventory_item_id = l_inventory_item_id
    AND   organization_id = l_organization_id
    AND   (start_date_active is null or trunc(start_date_active) <= trunc(sysdate)) and
          (end_date_active is null or trunc(end_date_active) >= trunc(sysdate));
 c_sr_criteria_exists_rec c_sr_criteria_exists_csr%ROWTYPE;

 CURSOR c_sr_prod_cat_valid_csr IS
    SELECT  category_id from mtl_category_set_valid_cats
    WHERE category_set_id = to_number(l_product_category_set)
    AND category_id = l_product_category_id;

 CURSOR c_sr_problem_code_valid_csr IS
    SELECT lookup_code from cs_lookups
    WHERE lookup_code = l_problem_code
    AND   lookup_type = 'REQUEST_PROBLEM_CODE'and
          (start_date_active is null or
           trunc(start_date_active) <= trunc(sysdate)) and
          (end_date_active is null or
           trunc(end_date_active) >= trunc(sysdate));

 CURSOR c_sr_prob_code_map_exists_csr IS
    SELECT problem_map_detail_id,start_date_active, end_date_active from cs_sr_prob_code_mapping_detail
    WHERE problem_map_id = l_problem_map_id
    AND   problem_code = l_problem_code
    AND  (start_date_active is null or trunc(start_date_active) <= trunc(sysdate))
    AND  (end_date_active is null or trunc(end_date_active) >= trunc(sysdate));
 c_sr_prob_code_map_exists_rec c_sr_prob_code_map_exists_csr%ROWTYPE;

BEGIN

      SAVEPOINT create_mapping_rules;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

/* First, we create the search criteria
   Then, we create the  problem code mappings to this search criteria */

/* The following validation checks will be executed on the search criteria:
    #1) the product categroy and product cannot be part of the same search criteria
    #2) all search criteria attributes should NOT be null in the search criteria
    #3) Organization Id should not be null IF inventory item is not null
    #4) the search criteria should not already be present in the CS_SR_PROB_CODE_MAPPING table
    #5) the product category of the new search criteria, if passed, should belong to the default category set
        whose value is held in the profile option - CS_SR_DEFAULT_CATEGORY_SET
    #6) the start date of the new search criteria should NOT be greater than the end date
*/

/* Validation check #1 */
      IF ( p_probcode_map_criteria_rec.product_category_id is not null and
           p_probcode_map_criteria_rec.inventory_item_id is not null) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

/* Validation check #2 */
      IF (p_probcode_map_criteria_rec.product_category_id is null and
          p_probcode_map_criteria_rec.inventory_item_id is null and
          p_probcode_map_criteria_rec.service_request_type_id is null) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

/* Validation check #3 */
      IF (p_probcode_map_criteria_rec.inventory_item_id is not null and
          p_probcode_map_criteria_rec.organization_id is null) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;

/* Validation check #4 */
      l_product_category_id := nvl(p_probcode_map_criteria_rec.product_category_id,0);
      l_inventory_item_id   := nvl(p_probcode_map_criteria_rec.inventory_item_id,0);
      l_organization_id := nvl(p_probcode_map_criteria_rec.organization_id,0);
      l_service_request_type_id := nvl(p_probcode_map_criteria_rec.service_request_type_id,0);

      l_start_date_active := nvl(p_probcode_map_criteria_rec.start_date_active, sysdate);
      l_end_date_active := nvl(p_probcode_map_criteria_rec.end_date_active, sysdate);

      OPEN c_sr_criteria_exists_csr;
      FETCH c_sr_criteria_exists_csr into c_sr_criteria_exists_rec;
      IF (c_sr_criteria_exists_csr%FOUND) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;-- end of IF (c_sr_criteria_exists_csr%FOUND)
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
   CS_SR_PROB_CODE_MAPPING table */
  CS_SR_PROBLEM_CODE_MAPPING_PKG.INSERT_ROW (
  PX_PROBLEM_MAP_ID => l_problem_map_id,
  P_INCIDENT_TYPE_ID => l_service_request_type_id,
  P_INVENTORY_ITEM_ID => l_inventory_item_id,
  P_ORGANIZATION_ID => l_organization_id,
  P_CATEGORY_ID => l_product_category_id,
  P_PROBLEM_CODE => null,
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
  X_MSG_COUNT	    => l_msg_count,
  X_MSG_DATA	    => l_errmsg);

     IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE fnd_api.g_exc_unexpected_error;
     END IF;

/* Now, we need to create the actual problem code -> search criteria mapping details in
   CS_SR_PROB_CODE_MAPPING_DETAIL table */

/* First, the following validation checks :
    #1) the problem code should be a CS lookup code with lookup type = 'REQUEST_PROBLEM_CODE'
    #2) the problem code mapping should not already be present. Though this is creation API, it is
        still possible that the same problem code is passed twice in the prob code mapping table parameter
    #3) the start date of the problem code mapping should NOT be greater than the mapping end date
*/


     l_prob_code_index := p_problem_codes_tbl.FIRST;
     WHILE l_prob_code_index IS NOT NULL LOOP

       IF ((p_problem_codes_tbl(l_prob_code_index).problem_code IS NOT NULL) AND
           (p_problem_codes_tbl(l_prob_code_index).problem_code <> FND_API.G_MISS_CHAR)) THEN

            l_problem_code := p_problem_codes_tbl(l_prob_code_index).problem_code;
            l_start_date_active := p_problem_codes_tbl(l_prob_code_index).start_date_active;
            l_end_date_active := p_problem_codes_tbl(l_prob_code_index).end_date_active;

/* Validation check #1 */
            OPEN c_sr_problem_code_valid_csr;
            FETCH c_sr_problem_code_valid_csr INTO l_problem_code;
            IF(c_sr_problem_code_valid_csr%NOTFOUND) THEN
                  RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            CLOSE c_sr_problem_code_valid_csr;

/* Validation check #2 */
          OPEN c_sr_prob_code_map_exists_csr;
          FETCH c_sr_prob_code_map_exists_csr into c_sr_prob_code_map_exists_rec;
          IF(c_sr_prob_code_map_exists_csr%FOUND) THEN
              RAISE fnd_api.g_exc_unexpected_error;
          END IF;
          CLOSE c_sr_prob_code_map_exists_csr;

/* Validation check #3 */
/* start date cannot be greater then end date */
      IF(l_start_date_active is not null AND l_end_date_active is not null AND
         l_start_date_active >= l_end_date_active) THEN
              RAISE fnd_api.g_exc_unexpected_error;
      END IF;

/* We can create the problem code mapping in CS_SR_PROB_CODE_MAPPING_DETAIL table now */
CS_SR_PROB_CODE_MAP_DETAIL_PKG.INSERT_ROW (
  PX_PROBLEM_MAP_DETAIL_ID => l_problem_map_detail_id,
  P_PROBLEM_MAP_ID => l_problem_map_id,
  P_INCIDENT_TYPE_ID => l_service_request_type_id,
  P_INVENTORY_ITEM_ID => l_inventory_item_id,
  P_ORGANIZATION_ID => l_organization_id,
  P_CATEGORY_ID => l_product_category_id,
  P_MAP_START_DATE_ACTIVE => null,
  P_MAP_END_DATE_ACTIVE => null,
  P_PROBLEM_CODE => null,
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
  P_LAST_UPDATED_BY  => l_created_by,
  P_LAST_UPDATE_LOGIN => l_login,
  X_RETURN_STATUS => l_return_status,
  X_MSG_COUNT		 => l_msg_count,
  X_MSG_DATA		=> l_errmsg);

             IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE fnd_api.g_exc_unexpected_error;
             END IF;

       END IF;
       l_prob_code_index := p_problem_codes_tbl.NEXT(l_prob_code_index);

     END LOOP;
     x_problem_map_id := l_problem_map_id;
     IF c_sr_criteria_exists_csr%isopen THEN
        CLOSE c_sr_criteria_exists_csr;
     END IF;
     IF c_sr_prod_cat_valid_csr%isopen THEN
        CLOSE c_sr_prod_cat_valid_csr;
     END IF;
     IF c_sr_problem_code_valid_csr%isopen THEN
        CLOSE c_sr_problem_code_valid_csr;
     END IF;
     IF c_sr_prob_code_map_exists_csr%isopen THEN
        CLOSE c_sr_prob_code_map_exists_csr;
     END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     IF c_sr_criteria_exists_csr%isopen THEN
        CLOSE c_sr_criteria_exists_csr;
     END IF;
     IF c_sr_prod_cat_valid_csr%isopen THEN
        CLOSE c_sr_prod_cat_valid_csr;
     END IF;
     IF c_sr_problem_code_valid_csr%isopen THEN
        CLOSE c_sr_problem_code_valid_csr;
     END IF;
     IF c_sr_prob_code_map_exists_csr%isopen THEN
        CLOSE c_sr_prob_code_map_exists_csr;
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
     IF c_sr_problem_code_valid_csr%isopen THEN
        CLOSE c_sr_problem_code_valid_csr;
     END IF;
     IF c_sr_prob_code_map_exists_csr%isopen THEN
        CLOSE c_sr_prob_code_map_exists_csr;
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
     IF c_sr_problem_code_valid_csr%isopen THEN
        CLOSE c_sr_problem_code_valid_csr;
     END IF;
     IF c_sr_prob_code_map_exists_csr%isopen THEN
        CLOSE c_sr_prob_code_map_exists_csr;
     END IF;
     ROLLBACK TO create_mapping_rules;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg('CS_SR_PROB_CODE_MAPPING_PKG', l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
END CREATE_MAPPING_RULES;


PROCEDURE UPDATE_MAPPING_RULES
( p_api_version			  IN         NUMBER,
  p_init_msg_list		  IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_commit			      IN         VARCHAR2 	:= FND_API.G_FALSE,
  p_probcode_map_criteria_rec IN probcode_map_criteria_rec,
  p_problem_codes_tbl            IN  problem_codes_tbl_type,
  x_return_status		  OUT NOCOPY VARCHAR2,
  x_msg_count			  OUT NOCOPY NUMBER,
  x_msg_data			  OUT NOCOPY VARCHAR2
) IS

 l_api_version     CONSTANT NUMBER := 1.0;
 l_api_name        CONSTANT VARCHAR2(30) := 'UPDATE_MAPPING_RULES';
 l_errname varchar2(60);
 l_errmsg varchar2(2000);
 l_msg_count NUMBER;
 l_errstack varchar2(4000);
 l_return_status              VARCHAR2(1);

 l_problem_map_id NUMBER;
 l_problem_map_detail_id NUMBER;
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

 l_prob_code_index             BINARY_INTEGER;

 CURSOR cs_sr_probmapid_exists_csr IS
    SELECT problem_map_id,incident_type_id,category_id,inventory_item_id,organization_id
    FROM CS_SR_PROB_CODE_MAPPING
    WHERE problem_map_id <> l_problem_map_id AND
          incident_type_id = l_service_request_type_id AND
          category_id = l_product_category_id AND
          inventory_item_id = l_inventory_item_id AND
          organization_id = l_organization_id AND
          (start_date_active is null or
           trunc(start_date_active) <= trunc(sysdate)) and
          (end_date_active is null or
           trunc(end_date_active) >= trunc(sysdate));


CURSOR cs_sr_problem_code_valid_csr IS
    SELECT lookup_code from cs_lookups a
    WHERE lookup_code = l_problem_code
    AND   lookup_type = 'REQUEST_PROBLEM_CODE' and
          (start_date_active is null or
           trunc(start_date_active) <= trunc(sysdate)) and
          (end_date_active is null or
           trunc(end_date_active) >= trunc(sysdate));

CURSOR cs_sr_probcode_mapped_csr IS
     SELECT problem_code,start_date_active,end_date_active from CS_SR_PROB_CODE_MAPPING_DETAIL
      WHERE problem_map_id = l_problem_map_id and
            problem_map_detail_id <> nvl(l_problem_map_detail_id,0) and
            problem_code = l_problem_code and
            (start_date_active is null or
             trunc(start_date_active) <= trunc(sysdate)) and
            (end_date_active is null or
             trunc(end_date_active) >= trunc(sysdate));

cs_sr_probcode_mapped_rec cs_sr_probcode_mapped_csr%ROWTYPE;


BEGIN

      SAVEPOINT update_mapping_rules;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      l_problem_map_id := p_probcode_map_criteria_rec.problem_map_id;
      l_start_date_active := p_probcode_map_criteria_rec.start_date_active;
      l_end_date_active   := p_probcode_map_criteria_rec.end_date_active;
      l_service_request_type_id := nvl(p_probcode_map_criteria_rec.service_request_type_id, 0);
      l_product_category_id := nvl(p_probcode_map_criteria_rec.product_category_id, 0);
      l_inventory_item_id := nvl(p_probcode_map_criteria_rec.inventory_item_id, 0);
      l_organization_id := nvl(p_probcode_map_criteria_rec.organization_id,0);

/* Validation checks are :
    #1) problem map id should not be null
    #2) All search attributes should not be null
    #3) product and product category cannot be part of the same search criteria
    #4) end date of the search criteria should not be lesser than start date
    #5) a search criteria should not exist which is exactly similar to the current search criteria
    #6) problem code being mapped to the search criteria should be an active CS lookup code of lookup type = 'REQUEST_PROBLEM_CODE'
    #7) a duplicate problem code mapping should not already exists for the current search criteria
*/

/* Validation check #1 */
    IF (l_problem_map_id is null) THEN
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
      OPEN   cs_sr_probmapid_exists_csr;
      IF(cs_sr_probmapid_exists_csr%FOUND) THEN
          RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      CLOSE  cs_sr_probmapid_exists_csr;


     l_prob_code_index := p_problem_codes_tbl.FIRST;
     WHILE l_prob_code_index IS NOT NULL LOOP

       IF ((p_problem_codes_tbl(l_prob_code_index).problem_code IS NOT NULL) AND
           (p_problem_codes_tbl(l_prob_code_index).problem_code <> FND_API.G_MISS_CHAR)) THEN

            l_problem_code := p_problem_codes_tbl(l_prob_code_index).problem_code;
            l_start_date_active := p_problem_codes_tbl(l_prob_code_index).start_date_active;
            l_end_date_active := p_problem_codes_tbl(l_prob_code_index).end_date_active;
            l_problem_map_detail_id := p_problem_codes_tbl(l_prob_code_index).problem_map_detail_id;


/* Validation check #6 */
            OPEN cs_sr_problem_code_valid_csr;
            IF(cs_sr_problem_code_valid_csr%NOTFOUND) THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            CLOSE cs_sr_problem_code_valid_csr;

/* Validation check #7 */
            OPEN cs_sr_probcode_mapped_csr;
            FETCH cs_sr_probcode_mapped_csr into cs_sr_probcode_mapped_rec;
            IF(cs_sr_probcode_mapped_csr%FOUND) THEN
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            CLOSE cs_sr_probcode_mapped_csr;

            IF(p_problem_codes_tbl(l_prob_code_index).problem_map_detail_id is null) THEN

CS_SR_PROB_CODE_MAP_DETAIL_PKG.INSERT_ROW (
  PX_PROBLEM_MAP_DETAIL_ID => l_problem_map_detail_id,
  P_PROBLEM_MAP_ID => l_problem_map_id,
  P_INCIDENT_TYPE_ID => l_service_request_type_id,
  P_INVENTORY_ITEM_ID => l_inventory_item_id,
  P_ORGANIZATION_ID => l_organization_id,
  P_CATEGORY_ID => l_product_category_id,
  P_MAP_START_DATE_ACTIVE => null,
  P_MAP_END_DATE_ACTIVE => null,
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
  P_LAST_UPDATED_BY  => l_created_by,
  P_LAST_UPDATE_LOGIN => l_login,
  X_RETURN_STATUS => l_return_status,
  X_MSG_COUNT		 => l_msg_count,
  X_MSG_DATA		=> l_errmsg);

        ELSE

CS_SR_PROB_CODE_MAP_DETAIL_PKG.UPDATE_ROW (
  P_PROBLEM_MAP_DETAIL_ID => l_problem_map_detail_id,
  P_PROBLEM_MAP_ID => l_problem_map_id,
  P_INCIDENT_TYPE_ID => l_service_request_type_id,
  P_INVENTORY_ITEM_ID => l_inventory_item_id,
  P_ORGANIZATION_ID => l_organization_id,
  P_CATEGORY_ID => l_product_category_id,
  P_MAP_START_DATE_ACTIVE => null,
  P_MAP_END_DATE_ACTIVE => null,
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
  P_LAST_UPDATE_DATE => l_current_date,
  P_LAST_UPDATED_BY  => l_created_by,
  P_LAST_UPDATE_LOGIN => l_login,
  X_RETURN_STATUS => l_return_status,
  X_MSG_COUNT		 => l_msg_count,
  X_MSG_DATA		=> l_errmsg);



        END IF;
        IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;
      l_prob_code_index := p_problem_codes_tbl.NEXT(l_prob_code_index);
      END LOOP;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF cs_sr_probmapid_exists_csr%isopen THEN
        CLOSE cs_sr_probmapid_exists_csr;
     END IF;
     IF cs_sr_problem_code_valid_csr%isopen THEN
        CLOSE cs_sr_problem_code_valid_csr;
     END IF;
     IF cs_sr_probcode_mapped_csr%isopen THEN
        CLOSE cs_sr_probcode_mapped_csr;
     END IF;
     ROLLBACK TO update_mapping_rules;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
        p_data  => x_msg_data
     );
    WHEN OTHERS THEN
     IF cs_sr_probmapid_exists_csr%isopen THEN
        CLOSE cs_sr_probmapid_exists_csr;
     END IF;
     IF cs_sr_problem_code_valid_csr%isopen THEN
        CLOSE cs_sr_problem_code_valid_csr;
     END IF;
     IF cs_sr_probcode_mapped_csr%isopen THEN
        CLOSE cs_sr_probcode_mapped_csr;
     END IF;
     ROLLBACK TO update_mapping_rules;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
        p_data  => x_msg_data
     );


END; -- End of procedure UPDATE_MAPPING_RULES()



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

 l_problem_map_id NUMBER;
 l_problem_map_detail_id NUMBER;
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

 CURSOR cs_sr_probmapid_crit_csr IS
    SELECT problem_map_id, start_date_active, end_date_active
    FROM CS_SR_PROB_CODE_MAPPING;
 cs_sr_probmapid_crit_rec cs_sr_probmapid_crit_csr%ROWTYPE;


 CURSOR cs_sr_probmapid_rules_csr IS
    SELECT problem_map_id, problem_map_detail_id,
           map_start_date_active, map_end_date_active,
           start_date_active, end_date_active,
           incident_type_id, inventory_item_id, organization_id,
           category_id, problem_code
    FROM CS_SR_PROB_CODE_MAPPING_DETAIL
    WHERE
        problem_map_id = l_problem_map_id;
 cs_sr_probmapid_rules_rec cs_sr_probmapid_rules_csr%ROWTYPE;


BEGIN
      SAVEPOINT propagate_map_criteria_dates;
      x_return_status := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      OPEN cs_sr_probmapid_crit_csr;
      LOOP

          FETCH cs_sr_probmapid_crit_csr into cs_sr_probmapid_crit_rec;
          EXIT WHEN cs_sr_probmapid_crit_csr%NOTFOUND;

          l_problem_map_id := cs_sr_probmapid_crit_rec.problem_map_id;
          OPEN cs_sr_probmapid_rules_csr;
          FETCH cs_sr_probmapid_rules_csr INTO cs_sr_probmapid_rules_rec;
          CLOSE cs_sr_probmapid_rules_csr;

          IF(cs_sr_probmapid_crit_rec.start_date_active is not null AND
             nvl(cs_sr_probmapid_rules_rec.map_start_date_active, cs_sr_probmapid_crit_rec.start_date_active+1) <> cs_sr_probmapid_crit_rec.start_date_active) THEN

            update CS_SR_PROB_CODE_MAPPING_DETAIL
            set
                map_start_date_active = cs_sr_probmapid_crit_rec.start_date_active,
                map_end_date_active = cs_sr_probmapid_crit_rec.end_date_active
            where
                problem_map_id = l_problem_map_id;
          ELSIF (cs_sr_probmapid_crit_rec.start_date_active is null AND
                 cs_sr_probmapid_crit_rec.end_date_active is not null AND
                 nvl(cs_sr_probmapid_rules_rec.map_end_date_active, cs_sr_probmapid_crit_rec.end_date_active+1) <> cs_sr_probmapid_crit_rec.end_date_active) THEN

            update CS_SR_PROB_CODE_MAPPING_DETAIL
            set
                map_start_date_active = cs_sr_probmapid_crit_rec.start_date_active,
                map_end_date_active = cs_sr_probmapid_crit_rec.end_date_active
            where
                problem_map_id = l_problem_map_id;

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
      CLOSE cs_sr_probmapid_crit_csr;
      commit;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     IF cs_sr_probmapid_crit_csr%isopen THEN
        CLOSE cs_sr_probmapid_crit_csr;
     END IF;
     IF cs_sr_probmapid_rules_csr%isopen THEN
        CLOSE cs_sr_probmapid_rules_csr;
     END IF;
     ROLLBACK TO propagate_map_criteria_dates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
        p_data  => x_msg_data
     );
    WHEN OTHERS THEN
     IF cs_sr_probmapid_crit_csr%isopen THEN
        CLOSE cs_sr_probmapid_crit_csr;
     END IF;
     IF cs_sr_probmapid_rules_csr%isopen THEN
        CLOSE cs_sr_probmapid_rules_csr;
     END IF;
     ROLLBACK TO propagate_map_criteria_dates;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
     ( p_count => x_msg_count,
        p_data  => x_msg_data
     );
END;




   -- Enter further code below as specified in the Package spec.
END CS_SR_PROB_CODE_MAPPING_PKG; -- Package Body CS_SR_PROB_CODE_MAPPING_PKG

/
