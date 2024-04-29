--------------------------------------------------------
--  DDL for Package Body EAM_WO_QUA_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WO_QUA_UTILITY_PVT" AS
/* $Header: EAMVWQUB.pls 120.1 2006/06/17 02:25:46 baroy noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWQUB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_WO_QUA_UTILITY_PVT
--
--  NOTES
--
--  HISTORY
--
--  14-FEB-2005    mmaduska     Initial Creation
***************************************************************************/

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'EAM_WO_QUA_UTILITY_PVT';

PROCEDURE Perform_Writes
(
	p_eam_request_rec         IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type,
	x_return_status           OUT NOCOPY  VARCHAR2,
	x_mesg_token_tbl          OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
)IS
BEGIN
	null;
END Perform_Writes;

  FUNCTION get_error_code(code IN NUMBER) RETURN VARCHAR2 IS
    BEGIN


IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Inside EAM_WO_QUA_UTILITY_PVT get_error_code'); END IF;

        --
        -- Should figure out the error message from dictionary.
        --
        RETURN qa_validation_api.get_error_message (code);
    END get_error_code;

PROCEDURE get_error_messages(
        errors IN qa_validation_api.ErrorArray,
        plan_id IN NUMBER,
        messages OUT NOCOPY VARCHAR2) IS

        separator CONSTANT VARCHAR2(1) := '@';
        name qa_chars.prompt%TYPE;
        code VARCHAR2(2000);
    BEGIN
        messages := '';
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Inside EAM_WO_QUA_UTILITY_PVT get_error_message'); END IF;

        --
        -- This bug is discovered during bug fix for 3402251.
        -- In some rare situation, this proc can be called when
        -- error stack is actually empty.  Should return
        -- immediately.
        -- bso Mon Feb  9 22:06:09 PST 2004
        --
        IF errors.count = 0 then
            RETURN;
        END IF;

        FOR i IN errors.FIRST .. errors.LAST LOOP
            name := qa_plan_element_api.get_prompt(plan_id,
                errors(i).element_id);
            --
            -- Just in case the prompt contains @
            --
            name := replace(name, separator, separator||separator);
            code := get_error_code(errors(i).error_code);
            messages := messages || name || ': ' || code;
            IF i < errors.LAST THEN
                messages := messages || separator;
            END IF;
        END LOOP;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Inside EAM_WO_QUA_UTILITY_PVT get_error_message completed ...'); END IF;
    END get_error_messages;

PROCEDURE insert_row
(
	  p_collection_id	   IN NUMBER
	, p_eam_wo_quality_tbl     IN  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	, x_eam_wo_quality_tbl     OUT NOCOPY  EAM_PROCESS_WO_PUB.eam_wo_quality_tbl_type
	, x_return_status          OUT NOCOPY  VARCHAR2
	, x_mesg_token_tbl         OUT NOCOPY EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type
 )IS

	Type header_plan_id_tbl_type is table of NUMBER  INDEX BY BINARY_INTEGER;
	header_plan_id_tbl	header_plan_id_tbl_type;
	flag			boolean;
	header_counter NUMBER   :=0;
	l_eam_wo_quality_rec	EAM_PROCESS_WO_PUB.eam_wo_quality_rec_type;
	elements		qa_validation_api.ElementsArray;
	l_org_id		NUMBER;
	l_collection_id  	        NUMBER;
	temp_occurence		NUMBER;
	msg_count		NUMBER;
	msg_data		VARCHAR2(2000);
	error_array		qa_validation_api.ErrorArray;
	message_array		qa_validation_api.MessageArray;
	return_status		VARCHAR2(1);
	action_result		VARCHAR2(1);
	x_messages		varchar2(2000);
        l_Mesg_Token_Tbl        EAM_ERROR_MESSAGE_PVT.Mesg_Token_Tbl_Type;
	l_txn_number		NUMBER;

