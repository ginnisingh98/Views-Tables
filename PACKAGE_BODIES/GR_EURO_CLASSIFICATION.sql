--------------------------------------------------------
--  DDL for Package Body GR_EURO_CLASSIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_EURO_CLASSIFICATION" AS
/*$Header: GRPEUROB.pls 120.1 2005/09/06 14:37:36 pbamb noship $*/
PROCEDURE Classify_Hazard
	   			 (errbuf OUT NOCOPY VARCHAR2,
	   			  retcode OUT NOCOPY VARCHAR2,
	   			  p_api_version IN NUMBER,
	   			  p_init_msg_list IN VARCHAR2,
	   			  p_commit IN VARCHAR2,
				  p_validation_level IN NUMBER,
				  p_item_to_classify_from IN VARCHAR2,
				  p_item_to_classify_to IN VARCHAR2,
				  p_print_calculations IN VARCHAR2,
				  x_session_id OUT NOCOPY NUMBER,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_msg_count OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)
	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Classify_Hazard;

PROCEDURE Assign_Risk_Phrases	(errbuf OUT NOCOPY VARCHAR2,
	   			  retcode OUT NOCOPY VARCHAR2,
	   			  p_api_version IN NUMBER,
	   			  p_session_id IN NUMBER,
				  p_item_to_classify IN VARCHAR2,
				  p_print_calculations IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_msg_count OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)

	IS
BEGIN

   NULL;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

/* 	Exception Handling */
EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Assign_Risk_Phrases;

PROCEDURE Assign_Safety_Phrases (errbuf OUT NOCOPY VARCHAR2,
	   			  retcode OUT NOCOPY VARCHAR2,
	   			  p_api_version IN NUMBER,
	   			  p_session_id IN NUMBER,
				  p_item_to_classify IN VARCHAR2,
				  p_print_calculations IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_msg_count OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)

  IS
  BEGIN
 NULL;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

/*    Exception Handling */
EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Assign_Safety_Phrases;


PROCEDURE Update_Hazard_Classifications	(errbuf OUT NOCOPY VARCHAR2,
	   			  	retcode OUT NOCOPY VARCHAR2,
	   			  	p_api_version IN NUMBER,
	   			  	p_init_msg_list IN VARCHAR2,
	   			  	p_commit IN VARCHAR2,
	   			  	p_validation_level IN NUMBER,
	   			  	p_session_id IN NUMBER,
				  	p_item_to_update IN VARCHAR2,
				  	p_update_documents IN VARCHAR2,
				  	p_delete_work IN VARCHAR2,
				  	x_return_status OUT NOCOPY VARCHAR2,
				  	x_msg_count OUT NOCOPY NUMBER,
				  	x_msg_data OUT NOCOPY VARCHAR2)

  IS
  BEGIN
 NULL;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

/*    Exception Handling */
EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Update_Hazard_Classifications;

PROCEDURE Delete_Work_Data	(errbuf OUT NOCOPY VARCHAR2,
	   			  retcode OUT NOCOPY VARCHAR2,
	   			  p_api_version IN NUMBER,
	   			  p_init_msg_list IN VARCHAR2,
	   			  p_commit IN VARCHAR2,
	   			  p_validation_level IN NUMBER,
	   			  p_session_id IN NUMBER,
				  p_item_code IN VARCHAR2,
				  x_return_status OUT NOCOPY VARCHAR2,
				  x_msg_count OUT NOCOPY NUMBER,
				  x_msg_data OUT NOCOPY VARCHAR2)

  IS
  BEGIN
 NULL;
   x_return_status := FND_API.G_RET_STS_SUCCESS;

/*    Exception Handling */
EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Delete_Work_Data;

FUNCTION ITEM_MATCHES_CATEGORY_VALUE(p_item_to_compare IN VARCHAR2,
                                       p_safety_category_code IN VARCHAR2,
                                       p_category_value IN VARCHAR2) RETURN BOOLEAN IS


  BEGIN
    NULL;
    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN

      RETURN TRUE ;
  END ITEM_MATCHES_CATEGORY_VALUE;
END GR_EURO_CLASSIFICATION;

/
