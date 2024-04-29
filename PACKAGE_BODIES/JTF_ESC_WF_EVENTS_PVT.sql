--------------------------------------------------------
--  DDL for Package Body JTF_ESC_WF_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_ESC_WF_EVENTS_PVT" AS
/* $Header: jtfecbeb.pls 115.7 2004/02/13 10:58:16 nselvam noship $ */
  --Created for Esc BES enh 2660883
  PROCEDURE publish_create_esc (
       P_ESC_REC	       IN      jtf_ec_pvt.Esc_Rec_type
  )
  IS
   l_list		    WF_PARAMETER_LIST_T;
   l_key		    varchar2(240);
   l_event_name 	    varchar2(240) := 'oracle.apps.jtf.cac.escalation.createEscalation';
   l_esc_record 	    jtf_ec_pvt.Esc_Rec_type := p_esc_rec;

  BEGIN
    savepoint cr_esc_publish_save;
    --Get the item key
	l_list := NULL;
    l_key := get_item_key(l_event_name);
    Compare_and_set_attr_to_list('TASK_ID', NULL, l_esc_record.escalation_id,'C', l_list,'N');

    -- Raise the create esc event
    wf_event.raise(
		   p_event_name        => l_event_name
		   ,p_event_key 	=> l_key
		   ,p_parameters	=> l_list
		  );
    l_list.DELETE;
    EXCEPTION when OTHERS then
    ROLLBACK TO cr_esc_publish_save;
  END publish_create_esc;



  PROCEDURE publish_update_esc
  (
       P_ESC_REC	       IN      jtf_ec_pvt.Esc_Rec_type
  ) IS
   l_list			WF_PARAMETER_LIST_T;
   l_key			varchar2(240);
   l_event_name 		varchar2(240);
   l_esc_record 		jtf_ec_pvt.Esc_Rec_type := p_esc_rec;

 BEGIN
    savepoint upd_esc_publish_save;
	l_list := NULL;
       l_event_name := 'oracle.apps.jtf.cac.escalation.updateEscalation';
       l_key := get_item_key(l_event_name);
	Compare_and_set_attr_to_list('TASK_ID',NULL,l_esc_record.escalation_id, 'U', l_list,'N');
	Compare_and_set_attr_to_list('TASK_AUDIT_ID',NULL,l_esc_record.task_audit_id, 'U', l_list);
       -- Raise the update esc Event
       wf_event.raise(
		      p_event_name	  => l_event_name
		     ,p_event_key	  => l_key
		     ,p_parameters	  => l_list
		     );
       l_list.DELETE;
    EXCEPTION when OTHERS then
    ROLLBACK TO upd_esc_publish_save;
 END publish_update_esc;



  PROCEDURE publish_delete_esc (
       P_ESC_REC	       IN      jtf_ec_pvt.Esc_Rec_type
  )
  IS
   l_list		WF_PARAMETER_LIST_T;
   l_key		varchar2(240);
   l_event_name 	varchar2(240) := 'oracle.apps.jtf.cac.escalation.deleteEscalation';
   l_esc_record 	   jtf_ec_pvt.Esc_Rec_type := p_esc_rec;
 BEGIN
    savepoint del_esc_publish_save;
	l_list := NULL;
    --Get the item key
    l_key := get_item_key(l_event_name);
    Compare_and_set_attr_to_list('TASK_ID', l_esc_record.escalation_id, NULL, 'D',l_list,'N');
    -- Raise delete esc Event
    wf_event.raise(
		   p_event_name        => l_event_name
		  ,p_event_key	       => l_key
		  ,p_parameters        => l_list
		  );
    l_list.DELETE;
    EXCEPTION when OTHERS then
       ROLLBACK TO del_esc_publish_save;
 END publish_delete_esc;



 PROCEDURE publish_create_escref (
       P_ESC_REF_REC		   IN	   Jtf_ec_references_pvt.Esc_ref_Rec
  )
  IS
    l_list	    WF_PARAMETER_LIST_T;
    l_key     VARCHAR2(240);
    l_event_name    VARCHAR2(240) := 'oracle.apps.jtf.cac.escalation.createEscReference';
    l_esc_ref_record		Jtf_ec_references_pvt.Esc_ref_Rec := p_esc_ref_rec;

  BEGIN
    l_list := NULL;
    l_key := get_item_key(l_event_name);

    Compare_and_set_attr_to_list('TASK_REFERENCE_ID', NULL, l_esc_ref_record.task_reference_id,'C',l_list,'N');
    Compare_and_set_attr_to_list('OBJECT_TYPE_CODE', NULL, l_esc_ref_record.object_type_code,'C',l_list);
    Compare_and_set_attr_to_list('REFERENCE_CODE', NULL, l_esc_ref_record.reference_code,'C',l_list);
    Compare_and_set_attr_to_list('OBJECT_ID',NULL ,l_esc_ref_record.object_id,'C',l_list);
