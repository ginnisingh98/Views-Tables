--------------------------------------------------------
--  DDL for Package Body ENG_CHANGE_ORDER_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_CHANGE_ORDER_TYPES_PKG" as
/* $Header: ENGCTYPEB.pls 120.3 2006/01/30 02:24:11 pdutta noship $ */

TYPE number_list IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

procedure ENG_LC_STATUSES_INSERT (
	X_ROWID in out nocopy VARCHAR2,
	X_CHANGE_LIFECYCLE_STATUS_ID in NUMBER,
	X_CHANGE_WF_ROUTE_ID in NUMBER,
	X_AUTO_PROMOTE_STATUS in NUMBER,
	X_AUTO_DEMOTE_STATUS in NUMBER,
	X_WORKFLOW_STATUS in VARCHAR2,
	X_CHANGE_EDITABLE_FLAG in VARCHAR2,
	X_ENTITY_ID4 in NUMBER,
	X_ENTITY_ID5 in NUMBER,
	X_ENTITY_NAME in VARCHAR2,
	X_ENTITY_ID1 in NUMBER,
	X_ENTITY_ID2 in NUMBER,
	X_ENTITY_ID3 in NUMBER,
	X_COMPLETION_DATE in DATE,
	X_STATUS_CODE in NUMBER,
	X_START_DATE in DATE,
	X_SEQUENCE_NUMBER in NUMBER,
	X_ITERATION_NUMBER in NUMBER,
	X_ACTIVE_FLAG in VARCHAR2,
	X_CREATION_DATE in DATE,
	X_CREATED_BY in NUMBER,
	X_LAST_UPDATE_DATE in DATE,
	X_LAST_UPDATED_BY in NUMBER,
	X_LAST_UPDATE_LOGIN in NUMBER)
IS
	cursor C is select ROWID from ENG_LIFECYCLE_STATUSES
	where CHANGE_LIFECYCLE_STATUS_ID = X_CHANGE_LIFECYCLE_STATUS_ID;
BEGIN
        insert into ENG_LIFECYCLE_STATUSES (
          CHANGE_WF_ROUTE_ID,
          AUTO_PROMOTE_STATUS,
          AUTO_DEMOTE_STATUS,
          WORKFLOW_STATUS,
          CHANGE_EDITABLE_FLAG,
          ENTITY_ID4,
          ENTITY_ID5,
          CHANGE_LIFECYCLE_STATUS_ID,
          ENTITY_NAME,
          ENTITY_ID1,
          ENTITY_ID2,
          ENTITY_ID3,
          COMPLETION_DATE,
          STATUS_CODE,
          START_DATE,
          SEQUENCE_NUMBER,
          ITERATION_NUMBER,
          ACTIVE_FLAG,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN
        ) values (
          X_CHANGE_WF_ROUTE_ID,
          X_AUTO_PROMOTE_STATUS,
          X_AUTO_DEMOTE_STATUS,
          X_WORKFLOW_STATUS,
          X_CHANGE_EDITABLE_FLAG,
          X_ENTITY_ID4,
          X_ENTITY_ID5,
          X_CHANGE_LIFECYCLE_STATUS_ID,
          X_ENTITY_NAME,
          X_ENTITY_ID1,
          X_ENTITY_ID2,
          X_ENTITY_ID3,
          X_COMPLETION_DATE,
          X_STATUS_CODE,
          X_START_DATE,
          X_SEQUENCE_NUMBER,
          X_ITERATION_NUMBER,
          X_ACTIVE_FLAG,
          X_CREATION_DATE,
          X_CREATED_BY,
          X_LAST_UPDATE_DATE,
          X_LAST_UPDATED_BY,
          X_LAST_UPDATE_LOGIN
        );

        OPEN c;
        FETCH c INTO X_ROWID;
        IF (c%notfound) then
          close c;
          raise no_data_found;
        END IF;
        CLOSE c;

END ENG_LC_STATUSES_INSERT;

procedure ENG_DUPLICATE_LC_PROP (
	X_CHANGE_LIFECYCLE_STATUS_ID in NUMBER ,
	X_LIFECYCLE_PARENT_ID        in NUMBER ,
	X_CREATION_DATE              in DATE ,
	X_CREATED_BY                 in NUMBER ,
	X_LAST_UPDATE_LOGIN          in NUMBER )
IS
	CURSOR status_properties IS
	SELECT *
	FROM ENG_STATUS_PROPERTIES
	WHERE CHANGE_LIFECYCLE_STATUS_ID = X_LIFECYCLE_PARENT_ID;
BEGIN
	FOR sp in status_properties
	LOOP
	  INSERT INTO ENG_STATUS_PROPERTIES (
	    CHANGE_LIFECYCLE_STATUS_ID,
	    STATUS_CODE,
	    PROMOTION_STATUS_FLAG,
	    CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_LOGIN ) values (
	    X_CHANGE_LIFECYCLE_STATUS_ID,
	    sp.STATUS_CODE,
	    sp.PROMOTION_STATUS_FLAG,
            X_CREATION_DATE,
            X_CREATED_BY,
	    X_CREATION_DATE,
	    X_CREATED_BY,
	    X_LAST_UPDATE_LOGIN);
	END LOOP;
END ENG_DUPLICATE_LC_PROP;

procedure DUPLICATE_LIFECYCLES (
	X_CHANGE_ORDER_TYPE_ID       in NUMBER,
        X_PARENT_CHANGE_TYPE_ID      in NUMBER,
	X_CREATED_BY                 in  NUMBER,
	X_CREATION_DATE              in  DATE,
	X_LAST_UPDATE_LOGIN          in  NUMBER)
IS
	v_row_id		     VARCHAR2(100);
	l_lifecycle_phase_id	     NUMBER;

	CURSOR lifecycles IS
	SELECT *
	FROM ENG_LIFECYCLE_STATUSES
	WHERE ENTITY_NAME = 'ENG_CHANGE_TYPE'
	AND ENTITY_ID1 = X_PARENT_CHANGE_TYPE_ID;
BEGIN
	FOR cl in lifecycles
	LOOP
	  SELECT eng_lifecycle_statuses_s.nextval
	  INTO l_lifecycle_phase_id
	  FROM dual;

	  ENG_LC_STATUSES_INSERT (
	    X_ROWID                      =>v_row_id ,
	    X_CHANGE_LIFECYCLE_STATUS_ID =>l_lifecycle_phase_id ,
	    X_CHANGE_WF_ROUTE_ID         =>cl.CHANGE_WF_ROUTE_ID ,
	    X_AUTO_PROMOTE_STATUS        =>cl.AUTO_PROMOTE_STATUS ,
	    X_AUTO_DEMOTE_STATUS         =>cl.AUTO_DEMOTE_STATUS ,
	    X_WORKFLOW_STATUS            =>cl.WORKFLOW_STATUS ,
	    X_CHANGE_EDITABLE_FLAG       =>cl.CHANGE_EDITABLE_FLAG ,
	    X_ENTITY_ID4                 =>cl.ENTITY_ID4 ,
	    X_ENTITY_ID5                 =>cl.ENTITY_ID5 ,
	    X_ENTITY_NAME                =>cl.ENTITY_NAME ,
	    X_ENTITY_ID1                 =>X_CHANGE_ORDER_TYPE_ID ,
	    X_ENTITY_ID2                 =>cl.ENTITY_ID2 ,
	    X_ENTITY_ID3                 =>cl.ENTITY_ID3 ,
	    X_COMPLETION_DATE            =>cl.COMPLETION_DATE ,
	    X_STATUS_CODE                =>cl.STATUS_CODE ,
	    X_START_DATE                 =>cl.START_DATE ,
	    X_SEQUENCE_NUMBER            =>cl.SEQUENCE_NUMBER ,
	    X_ITERATION_NUMBER           =>0 ,
	    X_ACTIVE_FLAG                =>'Y' ,
	    X_CREATION_DATE              =>X_CREATION_DATE ,
	    X_CREATED_BY                 =>X_CREATED_BY ,
	    X_LAST_UPDATE_DATE           =>X_CREATION_DATE ,
	    X_LAST_UPDATED_BY            =>X_CREATED_BY ,
	    X_LAST_UPDATE_LOGIN          =>X_LAST_UPDATE_LOGIN);

	  ENG_DUPLICATE_LC_PROP (
	    X_CHANGE_LIFECYCLE_STATUS_ID =>l_lifecycle_phase_id ,
	    X_LIFECYCLE_PARENT_ID        =>cl.CHANGE_LIFECYCLE_STATUS_ID ,
	    X_CREATION_DATE              =>X_CREATION_DATE ,
	    X_CREATED_BY                 =>X_CREATED_BY ,
	    X_LAST_UPDATE_LOGIN          =>X_LAST_UPDATE_LOGIN);
	END LOOP;
