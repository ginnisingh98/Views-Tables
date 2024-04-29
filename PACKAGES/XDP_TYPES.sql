--------------------------------------------------------
--  DDL for Package XDP_TYPES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_TYPES" AUTHID CURRENT_USER AS
/* $Header: XDPTYPES.pls 115.15 2002/05/21 19:05:02 pkm ship        $ */

-- PL/SQL Specification
-- Datastructure Definitions

-- SFM order header
 TYPE ORDER_HEADER IS RECORD
 (
	order_number  VARCHAR2(40),
	order_version VARCHAR2(40) default NULL,
	provisioning_date DATE default sysdate,
	priority NUMBER default 100,
	due_date DATE default NULL,
	customer_required_date DATE default NULL,
	order_type  VARCHAR2(40) default NULL,
	order_action  VARCHAR2(40) default NULL,
	order_source VARCHAR2(40) default NULL,
	related_order_id NUMBER default NULL,
	org_id NUMBER default NULL,
	customer_name VARCHAR2(80) default NULL,
	customer_id  NUMBER  default NULL,
	service_provider_id NUMBER default NULL,
	telephone_number  VARCHAR2(40) default NULL,
	order_status VARCHAR2(40) default NULL,
	order_state  VARCHAR2(40) default NULL,
	actual_provisioning_date DATE default NULL,
	completion_date  DATE default NULL,
	previous_order_id number default NULL,
	next_order_id number default null,
	sdp_order_id number default null,
	jeopardy_enabled_flag VARCHAR2(1) default 'N',
	order_ref_name VARCHAR2(80) default null,
	order_ref_value VARCHAR2(300) default null,
	sp_order_number VARCHAR2(80) default null,
	sp_userid NUMBER default null);

-- List of order Header records
  TYPE ORDER_HEADER_LIST IS TABLE OF ORDER_HEADER
	  INDEX BY BINARY_INTEGER;

-- order parameter record
  TYPE ORDER_PARAMETER IS RECORD
  (
    PARAMETER_NAME VARCHAR2(40),
    PARAMETER_VALUE VARCHAR2(4000));

-- list of the order parameter
  TYPE ORDER_PARAMETER_LIST IS TABLE OF ORDER_PARAMETER
	 INDEX BY BINARY_INTEGER;

-- order line item record
  TYPE LINE_ITEM IS RECORD
  (
  	LINE_NUMBER NUMBER,
  	LINE_ITEM_NAME VARCHAR2(40),
  	VERSION VARCHAR2(40) DEFAULT NULL ,
	IS_WORKITEM_FLAG VARCHAR2(1) DEFAULT 'N',
  	ACTION VARCHAR2(30),
	PROVISIONING_DATE DATE,
	PROVISIONING_REQUIRED_FLAG  VARCHAR2(1) DEFAULT 'Y',
  	PROVISIONING_SEQUENCE NUMBER := 0,
    BUNDLE_ID	NUMBER default NULL,
	BUNDLE_SEQUENCE  NUMBER DEFAULT NULL,
	PRIORITY NUMBER := 100,
	due_date DATE default NULL,
	customer_required_date DATE default NULL,
	line_status VARCHAR2(40) default NULL,
	completion_date  DATE default NULL,
	service_id NUMBER default NULL,
	package_id NUMBER default NULL,
	workitem_id NUMBER default NULL,
	line_state   VARCHAR2(40) default 'PREPROCESS',
	line_item_id NUMBER default null,
	jeopardy_enabled_flag VARCHAR2(1) default 'N',
	starting_number NUMBER default NULL,
	ending_number NUMBER default NULL );


-- list of order line items
  TYPE ORDER_LINE_LIST IS TABLE OF LINE_ITEM
	INDEX BY BINARY_INTEGER;

-- list item parameter record
  TYPE LINE_PARAM IS RECORD
  (
	line_number NUMBER,
	parameter_name VARCHAR2(40),
	parameter_value VARCHAR2(4000),
	parameter_ref_value VARCHAR2(4000) DEFAULT NULL);

-- line item parameter list
  TYPE LINE_PARAM_LIST IS TABLE OF LINE_PARAM
	 INDEX BY BINARY_INTEGER;