-- Added for Bug # 3385990
    Compare_and_set_attr_to_list('TASK_ID',NULL ,l_esc_ref_record.task_id,'C',l_list,'N');


	wf_event.raise (
		 p_event_name => l_event_name,
		 p_event_key => l_key,
		 p_parameters => l_list
    );

	l_list.DELETE;
  END publish_create_escref;


  PROCEDURE publish_update_escref (
       P_ESC_REF_REC_OLD	       IN      Jtf_ec_references_pvt.Esc_ref_Rec,
       P_ESC_REF_REC_NEW	       IN      Jtf_ec_references_pvt.Esc_ref_Rec
  )
  IS
    l_list   WF_PARAMETER_LIST_T;
    l_key    VARCHAR2(240);
	l_event_name   VARCHAR2(240) := 'oracle.apps.jtf.cac.escalation.updateEscReference';
  BEGIN
    l_key := get_item_key(l_event_name);

    Compare_and_set_attr_to_list('TASK_REFERENCE_ID', P_ESC_REF_REC_OLD.task_reference_id, P_ESC_REF_REC_NEW.task_reference_id, 'U', l_list,'N');
    Compare_and_set_attr_to_list('OBJECT_TYPE_CODE', P_ESC_REF_REC_OLD.object_type_code,P_ESC_REF_REC_NEW.object_type_code,'U',l_list);
    Compare_and_set_attr_to_list('REFERENCE_CODE',P_ESC_REF_REC_OLD.reference_code,P_ESC_REF_REC_NEW.reference_code,'U',l_list);
    Compare_and_set_attr_to_list('OBJECT_ID',P_ESC_REF_REC_OLD.object_id,P_ESC_REF_REC_NEW.object_id,'U',l_list);
-- Added for Bug # 3385990
    Compare_and_set_attr_to_list('TASK_ID',P_ESC_REF_REC_OLD.task_id ,P_ESC_REF_REC_NEW.task_id,'U',l_list, 'N');

	wf_event.raise (
		 p_event_name => l_event_name,
		 p_event_key => l_key,
		 p_parameters => l_list
    );
	l_list.DELETE;
  END publish_update_escref;

  PROCEDURE publish_delete_escref (
       P_ESC_REF_REC		   IN	   Jtf_ec_references_pvt.Esc_ref_Rec
  )
  IS
   l_list		    WF_PARAMETER_LIST_T;
   l_key	  varchar2(240);
   l_event_name 	varchar2(240) := 'oracle.apps.jtf.cac.escalation.deleteEscReference';
 BEGIN
    l_key := get_item_key(l_event_name);

-- Code Changes in sync with Task BES API - Swapped OLD and NEW values

    Compare_and_set_attr_to_list('TASK_REFERENCE_ID', P_ESC_REF_REC.task_reference_id, NULL, 'D',l_list,'N');
    Compare_and_set_attr_to_list('OBJECT_TYPE_CODE', P_ESC_REF_REC.object_type_code, NULL, 'D',l_list,'N');
    Compare_and_set_attr_to_list('REFERENCE_CODE', P_ESC_REF_REC.reference_code, NULL, 'D',l_list,'N');
    Compare_and_set_attr_to_list('OBJECT_ID', P_ESC_REF_REC.object_id, NULL, 'D',l_list,'N');
-- Added for Bug # 3385990
    Compare_and_set_attr_to_list('TASK_ID', P_ESC_REF_REC.task_id, NULL, 'D',l_list,'N');

-- End Changes

    wf_event.raise(
		   p_event_name        => l_event_name
		  ,p_event_key	       => l_key
		  ,p_parameters        => l_list
		  );
    l_list.DELETE;
 END publish_delete_escref;
--End Esc BES enh 2660883



  FUNCTION get_item_key(p_event_name IN VARCHAR2)
  RETURN VARCHAR2
  IS
  l_key varchar2(240);
  BEGIN
	SELECT p_event_name ||'-'|| jtf_ec_wf_events_s.nextval INTO l_key FROM DUAL;
	RETURN l_key;
  END get_item_key;

  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN VARCHAR2,
    P_NEW_VALUE IN VARCHAR2,
    P_ACTION	IN VARCHAR2,
    P_LIST	IN OUT NOCOPY WF_PARAMETER_LIST_T,
    PUBLISH_IF_CHANGE  IN VARCHAR2 DEFAULT 'Y'
  )
  IS
  BEGIN