END DUPLICATE_LIFECYCLES;

procedure DUPLICATE_PRIORITIES (
	X_CHANGE_ORDER_TYPE_ID       in NUMBER,
        X_PARENT_CHANGE_TYPE_ID      in NUMBER,
	X_CREATED_BY                 in  NUMBER,
	X_CREATION_DATE              in  DATE,
	X_LAST_UPDATE_LOGIN          in  NUMBER)
IS
	v_row_id		     VARCHAR2(100);
	l_priority_code 	     VARCHAR2(10);

	CURSOR priorities IS
	SELECT *
	FROM ENG_CHANGE_TYPE_PRIORITIES
	WHERE CHANGE_TYPE_ID = X_PARENT_CHANGE_TYPE_ID;
BEGIN
	FOR cl in priorities
	LOOP
	  INSERT INTO ENG_CHANGE_TYPE_PRIORITIES
	  (CHANGE_TYPE_ID,
	  PRIORITY_CODE,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN) VALUES (
          X_CHANGE_ORDER_TYPE_ID,
          cl.PRIORITY_CODE,
	  X_CREATION_DATE,
          X_CREATED_BY,
	  X_CREATION_DATE,
	  X_CREATED_BY,
	  X_LAST_UPDATE_LOGIN);
	END LOOP;
END DUPLICATE_PRIORITIES;

procedure DUPLICATE_REASONS (
	X_CHANGE_ORDER_TYPE_ID       in NUMBER,
        X_PARENT_CHANGE_TYPE_ID      in NUMBER,
	X_CREATED_BY                 in  NUMBER,
	X_CREATION_DATE              in  DATE,
	X_LAST_UPDATE_LOGIN          in  NUMBER)
IS
	v_row_id		     VARCHAR2(100);
	l_reason_code 	     VARCHAR2(10);

	CURSOR REASONS IS
	SELECT *
	FROM ENG_CHANGE_TYPE_REASONS
	WHERE CHANGE_TYPE_ID = X_PARENT_CHANGE_TYPE_ID;
BEGIN
	FOR cl in REASONS
	LOOP
	  INSERT INTO ENG_CHANGE_TYPE_REASONS
	  (CHANGE_TYPE_ID,
	  REASON_CODE,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN) VALUES (
          X_CHANGE_ORDER_TYPE_ID,
          cl.REASON_CODE,
	  X_CREATION_DATE,
          X_CREATED_BY,
	  X_CREATION_DATE,
	  X_CREATED_BY,
	  X_LAST_UPDATE_LOGIN);
	END LOOP;
END DUPLICATE_REASONS;

procedure DUPLICATE_CLASSCODES (
	X_CHANGE_ORDER_TYPE_ID       in NUMBER,
        X_PARENT_CHANGE_TYPE_ID      in NUMBER,
	X_CREATED_BY                 in  NUMBER,
	X_CREATION_DATE              in  DATE,
	X_LAST_UPDATE_LOGIN          in  NUMBER)
IS
	v_row_id		     VARCHAR2(100);
	l_code_id       	     NUMBER;

	CURSOR CLASSCODES IS
	SELECT *
	FROM ENG_CHANGE_TYPE_CLASS_CODES
	WHERE CHANGE_TYPE_ID = X_PARENT_CHANGE_TYPE_ID;
BEGIN
	FOR cl in CLASSCODES
	LOOP
	  INSERT INTO ENG_CHANGE_TYPE_CLASS_CODES
	  (CHANGE_TYPE_ID,
	  CLASSIFICATION_ID,
	  CREATION_DATE,
	  CREATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_LOGIN) VALUES (
          X_CHANGE_ORDER_TYPE_ID,
          cl.CLASSIFICATION_ID,
	  X_CREATION_DATE,
          X_CREATED_BY,
	  X_CREATION_DATE,
	  X_CREATED_BY,
	  X_LAST_UPDATE_LOGIN);
	END LOOP;
END DUPLICATE_CLASSCODES;

--Bug No: 3439555
--Issue: DEF-1473
--Procedure to insert the attribute/sections being
--defaulted.
procedure INSERT_TYPE_CONFIGURATION (
	   X_CONFIGURATION_TYPE         in  VARCHAR2,
	   X_CODE                       in  VARCHAR2,
	   X_DISPLAY_SEQUENCE           in  NUMBER,
	   X_REGION_CODE                in  VARCHAR2,
	   X_CLASSIFICAITON1            in  VARCHAR2,
	   X_CLASSIFICAITON2            in  NUMBER,
	   X_ATTRIBUTE_APPLICATION_ID   in  NUMBER,
	   X_CREATED_BY                 in  NUMBER,
	   X_CREATION_DATE              in  DATE,
	   X_LAST_UPDATE_LOGIN          in  NUMBER)
IS
	  l_customization_code          VARCHAR2(200);
          l_return_status               VARCHAR2(30);
	  l_error_code                  NUMBER;
BEGIN

    l_customization_code := X_CLASSIFICAITON2 || X_CLASSIFICAITON1;
    ENG_TYPE_CONFIGURATION_PKG.create_type_config
    (
      X_CUSTOMIZATION_APPLICATION_ID => X_ATTRIBUTE_APPLICATION_ID,
      X_CUSTOMIZATION_CODE           => l_customization_code,
      X_REGION_APPLICATION_ID        => X_ATTRIBUTE_APPLICATION_ID,
      X_REGION_CODE                  => X_REGION_CODE,
      X_NAME			     => 'CONFIG',
      X_CREATED_BY                   => X_CREATED_BY,
      X_CREATION_DATE                => X_CREATION_DATE,
      X_LAST_UPDATED_BY              => X_CREATED_BY,
      X_LAST_UPDATE_DATE             => X_CREATION_DATE,
      X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN,
      X_CLASSIFICATION_1             => X_CLASSIFICAITON1,
      X_CLASSIFICATION_2             => X_CLASSIFICAITON2,
      X_CLASSIFICATION_3             => null,
      X_RETURN_STATUS                => l_return_status,
      X_ERRORCODE                    => l_error_code
      );

    IF (X_CONFIGURATION_TYPE = 'ATTRIBUTE')
    THEN
      ENG_TYPE_CONFIGURATION_PKG.create_Primary_Attribute
          (
          X_CUSTOMIZATION_APPLICATION_ID => X_ATTRIBUTE_APPLICATION_ID,
          X_CUSTOMIZATION_CODE           => l_customization_code,
          X_REGION_APPLICATION_ID        => X_ATTRIBUTE_APPLICATION_ID,
          X_REGION_CODE                  => X_REGION_CODE,
          X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
          X_ATTRIBUTE_CODE               => X_CODE,
          X_DISPLAY_SEQUENCE             => X_DISPLAY_SEQUENCE,
          X_ORDER_SEQUENCE               => null,
          X_ORDER_DIRECTION              => null,
          X_COLUMN_NAME                  => null,
          X_SHOW_TOTAL                   => null,
          X_CREATED_BY                   => X_CREATED_BY,
          X_CREATION_DATE                => X_CREATION_DATE,
          X_LAST_UPDATED_BY              => X_CREATED_BY,
          X_LAST_UPDATE_DATE             => X_CREATION_DATE,
          X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN,
          X_RETURN_STATUS                => l_return_status,
          X_ERRORCODE                    => l_error_code
          );
    ELSE
      ENG_TYPE_CONFIGURATION_PKG.create_config_section
          (
          X_CUSTOMIZATION_APPLICATION_ID => X_ATTRIBUTE_APPLICATION_ID,
          X_CUSTOMIZATION_CODE           => l_customization_code,
          X_REGION_APPLICATION_ID        => X_ATTRIBUTE_APPLICATION_ID,
          X_REGION_CODE                  => X_REGION_CODE,
          X_ATTRIBUTE_APPLICATION_ID     => X_ATTRIBUTE_APPLICATION_ID,
          X_ATTRIBUTE_CODE               => X_CODE,
          X_DISPLAY_SEQUENCE             => X_DISPLAY_SEQUENCE,
          X_CREATED_BY                   => X_CREATED_BY,
          X_CREATION_DATE                => X_CREATION_DATE,
          X_LAST_UPDATED_BY              => X_CREATED_BY,
          X_LAST_UPDATE_DATE             => X_CREATION_DATE,
          X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN,
          X_RETURN_STATUS                => l_return_status,
          X_ERRORCODE                    => l_error_code
          );
    END IF;