BEGIN
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Inside EAM_WO_QUA_UTILITY_PVT insert_row ...'); END IF;

	IF  (p_eam_wo_quality_tbl.count >0) THEN
		l_org_id	:= p_eam_wo_quality_tbl(p_eam_wo_quality_tbl.FIRST).organization_id;
		IF p_eam_wo_quality_tbl(p_eam_wo_quality_tbl.FIRST).OPERATION_SEQ_NUMBER IS NOT NULL THEN
			l_txn_number := 33;
		ELSE
			l_txn_number := 31;
		END IF;

	END IF;

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Get the plan ids ...'); END IF;

	l_collection_id := p_collection_id;
	-- following loops gets the different plan ids that are in the data
	-- for 3 collection plans there will be 3 differnet plan ids
	-- after this loop header_id_tbl table will contain the list of plan ids
	IF (p_eam_wo_quality_tbl.count >0) THEN
		  FOR i_counter in p_eam_wo_quality_tbl.first..p_eam_wo_quality_tbl.last LOOP
			  flag:=TRUE;
			  l_eam_wo_quality_rec := p_eam_wo_quality_tbl(i_counter);

			  IF header_plan_id_tbl.COUNT  > 0 THEN
				  FOR J in header_plan_id_tbl.FIRST..header_plan_id_tbl.LAST LOOP
					IF l_eam_wo_quality_rec.plan_id = header_plan_id_tbl(j) THEN
						flag := FALSE;
					END IF;
				  END LOOP;
			  END IF;

			  IF flag = TRUE THEN
				IF header_plan_id_tbl.COUNT > 0 THEN
				   header_plan_id_tbl(header_plan_id_tbl.COUNT + 1) := l_eam_wo_quality_rec.plan_id;
				ELSE
				   header_plan_id_tbl(1) := l_eam_wo_quality_rec.plan_id;
				END IF;
			  END IF;
		  END LOOP;
	END IF;

	FOR xx IN header_plan_id_tbl.FIRST..header_plan_id_tbl.LAST loop
		elements.delete;
		FOR YY in p_eam_wo_quality_tbl.first..p_eam_wo_quality_tbl.last LOOP
			if p_eam_wo_quality_tbl(YY).PLAN_ID = header_plan_id_tbl(xx) then
				elements(p_eam_wo_quality_tbl(YY).ELEMENT_ID).id := p_eam_wo_quality_tbl(YY).ELEMENT_ID;
				elements(p_eam_wo_quality_tbl(YY).ELEMENT_ID).value := p_eam_wo_quality_tbl(YY).ELEMENT_VALUE;
			end if;
		END LOOP;

--		set_validation_flag (elements, 31);

IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('Calling qa_results_pub.insert_row ...'); END IF;
		qa_results_pub.insert_row(
			p_api_version => 1.0,
			p_init_msg_list => fnd_api.g_true,
			p_org_id => l_org_id,
			p_plan_id => header_plan_id_tbl(xx),
			p_spec_id => null,
			p_transaction_number => l_txn_number,
			p_transaction_id => null,
			p_enabled_flag => 1,
			p_commit =>  fnd_api.g_false,
			x_collection_id => l_collection_id,
			x_occurrence => temp_occurence,
			x_row_elements => elements,
			x_msg_count => msg_count,
			x_msg_data  => msg_data,
			x_error_array => error_array,
			x_message_array => message_array,
			x_return_status => return_status,
			x_action_result => action_result);

			x_return_status := return_status;

		IF error_array.count  <>0 THEN
			get_error_messages(error_array, header_plan_id_tbl(xx), x_messages);

	                 EAM_ERROR_MESSAGE_PVT.Add_Error_Token
				(  p_message_name       => NULL
				 , p_message_text       => x_messages
				 , x_mesg_token_Tbl     => x_mesg_token_tbl
				);

		         return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
		END IF;

		IF return_status <> 'S' THEN
			x_return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
			EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||' :Inserting Record ' || SQLERRM
                         , x_mesg_token_Tbl     => x_mesg_token_tbl
			);
			return;
		END IF;

	END LOOP;
IF EAM_PROCESS_WO_PVT.Get_Debug = 'Y' THEN EAM_ERROR_MESSAGE_PVT.Write_Debug('completed the insert_row procedure  ...'); END IF;

     EXCEPTION WHEN OTHERS THEN
	return_status := EAM_ERROR_MESSAGE_PVT.G_STATUS_ERROR;
	EAM_ERROR_MESSAGE_PVT.Add_Error_Token
                        (  p_message_name       => NULL
                         , p_message_text       => G_PKG_NAME ||' :Inserting Record ' || SQLERRM
                         , x_mesg_token_Tbl     => x_mesg_token_tbl
          );

END insert_row;

END EAM_WO_QUA_UTILITY_PVT;

/