-- work item record
  TYPE WORKITEM_REC IS RECORD
  (
	workitem_name varchar2(40),
	workitem_id   number,
	provisioning_sequence number,
	provisioning_date date,
	priority	number,
	workitem_status varchar2(40),
	workitem_state varchar2(40),
	workitem_instance_id number,
	line_item_id number,
	line_number number,
	error_description varchar2(4000));

-- list of workitem records
  TYPE WORKITEM_LIST IS TABLE OF WORKITEM_REC
	 INDEX BY BINARY_INTEGER;

-- fulfillment action record
  TYPE FULFILLMENT_ACTION_REC IS RECORD
  (
	fulfillment_action varchar2(40),
	fulfillment_action_id   number,
	provisioning_sequence number,
	priority	number,
	FA_status varchar2(40),
	FA_state varchar2(40),
	FA_instance_id number,
	error_description varchar2(4000));

-- list of fulfillment action records
  TYPE FULFILLMENT_ACTION_LIST IS TABLE OF FULFILLMENT_ACTION_REC
      INDEX BY BINARY_INTEGER;


-- fulfillment action command record
  TYPE FA_COMMAND_REC IS RECORD
  (
	FA_instance_id number,
	command_sequence number,
	fulfillment_action varchar2(40),
	fulfillment_action_id   number,
	fulfillment_element_name varchar2(40),
	command_sent varchar2(4000),
	command_sent_date DATE,
	FE_response varchar2(4000),
	response_date DATE,
    USER_RESPONSE varchar2(4000),
	message_id  number,
	fulfillment_procedure_name  varchar2(40));

-- list of fulfillment action records
  TYPE FA_COMMAND_AUDIT_TRAIL IS TABLE OF FA_COMMAND_REC
	  INDEX BY BINARY_INTEGER;

-- Order relationship enumerated constant
  IS_PREREQUISITE_OF 	CONSTANT BINARY_INTEGER := 1;
-- Order relationship enumerated constant
  COMES_BEFORE       	CONSTANT BINARY_INTEGER := 2;
-- Order relationship enumerated constant
  IS_CHILD_OF        	CONSTANT BINARY_INTEGER := 3;
-- Order relationship enumerated constant
  COMES_AFTER		CONSTANT BINARY_INTEGER := 4;

-- Workitem relationship enumerated constant
  MERGED_INTO  		CONSTANT BINARY_INTEGER := 1;

-- Copy mode enumerated constant
  APPEND_TO			CONSTANT BINARY_INTEGER := 1;
-- Copy mode enumerated constant
  OVERRIDE			CONSTANT BINARY_INTEGER := 2;

-- Datastructure Definitions required by error handling routines

-- Structure for the message which is to be displayed to the user
  TYPE MESSAGE_REC IS RECORD
  (
    MESSAGE_TYPE VARCHAR2(30),
    MESSAGE_TIME DATE,
    MESSAGE_TEXT VARCHAR2(2000));

-- Structure for the message token name and value
  TYPE MESSAGE_TOKEN_REC IS RECORD
  (
    MESSAGE_TOKEN_NAME VARCHAR2(30),
    MESSAGE_TOKEN_VALUE VARCHAR2(2000));

-- List of the messages to be displayed to the user
  TYPE MESSAGE_LIST IS TABLE OF MESSAGE_REC
	  INDEX BY BINARY_INTEGER;

-- List of the messages tokens required to be saved for a message
  TYPE MESSAGE_TOKEN_LIST IS TABLE OF MESSAGE_TOKEN_REC
	 INDEX BY BINARY_INTEGER;

-- Structure for the message token name and value
  TYPE NAME_VALUE_REC IS RECORD
  (
    NAME VARCHAR2(4000),
    VALUE VARCHAR2(4000));

-- List of the messages tokens required to be saved for a message
  TYPE NAME_VALUE_LIST IS TABLE OF NAME_VALUE_REC
    INDEX BY BINARY_INTEGER;

-- FMC retry parameter change record
 TYPE FMC_PARAM_CHANGE_REC IS RECORD
 (
   PARAMETER_NAME varchar2(40),
   PARAM_PREVIOUS_VAL varchar2(4000),
   PARAM_RETRY_VAL VARCHAR2(4000));