END INSERT_TYPE_CONFIGURATION;

--Bug No: 3439555
--Issue: DEF-1473
--Adding the default configuration 'Change_Notice'
--for all header types.
procedure ADD_DEFAULT_CONFIGURATIONS (
           X_CHANGE_ORDER_TYPE_ID       in  NUMBER,
           X_CHANGE_MGMT_TYPE_CODE      in  VARCHAR2,
	   X_CREATED_BY                 in  NUMBER,
	   X_CREATION_DATE              in  DATE,
	   X_LAST_UPDATE_LOGIN          in  NUMBER)
IS
BEGIN
        INSERT_TYPE_CONFIGURATION (
	  X_CONFIGURATION_TYPE         =>'ATTRIBUTE' ,
	  X_CODE                       =>'CHANGE_NOTICE' ,
	  X_DISPLAY_SEQUENCE           =>0 ,
	  X_REGION_CODE                =>'ENG_ADMIN_CONFIGURATIONS' ,
	  X_CLASSIFICAITON1            =>X_CHANGE_MGMT_TYPE_CODE ,
	  X_CLASSIFICAITON2            =>X_CHANGE_ORDER_TYPE_ID ,
	  X_ATTRIBUTE_APPLICATION_ID   =>703 ,
	  X_CREATION_DATE              =>X_CREATION_DATE ,
	  X_CREATED_BY                 =>X_CREATED_BY ,
	  X_LAST_UPDATE_LOGIN          =>X_LAST_UPDATE_LOGIN);
END ADD_DEFAULT_CONFIGURATIONS;

procedure ADD_DEFAULT_LIFECYCLES (
        X_CHANGE_ORDER_TYPE_ID       in NUMBER,
        X_BASE_CHANGE_MGMT_TYPE      in VARCHAR2,
	X_CREATED_BY                 in  NUMBER,
	X_CREATION_DATE              in  DATE,
	X_LAST_UPDATE_LOGIN          in  NUMBER)
IS
	phase_types	             number_list;
	v_row_id		     VARCHAR2(100);
	l_lifecycle_phase_id	     NUMBER;
	l_seq_no		     NUMBER := 0;
	l_phase_id		     NUMBER := null;
        l_route_id                   NUMBER := null;
BEGIN
        /* 30-JAN-2006: For DOM Lifecycles categories, no lifecycle is seeded
        */
        IF ( X_BASE_CHANGE_MGMT_TYPE = 'DOM_DOCUMENT_LIFECYCLE')
	THEN
	  return;
	END IF;

        /* 24-FEB-2004: Changing the sequence of the phases to Open->
        Released->Scheduled->Implemented
        */
	/* This procedure defaults the lifecycles for new header types.
	If the header type is a change order type then 4 phases:
		Open
		Released
		Scheduled
		Implemented
	are defaulted. In case it is of non change-order type then the
	following two phases are defaulted.
		Open
		Implemented
	*/
        /* Bug No: 3983759
           11-FEB-2005: Changing the sequnece of phases for 'Document Approval
           to Approval->Implemented.

           21-FEB-2005: Changing the sequence of statuses for 'Document Review
           to Review->Implemented.
        */

        IF ( X_BASE_CHANGE_MGMT_TYPE = 'ATTACHMENT_APPROVAL')
        THEN
          phase_types(1) := 8; --'Approval'
        ELSIF ( X_BASE_CHANGE_MGMT_TYPE = 'ATTACHMENT_REVIEW')
        THEN
          phase_types(1) := 12; --'Review'
        ELSE
          phase_types(1) := 1; --'Open'
        END IF;

	IF ( X_BASE_CHANGE_MGMT_TYPE = 'CHANGE_ORDER')
	THEN
	  --phase_types(2) := 4; --'Scheduled'
	  --phase_types(3) := 7; --'Released'
          phase_types(2) := 7; --'Released'
          phase_types(3) := 4; --'Scheduled'
	  phase_types(4) := 6; --'Implemented'
	ELSE
	  phase_types(2) := 11; --'Completed'
	END IF;

	l_phase_id := phase_types.first;
	WHILE l_phase_id is not null
	LOOP
	  l_seq_no := l_seq_no +10;
          l_route_id := null;

	  SELECT eng_lifecycle_statuses_s.nextval
	  INTO l_lifecycle_phase_id
	  FROM dual;

          IF (phase_types(l_phase_id) = 8) -- approval status code
          THEN
            SELECT a.route_id
            INTO l_route_id
            FROM eng_change_routes_tl a,
            eng_change_routes b
            WHERE a.ROUTE_NAME = 'Standard Approval Process'
            AND b.route_id = a.route_id
            AND a.language = 'US'
            AND b.TEMPLATE_FLAG = 'Y';
          END IF;

	  ENG_LC_STATUSES_INSERT (
	    X_ROWID                      =>v_row_id,
	    X_CHANGE_LIFECYCLE_STATUS_ID =>l_lifecycle_phase_id ,
	    X_CHANGE_WF_ROUTE_ID         =>l_route_id ,
	    X_AUTO_PROMOTE_STATUS        =>null ,
	    X_AUTO_DEMOTE_STATUS         =>null ,
	    X_WORKFLOW_STATUS            =>null ,
	    X_CHANGE_EDITABLE_FLAG       =>null ,
	    X_ENTITY_ID4                 =>null ,
	    X_ENTITY_ID5                 =>null ,
	    X_ENTITY_NAME                =>'ENG_CHANGE_TYPE' ,
	    X_ENTITY_ID1                 =>X_CHANGE_ORDER_TYPE_ID ,
	    X_ENTITY_ID2                 =>null ,
	    X_ENTITY_ID3                 =>null ,
	    X_COMPLETION_DATE            =>null ,
	    X_STATUS_CODE                =>phase_types(l_phase_id) ,
	    X_START_DATE                 =>null ,
	    X_SEQUENCE_NUMBER            =>l_seq_no ,
	    X_ITERATION_NUMBER           =>0 ,
	    X_ACTIVE_FLAG                =>'Y' ,
	    X_CREATION_DATE              =>X_CREATION_DATE ,
	    X_CREATED_BY                 =>X_CREATED_BY ,
	    X_LAST_UPDATE_DATE           =>X_CREATION_DATE ,
	    X_LAST_UPDATED_BY            =>X_CREATED_BY ,
	    X_LAST_UPDATE_LOGIN          =>X_LAST_UPDATE_LOGIN);

          l_phase_id := phase_types.next(l_phase_id);
	END LOOP;
END ADD_DEFAULT_LIFECYCLES;

procedure DUPLICATE_ATTR_SECT (
	X_CHANGE_ORDER_TYPE_ID       in  NUMBER,
	X_CREATED_BY                 in  NUMBER,
	X_CREATION_DATE              in  DATE,
	X_TYPE_ID		     in  NUMBER,
	X_LAST_UPDATE_LOGIN          in  NUMBER,
	X_CHANGE_MGMT_TYPE_CODE	     in  VARCHAR2,
	X_BASE_CHANGE_MGMT_TYPE_CODE in  VARCHAR2)
