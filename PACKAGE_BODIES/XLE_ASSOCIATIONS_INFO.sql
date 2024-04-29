--------------------------------------------------------
--  DDL for Package Body XLE_ASSOCIATIONS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_ASSOCIATIONS_INFO" AS
/* $Header: xleasinb.pls 120.2 2006/04/17 07:39:59 akonatha ship $ */

/* =======================================================================
 | Global Data Types
 * ======================================================================*/

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'XLE_ASSOCIATIONS_INFO';

G_MSG_UERROR   CONSTANT NUMBER  :=  FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR    CONSTANT NUMBER  :=  FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS  CONSTANT NUMBER  :=  FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH     CONSTANT NUMBER  :=  FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM   CONSTANT NUMBER  :=  FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW      CONSTANT NUMBER  :=  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

/*==========================================================================
 |  PROCEDURE
 |    Get_Associations_info
 |
 |  DESCRIPTION
 |    Retrieves Legal Association Info
 |
 |  ARGUMENTS
 |      IN     :
 |               p_init_msg_list
 |               p_commit
 |               p_context
 |               p_object_type
 |               p_subject_type
 |		 p_legal_entity_id
 |               p_object_id
 | 		 p_subject_id
 |
 |
 |      OUT    :
 |               x_return_status
 |               x_msg_count
 |               x_msg_data
 |               p_assocs
 |
 |      IN/OUT :
 |
 |
 |  MODIFICATION HISTORY
 | 						                                                        		       |    18-MAR-2005   T.Tran          Created.
 |
 |===========================================================================*/


PROCEDURE Get_Associations_Info(

  --   *****  Standard API parameters *****
  p_init_msg_list    IN  VARCHAR2,
  p_commit           IN  VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,


  --   *****  Legal Association information parameters *****
  p_context          IN  XLE_ASSOCIATION_TYPES.Context%TYPE,
  p_object_type      IN  XLE_ASSOC_OBJECT_TYPES.Name%TYPE,
  p_subject_type     IN  XLE_ASSOC_OBJECT_TYPES.Name%TYPE,
  p_legal_entity_id  IN  XLE_ASSOCIATIONS.SUBJECT_PARENT_ID%TYPE,
  p_object_id        IN  XLE_ASSOCIATIONS.Object_Id%TYPE,
  p_subject_id       IN  XLE_ASSOCIATIONS.Subject_Id%TYPE,
  p_assocs   OUT     NOCOPY tab_assoc)


IS

  l_api_name  CONSTANT  VARCHAR2(40) := 'Get_Associations_Info';
  l_subject_type_id XLE_ASSOCIATIONS.Subject_Id%TYPE;
  l_object_type_id XLE_ASSOCIATIONS.Object_Id%TYPE;
  l_init_msg_list VARCHAR2(40);
  l_commit VARCHAR2(40);
  x_association_type_id   NUMBER;


BEGIN

  x_msg_count	:=	NULL;
  x_msg_data	:=	NULL;
  l_init_msg_list := FND_API.G_TRUE;
  l_commit := FND_API.G_FALSE;

  -- ****   Standard start of API savepoint  ****
--  SAVEPOINT Get_Associations_Info_SP;


  -- ****  Initialize message list if l_init_msg_list is set to TRUE. ****
  IF FND_API.to_Boolean( l_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;


  -- ****  Initialize return status to SUCCESS   *****
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  /*-----------------------------------------------+
  |   ========  START OF API BODY  ============   |
  +-----------------------------------------------*/

  --  Validation of the Manadatory Input Parameters


    XLE_ASSOC_VALIDATIONS_PVT.Validate_Mandatory('p_context',p_context);
    XLE_ASSOC_VALIDATIONS_PVT.Validate_Mandatory('p_object_type',p_object_type);
    XLE_ASSOC_VALIDATIONS_PVT.Validate_Mandatory('p_subject_type',p_subject_type);


  --  Validating parameter combinations

    XLE_ASSOC_VALIDATIONS_PVT.Default_Association_Type(p_context,p_subject_type,p_object_type,x_association_type_id);


    IF (p_subject_id is NULL)
    THEN

	    XLE_ASSOC_VALIDATIONS_PVT.Validate_Mandatory('p_object_id',p_object_id);
	    XLE_ASSOC_VALIDATIONS_PVT.Validate_Object(p_object_type, p_object_id, 'Object Type', 'Object_Id', l_object_type_id);


	    select assoc.subject_id
	    BULK COLLECT
	    INTO p_assocs
	    from XLE_ASSOCIATIONS assoc, XLE_ASSOCIATION_TYPES assoc_types
	    where assoc.object_id = p_object_id
            and assoc_types.ASSOCIATION_TYPE_ID = assoc.ASSOCIATION_TYPE_ID
	    and assoc.association_type_id = x_association_type_id
	    and assoc.subject_parent_id = NVL(p_legal_entity_id,assoc.subject_parent_id)
            and assoc_types.context = p_context
	    and assoc_types.effective_to is null;


    END IF;

    IF (p_object_id is NULL)
    THEN

	    XLE_ASSOC_VALIDATIONS_PVT.Validate_Mandatory('p_subject_id',p_subject_id);
	    XLE_ASSOC_VALIDATIONS_PVT.Validate_Object(p_subject_type, p_subject_id, 'Subject Type','Subject_Id',l_subject_type_id);

	    select assoc.object_id
	    BULK COLLECT
	    INTO p_assocs
	    from XLE_ASSOCIATIONS assoc, XLE_ASSOCIATION_TYPES assoc_types
	    where assoc.subject_id = p_subject_id
            and assoc_types.ASSOCIATION_TYPE_ID = assoc.ASSOCIATION_TYPE_ID
	    and assoc.association_type_id = x_association_type_id
	    and assoc.subject_parent_id = NVL(p_legal_entity_id,assoc.subject_parent_id)
            and assoc_types.context = p_context
	    and assoc_types.effective_to is null;


    END IF;



  /*-----------------------------------------------+
  |   ========  END OF API BODY  ============   |
  +-----------------------------------------------*/


  -- Standard call to get message count and if count is 1,
  -- get message info.
  FND_MSG_PUB.Count_And_Get (
      p_count    =>  x_msg_count,
      p_data     =>  x_msg_data );

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
  --     ROLLBACK TO Get_Associations_Info_SP;
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get (
           p_count    =>  x_msg_count,
           p_data     =>  x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   --    ROLLBACK TO Get_Associations_Info_SP;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get (
           p_count    =>  x_msg_count,
           p_data     =>  x_msg_data );

  WHEN OTHERS THEN
  --     ROLLBACK TO Get_Associations_Info_SP;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
       END IF;
       FND_MSG_PUB.Count_And_Get (
           p_count    =>  x_msg_count,
           p_data     =>  x_msg_data );

END Get_Associations_Info;

END XLE_ASSOCIATIONS_INFO;


/