-- FMC retry parameter list
 TYPE FMC_RETRY_PARAM_LIST IS TABLE OF FMC_PARAM_CHANGE_REC
	INDEX BY BINARY_INTEGER;

-- vrachur : 10/18/1999 : Added Type definitions for XDP OE Order Records.
-- XDP OE Order Header Definition
	TYPE OE_ORDER_HEADER IS RECORD
	(
		ORDER_NUMBER		VARCHAR2(40),
		ORDER_VERSION		VARCHAR2(40) DEFAULT NULL,
		PROVISIONING_DATE	DATE DEFAULT SYSDATE,
		COMPLETION_DATE		DATE DEFAULT NULL,
		ORDER_TYPE		VARCHAR2(40) DEFAULT NULL,
		ORDER_ACTION		VARCHAR2(30) DEFAULT NULL,
		ORDER_SOURCE		VARCHAR2(40) DEFAULT NULL,
		PRIORITY		NUMBER DEFAULT NULL,
		STATUS			VARCHAR2(40) DEFAULT NULL,
		SDP_ORDER_ID		NUMBER DEFAULT NULL,
		DUE_DATE		DATE DEFAULT NULL,
		CUSTOMER_REQUIRED_DATE	DATE DEFAULT NULL,
		CUSTOMER_NAME		VARCHAR2(40) DEFAULT NULL,
		CUSTOMER_ID		NUMBER DEFAULT NULL,
		ORG_ID			NUMBER DEFAULT NULL,
		SERVICE_PROVIDER_ID	NUMBER DEFAULT NULL,
		TELEPHONE_NUMBER	VARCHAR2(40) DEFAULT NULL,
		RELATED_ORDER_ID	NUMBER DEFAULT NULL,
		ORDER_COMMENT		VARCHAR2(4000) DEFAULT NULL,
		SP_ORDER_NUMBER		VARCHAR2(80) DEFAULT NULL,
		SP_USERID		NUMBER DEFAULT NULL,
		JEOPARDY_ENABLED_FLAG	VARCHAR2(1) DEFAULT NULL,
		ORDER_REF_NAME		VARCHAR2(80) DEFAULT NULL,
		ORDER_REF_VALUE		VARCHAR2(300) DEFAULT NULL
	) ;

-- XDP OE Order Parameter
	TYPE OE_ORDER_PARAMETER IS RECORD
	(
		PARAMETER_NAME	VARCHAR2(40),
		PARAMETER_VALUE	VARCHAR2(4000)
	) ;

-- List of Parameters for a given Order
	TYPE OE_ORDER_PARAMETER_LIST IS TABLE OF OE_ORDER_PARAMETER
		INDEX BY BINARY_INTEGER ;

-- XDP OE Order Lines
	TYPE OE_ORDER_LINE IS RECORD
	(
		ORDER_NUMBER			VARCHAR2(40),
		ORDER_VERSION			VARCHAR2(40),
		LINE_NUMBER			NUMBER,
		LINE_ITEM_NAME			VARCHAR2(40),
		LINE_ITEM_VERSION		VARCHAR2(40),
		LINE_ITEM_ACTION		VARCHAR2(30),
		PROVISIONING_REQUIRED_FLAG	VARCHAR2(1),
		IS_WORKITEM_FLAG		VARCHAR2(1),
		LINE_ITEM_TYPE			VARCHAR2(20),
		STATUS				VARCHAR2(40),
		PROVISIONING_SEQUENCE		NUMBER,
		PRIORITY			NUMBER,
		PROVISIONING_DATE		DATE,
		DUE_DATE			DATE,
		CUSTOMER_REQUIRED_DATE		DATE,
		COMPLETION_DATE			DATE,
		BUNDLE_ID			NUMBER,
		BUNDLE_SEQUENCE			NUMBER,
		STARTING_NUMBER			NUMBER,
		ENDING_NUMBER			NUMBER,
		JEOPARDY_ENABLED_FLAG		VARCHAR2(1)
	) ;

-- XDP OE Order Line Details
	TYPE OE_ORDER_LINE_DETAIL IS RECORD
	(
		PARAMETER_NAME		VARCHAR2(40),
		PARAMETER_VALUE		VARCHAR2(4000),
		PARAMETER_REF_VALUE	VARCHAR2(4000)
	) ;