IS
	l_return_status                 VARCHAR2(30);
	l_error_code                    NUMBER;
	l_name			        VARCHAR2(2000);
	l_customization_code		VARCHAR2(200);
	l_classification2               VARCHAR2(30);

	CURSOR attr_sects_c IS
	Select
	  AK_ATTRIBUTES.ATTRIBUTE_APPLICATION_ID	ATTRIBUTE_APPLICATION_ID,
          AK_ATTRIBUTES.ATTRIBUTE_CODE			ATTRIBUTE_CODE,
	  AK_ATTRIBUTES.PROPERTY_NAME			PROPERTY_NAME,
          AK_ATTRIBUTES.PROPERTY_NUMBER_VALUE		PROPERTY_NUMBER_VALUE
	FROM
          AK_CUSTOM_REGION_ITEMS AK_ATTRIBUTES,
          EGO_CUSTOMIZATION_EXT  ATTRIBUTE_EXT
	WHERE
	  AK_ATTRIBUTES.CUSTOMIZATION_APPLICATION_ID = ATTRIBUTE_EXT.CUSTOMIZATION_APPLICATION_ID
          AND AK_ATTRIBUTES.CUSTOMIZATION_CODE = ATTRIBUTE_EXT.CUSTOMIZATION_CODE
	  AND AK_ATTRIBUTES.REGION_APPLICATION_ID = ATTRIBUTE_EXT.REGION_APPLICATION_ID
	  AND ATTRIBUTE_EXT.REGION_APPLICATION_ID = 703
	  AND AK_ATTRIBUTES.REGION_CODE = ATTRIBUTE_EXT.REGION_CODE
          AND ATTRIBUTE_EXT.REGION_CODE = 'ENG_ADMIN_CONFIGURATIONS'
	  AND (  (X_TYPE_ID is NULL AND ( ATTRIBUTE_EXT.CLASSIFICATION2 is NULL
	                                 AND ATTRIBUTE_EXT.CLASSIFICATION1 = X_BASE_CHANGE_MGMT_TYPE_CODE))
	      OR( X_TYPE_ID is NOT NULL AND ( ATTRIBUTE_EXT.CLASSIFICATION2 = X_TYPE_ID
	                                 AND ATTRIBUTE_EXT.CLASSIFICATION1 = X_CHANGE_MGMT_TYPE_CODE)));
BEGIN
	--l_customization_code := X_CHANGE_MGMT_TYPE_CODE||'_ENG_ADMIN_CONFIGR'; -- Commented as this gives values too large
	IF X_TYPE_ID IS NULL
	THEN
          l_customization_code := X_CHANGE_MGMT_TYPE_CODE;
	  l_classification2 := null;
	ELSE
	  l_customization_code := X_CHANGE_ORDER_TYPE_ID || X_CHANGE_MGMT_TYPE_CODE;
	  l_classification2 := X_CHANGE_ORDER_TYPE_ID;
	END IF;

	ENG_TYPE_CONFIGURATION_PKG.create_type_config
        (
        X_CUSTOMIZATION_APPLICATION_ID => 703,
        X_CUSTOMIZATION_CODE           => l_customization_code, --Modify if duplicating for types also
        X_REGION_APPLICATION_ID        => 703,
        X_REGION_CODE                  => 'ENG_ADMIN_CONFIGURATIONS',
        X_NAME			       => 'CONFIG',
        X_CREATED_BY                   => X_CREATED_BY,
        X_CREATION_DATE                => X_CREATION_DATE,
        X_LAST_UPDATED_BY              => X_CREATED_BY,
        X_LAST_UPDATE_DATE             => X_CREATION_DATE,
        X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN,
        X_CLASSIFICATION_1             => X_CHANGE_MGMT_TYPE_CODE,
        --X_CLASSIFICATION_2             => null,  -- Put X_TYPE_ID if duplicating for type also.
        X_CLASSIFICATION_2             => l_classification2,
        X_CLASSIFICATION_3             => null,
        X_RETURN_STATUS                => l_return_status,
        X_ERRORCODE                    => l_error_code
        );

	FOR atsec IN attr_sects_c
	LOOP
	  IF (atsec.PROPERTY_NAME = 'DISPLAY_SEQUENCE')
	  THEN
	    ENG_TYPE_CONFIGURATION_PKG.create_Primary_Attribute
            (
            X_CUSTOMIZATION_APPLICATION_ID => 703,
            X_CUSTOMIZATION_CODE           => l_customization_code,
            X_REGION_APPLICATION_ID        => 703,
            X_REGION_CODE                  => 'ENG_ADMIN_CONFIGURATIONS',
            X_ATTRIBUTE_APPLICATION_ID     => atsec.ATTRIBUTE_APPLICATION_ID,
            X_ATTRIBUTE_CODE               => atsec.ATTRIBUTE_CODE,
            X_DISPLAY_SEQUENCE             => atsec.PROPERTY_NUMBER_VALUE,
            X_ORDER_SEQUENCE               => null,
            X_ORDER_DIRECTION              => null,
            X_COLUMN_NAME                  => null,
            X_SHOW_TOTAL                   => null,
            X_CREATED_BY                   => X_CREATED_BY,
	    X_CREATION_DATE                => X_CREATION_DATE,
            X_LAST_UPDATED_BY              => X_CREATED_BY,
            X_LAST_UPDATE_DATE             => X_CREATION_DATE,
            X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN,
            X_RETURN_STATUS                => l_return_status,
            X_ERRORCODE                    => l_error_code
            );
	  END IF;
          IF (atsec.PROPERTY_NAME = 'SECTION_SEQUENCE')
	  THEN
	    ENG_TYPE_CONFIGURATION_PKG.create_config_section
            (
            X_CUSTOMIZATION_APPLICATION_ID => 703,
            X_CUSTOMIZATION_CODE           => l_customization_code,
            X_REGION_APPLICATION_ID        => 703,
            X_REGION_CODE                  => 'ENG_ADMIN_CONFIGURATIONS',
            X_ATTRIBUTE_APPLICATION_ID     => atsec.ATTRIBUTE_APPLICATION_ID,
            X_ATTRIBUTE_CODE               => atsec.ATTRIBUTE_CODE,
            X_DISPLAY_SEQUENCE             => atsec.PROPERTY_NUMBER_VALUE,
            X_CREATED_BY                   => X_CREATED_BY,
	    X_CREATION_DATE                => X_CREATION_DATE,
            X_LAST_UPDATED_BY              => X_CREATED_BY,
            X_LAST_UPDATE_DATE             => X_CREATION_DATE,
            X_LAST_UPDATE_LOGIN            => X_LAST_UPDATE_LOGIN,
            X_RETURN_STATUS                => l_return_status,
            X_ERRORCODE                    => l_error_code
            );
	  END IF;
	END LOOP;

END DUPLICATE_ATTR_SECT;

procedure DUPLICATE_TYPES (
	X_CHANGE_ORDER_TYPE_ID       in  NUMBER,
	X_CREATED_BY                 in  NUMBER,
	X_CREATION_DATE              in  DATE,
	X_LAST_UPDATE_LOGIN          in  NUMBER,
	X_CHANGE_MGMT_TYPE_CODE	     in  VARCHAR2,
	X_SEEDED_FLAG		     in  VARCHAR2,
	X_BASE_CHANGE_MGMT_TYPE_CODE in  VARCHAR2)
IS
   v_row_id		      VARCHAR2(100);
   l_change_order_type_id     NUMBER;
   l_default_assignee_id      NUMBER;
   l_subject_id		      NUMBER;
   l_default_assignee_type    VARCHAR2(30);
   l_type_classification      VARCHAR2(30);
   l_class_code_derived_flag  VARCHAR2(1);
   l_assembly_type	      NUMBER;
   l_disable_date	      DATE;
   l_start_date		      DATE;
   l_type_name                VARCHAR2(80);
   l_description	      VARCHAR2(240);
   l_tab_text		      VARCHAR2(80);
   l_enable_item_in_local_org VARCHAR2(1);
   l_create_bom_in_local_org  VARCHAR2(1);
   l_subject_updatable_flag   VARCHAR2(1);
   l_base_change_mgmt_type_code  VARCHAR2(30);
   c_start_date		      DATE;

