--------------------------------------------------------
--  DDL for Package Body PRP_IBC_INT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PRP_IBC_INT_PVT" AS
/* $Header: PRPVIBCB.pls 115.2 2003/10/28 22:49:24 hekkiral noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'PRP_IBC_INT_PVT';

PROCEDURE Get_Object_Name(
                P_ASSOCIATION_TYPE_CODE 	IN 			VARCHAR2
			,P_ASSOCIATED_OBJECT_VAL1	IN 			VARCHAR2
			,P_ASSOCIATED_OBJECT_VAL2	IN 			VARCHAR2
			,P_ASSOCIATED_OBJECT_VAL3	IN 			VARCHAR2
			,P_ASSOCIATED_OBJECT_VAL4	IN 			VARCHAR2
			,P_ASSOCIATED_OBJECT_VAL5	IN 			VARCHAR2
			,X_OBJECT_NAME	    	   		OUT NOCOPY	VARCHAR2
			,X_OBJECT_CODE	        		OUT NOCOPY	VARCHAR2
			,X_RETURN_STATUS       		OUT NOCOPY	VARCHAR2
			,X_MSG_COUNT	        		OUT NOCOPY	NUMBER
			,X_MSG_DATA	        		OUT NOCOPY	VARCHAR2)
AS

CURSOR Cur_Component_sytles(p_component_style_id NUMBER) IS
SELECT PCS.component_style_name,PCS.content_node_type
FROM PRP_COMPONENT_STYLES_VL PCS
WHERE PCS.component_style_id = p_component_style_id;

CURSOR Cur_Content_item_name(p_component_style_id NUMBER,p_association_type VARCHAR2) IS
SELECT ICV.Content_Item_Name
FROM IBC_CITEM_VERSIONS_VL ICV,
     IBC_CONTENT_ITEMS ICI,
     IBC_ASSOCIATIONS IBA
WHERE IBA.ASSOCIATION_TYPE_CODE = P_ASSOCIATION_TYPE_CODE
AND IBA.ASSOCIATED_OBJECT_VAL1 = p_component_style_id
AND ICI.CONTENT_ITEM_ID = IBA.CONTENT_ITEM_ID
AND ICV.CITEM_VERSION_ID = ICI.LIVE_CITEM_VERSION_ID;

CURSOR Cur_style_ctntvers(p_comp_style_ctntver_id NUMBER) IS
SELECT component_style_id
FROM prp_comp_style_ctntvers
WHERE comp_style_ctntver_id = p_comp_style_ctntver_id;

CURSOR Cur_Proposals(p_proposal_id NUMBER) IS
SELECT Proposal_Name
FROM PRP_PROPOSALS
WHERE PROPOSAL_ID = p_proposal_id;

CURSOR Cur_Proposal_ctntvers(p_proposal_ctntver_id NUMBER) IS
SELECT proposal_name
FROM prp_proposals pp, prp_proposal_ctntvers ppc
WHERE pp.proposal_id = ppc.proposal_id
AND ppc.PROPOSAL_CTNTVER_ID = p_proposal_ctntver_id;

CURSOR Cur_Perz_Files(p_perz_file_id NUMBER) IS
SELECT proposal_name
FROM prp_proposals pp, prp_perz_files ppf, prp_prop_style_ctntvers pps
WHERE pp.proposal_id = pps.proposal_id
AND pps.OBJECT_ID = ppf.perz_file_id
AND ppf.perz_file_id = p_perz_file_id;

l_api_name CONSTANT     VARCHAR2(30) := 'GET_OBJECT_NAME';
l_content_node_type     VARCHAR2(30);
l_component_style_id    NUMBER;
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

IF (p_association_type_code = 'PRP_COMPONENT_DOCUMENT') THEN

   -- Check to see if the component is in hidden folder. If it is in hidden folder return the component style name.
   OPEN Cur_Component_sytles(p_associated_object_val1);
   Fetch Cur_Component_sytles INTO x_object_name,l_content_node_type;
   IF(l_content_node_type = 'SHARED') THEN
     OPEN Cur_Content_item_name(p_associated_object_val1,p_association_type_code);
     FETCH Cur_Content_item_name INTO x_object_name;
     CLOSE Cur_Content_item_name;
   END IF;
   CLOSE Cur_Component_sytles;

ELSIF (p_association_type_code = 'PRP_COMPONENT_DOCUMENT_VERSION') THEN

   -- Get the Component_style_id.
   OPEN Cur_style_ctntvers(p_associated_object_val1);
   FETCH Cur_style_ctntvers INTO l_component_style_id;
   CLOSE Cur_style_ctntvers;

    -- Check to see if the component is in hidden folder. If it is in hidden folder return the component style name.
   OPEN Cur_Component_sytles(l_component_style_id);
   Fetch Cur_Component_sytles INTO x_object_name,l_content_node_type;
   IF(l_content_node_type = 'SHARED') THEN
     OPEN Cur_Content_item_name(p_associated_object_val1,p_association_type_code);
     FETCH Cur_Content_item_name INTO x_object_name;
     CLOSE Cur_Content_item_name;
   END IF;
   CLOSE Cur_Component_sytles;

ELSIF (p_association_type_code = 'PRP_GENERATED_PROPOSAL') THEN

   OPEN Cur_Proposals(p_associated_object_val1);
   FETCH Cur_Proposals INTO x_object_name;
   CLOSE Cur_Proposals;

ELSIF  (p_association_type_code = 'PRP_GENERATED_DOCUMENT_VERSION') THEN

   OPEN  Cur_Proposal_ctntvers(p_associated_object_val1);
   FETCH Cur_Proposal_ctntvers INTO x_object_name;
   CLOSE Cur_Proposal_ctntvers;

ELSIF  (p_association_type_code = 'PRP_PERZ_FILE_VERSION') THEN

   OPEN  Cur_Perz_Files(p_associated_object_val1);
   FETCH Cur_Perz_Files INTO x_object_name;
   CLOSE Cur_Perz_Files;

END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
	 FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
	                            p_data  => x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
	                            p_data  => x_msg_data);

  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	   FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
	 END IF;

	 FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
	                            p_data  => x_msg_data);

END Get_Object_Name;

END PRP_IBC_INT_PVT;

/