-- List of Line Details for a given Order Line
	TYPE OE_ORDER_LINE_DETAIL_LIST IS TABLE OF OE_ORDER_LINE_DETAIL
	   INDEX BY BINARY_INTEGER ;


-- From here on, all the types are used for new open interface APIs.

    TYPE SERVICE_ORDER_HEADER IS RECORD
    (
        order_number  		        VARCHAR2(40)	DEFAULT	FND_API.G_MISS_CHAR,
        order_version		        VARCHAR2(40) 	DEFAULT	1,
        required_fulfillment_date 	DATE 		DEFAULT	SYSDATE,
        priority 		            NUMBER 		DEFAULT	100,
        jeopardy_enabled_flag	    VARCHAR2(1)	DEFAULT	'N',
        execution_mode		        VARCHAR2(5)	DEFAULT	'ASYNC',
        account_number		        VARCHAR2(30)	DEFAULT	FND_API.G_MISS_CHAR,
        cust_account_id		            NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        due_date 	                DATE 		DEFAULT	FND_API.G_MISS_DATE,
        customer_required_date 	    DATE 		DEFAULT	FND_API.G_MISS_DATE,
        order_type  		        VARCHAR2(40) 	DEFAULT	FND_API.G_MISS_CHAR,
        order_source 		        VARCHAR2(40) 	DEFAULT	FND_API.G_MISS_CHAR,
        org_id	 		            NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        related_order_id 	        NUMBER 		DEFAULT	FND_API.G_MISS_NUM,
        previous_order_id 	        NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        next_order_id 		        NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        order_ref_name 		        VARCHAR2(80) 	DEFAULT	FND_API.G_MISS_CHAR,
        order_ref_value 		    VARCHAR2(300) 	DEFAULT	FND_API.G_MISS_CHAR,
        order_comments		        VARCHAR2(4000)	DEFAULT	FND_API.G_MISS_CHAR,
        order_id		            NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        order_status		        VARCHAR2(40)	DEFAULT	FND_API.G_MISS_CHAR,
        fulfillment_status	        VARCHAR2(40)	DEFAULT	FND_API.G_MISS_CHAR,
        fulfillment_result	        VARCHAR2(4000)	DEFAULT	FND_API.G_MISS_CHAR,
        completion_date		        DATE		DEFAULT	FND_API.G_MISS_DATE,
        actual_fulfillment_date		DATE		DEFAULT	FND_API.G_MISS_DATE,
        customer_id                              NUMBER DEFAULT	FND_API.G_MISS_NUM,
        customer_name                            VARCHAR2(80) DEFAULT  FND_API.G_MISS_CHAR,
        telephone_number                       VARCHAR2(40)   DEFAULT  FND_API.G_MISS_CHAR,
        attribute_category              VARCHAR2(30)   DEFAULT	FND_API.G_MISS_CHAR,
        attribute1	 		    	VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute2		    		VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute3		    		VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute4	   	    		VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute5	   	    		VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute6	  	    		VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute7	 	    		VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute8	 	    		VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute9	  				VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute10	 				VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute11					VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute12					VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute13	  				VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute14					VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute15					VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute16					VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute17					VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute18					VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute19					VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute20	  				VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR
    );

    G_MISS_SERVICE_ORDER_HEADER SERVICE_ORDER_HEADER;