BEGIN
	SELECT eng_change_order_types_s.nextval
	INTO l_change_order_type_id
	FROM dual;

	SELECT default_assignee_id,
	       subject_id,
	       default_assignee_type,
	       type_classification,
	       class_code_derived_flag,
	       assembly_type,
	       disable_date,
	       start_date,
	       type_name,
	       description,
	       tab_text,
	       enable_item_in_local_org,
	       create_bom_in_local_org,
	       subject_updatable_flag,
	       base_change_mgmt_type_code
	INTO l_default_assignee_id,
	       l_subject_id,
	       l_default_assignee_type,
	       l_type_classification,
	       l_class_code_derived_flag,
	       l_assembly_type,
	       l_disable_date,
	       l_start_date,
	       l_type_name,
	       l_description,
	       l_tab_text,
	       l_enable_item_in_local_org,
	       l_create_bom_in_local_org,
	       l_subject_updatable_flag,
	       l_base_change_mgmt_type_code    --Added for Bug No:3497234, Issue: DEF-2071
	FROM ENG_CHANGE_ORDER_TYPES_VL
	WHERE
	CHANGE_ORDER_TYPE_ID = X_CHANGE_ORDER_TYPE_ID;

	SELECT START_DATE INTO c_start_date
	FROM ENG_CHANGE_ORDER_TYPES_VL
	WHERE CHANGE_MGMT_TYPE_CODE = X_CHANGE_MGMT_TYPE_CODE
	AND TYPE_CLASSIFICATION = 'CATEGORY';

	ENG_CHANGE_ORDER_TYPES_PKG.INSERT_ROW(
	    X_ROWID                             => v_row_id
          , X_CHANGE_ORDER_TYPE_ID              => l_change_order_type_id
          , X_CHANGE_MGMT_TYPE_CODE             => X_CHANGE_MGMT_TYPE_CODE
	  , X_START_DATE                        => c_start_date		-- Start date should be same as category's start date
	  , X_DEFAULT_ASSIGNEE_ID               => l_default_assignee_id
	  , X_SUBJECT_ID                        => l_subject_id
	  , X_AUTO_NUMBERING_METHOD             => 'USR_ENT'
	  , X_DEFAULT_ASSIGNEE_TYPE             => l_default_assignee_type
	  , X_TYPE_CLASSIFICATION               => l_type_classification
	  , X_CLASS_CODE_DERIVED_FLAG           => l_class_code_derived_flag
	  , X_SEQUENCE_NUMBER                   => null
	  --, X_BASE_CHANGE_MGMT_TYPE_CODE        => X_BASE_CHANGE_MGMT_TYPE_CODE
          , X_BASE_CHANGE_MGMT_TYPE_CODE        => l_base_change_mgmt_type_code
	  , X_SEEDED_FLAG                       => X_SEEDED_FLAG
	  , X_ATTRIBUTE8                        => null
	  , X_ATTRIBUTE9                        => null
	  , X_ATTRIBUTE10                       => null
	  , X_ATTRIBUTE11                       => null
	  , X_ATTRIBUTE12                       => null
	  , X_ATTRIBUTE13                       => null
	  , X_ATTRIBUTE14                       => null
	  , X_ATTRIBUTE15                       => null
	  , X_CHANGE_ORDER_ORGANIZATION_ID      => null
	  , X_ASSEMBLY_TYPE                     => l_assembly_type
	  , X_DISABLE_DATE                      => null
	  , X_ATTRIBUTE_CATEGORY                => null
	  , X_ATTRIBUTE1                        => null
	  , X_ATTRIBUTE2                        => null
	  , X_ATTRIBUTE3                        => null
	  , X_ATTRIBUTE4                        => null
	  , X_ATTRIBUTE5                        => null
	  , X_ATTRIBUTE6                        => null
	  , X_ATTRIBUTE7                        => null
	  , X_TYPE_NAME                         => l_type_name
	  , X_DESCRIPTION                       => l_description
	  , X_TAB_TEXT			        => l_tab_text
	  , X_CREATION_DATE			=> X_CREATION_DATE
          , X_CREATED_BY		        => X_CREATED_BY
	  , X_LAST_UPDATE_DATE                  => X_CREATION_DATE
	  , X_LAST_UPDATED_BY                   => X_CREATED_BY
	  , X_LAST_UPDATE_LOGIN                 => X_LAST_UPDATE_LOGIN
	  , X_ENABLE_ITEM_IN_LOCAL_ORG		=> l_enable_item_in_local_org
          , X_CREATE_BOM_IN_LOCAL_ORG		=> l_create_bom_in_local_org
          , X_SUBJECT_UPDATABLE_FLAG		=> l_subject_updatable_flag);
END DUPLICATE_TYPES;

procedure DUPLICATE_CATEGORY_ENTRIES (
	X_CHANGE_ORDER_TYPE_ID       in  NUMBER,
	X_CREATED_BY                 in  NUMBER,
	X_CREATION_DATE              in  DATE,
	X_LAST_UPDATE_LOGIN          in  NUMBER,
	X_CHANGE_MGMT_TYPE_CODE	     in  VARCHAR2,
	X_BASE_CHANGE_MGMT_TYPE_CODE in  VARCHAR2)
IS

    CURSOR get_applications IS
    SELECT A.APPLICATION_ID
    FROM ENG_CHANGE_TYPE_APPLICATIONS A,
    ENG_CHANGE_ORDER_TYPES C
    WHERE C.CHANGE_ORDER_TYPE_ID = A.CHANGE_TYPE_ID
    AND C.TYPE_CLASSIFICATION = 'CATEGORY'
    AND C.CHANGE_MGMT_TYPE_CODE = X_BASE_CHANGE_MGMT_TYPE_CODE;

    CURSOR get_types IS
    SELECT CHANGE_ORDER_TYPE_ID
    FROM ENG_CHANGE_ORDER_TYPES
    WHERE
    --(TYPE_CLASSIFICATION = 'REVISED_LINE' OR TYPE_CLASSIFICATION = 'LINE')
    --AND SEEDED_FLAG = 'Y'
    TYPE_CLASSIFICATION = 'REVISED_LINE'
    AND CHANGE_MGMT_TYPE_CODE = X_BASE_CHANGE_MGMT_TYPE_CODE;

BEGIN

    -- Copying the entries for ENG_CHANGE_TYPE_APPLICATIONS
    FOR appl IN get_applications
    LOOP
      INSERT INTO ENG_CHANGE_TYPE_APPLICATIONS
      (CHANGE_TYPE_ID,
       APPLICATION_ID,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN) VALUES
      (X_CHANGE_ORDER_TYPE_ID,
       appl.application_id,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_CREATION_DATE,
       X_CREATED_BY,
       X_LAST_UPDATE_LOGIN);
     END LOOP;

     -- Copying the seeded line types
     FOR types IN get_types
     LOOP
       DUPLICATE_TYPES (
	 X_CHANGE_ORDER_TYPE_ID       => types.CHANGE_ORDER_TYPE_ID,
	 X_CREATED_BY                 => X_CREATED_BY,
	 X_CREATION_DATE              => X_CREATION_DATE,
	 X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN,
	 X_CHANGE_MGMT_TYPE_CODE      => X_CHANGE_MGMT_TYPE_CODE,
	 X_SEEDED_FLAG		      => 'N',
	 X_BASE_CHANGE_MGMT_TYPE_CODE => X_BASE_CHANGE_MGMT_TYPE_CODE);
     END LOOP;

     -- Copying the sections and attributes
     DUPLICATE_ATTR_SECT (
       X_CHANGE_ORDER_TYPE_ID      => X_CHANGE_ORDER_TYPE_ID,
       X_CREATED_BY                => X_CREATED_BY,
       X_CREATION_DATE             => X_CREATION_DATE,
       X_TYPE_ID		   => null,
       X_LAST_UPDATE_LOGIN         => X_LAST_UPDATE_LOGIN,
       X_CHANGE_MGMT_TYPE_CODE	   => X_CHANGE_MGMT_TYPE_CODE,
       X_BASE_CHANGE_MGMT_TYPE_CODE => X_BASE_CHANGE_MGMT_TYPE_CODE);

END DUPLICATE_CATEGORY_ENTRIES;