-- New code updated as per Task BES API jtftkbeb.pls
     IF    (P_ACTION = 'C')
         THEN
                    IF (P_NEW_VALUE IS NOT NULL)
                        THEN
                  wf_event.addparametertolist (P_ATTRIBUTE_NAME, P_NEW_VALUE, P_LIST);
                        END IF;
     ELSIF (P_ACTION = 'U')
         THEN
                    IF (PUBLISH_IF_CHANGE = 'N')
                        THEN
                            wf_event.addparametertolist (P_ATTRIBUTE_NAME, P_NEW_VALUE, P_LIST);
                        ELSE IF (PUBLISH_IF_CHANGE = 'Y') AND ((P_NEW_VALUE IS NULL) OR (P_OLD_VALUE IS NULL) OR  (P_NEW_VALUE <> P_OLD_VALUE))
			     THEN
				   wf_event.addparametertolist ('NEW_'||P_ATTRIBUTE_NAME, P_NEW_VALUE, P_LIST);
                                           wf_event.addparametertolist ('OLD_'||P_ATTRIBUTE_NAME, P_OLD_VALUE, P_LIST);
                 ELSE IF (PUBLISH_IF_CHANGE = 'Y') AND (P_NEW_VALUE IS NOT NULL) AND (P_OLD_VALUE IS NOT NULL)
                                          AND (P_NEW_VALUE = P_OLD_VALUE)
                                           THEN
                                                     wf_event.addparametertolist (P_ATTRIBUTE_NAME, P_NEW_VALUE, P_LIST);
                                      END IF;
                             END IF;
                        END IF;
     ELSIF (P_ACTION = 'D')
         THEN
                    IF (P_OLD_VALUE IS NOT NULL)
                        THEN
                   wf_event.addparametertolist (P_ATTRIBUTE_NAME, P_OLD_VALUE, P_LIST);
                    END IF;
         END IF;
-- End Add

/*     IF    (P_ACTION = 'C')
	 THEN
		    IF (P_NEW_VALUE IS NOT NULL)
			THEN
		  wf_event.addparametertolist (P_ATTRIBUTE_NAME, P_NEW_VALUE, P_LIST);
			END IF;
     ELSIF (P_ACTION = 'U')
	 THEN
		    IF (PUBLISH_IF_CHANGE = 'N')
			THEN
			    wf_event.addparametertolist (P_ATTRIBUTE_NAME, P_NEW_VALUE, P_LIST);
			ELSE IF (P_NEW_VALUE <> P_OLD_VALUE) AND (PUBLISH_IF_CHANGE = 'Y')
			     THEN
				   wf_event.addparametertolist ('NEW_'||P_ATTRIBUTE_NAME, P_NEW_VALUE, P_LIST);
					   wf_event.addparametertolist ('OLD_'||P_ATTRIBUTE_NAME, P_OLD_VALUE, P_LIST);
			     END IF;
			END IF;
     ELSIF (P_ACTION = 'D')
	 THEN
		    IF (P_OLD_VALUE IS NOT NULL)
			THEN
		   wf_event.addparametertolist (P_ATTRIBUTE_NAME, P_OLD_VALUE, P_LIST);
		    END IF;
	 END IF; */

  END;
  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN NUMBER,
    P_NEW_VALUE IN NUMBER,
    P_ACTION	IN VARCHAR2,
    P_LIST	IN OUT NOCOPY WF_PARAMETER_LIST_T,
	PUBLISH_IF_CHANGE    IN VARCHAR2 DEFAULT 'Y'
  )
  IS
  BEGIN
     compare_and_set_attr_to_list(P_ATTRIBUTE_NAME,to_char(P_OLD_VALUE),to_char(P_NEW_VALUE),
				      P_ACTION,P_LIST,PUBLISH_IF_CHANGE);
  END;
  PROCEDURE compare_and_set_attr_to_list (
    P_ATTRIBUTE_NAME IN VARCHAR2,
    P_OLD_VALUE IN DATE,
    P_NEW_VALUE IN DATE,
    P_ACTION	IN VARCHAR2,
    P_LIST	IN OUT NOCOPY WF_PARAMETER_LIST_T,
	PUBLISH_IF_CHANGE    IN VARCHAR2 DEFAULT 'Y'
  )
  IS
  BEGIN
     compare_and_set_attr_to_list(P_ATTRIBUTE_NAME,to_char(P_OLD_VALUE,'YYYY-MM-DD HH24:MI:SS'),to_char(P_NEW_VALUE,'YYYY-MM-DD HH24:MI:SS'),
				      P_ACTION,P_LIST,PUBLISH_IF_CHANGE);
  END;



END;

/