--   Modified by SXBANERJ 07/05. Parent_line_Id, Is_virtual_Flag and Attribute_Category

    TYPE SERVICE_LINE_ITEM IS RECORD
    (
        line_number 		NUMBER		DEFAULT 	FND_API.G_MISS_NUM,
        line_source		VARCHAR2(30)	DEFAULT 	FND_API.G_MISS_CHAR,
        inventory_item_id	NUMBER		DEFAULT 	FND_API.G_MISS_NUM,
        service_item_name	VARCHAR2(40)	DEFAULT 	FND_API.G_MISS_CHAR,
        version		        VARCHAR2(40)	DEFAULT 	FND_API.G_MISS_CHAR,
        action_code		VARCHAR2(30)    DEFAULT 	FND_API.G_MISS_CHAR,
        organization_code	VARCHAR2(4) 	DEFAULT	FND_API.G_MISS_CHAR,
        organization_id		NUMBER	 	DEFAULT	FND_API.G_MISS_NUM,
        site_use_id		NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        ib_source		VARCHAR2(20)	DEFAULT	'NONE',
        ib_source_id		NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        required_fulfillment_date DATE		DEFAULT FND_API.G_MISS_DATE,
        fulfillment_required_flag VARCHAR2(1)	DEFAULT	'Y',
        is_package_flag         VARCHAR2(1)     DEFAULT 'N',
        fulfillment_sequence 	NUMBER 		DEFAULT	0,
        bundle_id		NUMBER 		DEFAULT	FND_API.G_MISS_NUM,
        bundle_sequence 	NUMBER 		DEFAULT	FND_API.G_MISS_NUM,
        priority 		NUMBER 		DEFAULT	100,
        due_date 		DATE 		DEFAULT	FND_API.G_MISS_DATE,
        jeopardy_enabled_flag 	VARCHAR2(1) 	DEFAULT	'N',
        customer_required_date 	DATE 		DEFAULT	FND_API.G_MISS_DATE,
        starting_number         NUMBER 		DEFAULT	FND_API.G_MISS_NUM,
        ending_number 		NUMBER 		DEFAULT	FND_API.G_MISS_NUM,
        line_item_id		NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        workitem_id             NUMBER          DEFAULT	FND_API.G_MISS_NUM,
        line_status		VARCHAR2(40)	DEFAULT	FND_API.G_MISS_CHAR,
        completion_date		DATE		DEFAULT	FND_API.G_MISS_DATE,
        actual_fulfillment_date	DATE		DEFAULT	FND_API.G_MISS_DATE,
        parent_line_number     NUMBER           DEFAULT FND_API.G_MISS_NUM,
        is_virtual_line_flag         VARCHAR2(1)        DEFAULT 'N',
        attribute_category           VARCHAR2(30)       DEFAULT FND_API.G_MISS_CHAR,
        attribute1		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute2		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute3		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute4		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute5		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute6		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute7		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute8		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute9		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute10		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute11		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute12		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute13		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute14		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute15		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute16		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute17		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute18		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute19		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR,
        attribute20		    VARCHAR2(240)	DEFAULT	FND_API.G_MISS_CHAR
    );

-- list of order line items
    TYPE SERVICE_ORDER_LINE_LIST IS TABLE OF SERVICE_LINE_ITEM
	    INDEX BY BINARY_INTEGER;

    G_MISS_SERVICE_LINE_ITEM SERVICE_LINE_ITEM;
    G_MISS_SERVICE_ORDER_LINE_LIST SERVICE_ORDER_LINE_LIST;


    TYPE SERVICE_ORDER_PARAM IS RECORD
    (
  	parameter_name 		VARCHAR2(40)	DEFAULT	FND_API.G_MISS_CHAR,
      	parameter_value 		VARCHAR2(4000)	DEFAULT	FND_API.G_MISS_CHAR
    );
    TYPE SERVICE_ORDER_PARAM_LIST IS TABLE OF SERVICE_ORDER_PARAM
	    INDEX BY BINARY_INTEGER;
    G_MISS_ORDER_PARAMETER SERVICE_ORDER_PARAM;
    G_MISS_ORDER_PARAM_LIST SERVICE_ORDER_PARAM_LIST;

    TYPE SERVICE_LINE_PARAM IS RECORD
    (
	line_number 		NUMBER		DEFAULT	FND_API.G_MISS_NUM,
    	parameter_name 		VARCHAR2(40)	DEFAULT	FND_API.G_MISS_CHAR,
      	parameter_value 	VARCHAR2(4000)	DEFAULT	FND_API.G_MISS_CHAR,
        parameter_ref_value 	VARCHAR2(4000)	DEFAULT	FND_API.G_MISS_CHAR
    );
    TYPE SERVICE_LINE_PARAM_LIST IS TABLE OF SERVICE_LINE_PARAM
        INDEX BY BINARY_INTEGER;
    G_MISS_LINE_PARAM SERVICE_LINE_PARAM;
    G_MISS_LINE_PARAM_LIST SERVICE_LINE_PARAM_LIST;

    TYPE SERVICE_ORDER_STATUS IS RECORD
    (
        order_id            NUMBER		DEFAULT	FND_API.G_MISS_NUM,
        order_status		VARCHAR2(40)	DEFAULT	FND_API.G_MISS_CHAR,
        order_number  		VARCHAR2(40)	DEFAULT	FND_API.G_MISS_CHAR,
        order_version		VARCHAR2(40) 	DEFAULT	1,
        fulfillment_status	VARCHAR2(40)	DEFAULT	FND_API.G_MISS_CHAR,
        fulfillment_result	VARCHAR2(4000)	DEFAULT	FND_API.G_MISS_CHAR,
        completion_date		DATE		    DEFAULT	FND_API.G_MISS_DATE,
        actual_fulfillment_date	DATE		DEFAULT	FND_API.G_MISS_DATE
    );