procedure INSERT_ROW (
  X_ROWID in out nocopy  VARCHAR2,
  X_CHANGE_ORDER_TYPE_ID in NUMBER,
  X_CHANGE_MGMT_TYPE_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_DEFAULT_ASSIGNEE_ID in NUMBER,
  X_SUBJECT_ID in NUMBER,
  X_AUTO_NUMBERING_METHOD in VARCHAR2,
  X_DEFAULT_ASSIGNEE_TYPE in VARCHAR2,
  X_TYPE_CLASSIFICATION in VARCHAR2,
  X_CLASS_CODE_DERIVED_FLAG in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_BASE_CHANGE_MGMT_TYPE_CODE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CHANGE_ORDER_ORGANIZATION_ID in NUMBER,
  X_ASSEMBLY_TYPE in NUMBER,
  X_DISABLE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAB_TEXT in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ENABLE_ITEM_IN_LOCAL_ORG in VARCHAR2 DEFAULT NULL,
  X_CREATE_BOM_IN_LOCAL_ORG in VARCHAR2 DEFAULT NULL,
  X_SUBJECT_UPDATABLE_FLAG in VARCHAR2 DEFAULT NULL,
  x_xml_data_source_code IN VARCHAR2 DEFAULT NULL,
  X_TYPE_INTERNAL_NAME  in VARCHAR2 DEFAULT NULL
) is
  cursor C is select ROWID from ENG_CHANGE_ORDER_TYPES
    where CHANGE_ORDER_TYPE_ID = X_CHANGE_ORDER_TYPE_ID
    ;
    l_current_id	NUMBER;
    l_created_by	NUMBER;
    l_creation_date	DATE;
    l_last_update_login	NUMBER;
    l_assembly_type     NUMBER;
    l_change_mgmt_type_code VARCHAR2(30);
    l_base_change_mgmt_type_code VARCHAR2(30);
    l_parent_cat_id	NUMBER;
    l_subject_id	NUMBER := null;
    l_seq_id		NUMBER := null;
    l_auto_method	VARCHAR2(10) := null;
    l_class_code_derived_flag VARCHAR2(1);

begin
  if ( X_ASSEMBLY_TYPE is null)
  then
    l_assembly_type := '2';
  else
    l_assembly_type := X_ASSEMBLY_TYPE;
  end if;

  l_subject_id := X_SUBJECT_ID;
  l_seq_id := X_SEQUENCE_NUMBER;
  l_auto_method := X_AUTO_NUMBERING_METHOD;

  IF (l_auto_method is null)
  THEN
    l_auto_method := 'USR_ENT';
  END IF;

  IF (X_TYPE_CLASSIFICATION = 'CATEGORY')
  THEN
    l_parent_cat_id := X_SUBJECT_ID;
    l_subject_id := null;
  ELSE
    l_parent_cat_id := X_SEQUENCE_NUMBER;
    l_seq_id := null;
    IF (l_subject_id is null)
    THEN
      SELECT subject_id
      INTO l_subject_id
      FROM eng_subject_entities
      WHERE entity_name = 'ENG_CHANGE_MISC'
      AND SUBJECT_LEVEL = 1;
    END IF;
