--------------------------------------------------------
--  DDL for Package Body XNP_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNP_ADAPTER" AS
/* $Header: XNPADAPB.pls 120.1 2005/06/18 00:40:45 appldev  $ */

PROCEDURE talk_to_adapter(p_channel_name in VARCHAR2,
	p_msg_text in VARCHAR2,
	x_error_code OUT NOCOPY NUMBER,
	x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE open( p_fe_name in VARCHAR2
	,p_channel_name in VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 )
IS

	l_msg_header  xnp_message.msg_header_rec_type;
	l_msg_text    VARCHAR2(32767) ;
	l_op_data     VARCHAR2(32767) ;
	l_channel     VARCHAR2(1024) ;
	l_sp_name     VARCHAR2(1024) ;

	l_fe_attr_list xdp_types.order_parameter_list ;

BEGIN

null;


/* This procedure needs to be deleted once the SEED data is fixed
--	x_error_code := 0 ;
--	x_error_message := NULL ;
--
--	xnp_xml_utils.initialize_doc ;
--	xnp_xml_utils.write_element('FE_NAME', p_fe_name) ;
--
--        FND_PROFILE.GET( NAME => 'SP_NAME',
--                VAL => l_sp_name ) ;
--
--	xnp_xml_utils.write_element('SP_NAME', l_sp_name) ;
--
--
--	--Get all FE attributes for the given FE
--
--	l_fe_attr_list := xdp_engine.get_fe_attributeval_list(p_fe_name) ;
--
--
--	FOR i IN 1..l_fe_attr_list.COUNT LOOP
--
--		xnp_xml_utils.write_element(
--			l_fe_attr_list(i).parameter_name,
--			l_fe_attr_list(i).parameter_value ) ;
--
--	END LOOP ;
--
--	xnp_xml_utils.get_document(l_op_data) ;
--
--	xnp_control_u.create_msg(xnp$operation=>'OPEN',
--		xnp$op_data=>l_op_data,
--		x_msg_header=>l_msg_header,
--		x_msg_text=>l_msg_text,
--		x_error_code=>x_error_code,
--		x_error_message=>x_error_message
--	) ;
--
--	IF (x_error_code = 0) THEN
--
--		talk_to_adapter(p_channel_name,
--			l_msg_text,
--			x_error_code,
--    			x_error_message ) ;
--
--	END IF ;
*/

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		fnd_message.set_name('XNP','INVALID_FE_CONFIGURATION');
		fnd_message.set_token('FE_NAME',p_fe_name) ;
		x_error_message := fnd_message.get ;
		x_error_code := xnp_errors.G_INVALID_FE_CONFIGURATION;

	WHEN OTHERS THEN
		x_error_code := SQLCODE ;
		x_error_message := SQLERRM ;

END open;

/**********************************************************************************
***** PROCEDURE:	CLOSE()
*******************************************************************************/

PROCEDURE close( p_fe_name in VARCHAR2
		,p_channel_name in VARCHAR2
		,x_error_code OUT NOCOPY NUMBER
		,x_error_message OUT NOCOPY VARCHAR2 )
IS

	l_fe_attributes   fe_data ;

BEGIN


null;


/* This procedure needs to be deleted once the SEED data is fixed
--	user_control( p_fe_name => p_fe_name
--		,p_channel_name => p_channel_name
--                ,p_operation => 'CLOSE'
--                ,p_operation_data => l_fe_attributes
--                ,x_error_code => x_error_code
--                ,x_error_message => x_error_message) ;
*/

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE ;
		x_error_message := SQLERRM ;
END close;

/**********************************************************************************
***** PROCEDURE:	SUSPEND()
*******************************************************************************/

PROCEDURE suspend( p_fe_name in VARCHAR2
		,p_channel_name in VARCHAR2
		,x_error_code OUT NOCOPY NUMBER
		,x_error_message OUT NOCOPY VARCHAR2 )
IS

	l_fe_attributes   fe_data ;

BEGIN


	user_control( p_fe_name => p_fe_name
		,p_channel_name => p_channel_name
                ,p_operation => 'SUSPEND'
                ,p_operation_data => l_fe_attributes
                ,x_error_code => x_error_code
                ,x_error_message => x_error_message) ;

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE ;
		x_error_message := SQLERRM ;
END suspend;

/**********************************************************************************
***** PROCEDURE:	RESUME()
*******************************************************************************/

PROCEDURE resume( p_fe_name in VARCHAR2
		,p_channel_name in VARCHAR2
		,x_error_code OUT NOCOPY NUMBER
		,x_error_message OUT NOCOPY VARCHAR2 )

IS

	l_fe_attributes   fe_data ;

BEGIN


	user_control( p_fe_name => p_fe_name
		,p_channel_name => p_channel_name
                ,p_operation => 'RESUME'
                ,p_operation_data => l_fe_attributes
                ,x_error_code => x_error_code
                ,x_error_message => x_error_message) ;

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE ;
		x_error_message := SQLERRM ;
END resume ;

/**********************************************************************************
***** PROCEDURE:	SHUTDOWN()
*******************************************************************************/

PROCEDURE shutdown( p_fe_name in VARCHAR2
		,p_channel_name in VARCHAR2
		,x_error_code OUT NOCOPY NUMBER
		,x_error_message OUT NOCOPY VARCHAR2 )


IS

	l_fe_attributes   fe_data ;

BEGIN


	user_control( p_fe_name => p_fe_name
		,p_channel_name => p_channel_name
                ,p_operation => 'SHUTDOWN_NORMAL'
                ,p_operation_data => l_fe_attributes
                ,x_error_code => x_error_code
                ,x_error_message => x_error_message) ;

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE ;
		x_error_message := SQLERRM ;
END shutdown ;

/****************************************************************************
*** PROCEDURE:	user_control()
****************************************************************************/

PROCEDURE user_control( p_fe_name IN VARCHAR2
	,p_channel_name IN VARCHAR2
	,p_operation IN VARCHAR2
	,p_operation_data IN fe_data
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 )
IS

	l_msg_header  xnp_message.msg_header_rec_type;
	l_msg_text    VARCHAR2(32767) ;
	l_op_data     VARCHAR2(32767) ;
	l_count	      NUMBER ;

BEGIN

	xnp_xml_utils.initialize_doc ;
	xnp_xml_utils.write_element('FE_NAME', p_fe_name) ;

	/* generate XML for the rest of the attributes */

	l_count := p_operation_data.COUNT ;

	FOR i IN 1..l_count LOOP

		xnp_xml_utils.write_element (
			p_operation_data(i).attribute_name,
			p_operation_data(i).attribute_value
			);

	END LOOP;

	xnp_xml_utils.get_document(l_op_data) ;

	xnp_control_u.create_msg(xnp$operation=>p_operation,
		xnp$op_data=>l_op_data,
      		x_msg_header=>l_msg_header,
      		x_msg_text=>l_msg_text,
      		x_error_code=>x_error_code,
      		x_error_message=>x_error_message
      		) ;

	IF (x_error_code = 0) THEN
		talk_to_adapter(p_channel_name,
    			l_msg_text,
    			x_error_code,
    			x_error_message ) ;
	END IF ;
EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE ;
		x_error_message := SQLERRM ;

END user_control ;


/****************************************************************************
*** PROCEDURE:	close_file()
****************************************************************************/
PROCEDURE CLOSE_FILE( p_fe_name IN VARCHAR2
	,p_channel_name IN VARCHAR2
	,p_file_name IN VARCHAR2 DEFAULT NULL
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 )
IS

	l_file_attr   fe_data ;

BEGIN

	xnp_xml_utils.initialize_doc ;
	xnp_xml_utils.write_element('FE_NAME', p_fe_name) ;

	/* generate XML for the rest of the attributes */

	l_file_attr(1).attribute_name := 'FILE_NAME' ;
	l_file_attr(1).attribute_value := p_file_name ;

	user_control( p_fe_name => p_fe_name
		,p_channel_name => p_channel_name
		,p_operation => 'CLOSEFILE'
		,p_operation_data => l_file_attr
		,x_error_code => x_error_code
		,x_error_message => x_error_message) ;

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE ;
		x_error_message := SQLERRM ;

END close_file ;

/****************************************************************************
*** PROCEDURE:	new ftp() API
*** 11.5.6: Now this API uses new Adapter Business Object
****************************************************************************/

PROCEDURE FTP( p_channel_name IN VARCHAR2
	,p_file_name IN VARCHAR2 DEFAULT NULL
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 )

IS
	l_file_name VARCHAR2(1024);

BEGIN

	IF p_file_name IS NOT NULL THEN
		l_file_name :=  '<FILE_NAME>'||p_file_name||'</FILE_NAME>';
	ELSE
		l_file_name := NULL;
	END IF;

	xdp_adapter.GENERIC_OPERATION(p_Channel_Name,
								'FTP_FILE',
								l_file_name,
								x_error_code,
								x_error_message);
EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE ;
		x_error_message := SQLERRM ;
END ftp;

/****************************************************************************
*** PROCEDURE:	ftp()
*** maintained for backward compatibility
****************************************************************************/
PROCEDURE FTP( p_fe_name IN VARCHAR2
	,p_channel_name IN VARCHAR2
	,p_file_name IN VARCHAR2 DEFAULT NULL
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2 )

IS
--	l_file_attr   fe_data ;

BEGIN

--	xnp_xml_utils.initialize_doc ;
--	xnp_xml_utils.write_element('FE_NAME', p_fe_name) ;
--
--	/* generate XML for the rest of the attributes */
--
--	l_file_attr(1).attribute_name := 'FILE_NAME' ;
--	l_file_attr(1).attribute_value := p_file_name ;
--
--	user_control( p_fe_name => p_fe_name
--		,p_channel_name => p_channel_name
--		,p_operation => 'FTP_FILE'
--		,p_operation_data => l_file_attr
--		,x_error_code => x_error_code
--		,x_error_message => x_error_message) ;

	FTP(p_Channel_Name,
		p_file_name,
		x_error_code,
		x_error_message);

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE ;
		x_error_message := SQLERRM ;
END ftp;

/****************************************************************************
*** PROCEDURE:	talk_to_adapter()
****************************************************************************/

PROCEDURE talk_to_adapter(p_channel_name in VARCHAR2,
	p_msg_text in VARCHAR2,
	x_error_code OUT NOCOPY NUMBER,
	x_error_message OUT NOCOPY VARCHAR2)
IS
	l_msg_text VARCHAR2(32767) ;
	l_channel_name VARCHAR2(1024) ;
BEGIN
	x_error_code := 0;
	x_error_message := null;

	xnp_pipe.write(p_channel_name,
		p_msg_text,
		x_error_code,
    		x_error_message ) ;

	IF (x_error_code = 0) THEN

		l_channel_name := p_channel_name || '_REPLY' ;

		xnp_pipe.read(l_channel_name,
			l_msg_text,
			x_error_code,
			x_error_message,
			45) ;

		/* get adapter status on successful Pipe Reads */

		IF (x_error_code = 0) THEN
			xnp_xml_utils.decode(l_msg_text,'STATUS_CODE',
				x_error_code) ;
			xnp_xml_utils.decode(l_msg_text,'DESCRIPTION',
				x_error_message) ;
		END IF ;
	END IF;

END talk_to_adapter ;


/***************************************************************************
*****  Procedure:    NOTIFY_FMC()
*****  Purpose:      Notifies the FMC of Adapter Erors.
*****  Description:  Starts a Workflow to notify the FMC. The FMC waits
*****                for a response from an FMC user.
****************************************************************************/

PROCEDURE notify_fmc
	(p_msg_header IN xnp_message.msg_header_rec_type
	,p_msg_text IN VARCHAR2
	,x_error_code OUT NOCOPY NUMBER
	,x_error_message OUT NOCOPY VARCHAR2
	)
IS

	l_item_type 	VARCHAR2(1024) ;
	l_item_key  	VARCHAR2(4000) ;
	l_performer 	VARCHAR2(1024) ;
	l_fe_name   	VARCHAR2(1024) ;
	l_channel_name 	VARCHAR2(1024) ;
	l_description  	VARCHAR2(1024) ;

        l_NameArray      Wf_Engine.NameTabTyp;
        l_ValArray       Wf_Engine.TextTabTyp;

	CURSOR get_performer_name IS
		SELECT xms.role_name
		FROM xnp_msg_types_b xms,
			xnp_msgs xmg
		WHERE xmg.msg_id = p_msg_header.message_id
		AND xms.msg_code = xmg.msg_code;

BEGIN

	/* Create a Workflow Context */

	OPEN get_performer_name ;
	FETCH get_performer_name INTO l_performer ;
	CLOSE get_performer_name ;

	-- Notification performer is defaulted to 'NP_SYSADMIN'
	-- Bug 1658346
        -- Notification performer defaulted to 'OP_SYSADMIN' rnyberg March 08, 2002
	IF l_performer IS NULL THEN
		l_performer := 'FND_RESP535:21704';
	END IF;
--	l_performer := xdp_utilities.get_wf_notifrecipient(l_performer) ;


	l_item_type := 'XDPWFSTD' ;
	l_item_key := 'MESSAGE_' || TO_CHAR(p_msg_header.message_id) ;

	xnp_xml_utils.decode(p_msg_text,'FE_NAME',l_fe_name) ;
	xnp_xml_utils.decode(p_msg_text,'CHANNEL_NAME',l_channel_name) ;
	xnp_xml_utils.decode(p_msg_text,'DESCRIPTION',l_description) ;

	wf_core.context('XDP_WF_STANDARD',
		'ADAPTER_ERROR',
		l_item_type,
		l_item_key) ;

	wf_engine.createprocess(l_item_type,
		l_item_key,
		'ADAPTER_ERROR_NOTIFICATION') ;

        -- modified the code to replace the multiple calls to set the
        -- item attribute with Wf_Engine.SetItemAttrTextArray
        -- skilaru 03/23/2001

/****
	wf_engine.SetItemAttrText(
		ItemType=>l_item_type,
		ItemKey=>l_item_key,
		aname=>'FE_NAME',
		avalue=>l_fe_name);

	wf_engine.SetItemAttrText(
		ItemType=>l_item_type,
		ItemKey=>l_item_key,
		aname=>'CHANNEL_NAME',
		avalue=>l_channel_name);

	wf_engine.SetItemAttrText(
		ItemType=>l_item_type,
		ItemKey=>l_item_key,
		aname=>'DESCRIPTION',
		avalue=>l_description);

	wf_engine.SetItemAttrText(
		ItemType=>l_item_type,
		ItemKey=>l_item_key,
		aname=>'MSG_HANDLING_ROLE',
		avalue=>l_performer);
****/
        --
        -- Initialize workflow item attributes
        --
        l_NameArray(1) := 'FE_NAME';
        l_ValArray(1)  :=  l_fe_name;
        l_NameArray(2) := 'CHANNEL_NAME';
        l_ValArray(2)  :=  l_channel_name;
        l_NameArray(3) := 'DESCRIPTION';
        l_ValArray(3)  :=  l_description;
        l_NameArray(4) := 'MSG_HANDLING_ROLE';
        l_ValArray(4)  :=  l_performer;

        Wf_Engine.SetItemAttrTextArray (l_item_type, l_item_key, l_NameArray, l_ValArray);

	wf_engine.startprocess(l_item_type,
                         l_item_key ) ;

EXCEPTION
	WHEN OTHERS THEN
		x_error_code := SQLCODE;
		x_error_message := SQLERRM;

END notify_fmc ;

END xnp_adapter ;

/