--     Added by SXBANERJ 07/05/2001
--     Table of Primitives  used for bulk inserts

        TYPE NUMBER_TAB         IS TABLE OF NUMBER          INDEX BY BINARY_INTEGER;
        TYPE DATE_TAB           IS TABLE OF DATE            INDEX BY BINARY_INTEGER;
        TYPE VARCHAR2_1_TAB     IS TABLE OF VARCHAR2(1)     INDEX BY BINARY_INTEGER;
        TYPE VARCHAR2_30_TAB    IS TABLE OF VARCHAR2(30)    INDEX BY BINARY_INTEGER;
        TYPE VARCHAR2_40_TAB    IS TABLE OF VARCHAR2(40)    INDEX BY BINARY_INTEGER;
        TYPE VARCHAR2_240_TAB   IS TABLE OF VARCHAR2(240)   INDEX BY BINARY_INTEGER;
        TYPE VARCHAR2_4000_TAB  IS TABLE OF VARCHAR2(4000)  INDEX BY BINARY_INTEGER;
        TYPE VARCHAR2_32767_TAB IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;

-- Added by SXBANERJ 07/05/2001
 TYPE SERVICE_LINE_ITEM_RELATIONSHIP IS RECORD
  (
       LINE_ITEM_ID NUMBER            ,
       RELATED_LINE_ITEM_ID NUMBER    ,
       LINE_RELATIONSHIP VARCHAR2(40)
  );

-- Added by SXBANERJ 07/05/2001
 TYPE SERVICE_LINE_REL_LIST IS TABLE OF SERVICE_LINE_ITEM_RELATIONSHIP
        INDEX BY BINARY_INTEGER ;



-- Added Line Attribute record. Holds all possible values for a line item parameter

   TYPE SERVICE_LINE_ATTRIB IS RECORD (
        LINE_ITEM_ID     NUMBER               ,
        LINE_NUMBER              NUMBER          ,
        WORKITEM_INSTANCE_ID     NUMBER          ,
        WI_PARAMETER_ID          NUMBER          ,
        WORKITEM_ID              NUMBER          ,
        WORKITEM_NAME            VARCHAR2(40)    DEFAULT NULL ,
        PARAMETER_NAME           VARCHAR2(40)    ,
        PARAMETER_VALUE          VARCHAR2(4000)  ,
        PARAMETER_REF_VALUE      VARCHAR2(4000)  ,
        TXN_EXT_ATTRIB_DETAIL_ID NUMBER          ,
        ATTRIB_SOURCE_TABLE      VARCHAR2(30)    ,
        ATTRIB_SOURCE_ID         NUMBER         ,
        IS_VALUE_EVALUATED       VARCHAR2(1)     ,
        MODIFIED_FLAG            VARCHAR2(1)     ,
        REQUIRED_FLAG            VARCHAR2(1)     ,
        VALUE_LOOKUP_SQL         VARCHAR2(1996)  ,
        VALIDATION_PROCEDURE     VARCHAR2(80)    ,
        EVALUATION_MODE          VARCHAR2(20)    ,
        EVALUATION_SEQ           NUMBER          ,
        EVALUATION_PROCEDURE     VARCHAR2(80)    ,
        DISPLAY_SEQ              NUMBER          ,
        DEFAULT_VALUE            VARCHAR2(4000)
--        SECURITY_GROUP_ID        NUMBER
       );