/* This is to default the classification code to Y for all header types created : bug 3686483 */
    l_class_code_derived_flag := X_CLASS_CODE_DERIVED_FLAG;
    IF (X_TYPE_CLASSIFICATION = 'HEADER' AND X_CLASS_CODE_DERIVED_FLAG is null)
    THEN
      l_class_code_derived_flag := 'Y';
    END IF;
  END IF;



  insert into ENG_CHANGE_ORDER_TYPES (
    CHANGE_MGMT_TYPE_CODE,
    START_DATE,
    DEFAULT_ASSIGNEE_ID,
    SUBJECT_ID,
    AUTO_NUMBERING_METHOD,
    DEFAULT_ASSIGNEE_TYPE,
    TYPE_CLASSIFICATION,
    CLASS_CODE_DERIVED_FLAG,
    SEQUENCE_NUMBER,
    BASE_CHANGE_MGMT_TYPE_CODE,
    SEEDED_FLAG,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    CHANGE_ORDER_TYPE_ID,
    CHANGE_ORDER_ORGANIZATION_ID,
    ASSEMBLY_TYPE,
    DISABLE_DATE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ENABLE_ITEM_IN_LOCAL_ORG,
    CREATE_BOM_IN_LOCAL_ORG,
    SUBJECT_UPDATABLE_FLAG,
    XML_DATA_SOURCE_CODE,
    CHANGE_ORDER_TYPE
  ) values (
    X_CHANGE_MGMT_TYPE_CODE,
    X_START_DATE,
    X_DEFAULT_ASSIGNEE_ID,
    l_subject_id,
    l_auto_method,
    X_DEFAULT_ASSIGNEE_TYPE,
    X_TYPE_CLASSIFICATION,
    l_class_code_derived_flag,
    l_seq_id,
    X_BASE_CHANGE_MGMT_TYPE_CODE,
    X_SEEDED_FLAG,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_CHANGE_ORDER_TYPE_ID,
    X_CHANGE_ORDER_ORGANIZATION_ID,
    l_assembly_type,
    X_DISABLE_DATE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_ENABLE_ITEM_IN_LOCAL_ORG ,
    X_CREATE_BOM_IN_LOCAL_ORG ,
    X_SUBJECT_UPDATABLE_FLAG,
    X_XML_DATA_SOURCE_CODE,
    X_TYPE_INTERNAL_NAME
  );

  insert into ENG_CHANGE_ORDER_TYPES_TL (
    CHANGE_ORDER_TYPE_ID,
    TYPE_NAME,
    DESCRIPTION,
    TAB_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_CHANGE_ORDER_TYPE_ID,
    X_TYPE_NAME,
    X_DESCRIPTION,
    X_TAB_TEXT,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from ENG_CHANGE_ORDER_TYPES_TL T
    where T.CHANGE_ORDER_TYPE_ID = X_CHANGE_ORDER_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  IF ((X_TYPE_CLASSIFICATION = 'CATEGORY') AND ( NVL(X_SEEDED_FLAG,'N') <> 'Y'))
  THEN
    IF (l_parent_cat_id is not null)
    THEN

      SELECT CHANGE_MGMT_TYPE_CODE
      INTO l_base_change_mgmt_type_code
      FROM ENG_CHANGE_ORDER_TYPES_VL
      WHERE CHANGE_ORDER_TYPE_ID = l_parent_cat_id;

      DUPLICATE_CATEGORY_ENTRIES (
	X_CHANGE_ORDER_TYPE_ID       => X_CHANGE_ORDER_TYPE_ID,
	X_CREATED_BY                 => X_CREATED_BY,
	X_CREATION_DATE              => X_CREATION_DATE,
	X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN,
	X_CHANGE_MGMT_TYPE_CODE      => X_CHANGE_MGMT_TYPE_CODE,
	X_BASE_CHANGE_MGMT_TYPE_CODE => l_base_change_mgmt_type_code);
    END IF;
  ELSIF ((X_TYPE_CLASSIFICATION = 'HEADER') AND ( NVL(X_SEEDED_FLAG,'N') <> 'Y'))
  THEN
    IF (l_parent_cat_id is not null)
    THEN

      --Making calls to duplicate
      --1. Lifecycles
      --2. Priorities
      --3. Reasons
      --4. Classification Codes
      --5. Configurations (Sections and Attributes)

      DUPLICATE_LIFECYCLES (
	X_CHANGE_ORDER_TYPE_ID       => X_CHANGE_ORDER_TYPE_ID,
        X_PARENT_CHANGE_TYPE_ID      => l_parent_cat_id,
	X_CREATED_BY                 => X_CREATED_BY,
	X_CREATION_DATE              => X_CREATION_DATE,
	X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN);

      DUPLICATE_PRIORITIES(
	X_CHANGE_ORDER_TYPE_ID       => X_CHANGE_ORDER_TYPE_ID,
        X_PARENT_CHANGE_TYPE_ID      => l_parent_cat_id,
	X_CREATED_BY                 => X_CREATED_BY,
	X_CREATION_DATE              => X_CREATION_DATE,
	X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN);

      DUPLICATE_REASONS(
	X_CHANGE_ORDER_TYPE_ID       => X_CHANGE_ORDER_TYPE_ID,
        X_PARENT_CHANGE_TYPE_ID      => l_parent_cat_id,
	X_CREATED_BY                 => X_CREATED_BY,
	X_CREATION_DATE              => X_CREATION_DATE,
	X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN);

      DUPLICATE_CLASSCODES(
	X_CHANGE_ORDER_TYPE_ID       => X_CHANGE_ORDER_TYPE_ID,
        X_PARENT_CHANGE_TYPE_ID      => l_parent_cat_id,
	X_CREATED_BY                 => X_CREATED_BY,
	X_CREATION_DATE              => X_CREATION_DATE,
	X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN);

      DUPLICATE_ATTR_SECT (
       X_CHANGE_ORDER_TYPE_ID      => X_CHANGE_ORDER_TYPE_ID,
       X_CREATED_BY                => X_CREATED_BY,
       X_CREATION_DATE             => X_CREATION_DATE,
       X_TYPE_ID		   => l_parent_cat_id,
       X_LAST_UPDATE_LOGIN         => X_LAST_UPDATE_LOGIN,
       X_CHANGE_MGMT_TYPE_CODE	   => X_CHANGE_MGMT_TYPE_CODE,
       X_BASE_CHANGE_MGMT_TYPE_CODE => X_BASE_CHANGE_MGMT_TYPE_CODE);

    ELSE
      SELECT BASE_CHANGE_MGMT_TYPE_CODE
      INTO l_base_change_mgmt_type_code
      FROM ENG_CHANGE_ORDER_TYPES_VL
      WHERE CHANGE_ORDER_TYPE_ID = X_CHANGE_ORDER_TYPE_ID;

      ADD_DEFAULT_LIFECYCLES (
        X_CHANGE_ORDER_TYPE_ID       => X_CHANGE_ORDER_TYPE_ID,
        X_BASE_CHANGE_MGMT_TYPE      => l_base_change_mgmt_type_code,
	X_CREATED_BY                 => X_CREATED_BY,
	X_CREATION_DATE              => X_CREATION_DATE,
	X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN);

      --Commenting out the lines to default the defaulting of
      --attributes for a type.

      --Bug No: 3439555
      --Issue: DEF-1473
      --Defaulting the following attribute configuration for all types:
      --Change Number
      --ADD_DEFAULT_CONFIGURATIONS (
      --  X_CHANGE_ORDER_TYPE_ID       => X_CHANGE_ORDER_TYPE_ID,
      --  X_CHANGE_MGMT_TYPE_CODE      => X_CHANGE_MGMT_TYPE_CODE,
      --  X_CREATED_BY                 => X_CREATED_BY,
      --  X_CREATION_DATE              => X_CREATION_DATE,
      --  X_LAST_UPDATE_LOGIN          => X_LAST_UPDATE_LOGIN);

    END IF;
  END IF;
end INSERT_ROW;

procedure LOCK_ROW (
  X_CHANGE_ORDER_TYPE_ID in NUMBER,
  X_CHANGE_MGMT_TYPE_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_DEFAULT_ASSIGNEE_ID in NUMBER,
  X_SUBJECT_ID in NUMBER,
  X_AUTO_NUMBERING_METHOD in VARCHAR2,
  X_DEFAULT_ASSIGNEE_TYPE in VARCHAR2,
  X_TYPE_CLASSIFICATION in VARCHAR2,
  X_CLASS_CODE_DERIVED_FLAG in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_BASE_CHANGE_MGMT_TYPE_CODE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CHANGE_ORDER_ORGANIZATION_ID in NUMBER,
  X_ASSEMBLY_TYPE in NUMBER,
  X_DISABLE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAB_TEXT in VARCHAR2,
  X_ENABLE_ITEM_IN_LOCAL_ORG in VARCHAR2 DEFAULT NULL,
  X_CREATE_BOM_IN_LOCAL_ORG in VARCHAR2 DEFAULT NULL,
  X_SUBJECT_UPDATABLE_FLAG in VARCHAR2 DEFAULT NULL,
  x_xml_data_source_code IN varchar2 default NULL,
  X_TYPE_INTERNAL_NAME  in VARCHAR2 DEFAULT NULL
) is
  cursor c is select
      CHANGE_MGMT_TYPE_CODE,
      START_DATE,
      DEFAULT_ASSIGNEE_ID,
      SUBJECT_ID,
      AUTO_NUMBERING_METHOD,
      DEFAULT_ASSIGNEE_TYPE,
      TYPE_CLASSIFICATION,
      CLASS_CODE_DERIVED_FLAG,
      SEQUENCE_NUMBER,
      BASE_CHANGE_MGMT_TYPE_CODE,
      SEEDED_FLAG,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      CHANGE_ORDER_ORGANIZATION_ID,
      ASSEMBLY_TYPE,
      DISABLE_DATE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ENABLE_ITEM_IN_LOCAL_ORG ,
      CREATE_BOM_IN_LOCAL_ORG ,
      SUBJECT_UPDATABLE_FLAG,
	  xml_data_source_code,
      X_TYPE_INTERNAL_NAME
    from ENG_CHANGE_ORDER_TYPES
    where CHANGE_ORDER_TYPE_ID = X_CHANGE_ORDER_TYPE_ID
    for update of CHANGE_ORDER_TYPE_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      TYPE_NAME,
      DESCRIPTION,
      TAB_TEXT,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from ENG_CHANGE_ORDER_TYPES_TL
    where CHANGE_ORDER_TYPE_ID = X_CHANGE_ORDER_TYPE_ID
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of CHANGE_ORDER_TYPE_ID nowait;
begin
  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;

  if (    ((recinfo.CHANGE_MGMT_TYPE_CODE = X_CHANGE_MGMT_TYPE_CODE)
           OR ((recinfo.CHANGE_MGMT_TYPE_CODE is null) AND (X_CHANGE_MGMT_TYPE_CODE is null)))
      AND  ((recinfo.START_DATE = X_START_DATE)
           OR ((recinfo.START_DATE is null) AND (X_START_DATE is null)))
      AND ((recinfo.DEFAULT_ASSIGNEE_ID = X_DEFAULT_ASSIGNEE_ID)
           OR ((recinfo.DEFAULT_ASSIGNEE_ID is null) AND (X_DEFAULT_ASSIGNEE_ID is null)))
      AND ((recinfo.SUBJECT_ID = X_SUBJECT_ID)
           OR ((recinfo.SUBJECT_ID is null) AND (X_SUBJECT_ID is null)))
      AND ((recinfo.AUTO_NUMBERING_METHOD = X_AUTO_NUMBERING_METHOD)
           OR ((recinfo.AUTO_NUMBERING_METHOD is null) AND (X_AUTO_NUMBERING_METHOD is null)))
      AND ((recinfo.DEFAULT_ASSIGNEE_TYPE = X_DEFAULT_ASSIGNEE_TYPE)
           OR ((recinfo.DEFAULT_ASSIGNEE_TYPE is null) AND (X_DEFAULT_ASSIGNEE_TYPE is null)))
      AND ((recinfo.TYPE_CLASSIFICATION = X_TYPE_CLASSIFICATION)
           OR ((recinfo.TYPE_CLASSIFICATION is null) AND (X_TYPE_CLASSIFICATION is null)))
      AND ((recinfo.CLASS_CODE_DERIVED_FLAG = X_CLASS_CODE_DERIVED_FLAG)
           OR ((recinfo.CLASS_CODE_DERIVED_FLAG is null) AND (X_CLASS_CODE_DERIVED_FLAG is null)))
      AND ((recinfo.SEQUENCE_NUMBER = X_SEQUENCE_NUMBER)
           OR ((recinfo.SEQUENCE_NUMBER is null) AND (X_SEQUENCE_NUMBER is null)))
      AND ((recinfo.BASE_CHANGE_MGMT_TYPE_CODE = X_BASE_CHANGE_MGMT_TYPE_CODE)
           OR ((recinfo.BASE_CHANGE_MGMT_TYPE_CODE is null) AND (X_BASE_CHANGE_MGMT_TYPE_CODE is null)))
      AND ((recinfo.SEEDED_FLAG = X_SEEDED_FLAG)
           OR ((recinfo.SEEDED_FLAG is null) AND (X_SEEDED_FLAG is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.CHANGE_ORDER_ORGANIZATION_ID = X_CHANGE_ORDER_ORGANIZATION_ID)
           OR ((recinfo.CHANGE_ORDER_ORGANIZATION_ID is null) AND (X_CHANGE_ORDER_ORGANIZATION_ID is null)))
      AND ((recinfo.ASSEMBLY_TYPE = X_ASSEMBLY_TYPE)
           OR ((recinfo.ASSEMBLY_TYPE is null) AND (X_ASSEMBLY_TYPE is null)))
      AND ((recinfo.DISABLE_DATE = X_DISABLE_DATE)
           OR ((recinfo.DISABLE_DATE is null) AND (X_DISABLE_DATE is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ENABLE_ITEM_IN_LOCAL_ORG = X_ENABLE_ITEM_IN_LOCAL_ORG)
           OR ((recinfo.ENABLE_ITEM_IN_LOCAL_ORG is null) AND (X_ENABLE_ITEM_IN_LOCAL_ORG is null)))
      AND ((recinfo.CREATE_BOM_IN_LOCAL_ORG = X_CREATE_BOM_IN_LOCAL_ORG)
           OR ((recinfo.CREATE_BOM_IN_LOCAL_ORG is null) AND (X_CREATE_BOM_IN_LOCAL_ORG is null)))
      AND ((recinfo.SUBJECT_UPDATABLE_FLAG = X_SUBJECT_UPDATABLE_FLAG)
           OR ((recinfo.SUBJECT_UPDATABLE_FLAG is null) AND (X_SUBJECT_UPDATABLE_FLAG is null)))
  ) then
    null;
  else
       fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.TYPE_NAME = X_TYPE_NAME)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
          AND ((tlinfo.TAB_TEXT = X_TAB_TEXT)
               OR ((tlinfo.TAB_TEXT is null) AND (X_TAB_TEXT is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_CHANGE_ORDER_TYPE_ID in NUMBER,
  X_CHANGE_MGMT_TYPE_CODE in VARCHAR2,
  X_START_DATE in DATE,
  X_DEFAULT_ASSIGNEE_ID in NUMBER,
  X_SUBJECT_ID in NUMBER,
  X_AUTO_NUMBERING_METHOD in VARCHAR2,
  X_DEFAULT_ASSIGNEE_TYPE in VARCHAR2,
  X_TYPE_CLASSIFICATION in VARCHAR2,
  X_CLASS_CODE_DERIVED_FLAG in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_BASE_CHANGE_MGMT_TYPE_CODE in VARCHAR2,
  X_SEEDED_FLAG in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_CHANGE_ORDER_ORGANIZATION_ID in NUMBER,
  X_ASSEMBLY_TYPE in NUMBER,
  X_DISABLE_DATE in DATE,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_TYPE_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TAB_TEXT in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ENABLE_ITEM_IN_LOCAL_ORG in VARCHAR2 DEFAULT NULL,
  X_CREATE_BOM_IN_LOCAL_ORG in VARCHAR2 DEFAULT NULL,
  X_SUBJECT_UPDATABLE_FLAG in VARCHAR2 DEFAULT NULL,
  x_xml_data_source_code IN VARCHAR2 default NULL,
  X_TYPE_INTERNAL_NAME  in VARCHAR2 DEFAULT NULL
) is

   CURSOR c_get_change_order_type IS
   SELECT change_order_type
   FROM ENG_CHANGE_ORDER_TYPES
   WHERE change_order_type_id = X_CHANGE_ORDER_TYPE_ID;

   l_internal_type_name   VARCHAR2(80);
begin

  --Bug No: 4560949
  --When updating a change type, the change_order_Type should get updated
  --only when X_TYPE_INTERNAL_NAME is populated.
  l_internal_type_name := null;
  IF X_TYPE_INTERNAL_NAME IS NULL
  THEN
    FOR l_type_info IN c_get_change_order_type
    LOOP
      l_internal_type_name := l_type_info.change_order_type;
    END LOOP;
  ELSE
    l_internal_type_name := X_TYPE_INTERNAL_NAME;
  END IF;

  update ENG_CHANGE_ORDER_TYPES set
    CHANGE_MGMT_TYPE_CODE = X_CHANGE_MGMT_TYPE_CODE,
    START_DATE = X_START_DATE,
    DEFAULT_ASSIGNEE_ID = X_DEFAULT_ASSIGNEE_ID,
    SUBJECT_ID = X_SUBJECT_ID,
    AUTO_NUMBERING_METHOD = X_AUTO_NUMBERING_METHOD,
    DEFAULT_ASSIGNEE_TYPE = X_DEFAULT_ASSIGNEE_TYPE,
    TYPE_CLASSIFICATION = X_TYPE_CLASSIFICATION,
    CLASS_CODE_DERIVED_FLAG = X_CLASS_CODE_DERIVED_FLAG,
    SEQUENCE_NUMBER = X_SEQUENCE_NUMBER,
    BASE_CHANGE_MGMT_TYPE_CODE = X_BASE_CHANGE_MGMT_TYPE_CODE,
    SEEDED_FLAG = X_SEEDED_FLAG,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    CHANGE_ORDER_ORGANIZATION_ID = X_CHANGE_ORDER_ORGANIZATION_ID,
    ASSEMBLY_TYPE = X_ASSEMBLY_TYPE,
    DISABLE_DATE = X_DISABLE_DATE,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ENABLE_ITEM_IN_LOCAL_ORG = X_ENABLE_ITEM_IN_LOCAL_ORG,
    CREATE_BOM_IN_LOCAL_ORG = X_CREATE_BOM_IN_LOCAL_ORG,
    SUBJECT_UPDATABLE_FLAG = X_SUBJECT_UPDATABLE_FLAG,
    xml_data_source_code = x_xml_data_source_code,
    CHANGE_ORDER_TYPE = l_internal_type_name
  where CHANGE_ORDER_TYPE_ID = X_CHANGE_ORDER_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update ENG_CHANGE_ORDER_TYPES_TL set
    TYPE_NAME = X_TYPE_NAME,
    DESCRIPTION = X_DESCRIPTION,
    TAB_TEXT = X_TAB_TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where CHANGE_ORDER_TYPE_ID = X_CHANGE_ORDER_TYPE_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure DELETE_ROW (
  X_CHANGE_ORDER_TYPE_ID in NUMBER
) is
begin
  delete from ENG_CHANGE_ORDER_TYPES_TL
  where CHANGE_ORDER_TYPE_ID = X_CHANGE_ORDER_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from ENG_CHANGE_ORDER_TYPES
  where CHANGE_ORDER_TYPE_ID = X_CHANGE_ORDER_TYPE_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

procedure ADD_LANGUAGE
is
begin
  delete from ENG_CHANGE_ORDER_TYPES_TL T
  where not exists
    (select NULL
    from ENG_CHANGE_ORDER_TYPES B
    where B.CHANGE_ORDER_TYPE_ID = T.CHANGE_ORDER_TYPE_ID
    );

  update ENG_CHANGE_ORDER_TYPES_TL T set (
      TYPE_NAME,
      DESCRIPTION,
      TAB_TEXT
    ) = (select
      B.TYPE_NAME,
      B.DESCRIPTION,
      B.TAB_TEXT
    from ENG_CHANGE_ORDER_TYPES_TL B
    where B.CHANGE_ORDER_TYPE_ID = T.CHANGE_ORDER_TYPE_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.CHANGE_ORDER_TYPE_ID,
      T.LANGUAGE
  ) in (select
      SUBT.CHANGE_ORDER_TYPE_ID,
      SUBT.LANGUAGE
    from ENG_CHANGE_ORDER_TYPES_TL SUBB, ENG_CHANGE_ORDER_TYPES_TL SUBT
    where SUBB.CHANGE_ORDER_TYPE_ID = SUBT.CHANGE_ORDER_TYPE_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.TYPE_NAME <> SUBT.TYPE_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.TAB_TEXT <> SUBT.TAB_TEXT
      or (SUBB.TAB_TEXT is null and SUBT.TAB_TEXT is not null)
      or (SUBB.TAB_TEXT is not null and SUBT.TAB_TEXT is null)
  ));

  insert into ENG_CHANGE_ORDER_TYPES_TL (
    CHANGE_ORDER_TYPE_ID,
    TYPE_NAME,
    DESCRIPTION,
    TAB_TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.CHANGE_ORDER_TYPE_ID,
    B.TYPE_NAME,
    B.DESCRIPTION,
    B.TAB_TEXT,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from ENG_CHANGE_ORDER_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from ENG_CHANGE_ORDER_TYPES_TL T
    where T.CHANGE_ORDER_TYPE_ID = B.CHANGE_ORDER_TYPE_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

end ENG_CHANGE_ORDER_TYPES_PKG;

/