-- Added line item parameter list
  TYPE SERVICE_LINE_ATTRIB_LIST IS TABLE OF SERVICE_LINE_ATTRIB
  INDEX BY BINARY_INTEGER;

-- Added Type for Fulfill Worklist

TYPE FULFILL_WORKLIST IS RECORD (
     WORKITEM_INSTANCE_ID      NUMBER       ,
     SERVICE_ITEM_NAME         NUMBER       ,
     LINE_NUMBER               NUMBER       ,
     VALIDATION_PROCEDURE      VARCHAR2(80) ,
     VALIDATION_ENABLED_FLAG   VARCHAR2(1) DEFAULT 'N',
     VERSION                   VARCHAR2(40) ,
     FA_EXEC_MAP_PROC          VARCHAR2(80) ,
     USER_WF_ITEM_KEY_PREFIX   VARCHAR2(240),
     USER_WF_ITEM_TYPE         VARCHAR2(80) ,
     USER_WF_PROCESS_NAME      VARCHAR2(40),
     WF_EXEC_PROC              VARCHAR2(80) ,
     TIME_ESTIMATE             NUMBER       ,
     PROTECTED_FLAG            VARCHAR2(1)  ,
     ROLE_NAME                 VARCHAR2(100) ,
     WORKITEM_ID               NUMBER       ,
     STATUS_CODE               VARCHAR2(40) ,
     LINE_ITEM_ID              NUMBER       ,
     WORKITEM_NAME             VARCHAR2(40) ,
     REQUIRED_FULFILLMENT_DATE DATE         ,
     WI_SEQUENCE               NUMBER       ,
     PRIORITY                  NUMBER       ,
     DUE_DATE                  DATE         ,
     CUSTOMER_REQUIRED_DATE    DATE         ,
     COMPLETION_DATE           DATE         ,
     CANCEL_FULFILLMENT_DATE   DATE         ,
     CANCELLED_BY              VARCHAR2(40) ,
     HOLD_FULFILLMENT_DATE     DATE         ,
     HELD_BY                   VARCHAR2(40) ,
     RESUME_FULFILLMENT_DATE   DATE         ,
     RESUMED_BY                VARCHAR2(40) ,
     ACTUAL_FULFILLMENT_DATE   DATE         ,
     WF_ITEM_TYPE              VARCHAR2(8)  ,
     WF_ITEM_KEY               VARCHAR2(240),
     ERROR_REF_ID              NUMBER       ,
--     SECURITY_GROUP_ID         NUMBER       ,
     ATTRIBUTE_CATEGORY        VARCHAR2(30) ,
     ATTRIBUTE1                VARCHAR2(240),
     ATTRIBUTE2                VARCHAR2(240),
     ATTRIBUTE3                VARCHAR2(240),
     ATTRIBUTE4                VARCHAR2(240),
     ATTRIBUTE5                VARCHAR2(240),
     ATTRIBUTE6                VARCHAR2(240),
     ATTRIBUTE7                VARCHAR2(240),
     ATTRIBUTE8                VARCHAR2(240),
     ATTRIBUTE9                VARCHAR2(240),
     ATTRIBUTE10               VARCHAR2(240),
     ATTRIBUTE11               VARCHAR2(240),
     ATTRIBUTE12               VARCHAR2(240),
     ATTRIBUTE13               VARCHAR2(240),
     ATTRIBUTE14               VARCHAR2(240),
     ATTRIBUTE15               VARCHAR2(240),
     ATTRIBUTE16               VARCHAR2(240),
     ATTRIBUTE17               VARCHAR2(240),
     ATTRIBUTE18               VARCHAR2(240),
     ATTRIBUTE19               VARCHAR2(240),
     ATTRIBUTE20               VARCHAR2(240));

  -- fulfill worklist list
  TYPE FULFILL_WORKLIST_LIST IS TABLE OF FULFILL_WORKLIST
         INDEX BY BINARY_INTEGER;

END XDP_TYPES;

 

/
