--------------------------------------------------------
--  DDL for Package Body OKC_DELIVERABLE_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_DELIVERABLE_PROCESS_PVT" AS
/* $Header: OKCVDPRB.pls 120.11.12010000.12 2012/11/27 07:35:56 skavutha ship $ */

  ---------------------------------------------------------------------------
  -- package variables
  ---------------------------------------------------------------------------
    g_module          CONSTANT VARCHAR2(250) := 'okc.plsql.'||g_pkg_name||'.';
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  TYPE VerifiedEventsTbl IS TABLE OF OKC_BUS_DOC_EVENTS_B.bus_doc_event_id%TYPE
  INDEX BY BINARY_INTEGER;

  verifiedListOfEvents VerifiedEventsTbl;
  evtCount PLS_INTEGER := 0;

 /**
  * Bug 5143307, Helper function to check if deliverable copy allowed on the target doc type
  */
 FUNCTION copy_allowed(p_deliverable_type IN VARCHAR2,
                       p_target_doc_type IN VARCHAR2,
                       p_target_contractual_doc_type IN VARCHAR2)
 RETURN BOOLEAN
 IS

  CURSOR C_delTypeExists (x_deliverable_type VARCHAR2,
                x_doc_type VARCHAR2) is
    SELECT 'X'
    FROM
    okc_bus_doc_types_b doctyp,
    okc_del_bus_doc_combxns deltypcomb
    WHERE
    doctyp.document_type_class = deltypcomb.document_type_class
    AND doctyp.document_type = x_doc_type
    AND deltypcomb.deliverable_type_code = x_deliverable_type;

    l_api_name CONSTANT VARCHAR2(30) :='copy_allowed';
    l_return_value BOOLEAN := FALSE;

    C_delTypeExists_rec  C_delTypeExists%ROWTYPE;
 BEGIN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.copy_allowed (OVERLOADED) ');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'101: p_deliverable_type = '||p_deliverable_type);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'102: p_target_doc_type = '||p_target_doc_type);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'103: p_target_contractual_doc_type = '||p_target_contractual_doc_type);
  END IF;

    IF p_deliverable_type is null OR p_target_doc_type is null THEN
        return l_return_value;
    END IF;

    -- first check if deliverable type is valid for the target document type
    OPEN C_delTypeExists (p_deliverable_type, p_target_doc_type);
        FETCH C_delTypeExists into C_delTypeExists_rec;

    IF C_delTypeExists%FOUND THEN
    l_return_value := TRUE;
  ELSE
      IF C_delTypeExists%ISOPEN THEN
       CLOSE C_delTypeExists;
      END IF;

      -- check if deliverable type is valid for the target contractual document type
      OPEN C_delTypeExists (p_deliverable_type, p_target_contractual_doc_type);
          FETCH C_delTypeExists into C_delTypeExists_rec;

    IF C_delTypeExists%FOUND THEN
      l_return_value := TRUE;
    ELSE
      l_return_value := FALSE;
    END IF;
    END IF; -- IF C_delTypeExists%FOUND

    IF C_delTypeExists%ISOPEN THEN
     CLOSE C_delTypeExists;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'104: Returning l_return_value =  ');
    END IF;
    return l_return_value;

  EXCEPTION
   WHEN OTHERS THEN
     IF C_delTypeExists%ISOPEN THEN
     CLOSE C_delTypeExists;
     END IF;
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                         ,'106: IN EXCEPTION '||substr(sqlerrm,1,200));
     END IF;

    return l_return_value;

 END copy_allowed;

 /**
  * Bug 5143307, Helper function to check if mapping of events required for the given deliverable
  * type and on the target doc type
  */
 FUNCTION event_mapping_allowed(p_deliverable_type IN VARCHAR2,
                                p_target_doc_type IN VARCHAR2)
            RETURN BOOLEAN
  IS

   CURSOR C_delTypeExists (x_deliverable_type VARCHAR2,
                           x_doc_type VARCHAR2) is
    SELECT 'X'
    FROM
     okc_bus_doc_types_b doctyp,
     okc_del_bus_doc_combxns deltypcomb
     WHERE
     doctyp.document_type_class = deltypcomb.document_type_class
     AND doctyp.document_type = x_doc_type
     AND deltypcomb.deliverable_type_code = x_deliverable_type;

     l_api_name CONSTANT VARCHAR2(30) :='event_mapping_allowed';
     l_return_value BOOLEAN := FALSE;

      C_delTypeExists_rec  C_delTypeExists%ROWTYPE;
  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.event_mapping_allowed ');
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                         ,'101: p_deliverable_type = '||p_deliverable_type);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                         ,'102: p_target_doc_type = '||p_target_doc_type);
  END IF;

     IF p_deliverable_type is null OR p_target_doc_type is null THEN
         return l_return_value;
     END IF;

     -- check if deliverable type exists for the target document type
     OPEN C_delTypeExists (p_deliverable_type, p_target_doc_type);
         FETCH C_delTypeExists into C_delTypeExists_rec;

     IF C_delTypeExists%FOUND THEN
    l_return_value := TRUE;
     ELSE
    l_return_value := FALSE;
     END IF; -- IF C_delTypeExists%FOUND

     IF C_delTypeExists%ISOPEN THEN
       CLOSE C_delTypeExists;
     END IF;

     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                         ,'104: Returning l_return_value =  ');
     END IF;
     return l_return_value;

   EXCEPTION
    WHEN OTHERS THEN
      IF C_delTypeExists%ISOPEN THEN
       CLOSE C_delTypeExists;
      END IF;
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                          ,'106: IN EXCEPTION '||substr(sqlerrm,1,200));
      END IF;

     return l_return_value;

 END event_mapping_allowed;

 /**
  * Bug 5143307, Helper function to resolve target doc event id (start or end)
  * for the given source doc event id
  */
 FUNCTION resolveTargetDocEvent(p_source_event_id IN NUMBER,
                                p_target_doc_type IN VARCHAR2) return NUMBER IS

  CURSOR C_sourceEventCode (x_sourceEventId NUMBER) is
  select business_event_code, before_after
  from  okc_bus_doc_events_b
  where bus_doc_event_id = x_sourceEventId;

  CURSOR C_targetEventId (x_sourceEventCode VARCHAR2,
                          x_targetBusDocType VARCHAR2,
                          x_sourceBeforeAfter VARCHAR2) is
  select bus_doc_event_id
  from  okc_bus_doc_events_b
  where business_event_code = x_sourceEventCode
  and bus_doc_type = x_targetBusDocType
  and before_after = x_sourceBeforeAfter;

  CURSOR C_targetEventId2 (x_sourceEventCode VARCHAR2,
                           x_targetBusDocType VARCHAR2,
                           x_sourceBeforeAfter VARCHAR2) is
  select bus_doc_event_id
  from  okc_bus_doc_events_b
  where business_event_code = x_sourceEventCode
  and before_after = x_sourceBeforeAfter
  and bus_doc_type in (select target_response_doc_type from okc_bus_doc_types_b
                       where document_type = x_targetBusDocType);

  l_api_name  CONSTANT VARCHAR2(30) :='resolveTargetDocEvent';
  l_source_event_code okc_bus_doc_events_b.business_event_code%TYPE:=null;
  l_source_before_after okc_bus_doc_events_b.before_after%TYPE:=null;
  l_target_event_id okc_bus_doc_events_b.bus_doc_event_id%TYPE:=null;

 Begin
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'100: Inside FUNCTION: resolveTargetDocEvent');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'101: p_source_event_id = '||p_source_event_id);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'102: p_target_doc_type = '||p_target_doc_type);
    END IF;

    IF p_source_event_id is null OR p_target_doc_type is null THEN
        return null;
    END IF;

    -- get current source event code for the given event id
    OPEN C_sourceEventCode (p_source_event_id);
        FETCH C_sourceEventCode into l_source_event_code,l_source_before_after;
    CLOSE C_sourceEventCode;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'103: Found l_source_event_code =  '||l_source_event_code);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'103a: Found l_source_before_after =  '||l_source_before_after);
    END IF;

    IF l_source_event_code is not null AND l_source_before_after is not null THEN
        -- get target event id for the given source event code and target bus doc type
        OPEN C_targetEventId (l_source_event_code, p_target_doc_type, l_source_before_after);
            FETCH C_targetEventId into l_target_event_id;
        CLOSE C_targetEventId;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                            ,'104: Found l_target_event_id =  '||l_target_event_id);
        END IF;

        -- l_target_event_id is not resolved, it may be the case, p_target_doc_type
        -- is a response doc type (AUCTION_RESPONSE, RFQ_RESPONSE, RFI_RESPONSE)
        IF l_target_event_id is null THEN
            -- get target event id for the given source event code and target
            -- response doc type fetched from okc_bus_doc_types_b where doc_type
            -- is p_target_doc_type
            OPEN C_targetEventId2 (l_source_event_code, p_target_doc_type, l_source_before_after);
                FETCH C_targetEventId2 into l_target_event_id;
            CLOSE C_targetEventId2;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                                ,'105: Found l_target_event_id (RESPONSE DOC) =  '||l_target_event_id);
            END IF;
        END IF; -- IF l_target_event_id is null
    END IF; -- IF l_source_event_code is not null

    return l_target_event_id;
  EXCEPTION
   WHEN OTHERS THEN
     IF C_sourceEventCode%ISOPEN THEN
     CLOSE C_sourceEventCode;
     END IF;
     IF C_targetEventId%ISOPEN THEN
     CLOSE C_targetEventId;
     END IF;
     IF C_targetEventId2%ISOPEN THEN
     CLOSE C_targetEventId2;
     END IF;
     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                         ,'106: IN EXCEPTION '||substr(sqlerrm,1,200));
     END IF;

    return l_target_event_id;
 END resolveTargetDocEvent;

 /**
  * Helper method to return the Document Type Class for a given Business Document Type
  *
  */

 Function getDocTypeClass(p_bus_doctype IN VARCHAR2) return VARCHAR2 IS
  cursor getDocClass is
  select document_type_class
  from okc_bus_doc_types_b
  where document_type = p_bus_doctype;

  l_doc_type_class OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE_CLASS%TYPE;

 Begin
  OPEN getDocClass;
  FETCH getDocClass into l_doc_type_class;
    If getDocClass%NOTFOUND then
    l_doc_type_class := NULL;
    End If;
  CLOSE getDocClass;
   return l_doc_type_class;
  EXCEPTION
   WHEN OTHERS THEN
     If getDocClass%ISOPEN then
     CLOSE getDocClass;
     End If;
     l_doc_type_class := NULL;
     return l_doc_type_class;

 End getDocTypeClass;

/**
 * Helper Function to return all the attributes of a given Business Document Type
 *
 */
 Function getBusDocTypeInfo(p_bus_doc_type IN VARCHAR2) RETURN BUSDOCTYPE_REC_TYPE IS

  l_bus_doc_type_rec BUSDOCTYPE_REC_TYPE;
  CURSOR getBusDocTypeInfo IS
  select
   document_type_class
  ,intent
  from
  okc_bus_doc_types_b
  where document_type = p_bus_doc_type;

 Begin
  OPEN getBusDocTypeInfo;
  FETCH getBusDocTypeInfo into
   l_bus_doc_type_rec.document_type_class
  ,l_bus_doc_type_rec.document_type_intent;
    If getBusDocTypeInfo%NOTFOUND then
     l_bus_doc_type_rec.document_type_class := NULL;
  l_bus_doc_type_rec.document_type_intent := NULL;
    End If;
  CLOSE getBusDocTypeInfo;

     RETURN l_bus_doc_type_rec;

  EXCEPTION
   WHEN OTHERS THEN
    If getBusDocTypeInfo%ISOPEN then
      CLOSE getBusDocTypeInfo;
    End If;
    RETURN l_bus_doc_type_rec;

 End getBusDocTypeInfo;

/**
  * Helper method to return the Internal_flag for a given Deliverable_type and a given document type class
  */
   Function getDelTypeIntFlag(p_document_type_class IN VARCHAR2,
                              p_deliverable_type IN VARCHAR2) RETURN VARCHAR2 IS
    -- updated cursor for bug#4069955
   CURSOR getDelTypeIntFlag IS
   select delTyp.internal_flag
   from okc_deliverable_types_b delTyp,
   okc_del_bus_doc_combxns delComb
   where delTyp.deliverable_type_code = p_deliverable_type
   and delComb.deliverable_type_code = delTyp.deliverable_type_code
   and delComb.document_type_class = p_document_type_class;


   l_del_type_int_flag     OKC_DELIVERABLE_TYPES_B.INTERNAL_FLAG%TYPE;

   Begin
    OPEN getDelTypeIntFlag;
    FETCH getDelTypeIntFlag into l_del_type_int_flag;
    If getDelTypeIntFlag%NOTFOUND then
      l_del_type_int_flag := NULL;
    End If;
    CLOSE getDelTypeIntFlag;
      return l_del_type_int_flag;
   EXCEPTION
       WHEN OTHERS THEN
      If getDelTypeIntFlag%ISOPEN then
         close getDelTypeIntFlag;
      End If;
      l_del_type_int_flag := NULL;
         return l_del_type_int_flag;
   End getDelTypeIntFlag;

   /**
    * Helper method to return Event Code and Before After value for given
    * event id, stored in OKC_DELIVERABLES
    */
   PROCEDURE getDelEventDetails(
    p_event_id IN NUMBER,
    p_end_event_yn IN varchar2,
    x_event_name OUT NOCOPY VARCHAR2,
    x_event_full_name OUT NOCOPY VARCHAR2)
    IS
    l_api_name        CONSTANT VARCHAR2(30) := 'getDelEventDetails';

    BEGIN
           SELECT business_event_code, event_name into x_event_name, x_event_full_name
           FROM OKC_BUS_DOC_EVENTS_V
           WHERE bus_doc_event_id = p_event_id;
    EXCEPTION
        WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Leaving '||G_PKG_NAME ||'.'||l_api_name);
        END IF;
      Okc_Api.Set_Message(G_APP_NAME,
                        'OKC_DEL_ERR_EVT_DTLS');
        RAISE FND_API.G_EXC_ERROR;

  END;

/*    FUNCTION isQaMessageAlreadyExist(p_event_id NUMBER,
                                     p_list_events_tbl VerifiedEventsTbl)
    RETURN VARCHAR2
    IS
    BEGIN

      IF p_list_events_tbl.count > 0 THEN
         FOR k IN
             p_list_events_tbl.FIRST..p_list_events_tbl.LAST LOOP

             IF p_event_id = p_list_events_tbl(k) THEN
                return 'Y';
             END IF;
         END LOOP;
      END IF;

      return 'N';
    END isQaMessageAlreadyExist; */

    /**
     * Resolve date, for given event id and event codes/dates from table of records
     */
    FUNCTION resolveRelativeDueEvents(
                            p_bus_doc_date_events_tbl   IN OKC_TERMS_QA_GRP.BUSDOCDATES_TBL_TYPE,
                            p_event_id IN NUMBER,
                            p_end_event_yn IN VARCHAR2,
                            px_event_full_name OUT NOCOPY VARCHAR2,
                            px_not_matched_flag OUT NOCOPY VARCHAR2,
                            px_event_code OUT NOCOPY VARCHAR2)
    return DATE
    IS
         l_api_name CONSTANT VARCHAR2(30) := 'resolveRelativeDueEvents';
         l_del_event_name OKC_BUS_DOC_EVENTS_B.business_event_code%TYPE;
         l_event_full_name OKC_BUS_DOC_EVENTS_TL.meaning%TYPE := null;
         l_actual_date DATE := NULL;
         l_not_matched_flag varchar2(1) := 'Y';

    BEGIN

      -- start procedure
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Entered '||G_PKG_NAME ||'.'||l_api_name);
      END IF;
      IF p_event_id is NULL THEN
           Okc_Api.Set_Message(G_APP_NAME,
                          'OKC_DEL_NOT_RSLV_EVTS');
           RAISE FND_API.G_EXC_ERROR;

      END IF;

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: Calling getDelEventDetails');
          END IF;

          --- get current deliverable's end event details
          getDelEventDetails(
               p_event_id => p_event_id,
               p_end_event_yn => p_end_event_yn,
               x_event_name => l_del_event_name,
               x_event_full_name => l_event_full_name);

          px_event_full_name := l_event_full_name;
          px_event_code := l_del_event_name;

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: Finished getDelEventDetails - Event Name'||l_del_event_name);
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'102: Finished getDelEventDetails - Before After'||l_event_full_name);
          END IF;

          --- if relative, check for event name with the given event names
          --- in table of records.
          IF p_bus_doc_date_events_tbl.count <> 0 THEN
             FOR k IN
                 p_bus_doc_date_events_tbl.FIRST..p_bus_doc_date_events_tbl.LAST LOOP
                 IF p_bus_doc_date_events_tbl(k).event_code = l_del_event_name THEN

                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'103: Event Matched '||l_del_event_name);
                    END IF;

                    --- set the flag, that event is matched
                    l_not_matched_flag := 'N';

                    --- Calculate actual date
                    l_actual_date := p_bus_doc_date_events_tbl(k).event_date;
                  END IF;
             END LOOP;
      END IF;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'104: Returning Resolved Date as '||l_actual_date);
      END IF;
        px_not_matched_flag := l_not_matched_flag;
  return l_actual_date;

    END; --- resolveRelativeDueEvents


    -- This function checks if the given deliverable has an attachment
    FUNCTION attachment_exists(
    p_entity_name IN VARCHAR2
    ,p_pk1_value    IN VARCHAR2
    ) RETURN BOOLEAN
    IS
    CURSOR att_cur IS
    SELECT 'X'
    FROM fnd_attached_documents
    WHERE entity_name = p_entity_name
    AND pk1_value  =  p_pk1_value;

    att_rec  att_cur%ROWTYPE;
    l_return_value BOOLEAN := FALSE;
    l_api_name VARCHAR2(30) := 'attachment_exists';

    BEGIN

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.attachment_exists ');
            END IF;
            OPEN att_cur;
            FETCH att_cur INTO att_rec;
            IF att_cur%FOUND THEN
                l_return_value := TRUE;
            ELSE
                l_return_value := FALSE;
            END IF;
            CLOSE att_cur;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: Leaving attachment_exists ');
            END IF;

      RETURN l_return_value;

    EXCEPTION
    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'102: Leaving attachment_exists with Exception');
        END IF;
        IF att_cur %ISOPEN THEN
          CLOSE att_cur ;
        END IF;
          RETURN l_return_value;
    END attachment_exists;

    /*** This API is invoked from OKC_TERMS_PVT.COPY_TC.
    This API copies deliverables from one busdoc to another
    of same type. Used in Sourcing amendment process.
    1.  Verify if the source and target business documents
    are of same Class. If Not, raise error.
    2.  The procedure will query deliverables from source
    business document WHERE amendment_operation is NOT 'DELETE'.
    (The reson of this check: In case of RFQ, amendments operation
    and descriptions are maintained in the current copy,
    hence all deletes are just soft deletes.
    So the copy procedure should not copy deliverables which
    were deleted from the RFQ during amendment).
    3.  Create instances of deliverables for p_target_doc_id
    and p_target_doc_type, definition  copied from
    p_source_doc_id and p_source_doc_type.
    Carry forward original deliverable id. Copy attachments.
    ***/
    PROCEDURE copy_del_for_amendment (
    p_api_version           IN NUMBER,
    p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
    p_source_doc_id         IN NUMBER,
    p_source_doc_type       IN VARCHAR2,
    p_target_doc_id         IN NUMBER,
    p_target_doc_type       IN VARCHAR2,
    p_target_doc_number     IN VARCHAR2,
    p_reset_fixed_date_yn   IN VARCHAR2 ,
    x_msg_data              OUT NOCOPY VARCHAR2,
    x_msg_count             OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY VARCHAR2,
    p_copy_del_attachments_yn   IN VARCHAR2 default 'Y',
    p_target_contractual_doctype  IN  Varchar2 default null)
    IS

    -- used '*' in place of column list because the datastructure
    -- declared as table%ROWTYPE is structured based on column positions
    -- in the database. When the cursor is selected into the datastructure
    -- there is a mismatch.
    CURSOR del_cur IS
    SELECT *
    FROM OKC_DELIVERABLES
    WHERE business_document_id = p_source_doc_id
    AND   business_document_type = p_source_doc_type
    AND   NVL(amendment_operation,'NONE') <> 'DELETED'
    AND   manage_yn = 'N'
    AND   recurring_del_parent_id is null;
    del_rec  del_cur%ROWTYPE;


    CURSOR del_ins_cur(x NUMBER) IS
    SELECT *
    FROM okc_deliverables a
    WHERE business_document_id = p_source_doc_id
    AND   business_document_type = p_source_doc_type
    AND   recurring_del_parent_id = x;
    del_ins_rec   del_ins_cur%ROWTYPE;

    delRecTab       delRecTabType;
    delInsTab       delRecTabType;
    delNewTab       delRecTabType;
    l_api_name      CONSTANT VARCHAR2(30) :='copy_del_for_amendment';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_deliverable_id NUMBER;
   l_from_pk1_value   VARCHAR2(100);
   l_result            BOOLEAN;
   l_copy_attachments  VARCHAR2(1);
   k PLS_INTEGER := 0;
   m PLS_INTEGER := 0;
   j PLS_INTEGER := 0;
   q PLS_INTEGER := 0;
    TYPE delIdRecType IS RECORD (del_id NUMBER,orig_del_id NUMBER);
    TYPE delIdTabType IS TABLE OF delIdRecType;
    delIdTab    delIdTabType;
    l_recurring_del_parent_id NUMBER;

   l_target_start_event_id okc_deliverables.relative_st_date_event_id%TYPE:=null;
   l_target_end_event_id okc_deliverables.relative_end_date_event_id%TYPE:=null;

   	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);

    BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                                        ,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.copy_del_for_amendment'||
                                        'p_source_doc_id = '||p_source_doc_id||
                                        'p_source_doc_type = '||p_source_doc_type||
                                        'p_target_doc_type = '||p_target_doc_type||
                                        'p_target_doc_number = '||p_target_doc_number||
                                        'p_reset_fixed_date_yn = '||p_reset_fixed_date_yn||
                                        'p_copy_del_attachments_yn = '||p_copy_del_attachments_yn);
      END IF;

      -- initialize the table type variable
      delIdTab := delIdTabType();

      FOR del_rec IN del_cur LOOP
          k := k+1;
          delRecTab(k).deliverable_id := del_rec.deliverable_id;
          delRecTab(k).BUSINESS_DOCUMENT_TYPE:= del_rec.BUSINESS_DOCUMENT_TYPE;
          delRecTab(k).BUSINESS_DOCUMENT_ID:= del_rec.BUSINESS_DOCUMENT_ID;
          delRecTab(k).BUSINESS_DOCUMENT_NUMBER:= del_rec.BUSINESS_DOCUMENT_NUMBER;
          delRecTab(k).DELIVERABLE_TYPE:= del_rec.DELIVERABLE_TYPE;
          delRecTab(k).RESPONSIBLE_PARTY:= del_rec.RESPONSIBLE_PARTY;
          delRecTab(k).INTERNAL_PARTY_CONTACT_ID:= del_rec.INTERNAL_PARTY_CONTACT_ID;
          delRecTab(k).EXTERNAL_PARTY_CONTACT_ID:= del_rec.EXTERNAL_PARTY_CONTACT_ID;
          delRecTab(k).DELIVERABLE_NAME:= del_rec.DELIVERABLE_NAME;
          delRecTab(k).DESCRIPTION:= del_rec.DESCRIPTION;
          delRecTab(k).COMMENTS:= del_rec.COMMENTS;
          delRecTab(k).DISPLAY_SEQUENCE:= del_rec.DISPLAY_SEQUENCE;
          delRecTab(k).FIXED_DUE_DATE_YN:= del_rec.FIXED_DUE_DATE_YN;
          delRecTab(k).ACTUAL_DUE_DATE:= del_rec.ACTUAL_DUE_DATE;
          delRecTab(k).PRINT_DUE_DATE_MSG_NAME:= del_rec.PRINT_DUE_DATE_MSG_NAME;
          delRecTab(k).RECURRING_YN:= del_rec.RECURRING_YN;
          delRecTab(k).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
          delRecTab(k).NOTIFY_PRIOR_DUE_DATE_UOM:= del_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
          delRecTab(k).NOTIFY_PRIOR_DUE_DATE_YN:= del_rec.NOTIFY_PRIOR_DUE_DATE_YN;
          delRecTab(k).NOTIFY_COMPLETED_YN:= del_rec.NOTIFY_COMPLETED_YN;
          delRecTab(k).NOTIFY_OVERDUE_YN:= del_rec.NOTIFY_OVERDUE_YN;
          delRecTab(k).NOTIFY_ESCALATION_YN:= del_rec.NOTIFY_ESCALATION_YN;
          delRecTab(k).NOTIFY_ESCALATION_VALUE:= del_rec.NOTIFY_ESCALATION_VALUE;
          delRecTab(k).NOTIFY_ESCALATION_UOM:= del_rec.NOTIFY_ESCALATION_UOM;
          delRecTab(k).ESCALATION_ASSIGNEE:= del_rec.ESCALATION_ASSIGNEE;
          delRecTab(k).AMENDMENT_OPERATION:= del_rec.AMENDMENT_OPERATION;
          delRecTab(k).PRIOR_NOTIFICATION_ID:= del_rec.PRIOR_NOTIFICATION_ID;
          delRecTab(k).AMENDMENT_NOTES:= del_rec.AMENDMENT_NOTES;
          delRecTab(k).COMPLETED_NOTIFICATION_ID:= del_rec.COMPLETED_NOTIFICATION_ID;
          delRecTab(k).OVERDUE_NOTIFICATION_ID:= del_rec.OVERDUE_NOTIFICATION_ID;
          delRecTab(k).ESCALATION_NOTIFICATION_ID:= del_rec.ESCALATION_NOTIFICATION_ID;
          delRecTab(k).LANGUAGE:= del_rec.LANGUAGE;
          delRecTab(k).ORIGINAL_DELIVERABLE_ID:= del_rec.ORIGINAL_DELIVERABLE_ID;
          delRecTab(k).REQUESTER_ID:= del_rec.REQUESTER_ID;
          delRecTab(k).EXTERNAL_PARTY_ID:= del_rec.EXTERNAL_PARTY_ID;
          delRecTab(k).EXTERNAL_PARTY_ROLE := del_rec.EXTERNAL_PARTY_ROLE;
          delRecTab(k).RECURRING_DEL_PARENT_ID:= del_rec.RECURRING_DEL_PARENT_ID;
          delRecTab(k).BUSINESS_DOCUMENT_VERSION:= del_rec.BUSINESS_DOCUMENT_VERSION;
          delRecTab(k).RELATIVE_ST_DATE_DURATION:= del_rec.RELATIVE_ST_DATE_DURATION;
          delRecTab(k).RELATIVE_ST_DATE_UOM:= del_rec.RELATIVE_ST_DATE_UOM;
          delRecTab(k).RELATIVE_ST_DATE_EVENT_ID:= del_rec.RELATIVE_ST_DATE_EVENT_ID;
          delRecTab(k).RELATIVE_END_DATE_DURATION:= del_rec.RELATIVE_END_DATE_DURATION;
          delRecTab(k).RELATIVE_END_DATE_UOM:= del_rec.RELATIVE_END_DATE_UOM;
          delRecTab(k).RELATIVE_END_DATE_EVENT_ID:= del_rec.RELATIVE_END_DATE_EVENT_ID;
          delRecTab(k).REPEATING_DAY_OF_MONTH:= del_rec.REPEATING_DAY_OF_MONTH;
          delRecTab(k).REPEATING_DAY_OF_WEEK:= del_rec.REPEATING_DAY_OF_WEEK;
          delRecTab(k).REPEATING_FREQUENCY_UOM:= del_rec.REPEATING_FREQUENCY_UOM;
          delRecTab(k).REPEATING_DURATION:= del_rec.REPEATING_DURATION;
          delRecTab(k).FIXED_START_DATE:= del_rec.FIXED_START_DATE;
          delRecTab(k).FIXED_END_DATE:= del_rec.FIXED_END_DATE;
          delRecTab(k).MANAGE_YN:= del_rec.MANAGE_YN;
          delRecTab(k).INTERNAL_PARTY_ID:= del_rec.INTERNAL_PARTY_ID;
          delRecTab(k).DELIVERABLE_STATUS:= del_rec.DELIVERABLE_STATUS;
          delRecTab(k).STATUS_CHANGE_NOTES:= del_rec.STATUS_CHANGE_NOTES;
          delRecTab(k).CREATED_BY:= del_rec.CREATED_BY;
          delRecTab(k).CREATION_DATE:= del_rec.CREATION_DATE;
          delRecTab(k).LAST_UPDATED_BY:= del_rec.LAST_UPDATED_BY;
          delRecTab(k).LAST_UPDATE_DATE:= del_rec.LAST_UPDATE_DATE;
          delRecTab(k).LAST_UPDATE_LOGIN:= del_rec.LAST_UPDATE_LOGIN;
          delRecTab(k).OBJECT_VERSION_NUMBER:= del_rec.OBJECT_VERSION_NUMBER;
          delRecTab(k).ATTRIBUTE_CATEGORY:= del_rec.ATTRIBUTE_CATEGORY;
          delRecTab(k).ATTRIBUTE1:= del_rec.ATTRIBUTE1;
          delRecTab(k).ATTRIBUTE2:= del_rec.ATTRIBUTE2;
          delRecTab(k).ATTRIBUTE3:= del_rec.ATTRIBUTE3;
          delRecTab(k).ATTRIBUTE4:= del_rec.ATTRIBUTE4;
          delRecTab(k).ATTRIBUTE5:= del_rec.ATTRIBUTE5;
          delRecTab(k).ATTRIBUTE6:= del_rec.ATTRIBUTE6;
          delRecTab(k).ATTRIBUTE7:= del_rec.ATTRIBUTE7;
          delRecTab(k).ATTRIBUTE8:= del_rec.ATTRIBUTE8;
          delRecTab(k).ATTRIBUTE9:= del_rec.ATTRIBUTE9;
          delRecTab(k).ATTRIBUTE10:= del_rec.ATTRIBUTE10;
          delRecTab(k).ATTRIBUTE11:= del_rec.ATTRIBUTE11;
          delRecTab(k).ATTRIBUTE12:= del_rec.ATTRIBUTE12;
          delRecTab(k).ATTRIBUTE13:= del_rec.ATTRIBUTE13;
          delRecTab(k).ATTRIBUTE14:= del_rec.ATTRIBUTE14;
          delRecTab(k).ATTRIBUTE15:= del_rec.ATTRIBUTE15;
          delRecTab(k).DISABLE_NOTIFICATIONS_YN:= del_rec.DISABLE_NOTIFICATIONS_YN;
          delRecTab(k).LAST_AMENDMENT_DATE:= del_rec.LAST_AMENDMENT_DATE;
          delRecTab(k).BUSINESS_DOCUMENT_LINE_ID:= del_rec.BUSINESS_DOCUMENT_LINE_ID;
          delRecTab(k).EXTERNAL_PARTY_SITE_ID:= del_rec.EXTERNAL_PARTY_SITE_ID;
          delRecTab(k).START_EVENT_DATE:= del_rec.START_EVENT_DATE;
          delRecTab(k).END_EVENT_DATE:= del_rec.END_EVENT_DATE;
          delRecTab(k).SUMMARY_AMEND_OPERATION_CODE:= del_rec.SUMMARY_AMEND_OPERATION_CODE;
          delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
          delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
          delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
          delRecTab(k).PAY_HOLD_OVERDUE_YN:=del_rec.PAY_HOLD_OVERDUE_YN;
      END LOOP;

      -- commented as this is not supported by 8i PL/SQL Bug#3307941
      /*OPEN del_cur;
      FETCH del_cur BULK COLLECT INTO delRecTab;*/
      IF delRecTab.COUNT <> 0 THEN
          FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: Inside loop'||to_char(delRecTab(i).deliverable_id));
              END IF;

              IF copy_allowed (p_deliverable_type => delRecTab(i).deliverable_type,
                               p_target_doc_type => p_target_doc_type,
                               p_target_contractual_doc_type => p_target_contractual_doctype) THEN

                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101a: Copy ALLOWED');
                  END IF;

                  j := j+1;
                  q := q+1;

                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'102: deliverable table record = '||q);
                  END IF;

                  delNewTab(q) := delRecTab(i);

                  -- extend table type
                  delIdTab.extend;
                  delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;

                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'103: deliverable IDs table record = '||j);
                  END IF;

                  select okc_deliverable_id_s.nextval INTO delNewTab(q).deliverable_id from dual;

                  delNewTab(q).business_document_id := p_target_doc_id;
                  delNewTab(q).business_document_type := p_target_doc_type;
                  delNewTab(q).business_document_number := p_target_doc_number;

                  -- Bug 5143307, check if source and target do are not same
                  -- resolve source document relative due date events to target
                  -- document relative due date event
                  -- first initialize
                  l_target_start_event_id := null;
                  l_target_end_event_id := null;
                  IF p_source_doc_type <> p_target_doc_type
                     AND
                     event_mapping_allowed (p_deliverable_type => delRecTab(i).deliverable_type,
                                                            p_target_doc_type => p_target_doc_type) THEN

                          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'104: Source and Target docs are NOT SAME ');
                          END IF;

                          IF delRecTab(i).RELATIVE_ST_DATE_EVENT_ID is not null THEN

                                  -- resolve target start event id
                                  l_target_start_event_id := resolveTargetDocEvent(
                                  p_source_event_id => delRecTab(i).RELATIVE_ST_DATE_EVENT_ID,
                                  p_target_doc_type => p_target_doc_type);
                                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'105: Found l_target_start_event_id = '||l_target_start_event_id);
                                  END IF;

                                  -- raise error if could not resolve target event id
                                  IF l_target_start_event_id is null THEN
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_COULD_NT_RESOLVE_EVT',del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

/*                                          Okc_Api.Set_Message(G_APP_NAME
                                                    ,'OKC_DEL_COULD_NT_RESOLVE_EVT');*/

                                          Okc_Api.Set_Message(G_APP_NAME
                                                    ,l_resolved_msg_name,
                                                    p_token1 => 'DEL_TOKEN',
                                                    p_token1_value => l_resolved_token);
                                          RAISE FND_API.G_EXC_ERROR;
                                  END IF;
                          END IF; -- IF delRecTab(i).RELATIVE_ST_DATE_EVENT_ID is not null

                          IF delRecTab(i).RELATIVE_END_DATE_EVENT_ID is not null THEN
                                  -- resolve target end event id
                                  l_target_end_event_id := resolveTargetDocEvent(
                                  p_source_event_id => delRecTab(i).RELATIVE_END_DATE_EVENT_ID,
                                  p_target_doc_type => p_target_doc_type);

                                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'106: Found l_target_end_event_id = '||l_target_end_event_id);
                                  END IF;

                                  -- raise error if could not resolve target event id
                                  IF l_target_end_event_id is null THEN

				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_COULD_NT_RESOLVE_EVT',del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

/*                                          Okc_Api.Set_Message(G_APP_NAME
                                                    ,'OKC_DEL_COULD_NT_RESOLVE_EVT');*/

                                          Okc_Api.Set_Message(G_APP_NAME
                                                    ,l_resolved_msg_name,
                                                    p_token1 => 'DEL_TOKEN',
                                                    p_token1_value => l_resolved_token);

                                          RAISE FND_API.G_EXC_ERROR;
                                  END IF;
                          END IF; -- IF delRecTab(i).RELATIVE_END_DATE_EVENT_ID is not null

                          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'107: Setting NEW resolved Start Event and End Event Ids');
                          END IF;

                          -- set resolved start and event ids on new delRecTab
                          delNewTab(q).RELATIVE_ST_DATE_EVENT_ID := l_target_start_event_id;
                          delNewTab(q).RELATIVE_END_DATE_EVENT_ID := l_target_end_event_id;
                  END IF; -- IF p_source_doc_type <> p_target_doc_type

                  -- bug#3489625 POCST: DELIVERABLE ATTACHMENTS ARE NOT COPIED TO AMENDMENT
                  delIdTab(j).del_id := delNewTab(q).deliverable_id;

                  -- store the deliverable_id to assign to the instances
                  l_recurring_del_parent_id := delNewTab(q).deliverable_id;

                  -- flush amendment operation attributes
                  delNewTab(q).amendment_operation:= null;
                  delNewTab(q).amendment_notes:= null;
                  delNewTab(q).summary_amend_operation_code:= null;

                  -- fix bug 3667895, carrying forward last amendment date during amendments
                  --delNewTab(q).last_amendment_date:= null;

                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'108: Inside loop1'||to_char(delNewTab(q).deliverable_id));
                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'109: q in def loop'||to_char(q));
                  END IF;

                IF delRecTab(i).recurring_yn = 'N' THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'110: Recurring?'||delRecTab(i).recurring_yn);
          END IF;

                    -- initialize all resolved dates to null
                    delNewTab(q).start_event_date:= null;
                    delNewTab(q).end_event_date:= null;
                    delNewTab(q).actual_due_date:= null;

                ELSIF delRecTab(i).recurring_yn = 'Y' THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'111: Recurring?'||delRecTab(i).recurring_yn);
                    END IF;

                    --OPEN del_ins_cur(delRecTab(i).deliverable_id);
                    --Initialize the table with 0 rows
                    delInsTab.DELETE;
                    m := 0;
        FOR del_ins_rec IN del_ins_cur(delRecTab(i).deliverable_id) LOOP
      m := m+1;
      delInsTab(m).deliverable_id := del_ins_rec.deliverable_id;
      delInsTab(m).BUSINESS_DOCUMENT_TYPE:= del_ins_rec.BUSINESS_DOCUMENT_TYPE;
      delInsTab(m).BUSINESS_DOCUMENT_ID:= del_ins_rec.BUSINESS_DOCUMENT_ID;
      delInsTab(m).BUSINESS_DOCUMENT_NUMBER:= del_ins_rec.BUSINESS_DOCUMENT_NUMBER;
      delInsTab(m).DELIVERABLE_TYPE:= del_ins_rec.DELIVERABLE_TYPE;
      delInsTab(m).RESPONSIBLE_PARTY:= del_ins_rec.RESPONSIBLE_PARTY;
      delInsTab(m).INTERNAL_PARTY_CONTACT_ID:= del_ins_rec.INTERNAL_PARTY_CONTACT_ID;
      delInsTab(m).EXTERNAL_PARTY_CONTACT_ID:= del_ins_rec.EXTERNAL_PARTY_CONTACT_ID;
      delInsTab(m).DELIVERABLE_NAME:= del_ins_rec.DELIVERABLE_NAME;
      delInsTab(m).DESCRIPTION:= del_ins_rec.DESCRIPTION;
      delInsTab(m).COMMENTS:= del_ins_rec.COMMENTS;
      delInsTab(m).DISPLAY_SEQUENCE:= del_ins_rec.DISPLAY_SEQUENCE;
      delInsTab(m).FIXED_DUE_DATE_YN:= del_ins_rec.FIXED_DUE_DATE_YN;
      delInsTab(m).ACTUAL_DUE_DATE:= del_ins_rec.ACTUAL_DUE_DATE;
      delInsTab(m).PRINT_DUE_DATE_MSG_NAME:= del_ins_rec.PRINT_DUE_DATE_MSG_NAME;
      delInsTab(m).RECURRING_YN:= del_ins_rec.RECURRING_YN;
      delInsTab(m).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
      delInsTab(m).NOTIFY_PRIOR_DUE_DATE_UOM:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
      delInsTab(m).NOTIFY_PRIOR_DUE_DATE_YN:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_YN;
      delInsTab(m).NOTIFY_COMPLETED_YN:= del_ins_rec.NOTIFY_COMPLETED_YN;
      delInsTab(m).NOTIFY_OVERDUE_YN:= del_ins_rec.NOTIFY_OVERDUE_YN;
      delInsTab(m).NOTIFY_ESCALATION_YN:= del_ins_rec.NOTIFY_ESCALATION_YN;
      delInsTab(m).NOTIFY_ESCALATION_VALUE:= del_ins_rec.NOTIFY_ESCALATION_VALUE;
      delInsTab(m).NOTIFY_ESCALATION_UOM:= del_ins_rec.NOTIFY_ESCALATION_UOM;
      delInsTab(m).ESCALATION_ASSIGNEE:= del_ins_rec.ESCALATION_ASSIGNEE;
      delInsTab(m).AMENDMENT_OPERATION:= del_ins_rec.AMENDMENT_OPERATION;
      delInsTab(m).PRIOR_NOTIFICATION_ID:= del_ins_rec.PRIOR_NOTIFICATION_ID;
      delInsTab(m).AMENDMENT_NOTES:= del_ins_rec.AMENDMENT_NOTES;
      delInsTab(m).COMPLETED_NOTIFICATION_ID:= del_ins_rec.COMPLETED_NOTIFICATION_ID;
      delInsTab(m).OVERDUE_NOTIFICATION_ID:= del_ins_rec.OVERDUE_NOTIFICATION_ID;
      delInsTab(m).ESCALATION_NOTIFICATION_ID:= del_ins_rec.ESCALATION_NOTIFICATION_ID;
      delInsTab(m).LANGUAGE:= del_ins_rec.LANGUAGE;
      delInsTab(m).ORIGINAL_DELIVERABLE_ID:= del_ins_rec.ORIGINAL_DELIVERABLE_ID;
      delInsTab(m).REQUESTER_ID:= del_ins_rec.REQUESTER_ID;
      delInsTab(m).EXTERNAL_PARTY_ID:= del_ins_rec.EXTERNAL_PARTY_ID;
      delInsTab(m).EXTERNAL_PARTY_ROLE := del_ins_rec.EXTERNAL_PARTY_ROLE;
      delInsTab(m).RECURRING_DEL_PARENT_ID:= del_ins_rec.RECURRING_DEL_PARENT_ID;
      delInsTab(m).BUSINESS_DOCUMENT_VERSION:= del_ins_rec.BUSINESS_DOCUMENT_VERSION;
      delInsTab(m).RELATIVE_ST_DATE_DURATION:= del_ins_rec.RELATIVE_ST_DATE_DURATION;
      delInsTab(m).RELATIVE_ST_DATE_UOM:= del_ins_rec.RELATIVE_ST_DATE_UOM;
      delInsTab(m).RELATIVE_ST_DATE_EVENT_ID:= del_ins_rec.RELATIVE_ST_DATE_EVENT_ID;
      delInsTab(m).RELATIVE_END_DATE_DURATION:= del_ins_rec.RELATIVE_END_DATE_DURATION;
      delInsTab(m).RELATIVE_END_DATE_UOM:= del_ins_rec.RELATIVE_END_DATE_UOM;
      delInsTab(m).RELATIVE_END_DATE_EVENT_ID:= del_ins_rec.RELATIVE_END_DATE_EVENT_ID;
      delInsTab(m).REPEATING_DAY_OF_MONTH:= del_ins_rec.REPEATING_DAY_OF_MONTH;
      delInsTab(m).REPEATING_DAY_OF_WEEK:= del_ins_rec.REPEATING_DAY_OF_WEEK;
      delInsTab(m).REPEATING_FREQUENCY_UOM:= del_ins_rec.REPEATING_FREQUENCY_UOM;
      delInsTab(m).REPEATING_DURATION:= del_ins_rec.REPEATING_DURATION;
      delInsTab(m).FIXED_START_DATE:= del_ins_rec.FIXED_START_DATE;
      delInsTab(m).FIXED_END_DATE:= del_ins_rec.FIXED_END_DATE;
      delInsTab(m).MANAGE_YN:= del_ins_rec.MANAGE_YN;
      delInsTab(m).INTERNAL_PARTY_ID:= del_ins_rec.INTERNAL_PARTY_ID;
      delInsTab(m).DELIVERABLE_STATUS:= del_ins_rec.DELIVERABLE_STATUS;
      delInsTab(m).STATUS_CHANGE_NOTES:= del_ins_rec.STATUS_CHANGE_NOTES;
      delInsTab(m).CREATED_BY:= del_ins_rec.CREATED_BY;
      delInsTab(m).CREATION_DATE:= del_ins_rec.CREATION_DATE;
      delInsTab(m).LAST_UPDATED_BY:= del_ins_rec.LAST_UPDATED_BY;
      delInsTab(m).LAST_UPDATE_DATE:= del_ins_rec.LAST_UPDATE_DATE;
      delInsTab(m).LAST_UPDATE_LOGIN:= del_ins_rec.LAST_UPDATE_LOGIN;
      delInsTab(m).OBJECT_VERSION_NUMBER:= del_ins_rec.OBJECT_VERSION_NUMBER;
      delInsTab(m).ATTRIBUTE_CATEGORY:= del_ins_rec.ATTRIBUTE_CATEGORY;
      delInsTab(m).ATTRIBUTE1:= del_ins_rec.ATTRIBUTE1;
      delInsTab(m).ATTRIBUTE2:= del_ins_rec.ATTRIBUTE2;
      delInsTab(m).ATTRIBUTE3:= del_ins_rec.ATTRIBUTE3;
      delInsTab(m).ATTRIBUTE4:= del_ins_rec.ATTRIBUTE4;
      delInsTab(m).ATTRIBUTE5:= del_ins_rec.ATTRIBUTE5;
      delInsTab(m).ATTRIBUTE6:= del_ins_rec.ATTRIBUTE6;
      delInsTab(m).ATTRIBUTE7:= del_ins_rec.ATTRIBUTE7;
      delInsTab(m).ATTRIBUTE8:= del_ins_rec.ATTRIBUTE8;
      delInsTab(m).ATTRIBUTE9:= del_ins_rec.ATTRIBUTE9;
      delInsTab(m).ATTRIBUTE10:= del_ins_rec.ATTRIBUTE10;
      delInsTab(m).ATTRIBUTE11:= del_ins_rec.ATTRIBUTE11;
      delInsTab(m).ATTRIBUTE12:= del_ins_rec.ATTRIBUTE12;
      delInsTab(m).ATTRIBUTE13:= del_ins_rec.ATTRIBUTE13;
      delInsTab(m).ATTRIBUTE14:= del_ins_rec.ATTRIBUTE14;
      delInsTab(m).ATTRIBUTE15:= del_ins_rec.ATTRIBUTE15;
      delInsTab(m).DISABLE_NOTIFICATIONS_YN:= del_ins_rec.DISABLE_NOTIFICATIONS_YN;
      delInsTab(m).LAST_AMENDMENT_DATE:= del_ins_rec.LAST_AMENDMENT_DATE;
      delInsTab(m).BUSINESS_DOCUMENT_LINE_ID:= del_ins_rec.BUSINESS_DOCUMENT_LINE_ID;
      delInsTab(m).EXTERNAL_PARTY_SITE_ID:= del_ins_rec.EXTERNAL_PARTY_SITE_ID;
      delInsTab(m).START_EVENT_DATE:= del_ins_rec.START_EVENT_DATE;
      delInsTab(m).END_EVENT_DATE:= del_ins_rec.END_EVENT_DATE;
      delInsTab(m).SUMMARY_AMEND_OPERATION_CODE:= del_ins_rec.SUMMARY_AMEND_OPERATION_CODE;
      delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
      delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
      delInsTab(m).PAY_HOLD_OVERDUE_YN:=del_ins_rec.PAY_HOLD_OVERDUE_YN;

                    END LOOP;
                    IF del_ins_cur %ISOPEN THEN
                      CLOSE del_ins_cur ;
                    END IF;

                    /****
                    commented as this is not supported by 8i PL/SQL Bug#3307941
              OPEN del_ins_cur(delRecTab(i).deliverable_id);
                    FETCH del_ins_cur BULK COLLECT INTO delInsTab;****/

                    IF delInsTab.COUNT <> 0 THEN
                      FOR s IN delInsTab.FIRST..delInsTab.LAST LOOP
                          j := j+1;
                          q := q+1;
                          delNewTab(q) := delInsTab(s);

                          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'112: Deliverable Instance record = '||q);
                          END IF;

                          -- extend table type
                          delIdTab.extend;

                          delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;

                          select okc_deliverable_id_s.nextval INTO delNewTab(q).deliverable_id from dual;

                          delNewTab(q).business_document_id := p_target_doc_id;
                          delNewTab(q).business_document_type := p_target_doc_type;
                          delNewTab(q).business_document_number := p_target_doc_number;

                          -- Bug 5143307, resolve target start and end events for
                          -- recurring instances, assuming these events are already
                          -- resolved above for recurring deliverable definition
                          IF p_source_doc_type <> p_target_doc_type THEN
                             IF l_target_start_event_id is not null THEN
                                     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'113: Setting Start Event Id on this instance = '||l_target_start_event_id);
                                     END IF;

                                     delNewTab(q).RELATIVE_ST_DATE_EVENT_ID := l_target_start_event_id;
                             END IF;
                             IF l_target_end_event_id is not null THEN
                                     IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'114: Setting End Event Id on this instance = '||l_target_end_event_id);
                                     END IF;

                                    delNewTab(q).RELATIVE_END_DATE_EVENT_ID := l_target_end_event_id;
                             END IF;
                          END IF; -- IF p_source_doc_type <> p_target_doc_type

                          -- instantiate parent del id for the instances
                          delNewTab(q).recurring_del_parent_id := l_recurring_del_parent_id;
                          delIdTab(j).del_id := delNewTab(q).deliverable_id;

                          -- flush amendment operation attributes
                          delNewTab(q).amendment_operation:= null;
                          delNewTab(q).amendment_notes:= null;
                          delNewTab(q).summary_amend_operation_code:= null;
                          delNewTab(q).last_amendment_date:= null;
                          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'115: Inside loop2'||to_char(delNewTab(q).deliverable_id));
                                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'116: q in ins loop'||to_char(q));
                                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'117: s in ins loop'||to_char(s));
                          END IF;
            END LOOP;-- FOR s IN delInsTab.FIRST..delInsTab.LAST LOOP
          END IF; -- IF delInsTab.COUNT <> 0
                    IF del_ins_cur %ISOPEN THEN
                        CLOSE del_ins_cur ;
                    END IF;
                END IF; -- ELSIF delRecTab(i).recurring_yn = 'Y'
              END IF; -- IF copy_allowed ()
            END LOOP; -- FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
      END IF;-- IF delRecTab.COUNT <> 0
      IF del_cur %ISOPEN THEN
        CLOSE del_cur ;
      END IF;

      IF delNewTab.COUNT <> 0 THEN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'118: Before insert');
          END IF;
          FOR i IN delNewTab.FIRST..delNewTab.LAST LOOP
              INSERT INTO okc_deliverables
                          (DELIVERABLE_ID,
                          BUSINESS_DOCUMENT_TYPE      ,
                          BUSINESS_DOCUMENT_ID        ,
                          BUSINESS_DOCUMENT_NUMBER    ,
                          DELIVERABLE_TYPE            ,
                          RESPONSIBLE_PARTY           ,
                          INTERNAL_PARTY_CONTACT_ID   ,
                          EXTERNAL_PARTY_CONTACT_ID   ,
                          DELIVERABLE_NAME            ,
                          DESCRIPTION                 ,
                          COMMENTS                    ,
                          DISPLAY_SEQUENCE            ,
                          FIXED_DUE_DATE_YN           ,
                          ACTUAL_DUE_DATE             ,
                          PRINT_DUE_DATE_MSG_NAME     ,
                          RECURRING_YN                ,
                          NOTIFY_PRIOR_DUE_DATE_VALUE ,
                          NOTIFY_PRIOR_DUE_DATE_UOM   ,
                          NOTIFY_PRIOR_DUE_DATE_YN    ,
                          NOTIFY_COMPLETED_YN         ,
                          NOTIFY_OVERDUE_YN           ,
                          NOTIFY_ESCALATION_YN        ,
                          NOTIFY_ESCALATION_VALUE     ,
                          NOTIFY_ESCALATION_UOM       ,
                          ESCALATION_ASSIGNEE         ,
                          AMENDMENT_OPERATION         ,
                          PRIOR_NOTIFICATION_ID       ,
                          AMENDMENT_NOTES             ,
                          COMPLETED_NOTIFICATION_ID   ,
                          OVERDUE_NOTIFICATION_ID     ,
                          ESCALATION_NOTIFICATION_ID  ,
                          LANGUAGE                    ,
                          ORIGINAL_DELIVERABLE_ID     ,
                          REQUESTER_ID                ,
                          EXTERNAL_PARTY_ID           ,
                          EXTERNAL_PARTY_ROLE         ,
                          RECURRING_DEL_PARENT_ID     ,
                          BUSINESS_DOCUMENT_VERSION   ,
                          RELATIVE_ST_DATE_DURATION   ,
                          RELATIVE_ST_DATE_UOM        ,
                          RELATIVE_ST_DATE_EVENT_ID   ,
                          RELATIVE_END_DATE_DURATION  ,
                          RELATIVE_END_DATE_UOM       ,
                          RELATIVE_END_DATE_EVENT_ID  ,
                          REPEATING_DAY_OF_MONTH      ,
                          REPEATING_DAY_OF_WEEK       ,
                          REPEATING_FREQUENCY_UOM     ,
                          REPEATING_DURATION          ,
                          FIXED_START_DATE            ,
                          FIXED_END_DATE              ,
                          MANAGE_YN                   ,
                          INTERNAL_PARTY_ID           ,
                          DELIVERABLE_STATUS          ,
                          STATUS_CHANGE_NOTES         ,
                          CREATED_BY                  ,
                          CREATION_DATE               ,
                          LAST_UPDATED_BY             ,
                          LAST_UPDATE_DATE            ,
                          LAST_UPDATE_LOGIN           ,
                          OBJECT_VERSION_NUMBER       ,
                          ATTRIBUTE_CATEGORY          ,
                          ATTRIBUTE1                  ,
                          ATTRIBUTE2                  ,
                          ATTRIBUTE3                  ,
                          ATTRIBUTE4                  ,
                          ATTRIBUTE5                  ,
                          ATTRIBUTE6                  ,
                          ATTRIBUTE7                  ,
                          ATTRIBUTE8                  ,
                          ATTRIBUTE9                  ,
                          ATTRIBUTE10                 ,
                          ATTRIBUTE11                 ,
                          ATTRIBUTE12                 ,
                          ATTRIBUTE13                 ,
                          ATTRIBUTE14                 ,
                          ATTRIBUTE15                 ,
                          DISABLE_NOTIFICATIONS_YN    ,
                          LAST_AMENDMENT_DATE         ,
                          BUSINESS_DOCUMENT_LINE_ID   ,
                          EXTERNAL_PARTY_SITE_ID      ,
                          START_EVENT_DATE            ,
                          END_EVENT_DATE              ,
                          SUMMARY_AMEND_OPERATION_CODE,
                          PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                          PAY_HOLD_PRIOR_DUE_DATE_UOM,
                          PAY_HOLD_PRIOR_DUE_DATE_YN,
                          PAY_HOLD_OVERDUE_YN
                          )
                          VALUES (
                          delNewTab(i).DELIVERABLE_ID,
                          delNewTab(i).BUSINESS_DOCUMENT_TYPE      ,
                          delNewTab(i).BUSINESS_DOCUMENT_ID        ,
                          delNewTab(i).BUSINESS_DOCUMENT_NUMBER    ,
                          delNewTab(i).DELIVERABLE_TYPE            ,
                          delNewTab(i).RESPONSIBLE_PARTY           ,
                          delNewTab(i).INTERNAL_PARTY_CONTACT_ID   ,
                          delNewTab(i).EXTERNAL_PARTY_CONTACT_ID   ,
                          delNewTab(i).DELIVERABLE_NAME            ,
                          delNewTab(i).DESCRIPTION                 ,
                          delNewTab(i).COMMENTS                    ,
                          delNewTab(i).DISPLAY_SEQUENCE            ,
                          delNewTab(i).FIXED_DUE_DATE_YN           ,
                          delNewTab(i).ACTUAL_DUE_DATE             ,
                          delNewTab(i).PRINT_DUE_DATE_MSG_NAME     ,
                          delNewTab(i).RECURRING_YN                ,
                          delNewTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE ,
                          delNewTab(i).NOTIFY_PRIOR_DUE_DATE_UOM   ,
                          delNewTab(i).NOTIFY_PRIOR_DUE_DATE_YN    ,
                          delNewTab(i).NOTIFY_COMPLETED_YN         ,
                          delNewTab(i).NOTIFY_OVERDUE_YN           ,
                          delNewTab(i).NOTIFY_ESCALATION_YN        ,
                          delNewTab(i).NOTIFY_ESCALATION_VALUE     ,
                          delNewTab(i).NOTIFY_ESCALATION_UOM       ,
                          delNewTab(i).ESCALATION_ASSIGNEE         ,
                          delNewTab(i).AMENDMENT_OPERATION         ,
                          delNewTab(i).PRIOR_NOTIFICATION_ID       ,
                          delNewTab(i).AMENDMENT_NOTES             ,
                          delNewTab(i).COMPLETED_NOTIFICATION_ID   ,
                          delNewTab(i).OVERDUE_NOTIFICATION_ID     ,
                          delNewTab(i).ESCALATION_NOTIFICATION_ID  ,
                          delNewTab(i).LANGUAGE                    ,
                          delNewTab(i).ORIGINAL_DELIVERABLE_ID     ,
                          delNewTab(i).REQUESTER_ID                ,
                          delNewTab(i).EXTERNAL_PARTY_ID           ,
                          delNewTab(i).EXTERNAL_PARTY_ROLE         ,
                          delNewTab(i).RECURRING_DEL_PARENT_ID     ,
                          delNewTab(i).BUSINESS_DOCUMENT_VERSION   ,
                          delNewTab(i).RELATIVE_ST_DATE_DURATION   ,
                          delNewTab(i).RELATIVE_ST_DATE_UOM        ,
                          delNewTab(i).RELATIVE_ST_DATE_EVENT_ID   ,
                          delNewTab(i).RELATIVE_END_DATE_DURATION  ,
                          delNewTab(i).RELATIVE_END_DATE_UOM       ,
                          delNewTab(i).RELATIVE_END_DATE_EVENT_ID  ,
                          delNewTab(i).REPEATING_DAY_OF_MONTH      ,
                          delNewTab(i).REPEATING_DAY_OF_WEEK       ,
                          delNewTab(i).REPEATING_FREQUENCY_UOM     ,
                          delNewTab(i).REPEATING_DURATION          ,
                          delNewTab(i).FIXED_START_DATE            ,
                          delNewTab(i).FIXED_END_DATE              ,
                          delNewTab(i).MANAGE_YN                   ,
                          delNewTab(i).INTERNAL_PARTY_ID           ,
                          delNewTab(i).DELIVERABLE_STATUS          ,
                          delNewTab(i).STATUS_CHANGE_NOTES         ,
                          delNewTab(i).CREATED_BY                  ,
                          delNewTab(i).CREATION_DATE               ,
                          delNewTab(i).LAST_UPDATED_BY             ,
                          delNewTab(i).LAST_UPDATE_DATE            ,
                          delNewTab(i).LAST_UPDATE_LOGIN           ,
                          delNewTab(i).OBJECT_VERSION_NUMBER       ,
                          delNewTab(i).ATTRIBUTE_CATEGORY          ,
                          delNewTab(i).ATTRIBUTE1                  ,
                          delNewTab(i).ATTRIBUTE2                  ,
                          delNewTab(i).ATTRIBUTE3                  ,
                          delNewTab(i).ATTRIBUTE4                  ,
                          delNewTab(i).ATTRIBUTE5                  ,
                          delNewTab(i).ATTRIBUTE6                  ,
                          delNewTab(i).ATTRIBUTE7                  ,
                          delNewTab(i).ATTRIBUTE8                  ,
                          delNewTab(i).ATTRIBUTE9                  ,
                          delNewTab(i).ATTRIBUTE10                 ,
                          delNewTab(i).ATTRIBUTE11                 ,
                          delNewTab(i).ATTRIBUTE12                 ,
                          delNewTab(i).ATTRIBUTE13                 ,
                          delNewTab(i).ATTRIBUTE14                 ,
                          delNewTab(i).ATTRIBUTE15                 ,
                          delNewTab(i).DISABLE_NOTIFICATIONS_YN    ,
                          delNewTab(i).LAST_AMENDMENT_DATE         ,
                          delNewTab(i).BUSINESS_DOCUMENT_LINE_ID   ,
                          delNewTab(i).EXTERNAL_PARTY_SITE_ID      ,
                          delNewTab(i).START_EVENT_DATE            ,
                          delNewTab(i).END_EVENT_DATE              ,
                          delNewTab(i).SUMMARY_AMEND_OPERATION_CODE,
                          delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                          delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_UOM,
                          delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_YN,
                          delNewTab(i).PAY_HOLD_OVERDUE_YN
                          );
          END LOOP;
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'119: New deliverables inserted');
          END IF;
      END IF; -- IF delNewTab.COUNT <> 0

      -- copy any existing attachments if allowed
      IF p_copy_del_attachments_yn = 'Y' THEN

          -- copy any existing attachments
          IF delIdTab.COUNT <> 0 THEN
              FOR i IN delIdTab.FIRST..delIdTab.LAST LOOP
                  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'120: Inside loop'||to_char(delIdTab(i).del_id));
                  END IF;
                  -- check if attachments exists
                  IF attachment_exists(p_entity_name => G_ENTITY_NAME
                                      ,p_pk1_value    =>  delIdTab(i).orig_del_id) THEN

                      -- copy attachments
                      -- bug#3667712 added X_CREATED_BY,X_LAST_UPDATE_LOGIN params
                      fnd_attached_documents2_pkg.copy_attachments(
                                  X_from_entity_name =>  G_ENTITY_NAME,
                                  X_from_pk1_value   =>  delIdTab(i).orig_del_id,
                                  X_to_entity_name   =>  G_ENTITY_NAME,
                                  X_to_pk1_value     =>  to_char(delIdTab(i).del_id),
                                  X_CREATED_BY       =>  FND_GLOBAL.User_id,
                                  X_LAST_UPDATE_LOGIN => Fnd_Global.Login_Id
                                  );
                      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'121: Attachments copied for delId: '||to_char(delIdTab(i).del_id));
                      END IF;
                  END IF; -- IF attachment_exists()
              END LOOP; -- FOR i IN delIdTab.FIRST..delIdTab.LAST LOOP
          END IF;--delRecTab.COUNT
      END IF; -- IF p_copy_del_attachments_yn = 'Y'

      x_return_status := l_return_status;
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'122: leaving OKC_DELIVERABLE_PROCESS_PVT.copy_del_for_amendment' );
      END IF;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.copy_del_for_amendment with G_EXC_ERROR');
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.copy_del_for_amendment with G_EXC_UNEXPECTED_ERROR'||substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.copy_del_for_amendment with G_EXC_UNEXPECTED_ERROR'||substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END copy_del_for_amendment;


    -- this function checks if the a bus_doc_event exists
    -- for a given combination of busdoc_type and event_id
    FUNCTION event_matches(
    p_bus_doc_type  IN VARCHAR2
    ,p_event_id     IN NUMBER)
    RETURN BOOLEAN
    IS

    CURSOR event_cur
    IS
    SELECT 'X'
    FROM okc_bus_doc_events_b
    WHERE bus_doc_type = p_bus_doc_type
    AND   bus_doc_event_id = p_event_id;

    event_rec  event_cur%ROWTYPE;
    l_api_name        CONSTANT VARCHAR2(30) := 'event_matches';
    l_return_value BOOLEAN := FALSE;

    BEGIN

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.event_matches');
            END IF;
            OPEN event_cur;
            FETCH event_cur INTO event_rec;
            IF event_cur%FOUND THEN
          l_return_value := TRUE;
            ELSE
          l_return_value := FALSE;
            END IF;
            CLOSE event_cur;
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: Leaving event_matches');
            END IF;
      RETURN l_return_value;
    EXCEPTION
    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'102: Leaving event_matches with Exception');
        END IF;
        IF event_cur %ISOPEN THEN
          CLOSE event_cur ;
        END IF;
          RETURN l_return_value;
    END event_matches;


    -- function returns Y if the busdoc type and
    -- deliverable type belong to the same class
    FUNCTION deltype_matches(p_del_type IN VARCHAR2
                          ,p_busdoc_type IN VARCHAR2)
    RETURN VARCHAR2
    IS

   /*
    CURSOR delType_cur IS
    select 'Y'
    FROM okc_bus_doc_types_b docType,
    okc_del_bus_doc_combxns bdc
    WHERE docType.document_type_class = bdc.document_type_class
    AND docType.document_type = p_busdoc_type
    and bdc.deliverable_type = p_del_type;
    */
   --Repository change: Changed cursor to look at okc_deliverable_types_b
    -- updated cursor for bug#4069955
    CURSOR delType_cur IS
    select 'Y'
    FROM
    okc_bus_doc_types_b doctyp
    ,okc_del_bus_doc_combxns deltyp
    where
    doctyp.document_type_class = deltyp.document_type_class
    AND doctyp.document_type = p_busdoc_type
    AND deltyp.deliverable_type_code = p_del_type;

    l_deltype_matches    VARCHAR2(1);
    l_api_name        CONSTANT VARCHAR2(30) := 'deltype_matches';

    BEGIN

    OPEN delType_cur;
    FETCH delType_cur INTO l_deltype_matches;
    CLOSE delType_cur;
        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: DelType Matches is :'||l_deltype_matches);
        END IF;
    RETURN(l_deltype_matches);

    EXCEPTION
    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'102: Leaving Deltype_Matches with Exception');
        END IF;
        IF delType_cur %ISOPEN THEN
          CLOSE delType_cur ;
        END IF;
            RETURN(l_deltype_matches);

    END deltype_matches;


    /* Checks if the relative deliverable can be copied over to target document
    based on start or end date event matching the target response document type.
    Fixed date deliverables are copied over even if the dates are null.
    */
    ---bug#3594008 redid copy allowed to handle recurring contractual deliverables
    -- where fixed dates are nulled out
    -- bug#3675608 added new param p_target_doctype to check if recurring del end event
    -- matches target_doctype.

    FUNCTION copy_response_allowed (p_delrec  IN   okc_deliverables%ROWTYPE
    ,p_target_response_doctype  IN VARCHAR2
    ,p_target_doctype  IN VARCHAR2
    ) RETURN VARCHAR2
    IS
    l_copy   VARCHAR2(1);
    l_start_copy   VARCHAR2(1);
    l_end_copy   VARCHAR2(1);
    l_api_name        CONSTANT VARCHAR2(30) := 'copy_response_allowed';

    BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' 100: Inside copy_response_allowed ');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' recurring_yn is :'||p_delrec.recurring_yn);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' fixed_due_date_yn is :'||p_delrec.fixed_due_date_yn);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' p_target_response_doctype is :'||p_target_response_doctype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' deliverable name is :'||p_delrec.deliverable_name);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' deliverable id is :'||p_delrec.deliverable_id);
        END IF;
                    --If not a recurring deliverable
                    IF p_delrec.recurring_yn = 'N' THEN
                        IF p_delrec.fixed_due_date_yn = 'Y' THEN
                        -- copy deliverable as is
                        l_copy := 'Y';
                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: msg1 :'||l_copy);
                            END IF;
                        ELSE  --  p_delrec.fixed_due_date_yn = 'N'
                            IF p_delrec.relative_st_date_event_id is not null THEN
                                -- match the event doctype to target doctype
                                IF p_target_response_doctype is not null THEN
                                    -- match the event doctype to p_target_response_doctype
                                        IF event_matches(p_target_response_doctype
                                            ,p_delrec.relative_st_date_event_id) THEN
                                            --copy deliverable
                                            l_copy := 'Y';
                                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                                '100: msg3 :'||l_copy);
                                            END IF;
                                        END IF; -- event_matches
                                ELSE
                                    l_copy :='N';
                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: msg4 :'||l_copy);
                                    END IF;
                                END IF; -- event_matches
                            ELSE -- start event id is null
                                l_copy := 'Y';
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                    '100: msg5 :'||l_copy);
                                END IF;
                            END IF; -- p_delrec.relative_st_date_event_id is not null

                        END IF; -- fixed_due_date_yn = 'Y'
                        --------------------------------------------------------
                    --If recurring deliverable
                    ELSIF p_delrec.recurring_yn = 'Y' THEN
                        l_end_copy := null;
                        l_start_copy := null;
                        -- check if the recurring del has a fixed start or end date
                        IF p_delrec.fixed_start_date is not null THEN
                            IF p_delrec.fixed_end_date is not null THEN
                                --copy deliverables
                                l_end_copy := 'Y';
                                l_start_copy := 'Y';
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                    '100: msg6 : both are Y');
                                END IF;
                            ELSE -- fixed end date is null
                            IF p_delrec.relative_end_date_event_id is not null THEN
                                 IF p_target_response_doctype is not null THEN
                                    -- match the event doctype to p_target_response_doctype
                                        IF event_matches(p_target_response_doctype
                                        ,p_delrec.relative_end_date_event_id) THEN
                                        --copy deliverable
                                        l_end_copy := 'Y';
                                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                                '100: end msg2 :'||l_end_copy);
                                            END IF;
                                        END IF;
                                 ELSE
                                    l_end_copy := 'N';
                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: end msg3 :'||l_end_copy);
                                    END IF;
                                END IF;  -- event matches
                            ELSE -- end date event is null
                                l_end_copy := 'Y';
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                    '100: end msg4 :'||l_end_copy);
                                END IF;
                            END IF; -- end_date event is not null
                            END IF; -- fixed_end_date is not null
                                l_start_copy := 'Y';
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                    '100: start msg5 :'||l_start_copy);
                                END IF;
                        ELSE  -- fixed start date is null
                          IF p_delrec.relative_st_date_event_id is not null THEN
                                IF p_target_response_doctype is not null THEN
                                    IF event_matches(p_target_response_doctype
                                    ,p_delrec.relative_st_date_event_id) THEN
                                    --copy deliverable
                                    l_start_copy := 'Y';
                                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                            '100: start msg2 :'||l_start_copy);
                                        END IF;
                                    END IF;
                                ELSE
                                    l_start_copy := 'N';
                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: start msg3 :'||l_start_copy);
                                    END IF;
                                END IF;
                          ELSE -- start date event id is null
                            l_start_copy := 'Y';
                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                '100: start msg4 :'||l_start_copy);
                            END IF;
                          END IF; -- st event id is not null
                            IF p_delrec.fixed_end_date is null THEN
                              IF p_delrec.relative_end_date_event_id is not null THEN
                                IF p_target_response_doctype is not null THEN
                                    -- match the event doctype to p__doctype
                                        IF event_matches(p_target_response_doctype
                                        ,p_delrec.relative_end_date_event_id) THEN
                                        --copy deliverable
                                        l_end_copy := 'Y';
                                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                                '100: start end msg2 :'||l_end_copy);
                                            END IF;
                                        ELSE  -- event_matches is not true
                                        --check for target_contractual bug#3675608
                                        IF event_matches(p_target_doctype
                                           ,p_delrec.relative_end_date_event_id) THEN
                                                --copy deliverable
                                                l_end_copy := 'Y';
                                        END IF;
                                        END IF; -- event_matches

                                ELSE
                                   l_end_copy := 'N';
                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: start end msg3 :'||l_end_copy);
                                    END IF;
                                END IF; -- event matches
                              ELSE -- end event id is null
                                l_end_copy := 'Y';
                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: start end msg4 :'||l_end_copy);
                                    END IF;
                              END IF; -- end event id is not null
                             ELSE -- fixed end date is not null
                               l_end_copy := 'Y';
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                    '100: start end msg5 :'||l_end_copy);
                                END IF;
                             END IF; -- fixed end date is null

                        END IF; -- fixed st date is null
                        IF l_end_copy = 'Y' AND
                           l_start_copy = 'Y' THEN
                           l_copy := 'Y';
                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                '100: final msg1 :'||l_copy);
                            END IF;
                        ELSE
                            l_copy := 'N';
                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                '100: final msg2 :'||l_copy);
                            END IF;
                        END IF;
                    END IF; -- recurring yn
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: final msg3 :'||l_copy);
      END IF;
    RETURN(l_copy);
    END copy_response_allowed;

------------------
    /* Checks if the relative deliverable can be copied over to target document
    based on start or end date event matching the target document type or
    target contractual document type. Fixed date deliverables are copied over
    even if the dates are null.
    */
    ---bug#3594008 redid copy allowed to handle recurring contractual deliverables
    -- where fixed dates are nulled out
    FUNCTION copy_allowed (p_delrec  IN   okc_deliverables%ROWTYPE,
    p_target_doc_type              IN VARCHAR2,
    p_target_contractual_doctype  IN VARCHAR2
    ) RETURN VARCHAR2
    IS
    l_copy   VARCHAR2(1);
    l_start_copy   VARCHAR2(1);
    l_end_copy   VARCHAR2(1);
    l_api_name        CONSTANT VARCHAR2(30) := 'copy_allowed';

    BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Inside copy_allowed' );
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' recurring_yn is :'||p_delrec.recurring_yn);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' fixed_due_date_yn :'||p_delrec.fixed_due_date_yn);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' target doc type :'||p_target_doc_type);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' p_target_contractual_doctype :'||p_target_contractual_doctype);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' deliverable name :'||p_delrec.deliverable_name);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' deliverable id :'||p_delrec.deliverable_id);
      END IF;
                    --If not a recurring deliverable
                    IF p_delrec.recurring_yn = 'N' THEN
                        IF p_delrec.fixed_due_date_yn = 'Y' THEN
                        -- copy deliverable as is
                        l_copy := 'Y';
                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: msg1 :'||l_copy);
                            END IF;
                        ELSE -- p_delrec.fixed_due_date_yn = 'N'
                            IF p_delrec.relative_st_date_event_id is not null THEN
                                -- match the event doctype to target doctype
                                IF event_matches(p_target_doc_type
                                ,p_delrec.relative_st_date_event_id) THEN
                                --copy deliverable
                                l_copy := 'Y';
                                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: msg2 :'||l_copy);
                                    END IF;
                                ELSE
                                    l_copy :='N';
                                    IF p_target_contractual_doctype is not null THEN
                                    -- match the event doctype to p_target_contractual_doctype
                                        IF event_matches(p_target_contractual_doctype
                                            ,p_delrec.relative_st_date_event_id) THEN
                                            --copy deliverable
                                            l_copy := 'Y';
                                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                                '100: msg3 :'||l_copy);
                                            END IF;
                                        END IF; -- event_matches
                                    END IF; -- p_target_contractual_doctype is not null
                                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                            '100: msg4 :'||l_copy);
                                        END IF;
                                END IF; -- event_matches
                            ELSE -- start event id is null
                                l_copy := 'Y';
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                    '100: msg5 :'||l_copy);
                                END IF;
                            END IF; -- p_delrec.relative_st_date_event_id is not null

                        END IF; -- fixed_due_date_yn = 'Y'
                        --------------------------------------------------------
                    --If recurring deliverable
                    ELSIF p_delrec.recurring_yn = 'Y' THEN
                        l_end_copy := null;
                        l_start_copy := null;
                        -- check if the recurring del has a fixed start or end date
                        IF p_delrec.fixed_start_date is not null THEN
                            IF p_delrec.fixed_end_date is not null THEN
                                --copy deliverables
                                l_end_copy := 'Y';
                                l_start_copy := 'Y';
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                    '100: msg6 : both are Y');
                                END IF;
                            ELSE -- fixed end date is null
                            IF p_delrec.relative_end_date_event_id is not null THEN
                                IF event_matches(p_target_doc_type
                                   ,p_delrec.relative_end_date_event_id) THEN
                                    --copy deliverable
                                    l_end_copy := 'Y';
                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: end msg1 :'||l_end_copy);
                                    END IF;
                                ELSE
                                    l_end_copy := 'N';
                                    IF p_target_contractual_doctype is not null THEN
                                    -- match the event doctype to p_target_contractual_doctype
                                        IF event_matches(p_target_contractual_doctype
                                        ,p_delrec.relative_end_date_event_id) THEN
                                        --copy deliverable
                                        l_end_copy := 'Y';
                                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                                '100: end msg2 :'||l_end_copy);
                                            END IF;
                                        END IF;
                                     END IF;
                                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                            '100: end msg3 :'||l_end_copy);
                                        END IF;
                                END IF;  -- event matches
                            ELSE -- end date event is null
                                l_end_copy := 'Y';
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                    '100: end msg4 :'||l_end_copy);
                                END IF;
                            END IF; -- end_date event is not null
                            END IF; -- fixed_end_date is not null
                                l_start_copy := 'Y';
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                    '100: start msg5 :'||l_start_copy);
                                END IF;
                        ELSE  -- fixed start date is null
                          IF p_delrec.relative_st_date_event_id is not null THEN
                                IF event_matches(p_target_doc_type
                                   ,p_delrec.relative_st_date_event_id) THEN
                                    --copy deliverable
                                    l_start_copy := 'Y';
                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: start msg1 :'||l_start_copy);
                                    END IF;
                                ELSE
                                    l_start_copy := 'N';
                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: start msg2 :'||l_start_copy);
                                    END IF;
                                    IF p_target_contractual_doctype is not null THEN
                                        IF event_matches(p_target_contractual_doctype
                                            ,p_delrec.relative_st_date_event_id) THEN
                                            --copy deliverable
                                            l_start_copy := 'Y';
                                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                                '100: start msg3 :'||l_start_copy);
                                            END IF;
                                        END IF; -- event matches
                                    END IF; -- target contractual not null
                                 END IF; -- event matches
                          ELSE -- start date event id is null
                            l_start_copy := 'Y';
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                    '100: start msg4 :'||l_start_copy);
                                END IF;
                          END IF; -- st event id is not null
                            IF p_delrec.fixed_end_date is null THEN
                              IF p_delrec.relative_end_date_event_id is not null THEN
                                IF event_matches(p_target_doc_type
                                ,p_delrec.relative_end_date_event_id) THEN
                                    --copy deliverable
                                    l_end_copy := 'Y';
                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: start end msg1 :'||l_end_copy);
                                    END IF;
                                ELSE
                                   l_end_copy := 'N';
                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: start end msg2 :'||l_end_copy);
                                    END IF;
                                    IF p_target_contractual_doctype is not null THEN
                                    -- match the event doctype to p_target_contractual_doctype
                                        IF event_matches(p_target_contractual_doctype
                                        ,p_delrec.relative_end_date_event_id) THEN
                                        --copy deliverable
                                        l_end_copy := 'Y';
                                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                                '100: start end msg3 :'||l_end_copy);
                                            END IF;
                                        END IF; -- event matches
                                     END IF; -- target contractual not null
                                END IF; -- event matches
                              ELSE -- end event id is null
                                l_end_copy := 'Y';
                                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                        '100: start end msg4 :'||l_end_copy);
                                    END IF;
                              END IF; -- end event id is not null
                             ELSE -- fixed end date is not null
                               l_end_copy := 'Y';
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                    '100: start end msg5 :'||l_end_copy);
                                END IF;
                             END IF; -- fixed end date is null

                        END IF; -- fixed st date is null
                        IF l_end_copy = 'Y' AND
                           l_start_copy = 'Y' THEN
                           l_copy := 'Y';
                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                '100: final msg1 :'||l_copy);
                            END IF;
                        ELSE
                            l_copy := 'N';
                            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                                '100: final msg2 :'||l_copy);
                            END IF;
                        END IF;
                    END IF; -- recurring yn
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: final msg3 :'||l_copy);
      END IF;
    RETURN(l_copy);
    END copy_allowed;
----------------------------------------------------------

    /*** This API is invoked from OKC_TERMS_PVT.COPY_TC.
    Copies deliverables from source to target documents
    Template to template, Template to Business document
    Busdoc to busdoc of same or different types.
    The procedure will query deliverables from source
    business document WHERE amendment_operation is NOT 'DELETE'.
    (The reason of this check: In case of RFQ, amendments operation
    and descriptions are maintained in the current copy,
    hence all deletes are just soft deletes.
    So the copy procedure should not copy deliverables which
    were deleted from the RFQ during amendment).
    Bug#4126344
    p_carry_forward_ext_party_yn: If set to Y carry forward following attributes
    from source doc in busdoc to busdoc copy
     external_party_contact_id,
     external_party_id,
     external_party_site_id,
     external_party_role
    Else reset from parameters
    p_carry_forward_int_contact_yn: If set to Y carry forward following attributes from source doc in busdoc to busdoc copy
     internal_party_contact_id,
    ***/

    PROCEDURE copy_deliverables (
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
        p_source_doc_id             IN NUMBER,
        p_source_doc_type           IN VARCHAR2,
        p_target_doc_id             IN NUMBER,
        p_target_doc_type           IN VARCHAR2,
        p_target_doc_number         IN VARCHAR2,
        p_target_contractual_doctype IN VARCHAR2 default null,
        p_target_response_doctype    IN VARCHAR2 default null,
        p_initialize_status_yn      IN VARCHAR2 default 'Y',
        p_copy_del_attachments_yn   IN VARCHAR2 default 'Y',
        p_internal_party_id         IN NUMBER default null,
        p_reset_fixed_date_yn       IN VARCHAR2 default 'N',
        p_internal_contact_id       IN NUMBER default null,
        p_external_party_id         IN NUMBER default null,
        p_external_party_site_id    IN NUMBER default null,
        p_external_contact_id       IN NUMBER default null,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count                 OUT NOCOPY NUMBER,
        x_return_status             OUT NOCOPY VARCHAR2,
        p_carry_forward_ext_party_yn  IN  VARCHAR2 default 'N',
        p_carry_forward_int_contact_yn IN  VARCHAR2 default 'Y'
       ,p_add_only_amend_deliverables IN VARCHAR2 := 'N'
        )
    IS
    CURSOR del_cur IS
    SELECT *
    FROM OKC_DELIVERABLES s
    WHERE business_document_id = p_source_doc_id
    AND   business_document_version = -99
    AND   business_document_type = p_source_doc_type
    AND   NVL(amendment_operation,'NONE')<> 'DELETED'
    AND   NVL(summary_amend_operation_code,'NONE')<> 'DELETED'
    AND   recurring_del_parent_id is null
    AND  (( p_add_only_amend_deliverables = 'N')
          OR
         ( p_add_only_amend_deliverables = 'Y'
           AND  amendment_operation IS NOT NULL
          ))
    AND  (  (p_source_doc_type <> 'TEMPLATE')
             OR
             (  p_source_doc_type = 'TEMPLATE'
                AND NOT EXISTS ( SELECT 'Y'
                                   FROM okc_deliverables    t
                                 WHERE  t.original_deliverable_id   = s.original_deliverable_id
                                 AND    t.business_document_type    = p_target_doc_type
                                 AND    t.business_document_id      = p_target_doc_id
                                 AND    t.business_document_version = -99
                                )
              )
           )
    ;

    delRecTab           delRecTabType;
    delNewTab           delRecTabType;
    TYPE delIdRecType IS RECORD (del_id NUMBER,orig_del_id NUMBER);
    TYPE delIdTabType IS TABLE OF delIdRecType;
    delIdTab    delIdTabType;
    j PLS_INTEGER := 0;
    k PLS_INTEGER := 0;
    l_api_name      CONSTANT VARCHAR2(30) :='copy_deliverables';
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_deliverable_id    NUMBER;
    l_from_pk1_value    VARCHAR2(100);
    l_result            BOOLEAN;
    l_copy              VARCHAR2(1) := 'N';
    l_copy_attachments  VARCHAR2(1) := 'N';
        --ER strivedi
    l_doc_type_class okc_bus_doc_types_b.document_type_class%TYPE;

    -- 11.5.10+ code bug#4148082
    cursor getExtPartyRole is
    select resp.resp_party_code
    from okc_resp_parties_b resp, okc_bus_doc_types_b busdoc
    where resp.document_type_class = busdoc.document_type_class
    and resp.intent = busdoc.intent
    and resp.internal_external_flag = 'EXTERNAL'
    and busdoc.document_type = p_target_doc_type;
    l_ext_party_role  okc_resp_parties_b.resp_party_code%TYPE;

    --ER Structured Terms Authoring in Repository strivedi
    CURSOR getRepDefaultInternalContactId IS
    SELECT pf.person_id contact_id
    FROM  per_all_workforce_v  pf,fnd_user fu
    WHERE fu.user_id = fnd_global.user_id
    AND   pf.person_id = fu.employee_id;
    l_rep_dflt_int_contact_id okc_deliverables.INTERNAL_PARTY_CONTACT_ID%TYPE;
    --End of ER Code Modifications

    BEGIN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables');
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: budoc id is:'||to_char(p_target_doc_id));
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: budoc type:'||p_target_doc_type);
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: target contractual doctype:'||p_target_contractual_doctype);
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: target response doctype:'||p_target_response_doctype);
            END IF;
                -- initialize the table type variable
                delIdTab := delIdTabType();

        FOR del_rec IN del_cur LOOP

      k := k+1;
      delRecTab(k).deliverable_id := del_rec.deliverable_id;
      delRecTab(k).BUSINESS_DOCUMENT_TYPE:= del_rec.BUSINESS_DOCUMENT_TYPE;
      delRecTab(k).BUSINESS_DOCUMENT_ID:= del_rec.BUSINESS_DOCUMENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_NUMBER:= del_rec.BUSINESS_DOCUMENT_NUMBER;
      delRecTab(k).DELIVERABLE_TYPE:= del_rec.DELIVERABLE_TYPE;
      delRecTab(k).RESPONSIBLE_PARTY:= del_rec.RESPONSIBLE_PARTY;
      delRecTab(k).INTERNAL_PARTY_CONTACT_ID:= del_rec.INTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).EXTERNAL_PARTY_CONTACT_ID:= del_rec.EXTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).DELIVERABLE_NAME:= del_rec.DELIVERABLE_NAME;
      delRecTab(k).DESCRIPTION:= del_rec.DESCRIPTION;
      delRecTab(k).COMMENTS:= del_rec.COMMENTS;
      delRecTab(k).DISPLAY_SEQUENCE:= del_rec.DISPLAY_SEQUENCE;
      delRecTab(k).FIXED_DUE_DATE_YN:= del_rec.FIXED_DUE_DATE_YN;
      delRecTab(k).ACTUAL_DUE_DATE:= del_rec.ACTUAL_DUE_DATE;
      delRecTab(k).PRINT_DUE_DATE_MSG_NAME:= del_rec.PRINT_DUE_DATE_MSG_NAME;
      delRecTab(k).RECURRING_YN:= del_rec.RECURRING_YN;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_UOM:= del_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_YN:= del_rec.NOTIFY_PRIOR_DUE_DATE_YN;
      delRecTab(k).NOTIFY_COMPLETED_YN:= del_rec.NOTIFY_COMPLETED_YN;
      delRecTab(k).NOTIFY_OVERDUE_YN:= del_rec.NOTIFY_OVERDUE_YN;
      delRecTab(k).NOTIFY_ESCALATION_YN:= del_rec.NOTIFY_ESCALATION_YN;
      delRecTab(k).NOTIFY_ESCALATION_VALUE:= del_rec.NOTIFY_ESCALATION_VALUE;
      delRecTab(k).NOTIFY_ESCALATION_UOM:= del_rec.NOTIFY_ESCALATION_UOM;
      delRecTab(k).ESCALATION_ASSIGNEE:= del_rec.ESCALATION_ASSIGNEE;
      delRecTab(k).AMENDMENT_OPERATION:= del_rec.AMENDMENT_OPERATION;
      delRecTab(k).PRIOR_NOTIFICATION_ID:= del_rec.PRIOR_NOTIFICATION_ID;
      delRecTab(k).AMENDMENT_NOTES:= del_rec.AMENDMENT_NOTES;
      delRecTab(k).COMPLETED_NOTIFICATION_ID:= del_rec.COMPLETED_NOTIFICATION_ID;
      delRecTab(k).OVERDUE_NOTIFICATION_ID:= del_rec.OVERDUE_NOTIFICATION_ID;
      delRecTab(k).ESCALATION_NOTIFICATION_ID:= del_rec.ESCALATION_NOTIFICATION_ID;
      delRecTab(k).LANGUAGE:= del_rec.LANGUAGE;
      delRecTab(k).ORIGINAL_DELIVERABLE_ID:= del_rec.ORIGINAL_DELIVERABLE_ID;
      delRecTab(k).REQUESTER_ID:= del_rec.REQUESTER_ID;
      delRecTab(k).EXTERNAL_PARTY_ID:= del_rec.EXTERNAL_PARTY_ID;
      delRecTab(k).EXTERNAL_PARTY_ROLE := del_rec.EXTERNAL_PARTY_ROLE;
      delRecTab(k).RECURRING_DEL_PARENT_ID:= del_rec.RECURRING_DEL_PARENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_VERSION:= del_rec.BUSINESS_DOCUMENT_VERSION;
      delRecTab(k).RELATIVE_ST_DATE_DURATION:= del_rec.RELATIVE_ST_DATE_DURATION;
      delRecTab(k).RELATIVE_ST_DATE_UOM:= del_rec.RELATIVE_ST_DATE_UOM;
      delRecTab(k).RELATIVE_ST_DATE_EVENT_ID:= del_rec.RELATIVE_ST_DATE_EVENT_ID;
      delRecTab(k).RELATIVE_END_DATE_DURATION:= del_rec.RELATIVE_END_DATE_DURATION;
      delRecTab(k).RELATIVE_END_DATE_UOM:= del_rec.RELATIVE_END_DATE_UOM;
      delRecTab(k).RELATIVE_END_DATE_EVENT_ID:= del_rec.RELATIVE_END_DATE_EVENT_ID;
      delRecTab(k).REPEATING_DAY_OF_MONTH:= del_rec.REPEATING_DAY_OF_MONTH;
      delRecTab(k).REPEATING_DAY_OF_WEEK:= del_rec.REPEATING_DAY_OF_WEEK;
      delRecTab(k).REPEATING_FREQUENCY_UOM:= del_rec.REPEATING_FREQUENCY_UOM;
      delRecTab(k).REPEATING_DURATION:= del_rec.REPEATING_DURATION;
      delRecTab(k).FIXED_START_DATE:= del_rec.FIXED_START_DATE;
      delRecTab(k).FIXED_END_DATE:= del_rec.FIXED_END_DATE;
      delRecTab(k).MANAGE_YN:= del_rec.MANAGE_YN;
      delRecTab(k).INTERNAL_PARTY_ID:= del_rec.INTERNAL_PARTY_ID;
      delRecTab(k).DELIVERABLE_STATUS:= del_rec.DELIVERABLE_STATUS;
      delRecTab(k).STATUS_CHANGE_NOTES:= del_rec.STATUS_CHANGE_NOTES;
      delRecTab(k).CREATED_BY:= del_rec.CREATED_BY;
      delRecTab(k).CREATION_DATE:= del_rec.CREATION_DATE;
      delRecTab(k).LAST_UPDATED_BY:= del_rec.LAST_UPDATED_BY;
      delRecTab(k).LAST_UPDATE_DATE:= del_rec.LAST_UPDATE_DATE;
      delRecTab(k).LAST_UPDATE_LOGIN:= del_rec.LAST_UPDATE_LOGIN;
      delRecTab(k).OBJECT_VERSION_NUMBER:= del_rec.OBJECT_VERSION_NUMBER;
      delRecTab(k).ATTRIBUTE_CATEGORY:= del_rec.ATTRIBUTE_CATEGORY;
      delRecTab(k).ATTRIBUTE1:= del_rec.ATTRIBUTE1;
      delRecTab(k).ATTRIBUTE2:= del_rec.ATTRIBUTE2;
      delRecTab(k).ATTRIBUTE3:= del_rec.ATTRIBUTE3;
      delRecTab(k).ATTRIBUTE4:= del_rec.ATTRIBUTE4;
      delRecTab(k).ATTRIBUTE5:= del_rec.ATTRIBUTE5;
      delRecTab(k).ATTRIBUTE6:= del_rec.ATTRIBUTE6;
      delRecTab(k).ATTRIBUTE7:= del_rec.ATTRIBUTE7;
      delRecTab(k).ATTRIBUTE8:= del_rec.ATTRIBUTE8;
      delRecTab(k).ATTRIBUTE9:= del_rec.ATTRIBUTE9;
      delRecTab(k).ATTRIBUTE10:= del_rec.ATTRIBUTE10;
      delRecTab(k).ATTRIBUTE11:= del_rec.ATTRIBUTE11;
      delRecTab(k).ATTRIBUTE12:= del_rec.ATTRIBUTE12;
      delRecTab(k).ATTRIBUTE13:= del_rec.ATTRIBUTE13;
      delRecTab(k).ATTRIBUTE14:= del_rec.ATTRIBUTE14;
      delRecTab(k).ATTRIBUTE15:= del_rec.ATTRIBUTE15;
      delRecTab(k).DISABLE_NOTIFICATIONS_YN:= del_rec.DISABLE_NOTIFICATIONS_YN;
      delRecTab(k).LAST_AMENDMENT_DATE:= del_rec.LAST_AMENDMENT_DATE;
      delRecTab(k).BUSINESS_DOCUMENT_LINE_ID:= del_rec.BUSINESS_DOCUMENT_LINE_ID;
      delRecTab(k).EXTERNAL_PARTY_SITE_ID:= del_rec.EXTERNAL_PARTY_SITE_ID;
      delRecTab(k).START_EVENT_DATE:= del_rec.START_EVENT_DATE;
      delRecTab(k).END_EVENT_DATE:= del_rec.END_EVENT_DATE;
      delRecTab(k).SUMMARY_AMEND_OPERATION_CODE:= del_rec.SUMMARY_AMEND_OPERATION_CODE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
      delRecTab(k).PAY_HOLD_OVERDUE_YN:=del_rec.PAY_HOLD_OVERDUE_YN;



            END LOOP;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
            -- commented as this is not supported by 8i PL/SQL Bug#3307941
            /*OPEN del_cur;
            FETCH del_cur BULK COLLECT INTO delRecTab;*/



        IF p_source_doc_type = 'TEMPLATE' THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Source doc is template');
            END IF;
            -- copy from template to template
            IF p_target_doc_type = 'TEMPLATE' THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Target doc is template');
            END IF;

               /*** OPEN del_cur;
                FETCH del_cur BULK COLLECT INTO delRecTab;**/
                IF delRecTab.COUNT <> 0 THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Number of records in delRecTab :'||to_char(delRecTab.COUNT));
                    END IF;
                FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
                    j := j+1;
                    -- extend table type
                    delIdTab.extend;
                    delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                    delNewTab(j) := delRecTab(i);
                    select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id from dual;
                    delIdTab(j).del_id := delNewTab(j).deliverable_id;
                    delNewTab(j).original_deliverable_id :=  delNewTab(j).deliverable_id;
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: New Deliverable Id :'||to_char(delNewTab(j).deliverable_id));
                    END IF;
                    -- bug# 4335441 If p_internal_party_id is not null then assign it to new Template
                    IF p_internal_party_id is not null THEN
                        delNewTab(j).internal_party_id := p_internal_party_id;
                    END IF;

                END LOOP;
                END IF;-- cur_del%notfound
---------------------------------------------------------------------------------
            -- copy from template to business document
            -- example template to RFQ
            ELSIF p_target_doc_type <> 'TEMPLATE' THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Target doc is not template');
            END IF;

                IF p_target_contractual_doctype is not null THEN
               /*** OPEN del_cur;
                FETCH del_cur BULK COLLECT INTO delRecTab;***/
                IF delRecTab.COUNT <> 0 THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'100: target_contractual_doctype is not null and '||
                        'Number of records in delRecTab :'||to_char(delRecTab.COUNT));
                    END IF;
                FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
                    -- initialize
                    l_copy := 'N';
                    l_copy := copy_allowed (delRecTab(i),p_target_doc_type,
                    p_target_contractual_doctype);
                    IF l_copy = 'Y' THEN
                        j := j+1;
                        -- extend table type
                        delIdTab.extend;
                        delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                        delNewTab(j) := delRecTab(i);
                        select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id
                        from dual;
                        delIdTab(j).del_id := delNewTab(j).deliverable_id;
                        -- If party and contact info is null then assign the parameter values
                        delNewTab(j).internal_party_id :=
                        NVL(delNewTab(j).internal_party_id,p_internal_party_id);
                        delNewTab(j).internal_party_contact_id :=
                        NVL(delNewTab(j).internal_party_contact_id,p_internal_contact_id);
                        -- Nullout external party attributes as there are no external
                        -- parties on Negotiation document
                        delNewTab(j).external_party_contact_id := null;
                        delNewTab(j).external_party_id := null;
            delNewTab(j).external_party_role := null;
                        delNewTab(j).external_party_site_id := null;
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                            '100: New Deliverable Id :'||to_char(delNewTab(j).deliverable_id));
                        END IF;
                    ELSIF l_copy = 'N' AND p_target_response_doctype is not null THEN
                        l_copy := copy_response_allowed (delRecTab(i),p_target_response_doctype,p_target_doc_type);
                            IF l_copy = 'Y' THEN
                                j := j+1;
                                -- extend table type
                                delIdTab.extend;
                                delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                                delNewTab(j) := delRecTab(i);
                                select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id
                                from dual;
                                delIdTab(j).del_id := delNewTab(j).deliverable_id;
                                -- If party and contact info is null then assign the parameter values
                                delNewTab(j).internal_party_id :=
                                NVL(delNewTab(j).internal_party_id,p_internal_party_id);
                                delNewTab(j).internal_party_contact_id :=
                                NVL(delNewTab(j).internal_party_contact_id,p_internal_contact_id);
                                -- Nullout external party attributes as there are no external
                                -- parties on Negotiation document
                                delNewTab(j).external_party_contact_id := null;
                                delNewTab(j).external_party_id := null;
              delNewTab(j).external_party_role := null;
                                delNewTab(j).external_party_site_id := null;
                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                                ,'100: New Deliverable Id from copy_response_allowed :'||
                                to_char(delNewTab(j).deliverable_id));
                                END IF;
                            END IF;
                    END IF;-- l_copy is 'Y'
                END LOOP;
                END IF; -- del_cur%NOTFOUND

                /*** This copy is from template to contract.
                Only contractual, internal purchasing deliverables are copied
                Template to SPO or RFI ****/
               ELSIF p_target_contractual_doctype is null THEN

                                -- bug#4148082 set ext party role during template to PO copy
                                OPEN getExtPartyRole;
                                FETCH getExtPartyRole INTO l_ext_party_role;
                                CLOSE getExtPartyRole;

				-- ER Structured Terms Authoring in Repository strivedi
                                OPEN getRepDefaultInternalContactId;
                                FETCH getRepDefaultInternalContactId INTO l_rep_dflt_int_contact_id;
                                CLOSE getRepDefaultInternalContactId;
                /***OPEN del_cur;
                FETCH del_cur BULK COLLECT INTO delRecTab;***/
                IF delRecTab.COUNT <> 0 THEN
                FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
                    -- initialize
                    l_copy := 'N';
                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                      '100: Old Deliverable Id :'||to_char(delRecTab(i).deliverable_id));
                   END IF;


                  --ER Repository Structured Terms Authoring
                  --  if the target document type is a repository contract type, then Change the deliverable type
                  --  from INTERNAL_PURCHASING to INTERNAL as  INTERNAL_PURCHASING is not supported by repository.
                  l_doc_type_class := getDocTypeClass(p_target_doc_type);

                  IF l_doc_type_class = 'REPOSITORY' THEN
                    IF delRecTab(i).deliverable_type = 'INTERNAL_PURCHASING' THEN
                      delRecTab(i).deliverable_type := 'INTERNAL';
                    END IF;

                    IF delRecTab(i).internal_party_contact_id IS NULL THEN
                       delRecTab(i).internal_party_contact_id := l_rep_dflt_int_contact_id;
                    END IF;
                    --No need of setting the External Party Role as this is done only for PO flow.
                    l_ext_party_role:=NULL;
                  END IF;
                  -- End of ER code modifications

                  --check if the deliverable is of contractual type
                  IF deltype_matches(delRecTab(i).deliverable_type,p_target_doc_type) = 'Y' THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Contractual is :Y');
                    END IF;
                    l_copy := copy_allowed (delRecTab(i),p_target_doc_type,
                    p_target_contractual_doctype);
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                      '100: Copy allowed is :'||l_copy);
                    END IF;
                  END IF; -- deltype_matches
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                      '100: Copy allowed is :'||l_copy);
                    END IF;

                    IF l_copy = 'Y' THEN
                        j := j+1;
                        -- extend table type
                        delIdTab.extend;
                        delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                        delNewTab(j) := delRecTab(i);
                        select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id
                        from dual;
                                -- If party and contact info is null then assign the parameter values
                                delNewTab(j).internal_party_id :=
                                NVL(delNewTab(j).internal_party_id,p_internal_party_id);
                                delNewTab(j).external_party_id :=
                                NVL(delNewTab(j).external_party_id,p_external_party_id);


                                delNewTab(j).external_party_site_id :=
                                NVL(delNewTab(j).external_party_site_id,p_external_party_site_id);
                                delNewTab(j).internal_party_contact_id :=
                                NVL(delNewTab(j).internal_party_contact_id,p_internal_contact_id);
                                -- bug#4148082 set ext party role during template to PO copy
                                delNewTab(j).external_party_role := l_ext_party_role;



                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                            '100: New Deliverable Id :'||to_char(delNewTab(j).deliverable_id));
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                            '100: External Party Role :'||delNewTab(j).external_party_role);
                        END IF;
                        delIdTab(j).del_id := delNewTab(j).deliverable_id;
                    ELSIF l_copy = 'N' AND p_target_response_doctype is not null THEN
                      --do not copy contractual type deliverables on to RFI bug#3641673
                      IF deltype_matches(delRecTab(i).deliverable_type,p_target_doc_type) = 'Y' THEN
                        l_copy := copy_response_allowed (delRecTab(i),p_target_response_doctype,p_target_doc_type);
                            IF l_copy = 'Y' THEN
                                j := j+1;
                                -- extend table type
                                delIdTab.extend;
                                delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                                delNewTab(j) := delRecTab(i);
                                select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id
                                from dual;
                                delIdTab(j).del_id := delNewTab(j).deliverable_id;
                                -- If party and contact info is null then assign the parameter values
                                delNewTab(j).internal_party_id :=
                                NVL(delNewTab(j).internal_party_id,p_internal_party_id);
                                delNewTab(j).internal_party_contact_id :=
                                NVL(delNewTab(j).internal_party_contact_id,p_internal_contact_id);
                                delNewTab(j).external_party_id :=
                                NVL(delNewTab(j).external_party_id,p_external_party_id);

                                delNewTab(j).external_party_site_id :=
                                NVL(delNewTab(j).external_party_site_id,p_external_party_site_id);

                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                                    ,'100: New Deliverable Id from copy_response_allowed :'||
                                    to_char(delNewTab(j).deliverable_id));
                                END IF;
                            END IF; -- l_copy is Y
                      END IF; -- deltype_matches
                    END IF;-- l_copy is 'Y'
                END LOOP;
                END IF; -- del_cur%NOTFOUND

               END IF; -- p_target_contractual_doctype
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;

            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
---------------------------------------------------------------------------------
        -- Busdoc to Busdoc copy
        ELSIF p_source_doc_type <> 'TEMPLATE' THEN
                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                      '100: Source doc is not template');
                   END IF;
---------------------------------------------------------------------------------
            -- copy from business document to business document of different type
            -- for example RFI to RFQ
            IF p_source_doc_type <> p_target_doc_type THEN
                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                      '100: Source doc and target doc are different type');
                   END IF;
            IF p_target_contractual_doctype is not null THEN

                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                      '100: p_target_contractual_doctype:'||p_target_contractual_doctype);
                   END IF;
                /***OPEN del_cur;
                FETCH del_cur BULK COLLECT INTO delRecTab;***/
                IF delRecTab.COUNT <> 0 THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'100: target_contractual_doctype is not null and '||
                        'Number of records in delRecTab :'||to_char(delRecTab.COUNT));
                    END IF;
                FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
                    -- initialize
                    l_copy := 'N';
                    l_copy := copy_allowed (delRecTab(i),p_target_doc_type,
                    p_target_contractual_doctype);
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: l_copy is :'||l_copy);
                        END IF;
                    IF l_copy = 'Y' THEN
                        j := j+1;
                        -- extend table type
                        delIdTab.extend;
                        delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                        delNewTab(j) := delRecTab(i);
                        select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id
                        from dual;
                        -- 11.5.10+ bug#3670582 fix reset original del id
                        delNewTab(j).original_deliverable_id := delNewTab(j).deliverable_id;


                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                            '100: New Deliverable Id :'||to_char(delNewTab(j).deliverable_id));
                        END IF;
                        delIdTab(j).del_id := delNewTab(j).deliverable_id;
                        /* Nullout all external party attributes on deliverables.
                        Because external party is not assigned on Negociation
                        documents (RFQ, Auction). */
                        --Bug#4126344
                        IF p_carry_forward_ext_party_yn <> 'Y' THEN
                            delNewTab(j).external_party_contact_id := null;
                            delNewTab(j).external_party_id := null;
                            delNewTab(j).external_party_site_id := null;
                        END IF; -- p_carry_forward_ext_party_yn <> 'Y'

                        --Bug#4126344 set the param value if the flag says N
                        IF p_carry_forward_int_contact_yn = 'N' THEN
                            delNewTab(j).INTERNAL_PARTY_CONTACT_ID := p_internal_contact_id;
                        END IF; -- p_carry_forward_int_contact_yn = 'N'

                        /* Nullout actual due date,start_event_date, end event_date
                        bug#3369934*/
                            delNewTab(j).actual_due_date:= null;
                            delNewTab(j).start_event_date:= null;
                            delNewTab(j).end_event_date:= null;

                    END IF;-- l_copy is 'Y'
                END LOOP;
               END IF; -- del_cur%NOTFOUND
---------------------------------------------------
            -- busdoc to busdoc of different types
            -- for example RFQ to SPO or BPA
                ELSIF p_target_contractual_doctype is null THEN
                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                      '100: p_target_contractual_doctype is null');
                   END IF;
                /***OPEN del_cur;
                FETCH del_cur BULK COLLECT INTO delRecTab;***/
                IF delRecTab.COUNT <> 0 THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'100: target_contractual_doctype is null and '||
                        'Number of records in delRecTab :'||to_char(delRecTab.COUNT));
                    END IF;
                FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
                    -- initialize
                    l_copy := 'N';
                    --check if the deliverable belongs to target document type
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                            '100: deltype :'||delRecTab(i).deliverable_type);
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                            '100: doctype :'||p_target_doc_type);
                        END IF;
                    IF deltype_matches(delRecTab(i).deliverable_type,p_target_doc_type) = 'Y' THEN

                    l_copy := copy_allowed (delRecTab(i),p_target_doc_type,
                    p_target_contractual_doctype);
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                            '100: l_copy is :'||l_copy);
                        END IF;
                    END IF; -- deltype_matches

                    IF l_copy = 'Y' THEN
                        j := j+1;
                        -- extend table type
                        delIdTab.extend;
                        delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                        delNewTab(j) := delRecTab(i);
                        select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id
                        from dual;
                        -- 11.5.10+ bug#3670582 fix reset original del id
                        delNewTab(j).original_deliverable_id := delNewTab(j).deliverable_id;

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                            '100: New Deliverable Id :'||to_char(delNewTab(j).deliverable_id));
                        END IF;
                        delIdTab(j).del_id := delNewTab(j).deliverable_id;
                        -- Bug#3308804 assign param values if they are not null
                        --Bug#4126344
                        IF p_carry_forward_ext_party_yn <> 'Y' THEN
                        delNewTab(j).external_party_id := NVL(p_external_party_id,delNewTab(j).external_party_id);
                        delNewTab(j).external_party_site_id := NVL(p_external_party_site_id,delNewTab(j).external_party_site_id);
                        END IF; -- p_carry_forward_ext_party_yn <> 'Y' THEN

                        --Bug#4126344 set the param value if the flag says N
                        IF p_carry_forward_int_contact_yn = 'N' THEN
                            delNewTab(j).INTERNAL_PARTY_CONTACT_ID := p_internal_contact_id;
                        END IF; -- p_carry_forward_int_contact_yn = 'N'
                        /* Nullout actual due date,start_event_date, end event_date
                        bug#3369934*/
                            delNewTab(j).actual_due_date:= null;
                            delNewTab(j).start_event_date:= null;
                            delNewTab(j).end_event_date:= null;

                    END IF;-- l_copy is 'Y'
                END LOOP;
                END IF; -- del_cur%NOTFOUND
                END IF; -- p_target_contractual_doctype
---------------------------------------------------------------------------------
            -- copy from business document to business document of same type
            -- for example RFQ to RFQ
            ELSIF p_source_doc_type = p_target_doc_type THEN
                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                      '100: Source doc and target doc are same type');
                   END IF;
               IF p_target_contractual_doctype is not null THEN

                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                      '100: p_target_contractual_doctype is not null');
                   END IF;
                /***OPEN del_cur;
                FETCH del_cur BULK COLLECT INTO delRecTab;***/
                IF delRecTab.COUNT <> 0 THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'100: target_contractual_doctype is not null and '||
                        'Number of records in delRecTab :'||to_char(delRecTab.COUNT));
                    END IF;
                FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
                    -- initialize
                    l_copy := 'N';
                    l_copy := copy_allowed (delRecTab(i),p_target_doc_type,
                    p_target_contractual_doctype);
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                            '100: l_copy is :'||l_copy);
                        END IF;
                    IF l_copy = 'Y' THEN
                        j := j+1;
                        -- extend table type
                        delIdTab.extend;
                        delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                        delNewTab(j) := delRecTab(i);
                        select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id
                        from dual;
                        -- 11.5.10+ bug#3670582 fix reset original del id
                        delNewTab(j).original_deliverable_id := delNewTab(j).deliverable_id;

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                            '100: New Deliverable Id :'||to_char(delNewTab(j).deliverable_id));
                        END IF;
                        delIdTab(j).del_id := delNewTab(j).deliverable_id;
                        /* Nullout all external party attributes on deliverables.
                        Because external party is not assigned on Negotiation
                        documents (RFQ, Auction). */
                        --Bug#4126344
                        IF p_carry_forward_ext_party_yn <> 'Y' THEN
                            delNewTab(j).external_party_contact_id := null;
                            delNewTab(j).external_party_id := null;
                            delNewTab(j).external_party_site_id := null;
                        END IF; -- p_carry_forward_ext_party_yn <> 'Y'

                        --Bug#4126344 set the param value if the flag says N
                        IF p_carry_forward_int_contact_yn = 'N' THEN
                            delNewTab(j).INTERNAL_PARTY_CONTACT_ID := p_internal_contact_id;
                        END IF; -- p_carry_forward_int_contact_yn = 'N'

                            /*bug#3455441 reset buyer contact while creating new busdoc
                            by copying from another busdoc of same type*/
                            delNewTab(j).internal_party_id := p_internal_party_id;
                            --commented the below line as bug#4126344 superceeds bug#3455441
                            --delNewTab(j).internal_party_contact_id := p_internal_contact_id;
                        /* Nullout actual due date,start_event_date, end event_date
                        bug#3369934*/
                            delNewTab(j).actual_due_date:= null;
                            delNewTab(j).start_event_date:= null;
                            delNewTab(j).end_event_date:= null;

                            /**bug#3262940 added copy target_response_doctype deliverables logic
                            to support RFQ to RFQ copy case ********/

                    ELSIF l_copy = 'N' AND p_target_response_doctype is not null THEN
                        l_copy := copy_response_allowed (delRecTab(i),p_target_response_doctype,p_target_doc_type);
                            IF l_copy = 'Y' THEN
                                j := j+1;
                                -- extend table type
                                delIdTab.extend;
                                delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                                delNewTab(j) := delRecTab(i);
                                select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id
                                from dual;
                                -- 11.5.10+ bug#3670582 fix reset original del id
                                delNewTab(j).original_deliverable_id := delNewTab(j).deliverable_id;

                                delIdTab(j).del_id := delNewTab(j).deliverable_id;
                                /* Nullout all external party attributes on deliverables.
                                Because external party is not assigned on Negotiation
                                documents (RFQ, Auction). */
                        --Bug#4126344
                        IF p_carry_forward_ext_party_yn <> 'Y' THEN
                                delNewTab(j).external_party_contact_id := null;
                                delNewTab(j).external_party_id := null;
                                delNewTab(j).external_party_site_id := null;
                        END IF; -- p_carry_forward_ext_party_yn <> 'Y'

                        --Bug#4126344 set the param value if the flag says N
                        IF p_carry_forward_int_contact_yn = 'N' THEN
                            delNewTab(j).INTERNAL_PARTY_CONTACT_ID := p_internal_contact_id;
                        END IF; -- p_carry_forward_int_contact_yn = 'N'

                                /*bug#3455441 reset buyer contact while creating new busdoc
                                by copying from another busdoc of same type*/
                                delNewTab(j).internal_party_id := p_internal_party_id;
                            --commented the below line as bug#4126344 superceeds bug#3455441
                            --delNewTab(j).internal_party_contact_id := p_internal_contact_id;
                                /* Nullout actual due date,start_event_date, end event_date
                                bug#3369934*/
                                delNewTab(j).actual_due_date:= null;
                                delNewTab(j).start_event_date:= null;
                                delNewTab(j).end_event_date:= null;

                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                                    ,'100: New Deliverable Id from copy_response_allowed :'||
                                    to_char(delNewTab(j).deliverable_id));
                                END IF;
                            END IF;

                    END IF;-- l_copy is 'Y'
                END LOOP;
                END IF; -- del_cur%NOTFOUND
             -- this is applicable to purchasing documents and RFIs
             ELSIF p_target_contractual_doctype is null THEN
                   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                      ,'100: p_target_contractual_doctype is null');
                   END IF;
                /***OPEN del_cur;
                FETCH del_cur BULK COLLECT INTO delRecTab;***/
                IF delRecTab.COUNT <> 0 THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'100: target_contractual_doctype is null and '||
                        'Number of records in delRecTab :'||to_char(delRecTab.COUNT));
                    END IF;
                FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
                    -- initialize
                    l_copy := 'N';
                    --check if the deliverable belongs to target document type
                    IF deltype_matches(delRecTab(i).deliverable_type,p_target_doc_type) = 'Y' THEN

                    l_copy := copy_allowed (delRecTab(i),p_target_doc_type,
                    p_target_contractual_doctype);
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                            '100: l_copy is :'||l_copy);
                        END IF;
                    END IF; -- deltype_matches

                    IF l_copy = 'Y' THEN
                        j := j+1;
                        -- extend table type
                        delIdTab.extend;
                        delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                        delNewTab(j) := delRecTab(i);
                        select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id
                        from dual;
                        -- 11.5.10+ bug#3670582 fix reset original del id
                        delNewTab(j).original_deliverable_id := delNewTab(j).deliverable_id;

                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                            ,'100: New Deliverable Id :'||to_char(delNewTab(j).deliverable_id));
                        END IF;
                        delIdTab(j).del_id := delNewTab(j).deliverable_id;
                        --Bug#4126344
                        IF p_carry_forward_ext_party_yn <> 'Y' THEN
                        delNewTab(j).external_party_id := p_external_party_id;
                        delNewTab(j).external_party_site_id := p_external_party_site_id;
                        END IF; -- p_carry_forward_ext_party_yn <> 'Y' THEN

                        --Bug#4126344 set the param value if the flag says N
                        IF p_carry_forward_int_contact_yn = 'N' THEN
                            delNewTab(j).INTERNAL_PARTY_CONTACT_ID := p_internal_contact_id;
                        END IF; -- p_carry_forward_int_contact_yn = 'N'

                            /*bug#3455441 reset buyer contact while creating new busdoc
                            by copying from another busdoc of same type*/
                            delNewTab(j).internal_party_id := p_internal_party_id;
                            --commented the below line as bug#4126344 superceeds bug#3455441
                            --delNewTab(j).internal_party_contact_id := p_internal_contact_id;
                        /* Nullout actual due date,start_event_date, end event_date
                        bug#3369934*/
                            delNewTab(j).actual_due_date:= null;
                            delNewTab(j).start_event_date:= null;
                            delNewTab(j).end_event_date:= null;
                    /*then check if response document event matches. this check is for RFI**/
                    ELSIF l_copy = 'N' AND p_target_response_doctype is not null THEN
                        l_copy := copy_response_allowed (delRecTab(i),p_target_response_doctype,p_target_doc_type);
                            IF l_copy = 'Y' THEN
                                j := j+1;
                                -- extend table type
                                delIdTab.extend;
                                delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                                delNewTab(j) := delRecTab(i);
                                select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id
                                from dual;
                                -- 11.5.10+ bug#3670582 fix reset original del id
                                delNewTab(j).original_deliverable_id := delNewTab(j).deliverable_id;

                                delIdTab(j).del_id := delNewTab(j).deliverable_id;
                                /* Nullout all external party attributes on deliverables.
                                Because external party is not assigned on Negotiation
                                documents (RFQ, Auction,RFI). */
                        --Bug#4126344
                        IF p_carry_forward_ext_party_yn <> 'Y' THEN
                                delNewTab(j).external_party_contact_id := null;
                                delNewTab(j).external_party_id := null;
                                delNewTab(j).external_party_site_id := null;
                        END IF; -- p_carry_forward_ext_party_yn <> 'Y'

                        --Bug#4126344 set the param value if the flag says N
                        IF p_carry_forward_int_contact_yn = 'N' THEN
                            delNewTab(j).INTERNAL_PARTY_CONTACT_ID := p_internal_contact_id;
                        END IF; -- p_carry_forward_int_contact_yn = 'N'

                                /*bug#3455441 reset buyer contact while creating new busdoc
                                by copying from another busdoc of same type*/
                                delNewTab(j).internal_party_id := p_internal_party_id;
                            --commented the below line as bug#4126344 superceeds bug#3455441
                            --delNewTab(j).internal_party_contact_id := p_internal_contact_id;
                                /* Nullout actual due date,start_event_date, end event_date
                                bug#3369934*/
                                delNewTab(j).actual_due_date:= null;
                                delNewTab(j).start_event_date:= null;
                                delNewTab(j).end_event_date:= null;

                                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                                    ,'100: New Deliverable Id from copy_response_allowed :'||
                                    to_char(delNewTab(j).deliverable_id));
                                END IF;
                            END IF;

                    END IF;-- l_copy is 'Y'
                END LOOP;
                END IF; -- del_cur%NOTFOUND
                END IF; -- p_target_contractual_doctype

            END IF;
        END IF;

        -- create deliverables for the target document
        IF delNewTab.COUNT <> 0 THEN
          FOR i IN delNewTab.FIRST..delNewTab.LAST LOOP
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                 ,'100: Create new Deliverables  :'||to_char(delNewTab(i).deliverable_id));
               END IF;
            delNewTab(i).business_document_id := p_target_doc_id;
            delNewTab(i).business_document_type := p_target_doc_type;
            delNewTab(i).business_document_number := p_target_doc_number;
            delNewTab(i).business_document_version := -99;
            delNewTab(i).created_by:= Fnd_Global.User_Id;
            delNewTab(i).creation_date := sysdate;
            delNewTab(i).last_updated_by:= Fnd_Global.User_Id;
            delNewTab(i).last_update_date := sysdate;
            delNewTab(i).last_update_login:=Fnd_Global.Login_Id;
            /*bug#3631944 flush amendment attributes at the time of copy.
            Since the target document will be a new document.*/
            delNewTab(i).amendment_operation := null;
            delNewTab(i).summary_amend_operation_code := null;
            delNewTab(i).amendment_notes := null;
            delNewTab(i).last_amendment_date := null;

                IF p_reset_fixed_date_yn = 'Y' THEN
                    --delNewTab(i).fixed_due_date_yn = 'Y' THEN  -- Bug#3369934 reset recurring dels also
                    delNewTab(i).fixed_start_date:= null;
                    delNewTab(i).fixed_end_date:= null;
                    -- bug#3465662 clear print due date msg name only for recurring deliverables
                    -- with fixed start or end dates
                    IF delNewTab(i).recurring_yn = 'Y' AND
                        (delNewTab(i).relative_st_date_event_id is null OR
                        delNewTab(i).relative_end_date_event_id is null) THEN
                        delNewTab(i).print_due_date_msg_name:= null;
                    END IF;
                END IF;
                IF p_initialize_status_yn = 'Y' THEN
                    delNewTab(i).deliverable_status := 'INACTIVE';
                END IF;
          END LOOP;
            /*FORALL i IN delNewTab.FIRST..delNewTab.LAST
            INSERT INTO okc_deliverables VALUES delNewTab(i);*/
                FOR i IN delNewTab.FIRST..delNewTab.LAST LOOP
                INSERT INTO okc_deliverables
                (DELIVERABLE_ID,
                BUSINESS_DOCUMENT_TYPE      ,
                BUSINESS_DOCUMENT_ID        ,
                BUSINESS_DOCUMENT_NUMBER    ,
                DELIVERABLE_TYPE            ,
                RESPONSIBLE_PARTY           ,
                INTERNAL_PARTY_CONTACT_ID   ,
                EXTERNAL_PARTY_CONTACT_ID   ,
                DELIVERABLE_NAME            ,
                DESCRIPTION                 ,
                COMMENTS                    ,
                DISPLAY_SEQUENCE            ,
                FIXED_DUE_DATE_YN           ,
                ACTUAL_DUE_DATE             ,
                PRINT_DUE_DATE_MSG_NAME     ,
                RECURRING_YN                ,
                NOTIFY_PRIOR_DUE_DATE_VALUE ,
                NOTIFY_PRIOR_DUE_DATE_UOM   ,
                NOTIFY_PRIOR_DUE_DATE_YN    ,
                NOTIFY_COMPLETED_YN         ,
                NOTIFY_OVERDUE_YN           ,
                NOTIFY_ESCALATION_YN        ,
                NOTIFY_ESCALATION_VALUE     ,
                NOTIFY_ESCALATION_UOM       ,
                ESCALATION_ASSIGNEE         ,
                AMENDMENT_OPERATION         ,
                PRIOR_NOTIFICATION_ID       ,
                AMENDMENT_NOTES             ,
                COMPLETED_NOTIFICATION_ID   ,
                OVERDUE_NOTIFICATION_ID     ,
                ESCALATION_NOTIFICATION_ID  ,
                LANGUAGE                    ,
                ORIGINAL_DELIVERABLE_ID     ,
                REQUESTER_ID                ,
                EXTERNAL_PARTY_ID           ,
                EXTERNAL_PARTY_ROLE           ,
                RECURRING_DEL_PARENT_ID      ,
                BUSINESS_DOCUMENT_VERSION   ,
                RELATIVE_ST_DATE_DURATION   ,
                RELATIVE_ST_DATE_UOM        ,
                RELATIVE_ST_DATE_EVENT_ID   ,
                RELATIVE_END_DATE_DURATION  ,
                RELATIVE_END_DATE_UOM       ,
                RELATIVE_END_DATE_EVENT_ID  ,
                REPEATING_DAY_OF_MONTH      ,
                REPEATING_DAY_OF_WEEK       ,
                REPEATING_FREQUENCY_UOM     ,
                REPEATING_DURATION          ,
                FIXED_START_DATE            ,
                FIXED_END_DATE              ,
                MANAGE_YN                   ,
                INTERNAL_PARTY_ID           ,
                DELIVERABLE_STATUS          ,
                STATUS_CHANGE_NOTES         ,
                CREATED_BY                  ,
                CREATION_DATE               ,
                LAST_UPDATED_BY             ,
                LAST_UPDATE_DATE            ,
                LAST_UPDATE_LOGIN           ,
                OBJECT_VERSION_NUMBER       ,
                ATTRIBUTE_CATEGORY          ,
                ATTRIBUTE1                  ,
                ATTRIBUTE2                  ,
                ATTRIBUTE3                  ,
                ATTRIBUTE4                  ,
                ATTRIBUTE5                  ,
                ATTRIBUTE6                  ,
                ATTRIBUTE7                  ,
                ATTRIBUTE8                  ,
                ATTRIBUTE9                  ,
                ATTRIBUTE10                 ,
                ATTRIBUTE11                 ,
                ATTRIBUTE12                 ,
                ATTRIBUTE13                 ,
                ATTRIBUTE14                 ,
                ATTRIBUTE15                 ,
                DISABLE_NOTIFICATIONS_YN    ,
                LAST_AMENDMENT_DATE         ,
                BUSINESS_DOCUMENT_LINE_ID   ,
                EXTERNAL_PARTY_SITE_ID      ,
                START_EVENT_DATE            ,
                END_EVENT_DATE              ,
                SUMMARY_AMEND_OPERATION_CODE,
                PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                PAY_HOLD_PRIOR_DUE_DATE_UOM,
                PAY_HOLD_PRIOR_DUE_DATE_YN,
                PAY_HOLD_OVERDUE_YN
                )
                VALUES (
                delNewTab(i).DELIVERABLE_ID,
                delNewTab(i).BUSINESS_DOCUMENT_TYPE      ,
                delNewTab(i).BUSINESS_DOCUMENT_ID        ,
                delNewTab(i).BUSINESS_DOCUMENT_NUMBER    ,
                delNewTab(i).DELIVERABLE_TYPE            ,
                delNewTab(i).RESPONSIBLE_PARTY           ,
                delNewTab(i).INTERNAL_PARTY_CONTACT_ID   ,
                delNewTab(i).EXTERNAL_PARTY_CONTACT_ID   ,
                delNewTab(i).DELIVERABLE_NAME            ,
                delNewTab(i).DESCRIPTION                 ,
                delNewTab(i).COMMENTS                    ,
                delNewTab(i).DISPLAY_SEQUENCE            ,
                delNewTab(i).FIXED_DUE_DATE_YN           ,
                delNewTab(i).ACTUAL_DUE_DATE             ,
                delNewTab(i).PRINT_DUE_DATE_MSG_NAME     ,
                delNewTab(i).RECURRING_YN                ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_UOM   ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_YN    ,
                delNewTab(i).NOTIFY_COMPLETED_YN         ,
                delNewTab(i).NOTIFY_OVERDUE_YN           ,
                delNewTab(i).NOTIFY_ESCALATION_YN        ,
                delNewTab(i).NOTIFY_ESCALATION_VALUE     ,
                delNewTab(i).NOTIFY_ESCALATION_UOM       ,
                delNewTab(i).ESCALATION_ASSIGNEE         ,
                delNewTab(i).AMENDMENT_OPERATION         ,
                delNewTab(i).PRIOR_NOTIFICATION_ID       ,
                delNewTab(i).AMENDMENT_NOTES             ,
                delNewTab(i).COMPLETED_NOTIFICATION_ID   ,
                delNewTab(i).OVERDUE_NOTIFICATION_ID     ,
                delNewTab(i).ESCALATION_NOTIFICATION_ID  ,
                delNewTab(i).LANGUAGE                    ,
                delNewTab(i).ORIGINAL_DELIVERABLE_ID     ,
                delNewTab(i).REQUESTER_ID                ,
                delNewTab(i).EXTERNAL_PARTY_ID           ,
                delNewTab(i).EXTERNAL_PARTY_ROLE           ,
                delNewTab(i).RECURRING_DEL_PARENT_ID      ,
                delNewTab(i).BUSINESS_DOCUMENT_VERSION   ,
                delNewTab(i).RELATIVE_ST_DATE_DURATION   ,
                delNewTab(i).RELATIVE_ST_DATE_UOM        ,
                delNewTab(i).RELATIVE_ST_DATE_EVENT_ID   ,
                delNewTab(i).RELATIVE_END_DATE_DURATION  ,
                delNewTab(i).RELATIVE_END_DATE_UOM       ,
                delNewTab(i).RELATIVE_END_DATE_EVENT_ID  ,
                delNewTab(i).REPEATING_DAY_OF_MONTH      ,
                delNewTab(i).REPEATING_DAY_OF_WEEK       ,
                delNewTab(i).REPEATING_FREQUENCY_UOM     ,
                delNewTab(i).REPEATING_DURATION          ,
                delNewTab(i).FIXED_START_DATE            ,
                delNewTab(i).FIXED_END_DATE              ,
                delNewTab(i).MANAGE_YN                   ,
                delNewTab(i).INTERNAL_PARTY_ID           ,
                delNewTab(i).DELIVERABLE_STATUS          ,
                delNewTab(i).STATUS_CHANGE_NOTES         ,
                delNewTab(i).CREATED_BY                  ,
                delNewTab(i).CREATION_DATE               ,
                delNewTab(i).LAST_UPDATED_BY             ,
                delNewTab(i).LAST_UPDATE_DATE            ,
                delNewTab(i).LAST_UPDATE_LOGIN           ,
                delNewTab(i).OBJECT_VERSION_NUMBER       ,
                delNewTab(i).ATTRIBUTE_CATEGORY          ,
                delNewTab(i).ATTRIBUTE1                  ,
                delNewTab(i).ATTRIBUTE2                  ,
                delNewTab(i).ATTRIBUTE3                  ,
                delNewTab(i).ATTRIBUTE4                  ,
                delNewTab(i).ATTRIBUTE5                  ,
                delNewTab(i).ATTRIBUTE6                  ,
                delNewTab(i).ATTRIBUTE7                  ,
                delNewTab(i).ATTRIBUTE8                  ,
                delNewTab(i).ATTRIBUTE9                  ,
                delNewTab(i).ATTRIBUTE10                 ,
                delNewTab(i).ATTRIBUTE11                 ,
                delNewTab(i).ATTRIBUTE12                 ,
                delNewTab(i).ATTRIBUTE13                 ,
                delNewTab(i).ATTRIBUTE14                 ,
                delNewTab(i).ATTRIBUTE15                 ,
                delNewTab(i).DISABLE_NOTIFICATIONS_YN    ,
                delNewTab(i).LAST_AMENDMENT_DATE         ,
                delNewTab(i).BUSINESS_DOCUMENT_LINE_ID   ,
                delNewTab(i).EXTERNAL_PARTY_SITE_ID      ,
                delNewTab(i).START_EVENT_DATE            ,
                delNewTab(i).END_EVENT_DATE              ,
                delNewTab(i).SUMMARY_AMEND_OPERATION_CODE,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_UOM,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_YN,
                delNewTab(i).PAY_HOLD_OVERDUE_YN
                );
                END LOOP;
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                 '100: Done Creating Deliverables ');
               END IF;
        END IF; -- delNewTab.COUNT <> 0
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                 '100: New Deliverables COUNT :'||to_char(delIdTab.COUNT));
               END IF;

        -- copy any existing attachments if allowed
        IF p_copy_del_attachments_yn = 'Y' THEN

          IF delIdTab.COUNT <> 0 THEN
          FOR i IN delIdTab.FIRST..delIdTab.LAST LOOP
            -- check if attachments exists
            IF attachment_exists(p_entity_name => G_ENTITY_NAME
                  ,p_pk1_value    =>  delIdTab(i).orig_del_id) THEN

               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                 '100: Copy Deliverable Attachments :'||to_char(delIdTab(i).del_id));
               END IF;
              -- copy attachments
              -- bug#3667712 added X_CREATED_BY,X_LAST_UPDATE_LOGIN params
              fnd_attached_documents2_pkg.copy_attachments(
                  X_from_entity_name =>  G_ENTITY_NAME,
                  X_from_pk1_value   =>  delIdTab(i).orig_del_id,
                  X_to_entity_name   =>  G_ENTITY_NAME,
                  X_to_pk1_value     =>  to_char(delIdTab(i).del_id),
                  X_CREATED_BY       =>  FND_GLOBAL.User_id,
                  X_LAST_UPDATE_LOGIN => Fnd_Global.Login_Id
                  );
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                 '100: Done Copy Deliverable Attachments ');
               END IF;
            END IF;
          END LOOP;
          END IF;
        END IF; -- p_copy_del_attachments_yn = 'Y'

        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        x_return_status := l_return_status;
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                '100: leaving OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables');
            END IF;
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name
                ,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables with G_EXC_ERROR: '||
                substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name
                ,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables with '||
                'G_EXC_UNEXPECTED_ERROR :'||substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name
                ,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.copy_deliverables with '||
                'G_EXC_UNEXPECTED_ERROR :'||substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END copy_deliverables;




/** Invoked by activate_deliverables group API
1.Copies recurring instances from previous signed document.
2.Copies instance of onetime deliverable from previous signed
document and deletes the definition on the current document.
3. Copies status history, attachments from the instance.
4. creation_date will be reset for recurring instances of deliverables
copied from currently managed version of document. The deliverable definitions and
onetime deliverable instances will carry forwad the creation_date from the definition.
bug#3702020 added following  clauses to filter deleted deliverable
    AND   NVL(amendment_operation,'NONE')<> 'DELETED'
    AND   NVL(summary_amend_operation_code,'NONE')<> 'DELETED'
**/
PROCEDURE sync_deliverables (
        p_api_version   IN NUMBER,
        p_init_msg_list IN VARCHAR2,
        p_current_docid        IN NUMBER,
        p_current_doctype      IN  VARCHAR2,
        p_current_doc_version        IN NUMBER,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2)
    IS

    CURSOR del_cur IS
    SELECT *
    FROM okc_deliverables
    WHERE business_document_id = p_current_docid
    AND   business_document_version = p_current_doc_version
    AND   business_document_type = p_current_doctype
    AND   NVL(amendment_operation,'NONE')<> 'DELETED'
    AND   NVL(summary_amend_operation_code,'NONE')<> 'DELETED'
    AND   manage_yn = 'N';
    del_rec del_cur%ROWTYPE;


    CURSOR del_ins_cur(x NUMBER) IS
    SELECT *
    FROM okc_deliverables a
    WHERE a.business_document_id = p_current_docid
    AND   a.business_document_type = p_current_doctype
    AND   a.business_document_version <> -99
    AND   a.original_deliverable_id = x
    AND   a.manage_yn = 'Y';
    del_ins_rec  del_ins_cur%ROWTYPE;

    CURSOR delStsHist(X NUMBER) IS
    SELECT *
    FROM okc_del_status_history
    WHERE deliverable_id = X;
    delStsHist_rec delStsHist%ROWTYPE;
    delHistTab    delHistTabType;

    CURSOR event_date_cursor(X NUMBER) IS
    select start_event_date, end_event_date
    from okc_deliverables
    where deliverable_id = X;
    event_date_rec   event_date_cursor%ROWTYPE;

    l_api_name      CONSTANT VARCHAR2(30) :='sync_deliverables';
    delRecTab       delRecTabType;
    delNewTab       delRecTabType;
    delInsTab       delRecTabType;
    l_deliverable_id NUMBER;
    j PLS_INTEGER := 0;
    q PLS_INTEGER := 0;
    k PLS_INTEGER := 0;
    m PLS_INTEGER := 0;
    p PLS_INTEGER := 0;
    TYPE delIdRecType IS RECORD (del_id NUMBER,orig_del_id NUMBER);
    TYPE delIdTabType IS TABLE OF delIdRecType;
    delIdTab    delIdTabType;
    l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
    l_recur_parent_id  NUMBER;

    BEGIN

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                ,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.sync_deliverables');
            END IF;


/*****
8i compatability bug#3307941
***/


    FOR del_rec IN del_cur LOOP
      k := k+1;
      delRecTab(k).deliverable_id := del_rec.deliverable_id;
      delRecTab(k).BUSINESS_DOCUMENT_TYPE:= del_rec.BUSINESS_DOCUMENT_TYPE;
      delRecTab(k).BUSINESS_DOCUMENT_ID:= del_rec.BUSINESS_DOCUMENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_NUMBER:= del_rec.BUSINESS_DOCUMENT_NUMBER;
      delRecTab(k).DELIVERABLE_TYPE:= del_rec.DELIVERABLE_TYPE;
      delRecTab(k).RESPONSIBLE_PARTY:= del_rec.RESPONSIBLE_PARTY;
      delRecTab(k).INTERNAL_PARTY_CONTACT_ID:= del_rec.INTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).EXTERNAL_PARTY_CONTACT_ID:= del_rec.EXTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).DELIVERABLE_NAME:= del_rec.DELIVERABLE_NAME;
      delRecTab(k).DESCRIPTION:= del_rec.DESCRIPTION;
      delRecTab(k).COMMENTS:= del_rec.COMMENTS;
      delRecTab(k).DISPLAY_SEQUENCE:= del_rec.DISPLAY_SEQUENCE;
      delRecTab(k).FIXED_DUE_DATE_YN:= del_rec.FIXED_DUE_DATE_YN;
      delRecTab(k).ACTUAL_DUE_DATE:= del_rec.ACTUAL_DUE_DATE;
      delRecTab(k).PRINT_DUE_DATE_MSG_NAME:= del_rec.PRINT_DUE_DATE_MSG_NAME;
      delRecTab(k).RECURRING_YN:= del_rec.RECURRING_YN;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_UOM:= del_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_YN:= del_rec.NOTIFY_PRIOR_DUE_DATE_YN;
      delRecTab(k).NOTIFY_COMPLETED_YN:= del_rec.NOTIFY_COMPLETED_YN;
      delRecTab(k).NOTIFY_OVERDUE_YN:= del_rec.NOTIFY_OVERDUE_YN;
      delRecTab(k).NOTIFY_ESCALATION_YN:= del_rec.NOTIFY_ESCALATION_YN;
      delRecTab(k).NOTIFY_ESCALATION_VALUE:= del_rec.NOTIFY_ESCALATION_VALUE;
      delRecTab(k).NOTIFY_ESCALATION_UOM:= del_rec.NOTIFY_ESCALATION_UOM;
      delRecTab(k).ESCALATION_ASSIGNEE:= del_rec.ESCALATION_ASSIGNEE;
      delRecTab(k).AMENDMENT_OPERATION:= del_rec.AMENDMENT_OPERATION;
      delRecTab(k).PRIOR_NOTIFICATION_ID:= del_rec.PRIOR_NOTIFICATION_ID;
      delRecTab(k).AMENDMENT_NOTES:= del_rec.AMENDMENT_NOTES;
      delRecTab(k).COMPLETED_NOTIFICATION_ID:= del_rec.COMPLETED_NOTIFICATION_ID;
      delRecTab(k).OVERDUE_NOTIFICATION_ID:= del_rec.OVERDUE_NOTIFICATION_ID;
      delRecTab(k).ESCALATION_NOTIFICATION_ID:= del_rec.ESCALATION_NOTIFICATION_ID;
      delRecTab(k).LANGUAGE:= del_rec.LANGUAGE;
      delRecTab(k).ORIGINAL_DELIVERABLE_ID:= del_rec.ORIGINAL_DELIVERABLE_ID;
      delRecTab(k).REQUESTER_ID:= del_rec.REQUESTER_ID;
      delRecTab(k).EXTERNAL_PARTY_ID:= del_rec.EXTERNAL_PARTY_ID;
      delRecTab(k).EXTERNAL_PARTY_ROLE:= del_rec.EXTERNAL_PARTY_ROLE;
      delRecTab(k).RECURRING_DEL_PARENT_ID:= del_rec.RECURRING_DEL_PARENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_VERSION:= del_rec.BUSINESS_DOCUMENT_VERSION;
      delRecTab(k).RELATIVE_ST_DATE_DURATION:= del_rec.RELATIVE_ST_DATE_DURATION;
      delRecTab(k).RELATIVE_ST_DATE_UOM:= del_rec.RELATIVE_ST_DATE_UOM;
      delRecTab(k).RELATIVE_ST_DATE_EVENT_ID:= del_rec.RELATIVE_ST_DATE_EVENT_ID;
      delRecTab(k).RELATIVE_END_DATE_DURATION:= del_rec.RELATIVE_END_DATE_DURATION;
      delRecTab(k).RELATIVE_END_DATE_UOM:= del_rec.RELATIVE_END_DATE_UOM;
      delRecTab(k).RELATIVE_END_DATE_EVENT_ID:= del_rec.RELATIVE_END_DATE_EVENT_ID;
      delRecTab(k).REPEATING_DAY_OF_MONTH:= del_rec.REPEATING_DAY_OF_MONTH;
      delRecTab(k).REPEATING_DAY_OF_WEEK:= del_rec.REPEATING_DAY_OF_WEEK;
      delRecTab(k).REPEATING_FREQUENCY_UOM:= del_rec.REPEATING_FREQUENCY_UOM;
      delRecTab(k).REPEATING_DURATION:= del_rec.REPEATING_DURATION;
      delRecTab(k).FIXED_START_DATE:= del_rec.FIXED_START_DATE;
      delRecTab(k).FIXED_END_DATE:= del_rec.FIXED_END_DATE;
      delRecTab(k).MANAGE_YN:= del_rec.MANAGE_YN;
      delRecTab(k).INTERNAL_PARTY_ID:= del_rec.INTERNAL_PARTY_ID;
      delRecTab(k).DELIVERABLE_STATUS:= del_rec.DELIVERABLE_STATUS;
      delRecTab(k).STATUS_CHANGE_NOTES:= del_rec.STATUS_CHANGE_NOTES;
      delRecTab(k).CREATED_BY:= del_rec.CREATED_BY;
      delRecTab(k).CREATION_DATE:= del_rec.CREATION_DATE;
      delRecTab(k).LAST_UPDATED_BY:= del_rec.LAST_UPDATED_BY;
      delRecTab(k).LAST_UPDATE_DATE:= del_rec.LAST_UPDATE_DATE;
      delRecTab(k).LAST_UPDATE_LOGIN:= del_rec.LAST_UPDATE_LOGIN;
      delRecTab(k).OBJECT_VERSION_NUMBER:= del_rec.OBJECT_VERSION_NUMBER;
      delRecTab(k).ATTRIBUTE_CATEGORY:= del_rec.ATTRIBUTE_CATEGORY;
      delRecTab(k).ATTRIBUTE1:= del_rec.ATTRIBUTE1;
      delRecTab(k).ATTRIBUTE2:= del_rec.ATTRIBUTE2;
      delRecTab(k).ATTRIBUTE3:= del_rec.ATTRIBUTE3;
      delRecTab(k).ATTRIBUTE4:= del_rec.ATTRIBUTE4;
      delRecTab(k).ATTRIBUTE5:= del_rec.ATTRIBUTE5;
      delRecTab(k).ATTRIBUTE6:= del_rec.ATTRIBUTE6;
      delRecTab(k).ATTRIBUTE7:= del_rec.ATTRIBUTE7;
      delRecTab(k).ATTRIBUTE8:= del_rec.ATTRIBUTE8;
      delRecTab(k).ATTRIBUTE9:= del_rec.ATTRIBUTE9;
      delRecTab(k).ATTRIBUTE10:= del_rec.ATTRIBUTE10;
      delRecTab(k).ATTRIBUTE11:= del_rec.ATTRIBUTE11;
      delRecTab(k).ATTRIBUTE12:= del_rec.ATTRIBUTE12;
      delRecTab(k).ATTRIBUTE13:= del_rec.ATTRIBUTE13;
      delRecTab(k).ATTRIBUTE14:= del_rec.ATTRIBUTE14;
      delRecTab(k).ATTRIBUTE15:= del_rec.ATTRIBUTE15;
      delRecTab(k).DISABLE_NOTIFICATIONS_YN:= del_rec.DISABLE_NOTIFICATIONS_YN;
      delRecTab(k).LAST_AMENDMENT_DATE:= del_rec.LAST_AMENDMENT_DATE;
      delRecTab(k).BUSINESS_DOCUMENT_LINE_ID:= del_rec.BUSINESS_DOCUMENT_LINE_ID;
      delRecTab(k).EXTERNAL_PARTY_SITE_ID:= del_rec.EXTERNAL_PARTY_SITE_ID;
      delRecTab(k).START_EVENT_DATE:= del_rec.START_EVENT_DATE;
      delRecTab(k).END_EVENT_DATE:= del_rec.END_EVENT_DATE;
      delRecTab(k).SUMMARY_AMEND_OPERATION_CODE:= del_rec.SUMMARY_AMEND_OPERATION_CODE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
      delRecTab(k).PAY_HOLD_OVERDUE_YN:=del_rec.PAY_HOLD_OVERDUE_YN;

            END LOOP;
        IF del_cur%ISOPEN THEN
          CLOSE del_cur ;
        END IF;



        /**commented as this is not supported by 8i PL/SQL Bug#3307941
        OPEN del_cur;
        FETCH del_cur BULK COLLECT INTO delDefRecTab;**/
        IF delRecTab.COUNT <> 0 THEN
           -- initialize the table type variable
           delIdTab := delIdTabType();
        FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                ,'100: Inside def cursor loop'||to_char(delRecTab(i).deliverable_id));
            END IF;


             -- if it is a recurrying deliverable
             IF delRecTab(i).recurring_yn = 'Y' THEN
----------------------------------
            --OPEN del_ins_cur(delRecTab(i).original_deliverable_id);
            --Initialize the table with 0 rows
            delInsTab.DELETE;
      m := 0;
            -- if deliverable is updated from onetime to recurring due to amendment
            -- don't copy the instance
        FOR del_ins_rec IN del_ins_cur(delRecTab(i).original_deliverable_id) LOOP
            IF del_ins_rec.recurring_yn = 'N' AND
                  del_ins_rec.recurring_del_parent_id is null THEN
                  null;
            ELSE
      m := m+1;
      delInsTab(m).deliverable_id := del_ins_rec.deliverable_id;
      delInsTab(m).BUSINESS_DOCUMENT_TYPE:= del_ins_rec.BUSINESS_DOCUMENT_TYPE;
      delInsTab(m).BUSINESS_DOCUMENT_ID:= del_ins_rec.BUSINESS_DOCUMENT_ID;
      delInsTab(m).BUSINESS_DOCUMENT_NUMBER:= del_ins_rec.BUSINESS_DOCUMENT_NUMBER;
      delInsTab(m).DELIVERABLE_TYPE:= del_ins_rec.DELIVERABLE_TYPE;
      delInsTab(m).RESPONSIBLE_PARTY:= del_ins_rec.RESPONSIBLE_PARTY;
      delInsTab(m).INTERNAL_PARTY_CONTACT_ID:= del_ins_rec.INTERNAL_PARTY_CONTACT_ID;
      delInsTab(m).EXTERNAL_PARTY_CONTACT_ID:= del_ins_rec.EXTERNAL_PARTY_CONTACT_ID;
      delInsTab(m).DELIVERABLE_NAME:= del_ins_rec.DELIVERABLE_NAME;
      delInsTab(m).DESCRIPTION:= del_ins_rec.DESCRIPTION;
      delInsTab(m).COMMENTS:= del_ins_rec.COMMENTS;
      delInsTab(m).DISPLAY_SEQUENCE:= del_ins_rec.DISPLAY_SEQUENCE;
      delInsTab(m).FIXED_DUE_DATE_YN:= del_ins_rec.FIXED_DUE_DATE_YN;
      delInsTab(m).ACTUAL_DUE_DATE:= del_ins_rec.ACTUAL_DUE_DATE;
      delInsTab(m).PRINT_DUE_DATE_MSG_NAME:= del_ins_rec.PRINT_DUE_DATE_MSG_NAME;
      delInsTab(m).RECURRING_YN:= del_ins_rec.RECURRING_YN;
      delInsTab(m).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
      delInsTab(m).NOTIFY_PRIOR_DUE_DATE_UOM:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
      delInsTab(m).NOTIFY_PRIOR_DUE_DATE_YN:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_YN;
      delInsTab(m).NOTIFY_COMPLETED_YN:= del_ins_rec.NOTIFY_COMPLETED_YN;
      delInsTab(m).NOTIFY_OVERDUE_YN:= del_ins_rec.NOTIFY_OVERDUE_YN;
      delInsTab(m).NOTIFY_ESCALATION_YN:= del_ins_rec.NOTIFY_ESCALATION_YN;
      delInsTab(m).NOTIFY_ESCALATION_VALUE:= del_ins_rec.NOTIFY_ESCALATION_VALUE;
      delInsTab(m).NOTIFY_ESCALATION_UOM:= del_ins_rec.NOTIFY_ESCALATION_UOM;
      delInsTab(m).ESCALATION_ASSIGNEE:= del_ins_rec.ESCALATION_ASSIGNEE;
      delInsTab(m).AMENDMENT_OPERATION:= del_ins_rec.AMENDMENT_OPERATION;
      delInsTab(m).PRIOR_NOTIFICATION_ID:= del_ins_rec.PRIOR_NOTIFICATION_ID;
      delInsTab(m).AMENDMENT_NOTES:= del_ins_rec.AMENDMENT_NOTES;
      delInsTab(m).COMPLETED_NOTIFICATION_ID:= del_ins_rec.COMPLETED_NOTIFICATION_ID;
      delInsTab(m).OVERDUE_NOTIFICATION_ID:= del_ins_rec.OVERDUE_NOTIFICATION_ID;
      delInsTab(m).ESCALATION_NOTIFICATION_ID:= del_ins_rec.ESCALATION_NOTIFICATION_ID;
      delInsTab(m).LANGUAGE:= del_ins_rec.LANGUAGE;
      delInsTab(m).ORIGINAL_DELIVERABLE_ID:= del_ins_rec.ORIGINAL_DELIVERABLE_ID;
      delInsTab(m).REQUESTER_ID:= del_ins_rec.REQUESTER_ID;
      delInsTab(m).EXTERNAL_PARTY_ID:= del_ins_rec.EXTERNAL_PARTY_ID;
      delInsTab(m).EXTERNAL_PARTY_ROLE:= del_ins_rec.EXTERNAL_PARTY_ROLE;
      delInsTab(m).RECURRING_DEL_PARENT_ID:= del_ins_rec.RECURRING_DEL_PARENT_ID;
      delInsTab(m).BUSINESS_DOCUMENT_VERSION:= del_ins_rec.BUSINESS_DOCUMENT_VERSION;
      delInsTab(m).RELATIVE_ST_DATE_DURATION:= del_ins_rec.RELATIVE_ST_DATE_DURATION;
      delInsTab(m).RELATIVE_ST_DATE_UOM:= del_ins_rec.RELATIVE_ST_DATE_UOM;
      delInsTab(m).RELATIVE_ST_DATE_EVENT_ID:= del_ins_rec.RELATIVE_ST_DATE_EVENT_ID;
      delInsTab(m).RELATIVE_END_DATE_DURATION:= del_ins_rec.RELATIVE_END_DATE_DURATION;
      delInsTab(m).RELATIVE_END_DATE_UOM:= del_ins_rec.RELATIVE_END_DATE_UOM;
      delInsTab(m).RELATIVE_END_DATE_EVENT_ID:= del_ins_rec.RELATIVE_END_DATE_EVENT_ID;
      delInsTab(m).REPEATING_DAY_OF_MONTH:= del_ins_rec.REPEATING_DAY_OF_MONTH;
      delInsTab(m).REPEATING_DAY_OF_WEEK:= del_ins_rec.REPEATING_DAY_OF_WEEK;
      delInsTab(m).REPEATING_FREQUENCY_UOM:= del_ins_rec.REPEATING_FREQUENCY_UOM;
      delInsTab(m).REPEATING_DURATION:= del_ins_rec.REPEATING_DURATION;
      delInsTab(m).FIXED_START_DATE:= del_ins_rec.FIXED_START_DATE;
      delInsTab(m).FIXED_END_DATE:= del_ins_rec.FIXED_END_DATE;
      delInsTab(m).MANAGE_YN:= del_ins_rec.MANAGE_YN;
      delInsTab(m).INTERNAL_PARTY_ID:= del_ins_rec.INTERNAL_PARTY_ID;
      delInsTab(m).DELIVERABLE_STATUS:= del_ins_rec.DELIVERABLE_STATUS;
      delInsTab(m).STATUS_CHANGE_NOTES:= del_ins_rec.STATUS_CHANGE_NOTES;
      delInsTab(m).CREATED_BY:= del_ins_rec.CREATED_BY;
      delInsTab(m).CREATION_DATE:= del_ins_rec.CREATION_DATE;
      delInsTab(m).LAST_UPDATED_BY:= del_ins_rec.LAST_UPDATED_BY;
      delInsTab(m).LAST_UPDATE_DATE:= del_ins_rec.LAST_UPDATE_DATE;
      delInsTab(m).LAST_UPDATE_LOGIN:= del_ins_rec.LAST_UPDATE_LOGIN;
      delInsTab(m).OBJECT_VERSION_NUMBER:= del_ins_rec.OBJECT_VERSION_NUMBER;
      delInsTab(m).ATTRIBUTE_CATEGORY:= del_ins_rec.ATTRIBUTE_CATEGORY;
      delInsTab(m).ATTRIBUTE1:= del_ins_rec.ATTRIBUTE1;
      delInsTab(m).ATTRIBUTE2:= del_ins_rec.ATTRIBUTE2;
      delInsTab(m).ATTRIBUTE3:= del_ins_rec.ATTRIBUTE3;
      delInsTab(m).ATTRIBUTE4:= del_ins_rec.ATTRIBUTE4;
      delInsTab(m).ATTRIBUTE5:= del_ins_rec.ATTRIBUTE5;
      delInsTab(m).ATTRIBUTE6:= del_ins_rec.ATTRIBUTE6;
      delInsTab(m).ATTRIBUTE7:= del_ins_rec.ATTRIBUTE7;
      delInsTab(m).ATTRIBUTE8:= del_ins_rec.ATTRIBUTE8;
      delInsTab(m).ATTRIBUTE9:= del_ins_rec.ATTRIBUTE9;
      delInsTab(m).ATTRIBUTE10:= del_ins_rec.ATTRIBUTE10;
      delInsTab(m).ATTRIBUTE11:= del_ins_rec.ATTRIBUTE11;
      delInsTab(m).ATTRIBUTE12:= del_ins_rec.ATTRIBUTE12;
      delInsTab(m).ATTRIBUTE13:= del_ins_rec.ATTRIBUTE13;
      delInsTab(m).ATTRIBUTE14:= del_ins_rec.ATTRIBUTE14;
      delInsTab(m).ATTRIBUTE15:= del_ins_rec.ATTRIBUTE15;
      delInsTab(m).DISABLE_NOTIFICATIONS_YN:= del_ins_rec.DISABLE_NOTIFICATIONS_YN;
      delInsTab(m).LAST_AMENDMENT_DATE:= del_ins_rec.LAST_AMENDMENT_DATE;
      delInsTab(m).BUSINESS_DOCUMENT_LINE_ID:= del_ins_rec.BUSINESS_DOCUMENT_LINE_ID;
      delInsTab(m).EXTERNAL_PARTY_SITE_ID:= del_ins_rec.EXTERNAL_PARTY_SITE_ID;
      delInsTab(m).START_EVENT_DATE:= del_ins_rec.START_EVENT_DATE;
      delInsTab(m).END_EVENT_DATE:= del_ins_rec.END_EVENT_DATE;
      delInsTab(m).SUMMARY_AMEND_OPERATION_CODE:= del_ins_rec.SUMMARY_AMEND_OPERATION_CODE;
      delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
      delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
      delInsTab(m).PAY_HOLD_OVERDUE_YN:=del_ins_rec.PAY_HOLD_OVERDUE_YN;

            END IF;
     END LOOP;
        IF del_ins_cur %ISOPEN THEN
          CLOSE del_ins_cur ;
        END IF;



--------------------------------------
                -- check for instances and copy instances from managing version
                /****
                commented as this is not supported by 8i PL/SQL Bug#3307941
                OPEN del_ins_cur(delRecTab(i).original_deliverable_id);
                FETCH del_ins_cur BULK COLLECT INTO delInsTab;*/
                IF delInsTab.COUNT <> 0 THEN
                   FOR k IN delInsTab.FIRST..delInsTab.LAST LOOP
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside Instance cursor loop');
                    END IF;
                        j:=j+1;
                        q:=q+1;
                        -- extend table type
                        delIdTab.extend;
                        -- build the id table to copy attachments
                        delIdTab(q).orig_del_id := delInsTab(k).deliverable_id;
                        -- build new version deliverables table
                        delNewTab(j):= delInsTab(k);
                        --store the recurring_del_parent_id in local variable
                        l_recur_parent_id := delInsTab(k).recurring_del_parent_id;
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Recur Id'||l_recur_parent_id);
                    END IF;
                        delNewTab(j).business_document_version := p_current_doc_version;
                        delNewTab(j).recurring_del_parent_id := delRecTab(i).deliverable_id;
                        select okc_deliverable_id_s.nextval
                        INTO delNewTab(j).deliverable_id from dual;
                        delIdTab(q).del_id := delNewTab(j).deliverable_id;
                        -- reset end date definition to new definition
                        delNewTab(j).RELATIVE_END_DATE_DURATION:=
                                            delRecTab(i).RELATIVE_END_DATE_DURATION;
                        delNewTab(j).RELATIVE_END_DATE_UOM:= delRecTab(i).RELATIVE_END_DATE_UOM;
                        delNewTab(j).RELATIVE_END_DATE_EVENT_ID:=
                                            delRecTab(i).RELATIVE_END_DATE_EVENT_ID;
                        delNewTab(j).FIXED_END_DATE:= delRecTab(i).FIXED_END_DATE;
                        -- Start 3711754 reset the contact ids and notification attributes from the definition
                        delNewTab(j).INTERNAL_PARTY_CONTACT_ID := delRecTab(i).INTERNAL_PARTY_CONTACT_ID;
                        delNewTab(j).EXTERNAL_PARTY_CONTACT_ID := delRecTab(i).EXTERNAL_PARTY_CONTACT_ID;
                        delNewTab(j).REQUESTER_ID := delRecTab(i).REQUESTER_ID;
                        delNewTab(j).comments:= delRecTab(i).comments;
                        delNewTab(j).NOTIFY_OVERDUE_YN := delRecTab(i).NOTIFY_OVERDUE_YN;
                        delNewTab(j).NOTIFY_COMPLETED_YN := delRecTab(i).NOTIFY_COMPLETED_YN;
                        -- Prior due date notification attributes
                        delNewTab(j).NOTIFY_PRIOR_DUE_DATE_YN := delRecTab(i).NOTIFY_PRIOR_DUE_DATE_YN;
                        delNewTab(j).NOTIFY_PRIOR_DUE_DATE_UOM := delRecTab(i).NOTIFY_PRIOR_DUE_DATE_UOM;
                        delNewTab(j).NOTIFY_PRIOR_DUE_DATE_VALUE := delRecTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE;
                        -- Escalation notification attributes
                        delNewTab(j).NOTIFY_ESCALATION_YN := delRecTab(i).NOTIFY_ESCALATION_YN;
                        delNewTab(j).NOTIFY_ESCALATION_UOM := delRecTab(i).NOTIFY_ESCALATION_UOM;
                        delNewTab(j).NOTIFY_ESCALATION_VALUE := delRecTab(i).NOTIFY_ESCALATION_VALUE;
                        delNewTab(j).ESCALATION_ASSIGNEE := delRecTab(i).ESCALATION_ASSIGNEE;
                        -- Reset the notification ids to null if deliverables are not fulfilled.
                        IF delNewTab(j).deliverable_status  = 'OPEN' OR
                           delNewTab(j).deliverable_status  = 'REJECTED' THEN
                           delNewTab(j).OVERDUE_NOTIFICATION_ID := null;
                           delNewTab(j).PRIOR_NOTIFICATION_ID := null;
                           delNewTab(j).ESCALATION_NOTIFICATION_ID := null;
                        END IF;
                        -- End 3711754 reset the contact ids and notification attributes from the definition

                        -- 3667445 Reset the creation_date and created_by for instances. 03-Jun-2004
                        delNewTab(j).creation_date := sysdate;
                        delNewTab(j).created_by := FND_GLOBAL.User_id;

			--bug 6055520
                        delNewTab(j).ATTRIBUTE_CATEGORY := delRecTab(i).ATTRIBUTE_CATEGORY;
                        delNewTab(j).ATTRIBUTE1 := delRecTab(i).ATTRIBUTE1;
                        delNewTab(j).ATTRIBUTE2 := delRecTab(i).ATTRIBUTE2;
                        delNewTab(j).ATTRIBUTE3 := delRecTab(i).ATTRIBUTE3;
                        delNewTab(j).ATTRIBUTE4 := delRecTab(i).ATTRIBUTE4;
                        delNewTab(j).ATTRIBUTE5 := delRecTab(i).ATTRIBUTE5;
                        delNewTab(j).ATTRIBUTE6 := delRecTab(i).ATTRIBUTE6;
                        delNewTab(j).ATTRIBUTE7 := delRecTab(i).ATTRIBUTE7;
                        delNewTab(j).ATTRIBUTE8 := delRecTab(i).ATTRIBUTE8;
                        delNewTab(j).ATTRIBUTE9 := delRecTab(i).ATTRIBUTE9;
                        delNewTab(j).ATTRIBUTE10 := delRecTab(i).ATTRIBUTE10;
                        delNewTab(j).ATTRIBUTE11 := delRecTab(i).ATTRIBUTE11;
                        delNewTab(j).ATTRIBUTE12 := delRecTab(i).ATTRIBUTE12;
                        delNewTab(j).ATTRIBUTE13 := delRecTab(i).ATTRIBUTE13;
                        delNewTab(j).ATTRIBUTE14 := delRecTab(i).ATTRIBUTE14;
                        delNewTab(j).ATTRIBUTE15 := delRecTab(i).ATTRIBUTE15;
			--bug 6055520

                        delNewTab(j).PAY_HOLD_PRIOR_DUE_DATE_VALUE := delRecTab(i).PAY_HOLD_PRIOR_DUE_DATE_VALUE;
                        delNewTab(j).PAY_HOLD_PRIOR_DUE_DATE_UOM := delRecTab(i).PAY_HOLD_PRIOR_DUE_DATE_UOM;
                        delNewTab(j).PAY_HOLD_PRIOR_DUE_DATE_YN := delRecTab(i).PAY_HOLD_PRIOR_DUE_DATE_YN;
                        delNewTab(j).PAY_HOLD_OVERDUE_YN := delRecTab(i).PAY_HOLD_OVERDUE_YN;



                    END LOOP;
                END IF;
        IF del_ins_cur %ISOPEN THEN
          CLOSE del_ins_cur ;
        END IF;

                --Assign start and end eventdates to the new definition from instance
                open event_date_cursor(l_recur_parent_id);
                fetch event_date_cursor INTO event_date_rec;
                IF event_date_cursor%FOUND THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'Def Id'||delRecTab(i).deliverable_id);
                    END IF;

                    Update okc_deliverables set start_event_date = event_date_rec.start_event_date,
                    end_event_date = event_date_rec.end_event_date
                    where deliverable_id = delRecTab(i).deliverable_id;


                END IF;
                close event_date_cursor;

             ELSIF delRecTab(i).recurring_yn = 'N' THEN

            --If the amendment_action on the deliverable definition
            --is null then open deliverable instance for the definition.
            --Add this deliverable record to delNewVersion Table.

            IF delRecTab(i).amendment_operation is null AND
               delRecTab(i).summary_amend_operation_code is null THEN -- bug#3656679
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: amendment_operation is null');
                END IF;
                -- Always copy instance from managing version
                -- do not copy definition
 ----------------------------------
            --OPEN del_ins_cur(delRecTab(i).original_deliverable_id);
            -- 02-FEB-2004 pnayani -- Fix for bug 3407758
            --Initialize the table with 0 rows
            delInsTab.DELETE;
      m := 0;
        FOR del_ins_rec IN del_ins_cur(delRecTab(i).original_deliverable_id) LOOP
      m := m+1;
      delInsTab(m).deliverable_id := del_ins_rec.deliverable_id;
      delInsTab(m).BUSINESS_DOCUMENT_TYPE:= del_ins_rec.BUSINESS_DOCUMENT_TYPE;
      delInsTab(m).BUSINESS_DOCUMENT_ID:= del_ins_rec.BUSINESS_DOCUMENT_ID;
      delInsTab(m).BUSINESS_DOCUMENT_NUMBER:= del_ins_rec.BUSINESS_DOCUMENT_NUMBER;
      delInsTab(m).DELIVERABLE_TYPE:= del_ins_rec.DELIVERABLE_TYPE;
      delInsTab(m).RESPONSIBLE_PARTY:= del_ins_rec.RESPONSIBLE_PARTY;
      delInsTab(m).INTERNAL_PARTY_CONTACT_ID:= del_ins_rec.INTERNAL_PARTY_CONTACT_ID;
      delInsTab(m).EXTERNAL_PARTY_CONTACT_ID:= del_ins_rec.EXTERNAL_PARTY_CONTACT_ID;
      delInsTab(m).DELIVERABLE_NAME:= del_ins_rec.DELIVERABLE_NAME;
      delInsTab(m).DESCRIPTION:= del_ins_rec.DESCRIPTION;
      delInsTab(m).COMMENTS:= del_ins_rec.COMMENTS;
      delInsTab(m).DISPLAY_SEQUENCE:= del_ins_rec.DISPLAY_SEQUENCE;
      delInsTab(m).FIXED_DUE_DATE_YN:= del_ins_rec.FIXED_DUE_DATE_YN;
      delInsTab(m).ACTUAL_DUE_DATE:= del_ins_rec.ACTUAL_DUE_DATE;
      delInsTab(m).PRINT_DUE_DATE_MSG_NAME:= del_ins_rec.PRINT_DUE_DATE_MSG_NAME;
      delInsTab(m).RECURRING_YN:= del_ins_rec.RECURRING_YN;
      delInsTab(m).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
      delInsTab(m).NOTIFY_PRIOR_DUE_DATE_UOM:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
      delInsTab(m).NOTIFY_PRIOR_DUE_DATE_YN:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_YN;
      delInsTab(m).NOTIFY_COMPLETED_YN:= del_ins_rec.NOTIFY_COMPLETED_YN;
      delInsTab(m).NOTIFY_OVERDUE_YN:= del_ins_rec.NOTIFY_OVERDUE_YN;
      delInsTab(m).NOTIFY_ESCALATION_YN:= del_ins_rec.NOTIFY_ESCALATION_YN;
      delInsTab(m).NOTIFY_ESCALATION_VALUE:= del_ins_rec.NOTIFY_ESCALATION_VALUE;
      delInsTab(m).NOTIFY_ESCALATION_UOM:= del_ins_rec.NOTIFY_ESCALATION_UOM;
      delInsTab(m).ESCALATION_ASSIGNEE:= del_ins_rec.ESCALATION_ASSIGNEE;
      delInsTab(m).AMENDMENT_OPERATION:= del_ins_rec.AMENDMENT_OPERATION;
      delInsTab(m).PRIOR_NOTIFICATION_ID:= del_ins_rec.PRIOR_NOTIFICATION_ID;
      delInsTab(m).AMENDMENT_NOTES:= del_ins_rec.AMENDMENT_NOTES;
      delInsTab(m).COMPLETED_NOTIFICATION_ID:= del_ins_rec.COMPLETED_NOTIFICATION_ID;
      delInsTab(m).OVERDUE_NOTIFICATION_ID:= del_ins_rec.OVERDUE_NOTIFICATION_ID;
      delInsTab(m).ESCALATION_NOTIFICATION_ID:= del_ins_rec.ESCALATION_NOTIFICATION_ID;
      delInsTab(m).LANGUAGE:= del_ins_rec.LANGUAGE;
      delInsTab(m).ORIGINAL_DELIVERABLE_ID:= del_ins_rec.ORIGINAL_DELIVERABLE_ID;
      delInsTab(m).REQUESTER_ID:= del_ins_rec.REQUESTER_ID;
      delInsTab(m).EXTERNAL_PARTY_ID:= del_ins_rec.EXTERNAL_PARTY_ID;
      delInsTab(m).EXTERNAL_PARTY_ROLE:= del_ins_rec.EXTERNAL_PARTY_ROLE;
      delInsTab(m).RECURRING_DEL_PARENT_ID:= del_ins_rec.RECURRING_DEL_PARENT_ID;
      delInsTab(m).BUSINESS_DOCUMENT_VERSION:= del_ins_rec.BUSINESS_DOCUMENT_VERSION;
      delInsTab(m).RELATIVE_ST_DATE_DURATION:= del_ins_rec.RELATIVE_ST_DATE_DURATION;
      delInsTab(m).RELATIVE_ST_DATE_UOM:= del_ins_rec.RELATIVE_ST_DATE_UOM;
      delInsTab(m).RELATIVE_ST_DATE_EVENT_ID:= del_ins_rec.RELATIVE_ST_DATE_EVENT_ID;
      delInsTab(m).RELATIVE_END_DATE_DURATION:= del_ins_rec.RELATIVE_END_DATE_DURATION;
      delInsTab(m).RELATIVE_END_DATE_UOM:= del_ins_rec.RELATIVE_END_DATE_UOM;
      delInsTab(m).RELATIVE_END_DATE_EVENT_ID:= del_ins_rec.RELATIVE_END_DATE_EVENT_ID;
      delInsTab(m).REPEATING_DAY_OF_MONTH:= del_ins_rec.REPEATING_DAY_OF_MONTH;
      delInsTab(m).REPEATING_DAY_OF_WEEK:= del_ins_rec.REPEATING_DAY_OF_WEEK;
      delInsTab(m).REPEATING_FREQUENCY_UOM:= del_ins_rec.REPEATING_FREQUENCY_UOM;
      delInsTab(m).REPEATING_DURATION:= del_ins_rec.REPEATING_DURATION;
      delInsTab(m).FIXED_START_DATE:= del_ins_rec.FIXED_START_DATE;
      delInsTab(m).FIXED_END_DATE:= del_ins_rec.FIXED_END_DATE;
      delInsTab(m).MANAGE_YN:= del_ins_rec.MANAGE_YN;
      delInsTab(m).INTERNAL_PARTY_ID:= del_ins_rec.INTERNAL_PARTY_ID;
      delInsTab(m).DELIVERABLE_STATUS:= del_ins_rec.DELIVERABLE_STATUS;
      delInsTab(m).STATUS_CHANGE_NOTES:= del_ins_rec.STATUS_CHANGE_NOTES;
      delInsTab(m).CREATED_BY:= del_ins_rec.CREATED_BY;
      delInsTab(m).CREATION_DATE:= del_ins_rec.CREATION_DATE;
      delInsTab(m).LAST_UPDATED_BY:= del_ins_rec.LAST_UPDATED_BY;
      delInsTab(m).LAST_UPDATE_DATE:= del_ins_rec.LAST_UPDATE_DATE;
      delInsTab(m).LAST_UPDATE_LOGIN:= del_ins_rec.LAST_UPDATE_LOGIN;
      delInsTab(m).OBJECT_VERSION_NUMBER:= del_ins_rec.OBJECT_VERSION_NUMBER;
      delInsTab(m).ATTRIBUTE_CATEGORY:= del_ins_rec.ATTRIBUTE_CATEGORY;
      delInsTab(m).ATTRIBUTE1:= del_ins_rec.ATTRIBUTE1;
      delInsTab(m).ATTRIBUTE2:= del_ins_rec.ATTRIBUTE2;
      delInsTab(m).ATTRIBUTE3:= del_ins_rec.ATTRIBUTE3;
      delInsTab(m).ATTRIBUTE4:= del_ins_rec.ATTRIBUTE4;
      delInsTab(m).ATTRIBUTE5:= del_ins_rec.ATTRIBUTE5;
      delInsTab(m).ATTRIBUTE6:= del_ins_rec.ATTRIBUTE6;
      delInsTab(m).ATTRIBUTE7:= del_ins_rec.ATTRIBUTE7;
      delInsTab(m).ATTRIBUTE8:= del_ins_rec.ATTRIBUTE8;
      delInsTab(m).ATTRIBUTE9:= del_ins_rec.ATTRIBUTE9;
      delInsTab(m).ATTRIBUTE10:= del_ins_rec.ATTRIBUTE10;
      delInsTab(m).ATTRIBUTE11:= del_ins_rec.ATTRIBUTE11;
      delInsTab(m).ATTRIBUTE12:= del_ins_rec.ATTRIBUTE12;
      delInsTab(m).ATTRIBUTE13:= del_ins_rec.ATTRIBUTE13;
      delInsTab(m).ATTRIBUTE14:= del_ins_rec.ATTRIBUTE14;
      delInsTab(m).ATTRIBUTE15:= del_ins_rec.ATTRIBUTE15;
      delInsTab(m).DISABLE_NOTIFICATIONS_YN:= del_ins_rec.DISABLE_NOTIFICATIONS_YN;
      delInsTab(m).LAST_AMENDMENT_DATE:= del_ins_rec.LAST_AMENDMENT_DATE;
      delInsTab(m).BUSINESS_DOCUMENT_LINE_ID:= del_ins_rec.BUSINESS_DOCUMENT_LINE_ID;
      delInsTab(m).EXTERNAL_PARTY_SITE_ID:= del_ins_rec.EXTERNAL_PARTY_SITE_ID;
      delInsTab(m).START_EVENT_DATE:= del_ins_rec.START_EVENT_DATE;
      delInsTab(m).END_EVENT_DATE:= del_ins_rec.END_EVENT_DATE;
      delInsTab(m).SUMMARY_AMEND_OPERATION_CODE:= del_ins_rec.SUMMARY_AMEND_OPERATION_CODE;
      delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
      delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
      delInsTab(m).PAY_HOLD_OVERDUE_YN:=del_ins_rec.PAY_HOLD_OVERDUE_YN;

     END LOOP;
        IF del_ins_cur %ISOPEN THEN
          CLOSE del_ins_cur ;
        END IF;
 ----------------------------------
                /****
                commented as this is not supported by 8i PL/SQL Bug#3307941
                OPEN del_ins_cur(delRecTab(i).original_deliverable_id);
                FETCH del_ins_cur BULK COLLECT INTO delInsTab;**/
                IF delInsTab.COUNT <> 0 THEN
                   FOR k IN delInsTab.FIRST..delInsTab.LAST LOOP
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside Instance cursor loop');
                    END IF;
                        j:=j+1;
                        q:=q+1;
                        -- extend table type
                        delIdTab.extend;
                        -- build the id table to copy attachments
                        delIdTab(q).orig_del_id := delInsTab(k).deliverable_id;
                        -- build new version deliverables table
                        delNewTab(j):= delInsTab(k);
                        select okc_deliverable_id_s.nextval
                        INTO delNewTab(j).deliverable_id from dual;
                        delNewTab(j).business_document_version := p_current_doc_version;
                        delIdTab(q).del_id := delNewTab(j).deliverable_id;
                        -- Resetting the amendment attributes to the definition values bug#3293314
                        delNewTab(j).AMENDMENT_OPERATION := delRecTab(i).amendment_operation;
                        delNewTab(j).SUMMARY_AMEND_OPERATION_CODE := delRecTab(i).summary_amend_operation_code;
                        delNewTab(j).LAST_AMENDMENT_DATE:= delRecTab(i).LAST_AMENDMENT_DATE;
                        delNewTab(j).AMENDMENT_NOTES:= delRecTab(i).AMENDMENT_NOTES;
                        -- Start 3711754 reset the contact ids and notification attributes from the definition
                        delNewTab(j).INTERNAL_PARTY_CONTACT_ID := delRecTab(i).INTERNAL_PARTY_CONTACT_ID;
                        delNewTab(j).EXTERNAL_PARTY_CONTACT_ID := delRecTab(i).EXTERNAL_PARTY_CONTACT_ID;
                        delNewTab(j).REQUESTER_ID := delRecTab(i).REQUESTER_ID;
                        delNewTab(j).comments:= delRecTab(i).comments;
                        delNewTab(j).NOTIFY_OVERDUE_YN := delRecTab(i).NOTIFY_OVERDUE_YN;
                        delNewTab(j).NOTIFY_COMPLETED_YN := delRecTab(i).NOTIFY_COMPLETED_YN;
                        -- Prior due date notification attributes
                        delNewTab(j).NOTIFY_PRIOR_DUE_DATE_YN := delRecTab(i).NOTIFY_PRIOR_DUE_DATE_YN;
                        delNewTab(j).NOTIFY_PRIOR_DUE_DATE_UOM := delRecTab(i).NOTIFY_PRIOR_DUE_DATE_UOM;
                        delNewTab(j).NOTIFY_PRIOR_DUE_DATE_VALUE := delRecTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE;
                        -- Escalation notification attributes
                        delNewTab(j).NOTIFY_ESCALATION_YN := delRecTab(i).NOTIFY_ESCALATION_YN;
                        delNewTab(j).NOTIFY_ESCALATION_UOM := delRecTab(i).NOTIFY_ESCALATION_UOM;
                        delNewTab(j).NOTIFY_ESCALATION_VALUE := delRecTab(i).NOTIFY_ESCALATION_VALUE;
                        delNewTab(j).ESCALATION_ASSIGNEE := delRecTab(i).ESCALATION_ASSIGNEE;
                        -- Reset the notification ids to null if deliverables are not fulfilled.
                        IF delNewTab(j).deliverable_status  = 'OPEN' OR
                           delNewTab(j).deliverable_status  = 'REJECTED' THEN
                           delNewTab(j).OVERDUE_NOTIFICATION_ID := null;
                           delNewTab(j).PRIOR_NOTIFICATION_ID := null;
                           delNewTab(j).ESCALATION_NOTIFICATION_ID := null;
                        END IF;
                        -- End 3711754 reset the contact ids and notification attributes from the definition

                        -- Bug 5911527. Reset the DFF values
                        delNewTab(j).ATTRIBUTE_CATEGORY := delRecTab(i).ATTRIBUTE_CATEGORY;
                        delNewTab(j).ATTRIBUTE1 := delRecTab(i).ATTRIBUTE1;
                        delNewTab(j).ATTRIBUTE2 := delRecTab(i).ATTRIBUTE2;
                        delNewTab(j).ATTRIBUTE3 := delRecTab(i).ATTRIBUTE3;
                        delNewTab(j).ATTRIBUTE4 := delRecTab(i).ATTRIBUTE4;
                        delNewTab(j).ATTRIBUTE5 := delRecTab(i).ATTRIBUTE5;
                        delNewTab(j).ATTRIBUTE6 := delRecTab(i).ATTRIBUTE6;
                        delNewTab(j).ATTRIBUTE7 := delRecTab(i).ATTRIBUTE7;
                        delNewTab(j).ATTRIBUTE8 := delRecTab(i).ATTRIBUTE8;
                        delNewTab(j).ATTRIBUTE9 := delRecTab(i).ATTRIBUTE9;
                        delNewTab(j).ATTRIBUTE10 := delRecTab(i).ATTRIBUTE10;
                        delNewTab(j).ATTRIBUTE11 := delRecTab(i).ATTRIBUTE11;
                        delNewTab(j).ATTRIBUTE12 := delRecTab(i).ATTRIBUTE12;
                        delNewTab(j).ATTRIBUTE13 := delRecTab(i).ATTRIBUTE13;
                        delNewTab(j).ATTRIBUTE14 := delRecTab(i).ATTRIBUTE14;
                        delNewTab(j).ATTRIBUTE15 := delRecTab(i).ATTRIBUTE15;

                        delNewTab(j).PAY_HOLD_PRIOR_DUE_DATE_VALUE := delRecTab(i).PAY_HOLD_PRIOR_DUE_DATE_VALUE;
                        delNewTab(j).PAY_HOLD_PRIOR_DUE_DATE_UOM := delRecTab(i).PAY_HOLD_PRIOR_DUE_DATE_UOM;
                        delNewTab(j).PAY_HOLD_PRIOR_DUE_DATE_YN := delRecTab(i).PAY_HOLD_PRIOR_DUE_DATE_YN;
                        delNewTab(j).PAY_HOLD_OVERDUE_YN := delRecTab(i).PAY_HOLD_OVERDUE_YN;


                    END LOOP;
                    -- delete the deliverable definition
                    delete_deliverable (
                    p_api_version  => l_api_version,
                    p_init_msg_list => OKC_API.G_FALSE,
                    p_del_id    => delRecTab(i).deliverable_id,
                    x_msg_data  => l_msg_data ,
                    x_msg_count => l_msg_count,
                    x_return_status  => l_return_status);

                    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF;

                END IF;
        IF del_ins_cur %ISOPEN THEN
          CLOSE del_ins_cur ;
        END IF;
             END IF;-- amendment_operation is null
             END IF; -- recurring_yn = 'Y'

        END  LOOP;-- delRecTab(i)
        END IF; --delRecTab.COUNT <> 0
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'outside def cursor loop');
                    END IF;

        --BULK INSERT into okc_deliverables the new version of deliverables.
        IF delNewTab.COUNT <> 0 THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Insert new version records');
                    END IF;
        -- update the who columns
        FOR j IN delNewTab.FIRST..delNewTab.LAST LOOP
        --3667445 do not reset creation date for definitions, reset only for instances
        -- of recurring deliverables
          -- delNewTab(j).creation_date := sysdate;
          -- delNewTab(j).created_by := FND_GLOBAL.User_id;
           delNewTab(j).last_update_date := sysdate;
           delNewTab(j).last_updated_by := FND_GLOBAL.User_id;
           delNewTab(j).last_update_login:= Fnd_Global.Login_Id;
           --copy status history not done as status is not being changed here
           --OPEN delStsHist(delNewTab(j).deliverable_id);
           /*FOR delStsHist_rec in delStsHist(delNewTab(j).deliverable_id) LOOP
           p := p+1;
           delHistTab(p).DELIVERABLE_ID := delStsHist_rec.DELIVERABLE_ID;
           delHistTab(p).DELIVERABLE_STATUS := delStsHist_rec.DELIVERABLE_STATUS;
           delHistTab(p).STATUS_CHANGED_BY := delStsHist_rec.STATUS_CHANGED_BY;
           delHistTab(p).STATUS_CHANGE_DATE := delStsHist_rec.STATUS_CHANGE_DATE;
           delHistTab(p).STATUS_CHANGE_NOTES := delStsHist_rec.STATUS_CHANGE_NOTES;
           delHistTab(p).OBJECT_VERSION_NUMBER := delStsHist_rec.OBJECT_VERSION_NUMBER;
           delHistTab(p).CREATED_BY := delStsHist_rec.CREATED_BY;
           delHistTab(p).CREATION_DATE := delStsHist_rec.CREATION_DATE;
           delHistTab(p).LAST_UPDATED_BY := delStsHist_rec.LAST_UPDATED_BY;
           delHistTab(p).LAST_UPDATE_DATE := delStsHist_rec.LAST_UPDATE_DATE;
           delHistTab(p).LAST_UPDATE_LOGIN := delStsHist_rec.LAST_UPDATE_LOGIN;

           END LOOP;
           IF delStsHist%ISOPEN THEN
            CLOSE  delStsHist;
           END IF;*/
           /* commented for 8i compatability bug#330794 major code change
           OPEN delStsHist(delNewTab(j).deliverable_id);
           FETCH delStsHist BULK COLLECT INTO delHistTab;*/
           /*IF delHistTab.COUNT <> 0 THEN
            FOR j IN delHistTab.FIRST..delHistTab.LAST LOOP
                delHistTab(j).deliverable_id := delNewTab(j).deliverable_id;
                delHistTab(j).creation_date := sysdate;
                delHistTab(j).created_by := FND_GLOBAL.User_id;
                delHistTab(j).last_update_date := sysdate;
                delHistTab(j).last_updated_by := FND_GLOBAL.User_id;
                delHistTab(j).last_update_login:= Fnd_Global.Login_Id;
            END LOOP;
           END IF;
           IF delStsHist%ISOPEN THEN
            CLOSE  delStsHist;
           END IF;*/
        END  LOOP;
        -- insert records code changed for 8i compatability bug#3307941
       /* commented for 8i compatability bug#330794 major code change
        FORALL j IN delNewTab.FIRST..delNewTab.LAST
        INSERT INTO okc_deliverables VALUES delNewTab(j);*/

        --------------------------------------------

                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Before insert');
                END IF;
                FOR i IN delNewTab.FIRST..delNewTab.LAST LOOP
                INSERT INTO okc_deliverables
                (DELIVERABLE_ID,
                BUSINESS_DOCUMENT_TYPE      ,
                BUSINESS_DOCUMENT_ID        ,
                BUSINESS_DOCUMENT_NUMBER    ,
                DELIVERABLE_TYPE            ,
                RESPONSIBLE_PARTY           ,
                INTERNAL_PARTY_CONTACT_ID   ,
                EXTERNAL_PARTY_CONTACT_ID   ,
                DELIVERABLE_NAME            ,
                DESCRIPTION                 ,
                COMMENTS                    ,
                DISPLAY_SEQUENCE            ,
                FIXED_DUE_DATE_YN           ,
                ACTUAL_DUE_DATE             ,
                PRINT_DUE_DATE_MSG_NAME     ,
                RECURRING_YN                ,
                NOTIFY_PRIOR_DUE_DATE_VALUE ,
                NOTIFY_PRIOR_DUE_DATE_UOM   ,
                NOTIFY_PRIOR_DUE_DATE_YN    ,
                NOTIFY_COMPLETED_YN         ,
                NOTIFY_OVERDUE_YN           ,
                NOTIFY_ESCALATION_YN        ,
                NOTIFY_ESCALATION_VALUE     ,
                NOTIFY_ESCALATION_UOM       ,
                ESCALATION_ASSIGNEE         ,
                AMENDMENT_OPERATION         ,
                PRIOR_NOTIFICATION_ID       ,
                AMENDMENT_NOTES             ,
                COMPLETED_NOTIFICATION_ID   ,
                OVERDUE_NOTIFICATION_ID     ,
                ESCALATION_NOTIFICATION_ID  ,
                LANGUAGE                    ,
                ORIGINAL_DELIVERABLE_ID     ,
                REQUESTER_ID                ,
                EXTERNAL_PARTY_ID           ,
                EXTERNAL_PARTY_ROLE           ,
                RECURRING_DEL_PARENT_ID      ,
                BUSINESS_DOCUMENT_VERSION   ,
                RELATIVE_ST_DATE_DURATION   ,
                RELATIVE_ST_DATE_UOM        ,
                RELATIVE_ST_DATE_EVENT_ID   ,
                RELATIVE_END_DATE_DURATION  ,
                RELATIVE_END_DATE_UOM       ,
                RELATIVE_END_DATE_EVENT_ID  ,
                REPEATING_DAY_OF_MONTH      ,
                REPEATING_DAY_OF_WEEK       ,
                REPEATING_FREQUENCY_UOM     ,
                REPEATING_DURATION          ,
                FIXED_START_DATE            ,
                FIXED_END_DATE              ,
                MANAGE_YN                   ,
                INTERNAL_PARTY_ID           ,
                DELIVERABLE_STATUS          ,
                STATUS_CHANGE_NOTES         ,
                CREATED_BY                  ,
                CREATION_DATE               ,
                LAST_UPDATED_BY             ,
                LAST_UPDATE_DATE            ,
                LAST_UPDATE_LOGIN           ,
                OBJECT_VERSION_NUMBER       ,
                ATTRIBUTE_CATEGORY          ,
                ATTRIBUTE1                  ,
                ATTRIBUTE2                  ,
                ATTRIBUTE3                  ,
                ATTRIBUTE4                  ,
                ATTRIBUTE5                  ,
                ATTRIBUTE6                  ,
                ATTRIBUTE7                  ,
                ATTRIBUTE8                  ,
                ATTRIBUTE9                  ,
                ATTRIBUTE10                 ,
                ATTRIBUTE11                 ,
                ATTRIBUTE12                 ,
                ATTRIBUTE13                 ,
                ATTRIBUTE14                 ,
                ATTRIBUTE15                 ,
                DISABLE_NOTIFICATIONS_YN    ,
                LAST_AMENDMENT_DATE         ,
                BUSINESS_DOCUMENT_LINE_ID   ,
                EXTERNAL_PARTY_SITE_ID      ,
                START_EVENT_DATE            ,
                END_EVENT_DATE              ,
                SUMMARY_AMEND_OPERATION_CODE,
                PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                PAY_HOLD_PRIOR_DUE_DATE_UOM,
                PAY_HOLD_PRIOR_DUE_DATE_YN,
                PAY_HOLD_OVERDUE_YN
                )
                VALUES (
                delNewTab(i).DELIVERABLE_ID,
                delNewTab(i).BUSINESS_DOCUMENT_TYPE      ,
                delNewTab(i).BUSINESS_DOCUMENT_ID        ,
                delNewTab(i).BUSINESS_DOCUMENT_NUMBER    ,
                delNewTab(i).DELIVERABLE_TYPE            ,
                delNewTab(i).RESPONSIBLE_PARTY           ,
                delNewTab(i).INTERNAL_PARTY_CONTACT_ID   ,
                delNewTab(i).EXTERNAL_PARTY_CONTACT_ID   ,
                delNewTab(i).DELIVERABLE_NAME            ,
                delNewTab(i).DESCRIPTION                 ,
                delNewTab(i).COMMENTS                    ,
                delNewTab(i).DISPLAY_SEQUENCE            ,
                delNewTab(i).FIXED_DUE_DATE_YN           ,
                delNewTab(i).ACTUAL_DUE_DATE             ,
                delNewTab(i).PRINT_DUE_DATE_MSG_NAME     ,
                delNewTab(i).RECURRING_YN                ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_UOM   ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_YN    ,
                delNewTab(i).NOTIFY_COMPLETED_YN         ,
                delNewTab(i).NOTIFY_OVERDUE_YN           ,
                delNewTab(i).NOTIFY_ESCALATION_YN        ,
                delNewTab(i).NOTIFY_ESCALATION_VALUE     ,
                delNewTab(i).NOTIFY_ESCALATION_UOM       ,
                delNewTab(i).ESCALATION_ASSIGNEE         ,
                delNewTab(i).AMENDMENT_OPERATION         ,
                delNewTab(i).PRIOR_NOTIFICATION_ID       ,
                delNewTab(i).AMENDMENT_NOTES             ,
                delNewTab(i).COMPLETED_NOTIFICATION_ID   ,
                delNewTab(i).OVERDUE_NOTIFICATION_ID     ,
                delNewTab(i).ESCALATION_NOTIFICATION_ID  ,
                delNewTab(i).LANGUAGE                    ,
                delNewTab(i).ORIGINAL_DELIVERABLE_ID     ,
                delNewTab(i).REQUESTER_ID                ,
                delNewTab(i).EXTERNAL_PARTY_ID           ,
                delNewTab(i).EXTERNAL_PARTY_ROLE           ,
                delNewTab(i).RECURRING_DEL_PARENT_ID      ,
                delNewTab(i).BUSINESS_DOCUMENT_VERSION   ,
                delNewTab(i).RELATIVE_ST_DATE_DURATION   ,
                delNewTab(i).RELATIVE_ST_DATE_UOM        ,
                delNewTab(i).RELATIVE_ST_DATE_EVENT_ID   ,
                delNewTab(i).RELATIVE_END_DATE_DURATION  ,
                delNewTab(i).RELATIVE_END_DATE_UOM       ,
                delNewTab(i).RELATIVE_END_DATE_EVENT_ID  ,
                delNewTab(i).REPEATING_DAY_OF_MONTH      ,
                delNewTab(i).REPEATING_DAY_OF_WEEK       ,
                delNewTab(i).REPEATING_FREQUENCY_UOM     ,
                delNewTab(i).REPEATING_DURATION          ,
                delNewTab(i).FIXED_START_DATE            ,
                delNewTab(i).FIXED_END_DATE              ,
                delNewTab(i).MANAGE_YN                   ,
                delNewTab(i).INTERNAL_PARTY_ID           ,
                delNewTab(i).DELIVERABLE_STATUS          ,
                delNewTab(i).STATUS_CHANGE_NOTES         ,
                delNewTab(i).CREATED_BY                  ,
                delNewTab(i).CREATION_DATE               ,
                delNewTab(i).LAST_UPDATED_BY             ,
                delNewTab(i).LAST_UPDATE_DATE            ,
                delNewTab(i).LAST_UPDATE_LOGIN           ,
                delNewTab(i).OBJECT_VERSION_NUMBER       ,
                delNewTab(i).ATTRIBUTE_CATEGORY          ,
                delNewTab(i).ATTRIBUTE1                  ,
                delNewTab(i).ATTRIBUTE2                  ,
                delNewTab(i).ATTRIBUTE3                  ,
                delNewTab(i).ATTRIBUTE4                  ,
                delNewTab(i).ATTRIBUTE5                  ,
                delNewTab(i).ATTRIBUTE6                  ,
                delNewTab(i).ATTRIBUTE7                  ,
                delNewTab(i).ATTRIBUTE8                  ,
                delNewTab(i).ATTRIBUTE9                  ,
                delNewTab(i).ATTRIBUTE10                 ,
                delNewTab(i).ATTRIBUTE11                 ,
                delNewTab(i).ATTRIBUTE12                 ,
                delNewTab(i).ATTRIBUTE13                 ,
                delNewTab(i).ATTRIBUTE14                 ,
                delNewTab(i).ATTRIBUTE15                 ,
                delNewTab(i).DISABLE_NOTIFICATIONS_YN    ,
                delNewTab(i).LAST_AMENDMENT_DATE         ,
                delNewTab(i).BUSINESS_DOCUMENT_LINE_ID   ,
                delNewTab(i).EXTERNAL_PARTY_SITE_ID      ,
                delNewTab(i).START_EVENT_DATE            ,
                delNewTab(i).END_EVENT_DATE              ,
                delNewTab(i).SUMMARY_AMEND_OPERATION_CODE,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_UOM,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_YN,
                delNewTab(i).PAY_HOLD_OVERDUE_YN
                );
                END LOOP;



        -------------------------------------------------

            FOR j IN delIdTab.FIRST..delIdTab.LAST LOOP

            --copy status history not done as status is not being changed here
            --OPEN delStsHist(delNewTab(j).deliverable_id);
            /* commented for 8i compatability bug#330794 major code change
            OPEN delStsHist(delNewTab(j).deliverable_id);
            FETCH delStsHist BULK COLLECT INTO delHistTab;*/
            FOR delStsHist_rec in delStsHist(delIdTab(j).orig_del_id) LOOP
            /*p := p+1;
            delHistTab(p).DELIVERABLE_ID := delIdTab(j).del_id;
            delHistTab(p).DELIVERABLE_STATUS := delStsHist_rec.DELIVERABLE_STATUS;
            delHistTab(p).STATUS_CHANGED_BY := delStsHist_rec.STATUS_CHANGED_BY;
            delHistTab(p).STATUS_CHANGE_DATE := delStsHist_rec.STATUS_CHANGE_DATE;
            delHistTab(p).STATUS_CHANGE_NOTES := delStsHist_rec.STATUS_CHANGE_NOTES;
            delHistTab(p).OBJECT_VERSION_NUMBER := delStsHist_rec.OBJECT_VERSION_NUMBER;
            delHistTab(p).CREATED_BY := FND_GLOBAL.User_id;
            delHistTab(p).CREATION_DATE := sysdate;
            delHistTab(p).LAST_UPDATED_BY := FND_GLOBAL.User_id;
            delHistTab(p).LAST_UPDATE_DATE := sysdate;
            delHistTab(p).LAST_UPDATE_LOGIN := Fnd_Global.Login_Id;*/

            --insert into status history
            INSERT INTO okc_del_status_history (
            deliverable_id,
            deliverable_status,
            status_changed_by,
            status_change_date,
            status_change_notes,
            object_version_number,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login)
            VALUES(
            delIdTab(j).del_id,
            delStsHist_rec.DELIVERABLE_STATUS,
            delStsHist_rec.STATUS_CHANGED_BY,
            delStsHist_rec.STATUS_CHANGE_DATE,
            delStsHist_rec.STATUS_CHANGE_NOTES,
            delStsHist_rec.OBJECT_VERSION_NUMBER,
            FND_GLOBAL.User_id,
            sysdate,
            FND_GLOBAL.User_id,
            sysdate,
            Fnd_Global.Login_Id);
                                                                                                                          END LOOP;
                                                                                                                            IF delStsHist%ISOPEN THEN
                  CLOSE  delStsHist;
              END IF;


        -------------------------------------------------
                IF attachment_exists(p_entity_name => G_ENTITY_NAME
                      ,p_pk1_value    =>  delIdTab(j).orig_del_id) THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: create attachments');
                    END IF;
                    -- copy attachments
                    -- bug#3667712 added X_CREATED_BY,X_LAST_UPDATE_LOGIN params
                    fnd_attached_documents2_pkg.copy_attachments(
                    X_from_entity_name =>  G_ENTITY_NAME,
                    X_from_pk1_value   =>  delIdTab(j).orig_del_id,
                    X_to_entity_name   =>  G_ENTITY_NAME,
                    X_to_pk1_value     =>  to_char(delIdTab(j).del_id),
                    X_CREATED_BY       =>  FND_GLOBAL.User_id,
                    X_LAST_UPDATE_LOGIN => Fnd_Global.Login_Id
                    );
                END IF;
            END LOOP;
        END IF; -- delNewTab.COUNT

        IF del_cur%ISOPEN THEN
          CLOSE del_cur ;
        END IF;


            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                ,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.sync_deliverables');
            END IF;

            x_return_status := l_return_status;
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name
                ,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.sync_deliverables with G_EXC_ERROR'||
                substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        IF delStsHist%ISOPEN THEN
          CLOSE delStsHist;
        END IF;
        IF del_ins_cur %ISOPEN THEN
          CLOSE del_ins_cur ;
        END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name
                ,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.sync_deliverables with G_EXC_UNEXPECTED_ERROR'||
                substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        IF del_ins_cur %ISOPEN THEN
          CLOSE del_ins_cur ;
        END IF;
        IF delStsHist%ISOPEN THEN
          CLOSE delStsHist;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name
          ,'100: In when others leaving OKC_DELIVERABLE_PROCESS_PVT.sync_deliverables with G_EXC_UNEXPECTED_ERROR'||substr(sqlerrm,1,200));
        END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        IF del_ins_cur %ISOPEN THEN
          CLOSE del_ins_cur ;
        END IF;
        IF delStsHist%ISOPEN THEN
          CLOSE delStsHist;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END sync_deliverables;




    /***This API is invoked from OKC_TERMS_PVT.VERSION_DOC.
    This API creates new set of deliverables for a given
    version of document.
    1.Gets all dliverable definitions for a given busdoc version
    2.Check if amendment operation code is null
        i.check if recurring deliverable
            a.copy definition
            b.open instances cursor and copy instances
        ii.if not recurring del
            a.copy instance of one time deliverable
    3.If amendment operation is not null
        i.amendment operation is DELETE and summary amendment operation
        is not null
            a.Recurring del then copy both def and instances
            b.One time del then copy only definition
        ii.amendment operation is UPDATE or ADDED
            a.Recurring del then copy both def and instances
            b.One time del then copy only definition
    4.Copy attachments
    ***/




    PROCEDURE version_deliverables (
        p_api_version   IN NUMBER,
        p_init_msg_list IN VARCHAR2,
        p_doc_id        IN NUMBER,
        p_doc_version   IN NUMBER,
        p_doc_type      IN  VARCHAR2,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2)
    IS

    CURSOR del_cur IS
    SELECT *
    FROM okc_deliverables
    WHERE business_document_id = p_doc_id
    AND   business_document_version = -99
    AND   business_document_type = p_doc_type
    AND   manage_yn = 'N';
    del_rec del_cur%ROWTYPE;


    l_api_name      CONSTANT VARCHAR2(30) :='version_deliverables';
    delRecTab       delRecTabType;
    delNewTab       delRecTabType;
    --delInsTab       delRecTabType;
    l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_deliverable_id NUMBER;
    j PLS_INTEGER := 0;
    k PLS_INTEGER := 0;
    q PLS_INTEGER := 0;
    TYPE delIdRecType IS RECORD (del_id NUMBER,orig_del_id NUMBER);
    TYPE delIdTabType IS TABLE OF delIdRecType;
    delIdTab    delIdTabType;

    BEGIN

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                ,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.version_deliverables');
            END IF;
----------------------------------------
/*****
8i compatability bug#3307941
***/


    FOR del_rec IN del_cur LOOP
      k := k+1;
      delRecTab(k).deliverable_id := del_rec.deliverable_id;
      delRecTab(k).BUSINESS_DOCUMENT_TYPE:= del_rec.BUSINESS_DOCUMENT_TYPE;
      delRecTab(k).BUSINESS_DOCUMENT_ID:= del_rec.BUSINESS_DOCUMENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_NUMBER:= del_rec.BUSINESS_DOCUMENT_NUMBER;
      delRecTab(k).DELIVERABLE_TYPE:= del_rec.DELIVERABLE_TYPE;
      delRecTab(k).RESPONSIBLE_PARTY:= del_rec.RESPONSIBLE_PARTY;
      delRecTab(k).INTERNAL_PARTY_CONTACT_ID:= del_rec.INTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).EXTERNAL_PARTY_CONTACT_ID:= del_rec.EXTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).DELIVERABLE_NAME:= del_rec.DELIVERABLE_NAME;
      delRecTab(k).DESCRIPTION:= del_rec.DESCRIPTION;
      delRecTab(k).COMMENTS:= del_rec.COMMENTS;
      delRecTab(k).DISPLAY_SEQUENCE:= del_rec.DISPLAY_SEQUENCE;
      delRecTab(k).FIXED_DUE_DATE_YN:= del_rec.FIXED_DUE_DATE_YN;
      delRecTab(k).ACTUAL_DUE_DATE:= del_rec.ACTUAL_DUE_DATE;
      delRecTab(k).PRINT_DUE_DATE_MSG_NAME:= del_rec.PRINT_DUE_DATE_MSG_NAME;
      delRecTab(k).RECURRING_YN:= del_rec.RECURRING_YN;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_UOM:= del_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_YN:= del_rec.NOTIFY_PRIOR_DUE_DATE_YN;
      delRecTab(k).NOTIFY_COMPLETED_YN:= del_rec.NOTIFY_COMPLETED_YN;
      delRecTab(k).NOTIFY_OVERDUE_YN:= del_rec.NOTIFY_OVERDUE_YN;
      delRecTab(k).NOTIFY_ESCALATION_YN:= del_rec.NOTIFY_ESCALATION_YN;
      delRecTab(k).NOTIFY_ESCALATION_VALUE:= del_rec.NOTIFY_ESCALATION_VALUE;
      delRecTab(k).NOTIFY_ESCALATION_UOM:= del_rec.NOTIFY_ESCALATION_UOM;
      delRecTab(k).ESCALATION_ASSIGNEE:= del_rec.ESCALATION_ASSIGNEE;
      delRecTab(k).AMENDMENT_OPERATION:= del_rec.AMENDMENT_OPERATION;
      delRecTab(k).PRIOR_NOTIFICATION_ID:= del_rec.PRIOR_NOTIFICATION_ID;
      delRecTab(k).AMENDMENT_NOTES:= del_rec.AMENDMENT_NOTES;
      delRecTab(k).COMPLETED_NOTIFICATION_ID:= del_rec.COMPLETED_NOTIFICATION_ID;
      delRecTab(k).OVERDUE_NOTIFICATION_ID:= del_rec.OVERDUE_NOTIFICATION_ID;
      delRecTab(k).ESCALATION_NOTIFICATION_ID:= del_rec.ESCALATION_NOTIFICATION_ID;
      delRecTab(k).LANGUAGE:= del_rec.LANGUAGE;
      delRecTab(k).ORIGINAL_DELIVERABLE_ID:= del_rec.ORIGINAL_DELIVERABLE_ID;
      delRecTab(k).REQUESTER_ID:= del_rec.REQUESTER_ID;
      delRecTab(k).EXTERNAL_PARTY_ID:= del_rec.EXTERNAL_PARTY_ID;
      delRecTab(k).EXTERNAL_PARTY_ROLE:= del_rec.EXTERNAL_PARTY_ROLE;
      delRecTab(k).RECURRING_DEL_PARENT_ID:= del_rec.RECURRING_DEL_PARENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_VERSION:= del_rec.BUSINESS_DOCUMENT_VERSION;
      delRecTab(k).RELATIVE_ST_DATE_DURATION:= del_rec.RELATIVE_ST_DATE_DURATION;
      delRecTab(k).RELATIVE_ST_DATE_UOM:= del_rec.RELATIVE_ST_DATE_UOM;
      delRecTab(k).RELATIVE_ST_DATE_EVENT_ID:= del_rec.RELATIVE_ST_DATE_EVENT_ID;
      delRecTab(k).RELATIVE_END_DATE_DURATION:= del_rec.RELATIVE_END_DATE_DURATION;
      delRecTab(k).RELATIVE_END_DATE_UOM:= del_rec.RELATIVE_END_DATE_UOM;
      delRecTab(k).RELATIVE_END_DATE_EVENT_ID:= del_rec.RELATIVE_END_DATE_EVENT_ID;
      delRecTab(k).REPEATING_DAY_OF_MONTH:= del_rec.REPEATING_DAY_OF_MONTH;
      delRecTab(k).REPEATING_DAY_OF_WEEK:= del_rec.REPEATING_DAY_OF_WEEK;
      delRecTab(k).REPEATING_FREQUENCY_UOM:= del_rec.REPEATING_FREQUENCY_UOM;
      delRecTab(k).REPEATING_DURATION:= del_rec.REPEATING_DURATION;
      delRecTab(k).FIXED_START_DATE:= del_rec.FIXED_START_DATE;
      delRecTab(k).FIXED_END_DATE:= del_rec.FIXED_END_DATE;
      delRecTab(k).MANAGE_YN:= del_rec.MANAGE_YN;
      delRecTab(k).INTERNAL_PARTY_ID:= del_rec.INTERNAL_PARTY_ID;
      delRecTab(k).DELIVERABLE_STATUS:= del_rec.DELIVERABLE_STATUS;
      delRecTab(k).STATUS_CHANGE_NOTES:= del_rec.STATUS_CHANGE_NOTES;
      delRecTab(k).CREATED_BY:= del_rec.CREATED_BY;
      delRecTab(k).CREATION_DATE:= del_rec.CREATION_DATE;
      delRecTab(k).LAST_UPDATED_BY:= del_rec.LAST_UPDATED_BY;
      delRecTab(k).LAST_UPDATE_DATE:= del_rec.LAST_UPDATE_DATE;
      delRecTab(k).LAST_UPDATE_LOGIN:= del_rec.LAST_UPDATE_LOGIN;
      delRecTab(k).OBJECT_VERSION_NUMBER:= del_rec.OBJECT_VERSION_NUMBER;
      delRecTab(k).ATTRIBUTE_CATEGORY:= del_rec.ATTRIBUTE_CATEGORY;
      delRecTab(k).ATTRIBUTE1:= del_rec.ATTRIBUTE1;
      delRecTab(k).ATTRIBUTE2:= del_rec.ATTRIBUTE2;
      delRecTab(k).ATTRIBUTE3:= del_rec.ATTRIBUTE3;
      delRecTab(k).ATTRIBUTE4:= del_rec.ATTRIBUTE4;
      delRecTab(k).ATTRIBUTE5:= del_rec.ATTRIBUTE5;
      delRecTab(k).ATTRIBUTE6:= del_rec.ATTRIBUTE6;
      delRecTab(k).ATTRIBUTE7:= del_rec.ATTRIBUTE7;
      delRecTab(k).ATTRIBUTE8:= del_rec.ATTRIBUTE8;
      delRecTab(k).ATTRIBUTE9:= del_rec.ATTRIBUTE9;
      delRecTab(k).ATTRIBUTE10:= del_rec.ATTRIBUTE10;
      delRecTab(k).ATTRIBUTE11:= del_rec.ATTRIBUTE11;
      delRecTab(k).ATTRIBUTE12:= del_rec.ATTRIBUTE12;
      delRecTab(k).ATTRIBUTE13:= del_rec.ATTRIBUTE13;
      delRecTab(k).ATTRIBUTE14:= del_rec.ATTRIBUTE14;
      delRecTab(k).ATTRIBUTE15:= del_rec.ATTRIBUTE15;
      delRecTab(k).DISABLE_NOTIFICATIONS_YN:= del_rec.DISABLE_NOTIFICATIONS_YN;
      delRecTab(k).LAST_AMENDMENT_DATE:= del_rec.LAST_AMENDMENT_DATE;
      delRecTab(k).BUSINESS_DOCUMENT_LINE_ID:= del_rec.BUSINESS_DOCUMENT_LINE_ID;
      delRecTab(k).EXTERNAL_PARTY_SITE_ID:= del_rec.EXTERNAL_PARTY_SITE_ID;
      delRecTab(k).START_EVENT_DATE:= del_rec.START_EVENT_DATE;
      delRecTab(k).END_EVENT_DATE:= del_rec.END_EVENT_DATE;
      delRecTab(k).SUMMARY_AMEND_OPERATION_CODE:= del_rec.SUMMARY_AMEND_OPERATION_CODE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
      delRecTab(k).PAY_HOLD_OVERDUE_YN:=del_rec.PAY_HOLD_OVERDUE_YN;

            END LOOP;
        IF del_cur%ISOPEN THEN
          CLOSE del_cur ;
        END IF;


        /* commented for 8i compatability bug#330794 major code change
        OPEN del_cur;
        FETCH del_cur BULK COLLECT INTO delRecTab;**/
        IF delRecTab.COUNT <> 0 THEN
           -- initialize the table type variable
           delIdTab := delIdTabType();
        FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside def cursor loop'||
                to_char(delRecTab(i).deliverable_id));
            END IF;

                /* bug#3630770 commented this code and moved to clear_amendment_operation
                   IF delRecTab(i).amendment_operation = 'DELETED' AND
                   delRecTab(i).summary_amend_operation_code is null THEN
                   -- Since the summary_amend_operation_code is null, the deliverable is not
                   -- existing in the signed contract, it was added and deleted in the intermediate
                   -- versions. So hard delete the record.
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'100: Amendment_operation_summary_code is null hard delete this deliverable'||
                        to_char(delRecTab(i).deliverable_id));
                    END IF;
                     delete from okc_deliverables where deliverable_id = delRecTab(i).deliverable_id;*/


                        j:=j+1;
                        q:=q+1;
                        -- extend table type
                        delIdTab.extend;
                        -- build the id table to copy attachments
                        delIdTab(q).orig_del_id := delRecTab(i).deliverable_id;
                        -- build new version deliverables table
                        delNewTab(j):= delRecTab(i);
                        --bug#3293314 update last amendment date only
                        --if they is an amendment on the deliverable
                        IF delRecTab(i).amendment_operation IS NOT NULL THEN
                            delNewTab(j).last_amendment_date :=  delRecTab(i).last_amendment_date;
                        END IF;
                        select okc_deliverable_id_s.nextval
                        INTO delNewTab(j).deliverable_id from dual;
                        delNewTab(j).business_document_version := p_doc_version;
                        delIdTab(q).del_id := delNewTab(j).deliverable_id;

        END  LOOP;-- delRecTab(i)
        END IF; --delRecTab.COUNT <> 0

        /***
        BULK INSERT into okc_deliverables the new version of deliverables.
        ***/
        IF delNewTab.COUNT <> 0 THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Insert new version records');
                    END IF;
        -- update the who columns
        FOR j IN delNewTab.FIRST..delNewTab.LAST LOOP
          -- do not reset the creation date bug#3641366
          -- delNewTab(j).creation_date := sysdate;
          -- delNewTab(j).created_by := FND_GLOBAL.User_id;
           delNewTab(j).last_update_date := sysdate;
           delNewTab(j).last_updated_by := FND_GLOBAL.User_id;
           delNewTab(j).last_update_login:= Fnd_Global.Login_Id;
        END  LOOP;
        ------------------------------------------


                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Before insert');
                END IF;
                FOR i IN delNewTab.FIRST..delNewTab.LAST LOOP
                INSERT INTO okc_deliverables
                (DELIVERABLE_ID,
                BUSINESS_DOCUMENT_TYPE      ,
                BUSINESS_DOCUMENT_ID        ,
                BUSINESS_DOCUMENT_NUMBER    ,
                DELIVERABLE_TYPE            ,
                RESPONSIBLE_PARTY           ,
                INTERNAL_PARTY_CONTACT_ID   ,
                EXTERNAL_PARTY_CONTACT_ID   ,
                DELIVERABLE_NAME            ,
                DESCRIPTION                 ,
                COMMENTS                    ,
                DISPLAY_SEQUENCE            ,
                FIXED_DUE_DATE_YN           ,
                ACTUAL_DUE_DATE             ,
                PRINT_DUE_DATE_MSG_NAME     ,
                RECURRING_YN                ,
                NOTIFY_PRIOR_DUE_DATE_VALUE ,
                NOTIFY_PRIOR_DUE_DATE_UOM   ,
                NOTIFY_PRIOR_DUE_DATE_YN    ,
                NOTIFY_COMPLETED_YN         ,
                NOTIFY_OVERDUE_YN           ,
                NOTIFY_ESCALATION_YN        ,
                NOTIFY_ESCALATION_VALUE     ,
                NOTIFY_ESCALATION_UOM       ,
                ESCALATION_ASSIGNEE         ,
                AMENDMENT_OPERATION         ,
                PRIOR_NOTIFICATION_ID       ,
                AMENDMENT_NOTES             ,
                COMPLETED_NOTIFICATION_ID   ,
                OVERDUE_NOTIFICATION_ID     ,
                ESCALATION_NOTIFICATION_ID  ,
                LANGUAGE                    ,
                ORIGINAL_DELIVERABLE_ID     ,
                REQUESTER_ID                ,
                EXTERNAL_PARTY_ID           ,
                EXTERNAL_PARTY_ROLE           ,
                RECURRING_DEL_PARENT_ID      ,
                BUSINESS_DOCUMENT_VERSION   ,
                RELATIVE_ST_DATE_DURATION   ,
                RELATIVE_ST_DATE_UOM        ,
                RELATIVE_ST_DATE_EVENT_ID   ,
                RELATIVE_END_DATE_DURATION  ,
                RELATIVE_END_DATE_UOM       ,
                RELATIVE_END_DATE_EVENT_ID  ,
                REPEATING_DAY_OF_MONTH      ,
                REPEATING_DAY_OF_WEEK       ,
                REPEATING_FREQUENCY_UOM     ,
                REPEATING_DURATION          ,
                FIXED_START_DATE            ,
                FIXED_END_DATE              ,
                MANAGE_YN                   ,
                INTERNAL_PARTY_ID           ,
                DELIVERABLE_STATUS          ,
                STATUS_CHANGE_NOTES         ,
                CREATED_BY                  ,
                CREATION_DATE               ,
                LAST_UPDATED_BY             ,
                LAST_UPDATE_DATE            ,
                LAST_UPDATE_LOGIN           ,
                OBJECT_VERSION_NUMBER       ,
                ATTRIBUTE_CATEGORY          ,
                ATTRIBUTE1                  ,
                ATTRIBUTE2                  ,
                ATTRIBUTE3                  ,
                ATTRIBUTE4                  ,
                ATTRIBUTE5                  ,
                ATTRIBUTE6                  ,
                ATTRIBUTE7                  ,
                ATTRIBUTE8                  ,
                ATTRIBUTE9                  ,
                ATTRIBUTE10                 ,
                ATTRIBUTE11                 ,
                ATTRIBUTE12                 ,
                ATTRIBUTE13                 ,
                ATTRIBUTE14                 ,
                ATTRIBUTE15                 ,
                DISABLE_NOTIFICATIONS_YN    ,
                LAST_AMENDMENT_DATE         ,
                BUSINESS_DOCUMENT_LINE_ID   ,
                EXTERNAL_PARTY_SITE_ID      ,
                START_EVENT_DATE            ,
                END_EVENT_DATE              ,
                SUMMARY_AMEND_OPERATION_CODE,
                PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                PAY_HOLD_PRIOR_DUE_DATE_UOM,
                PAY_HOLD_PRIOR_DUE_DATE_YN,
                PAY_HOLD_OVERDUE_YN
                )
                VALUES (
                delNewTab(i).DELIVERABLE_ID,
                delNewTab(i).BUSINESS_DOCUMENT_TYPE      ,
                delNewTab(i).BUSINESS_DOCUMENT_ID        ,
                delNewTab(i).BUSINESS_DOCUMENT_NUMBER    ,
                delNewTab(i).DELIVERABLE_TYPE            ,
                delNewTab(i).RESPONSIBLE_PARTY           ,
                delNewTab(i).INTERNAL_PARTY_CONTACT_ID   ,
                delNewTab(i).EXTERNAL_PARTY_CONTACT_ID   ,
                delNewTab(i).DELIVERABLE_NAME            ,
                delNewTab(i).DESCRIPTION                 ,
                delNewTab(i).COMMENTS                    ,
                delNewTab(i).DISPLAY_SEQUENCE            ,
                delNewTab(i).FIXED_DUE_DATE_YN           ,
                delNewTab(i).ACTUAL_DUE_DATE             ,
                delNewTab(i).PRINT_DUE_DATE_MSG_NAME     ,
                delNewTab(i).RECURRING_YN                ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_UOM   ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_YN    ,
                delNewTab(i).NOTIFY_COMPLETED_YN         ,
                delNewTab(i).NOTIFY_OVERDUE_YN           ,
                delNewTab(i).NOTIFY_ESCALATION_YN        ,
                delNewTab(i).NOTIFY_ESCALATION_VALUE     ,
                delNewTab(i).NOTIFY_ESCALATION_UOM       ,
                delNewTab(i).ESCALATION_ASSIGNEE         ,
                delNewTab(i).AMENDMENT_OPERATION         ,
                delNewTab(i).PRIOR_NOTIFICATION_ID       ,
                delNewTab(i).AMENDMENT_NOTES             ,
                delNewTab(i).COMPLETED_NOTIFICATION_ID   ,
                delNewTab(i).OVERDUE_NOTIFICATION_ID     ,
                delNewTab(i).ESCALATION_NOTIFICATION_ID  ,
                delNewTab(i).LANGUAGE                    ,
                delNewTab(i).ORIGINAL_DELIVERABLE_ID     ,
                delNewTab(i).REQUESTER_ID                ,
                delNewTab(i).EXTERNAL_PARTY_ID           ,
                delNewTab(i).EXTERNAL_PARTY_ROLE           ,
                delNewTab(i).RECURRING_DEL_PARENT_ID      ,
                delNewTab(i).BUSINESS_DOCUMENT_VERSION   ,
                delNewTab(i).RELATIVE_ST_DATE_DURATION   ,
                delNewTab(i).RELATIVE_ST_DATE_UOM        ,
                delNewTab(i).RELATIVE_ST_DATE_EVENT_ID   ,
                delNewTab(i).RELATIVE_END_DATE_DURATION  ,
                delNewTab(i).RELATIVE_END_DATE_UOM       ,
                delNewTab(i).RELATIVE_END_DATE_EVENT_ID  ,
                delNewTab(i).REPEATING_DAY_OF_MONTH      ,
                delNewTab(i).REPEATING_DAY_OF_WEEK       ,
                delNewTab(i).REPEATING_FREQUENCY_UOM     ,
                delNewTab(i).REPEATING_DURATION          ,
                delNewTab(i).FIXED_START_DATE            ,
                delNewTab(i).FIXED_END_DATE              ,
                delNewTab(i).MANAGE_YN                   ,
                delNewTab(i).INTERNAL_PARTY_ID           ,
                delNewTab(i).DELIVERABLE_STATUS          ,
                delNewTab(i).STATUS_CHANGE_NOTES         ,
                delNewTab(i).CREATED_BY                  ,
                delNewTab(i).CREATION_DATE               ,
                delNewTab(i).LAST_UPDATED_BY             ,
                delNewTab(i).LAST_UPDATE_DATE            ,
                delNewTab(i).LAST_UPDATE_LOGIN           ,
                delNewTab(i).OBJECT_VERSION_NUMBER       ,
                delNewTab(i).ATTRIBUTE_CATEGORY          ,
                delNewTab(i).ATTRIBUTE1                  ,
                delNewTab(i).ATTRIBUTE2                  ,
                delNewTab(i).ATTRIBUTE3                  ,
                delNewTab(i).ATTRIBUTE4                  ,
                delNewTab(i).ATTRIBUTE5                  ,
                delNewTab(i).ATTRIBUTE6                  ,
                delNewTab(i).ATTRIBUTE7                  ,
                delNewTab(i).ATTRIBUTE8                  ,
                delNewTab(i).ATTRIBUTE9                  ,
                delNewTab(i).ATTRIBUTE10                 ,
                delNewTab(i).ATTRIBUTE11                 ,
                delNewTab(i).ATTRIBUTE12                 ,
                delNewTab(i).ATTRIBUTE13                 ,
                delNewTab(i).ATTRIBUTE14                 ,
                delNewTab(i).ATTRIBUTE15                 ,
                delNewTab(i).DISABLE_NOTIFICATIONS_YN    ,
                delNewTab(i).LAST_AMENDMENT_DATE         ,
                delNewTab(i).BUSINESS_DOCUMENT_LINE_ID   ,
                delNewTab(i).EXTERNAL_PARTY_SITE_ID      ,
                delNewTab(i).START_EVENT_DATE            ,
                delNewTab(i).END_EVENT_DATE              ,
                delNewTab(i).SUMMARY_AMEND_OPERATION_CODE,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_UOM,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_YN,
                delNewTab(i).PAY_HOLD_OVERDUE_YN
                );
                END LOOP;

        -- insert records code changed for 8i compatability bug#3307941
        /* commented for 8i compatability bug#330794 major code change
        FORALL j IN delNewTab.FIRST..delNewTab.LAST
        INSERT INTO okc_deliverables VALUES delNewTab(j);*/

            FOR j IN delIdTab.FIRST..delIdTab.LAST LOOP
                IF attachment_exists(p_entity_name => G_ENTITY_NAME
                      ,p_pk1_value    =>  delIdTab(j).orig_del_id) THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: create attachments');
                    END IF;
                    -- copy attachments
                    -- bug#3667712 added X_CREATED_BY,X_LAST_UPDATE_LOGIN params
                    fnd_attached_documents2_pkg.copy_attachments(
                    X_from_entity_name =>  G_ENTITY_NAME,
                    X_from_pk1_value   =>  delIdTab(j).orig_del_id,
                    X_to_entity_name   =>  G_ENTITY_NAME,
                    X_to_pk1_value     =>  to_char(delIdTab(j).del_id),
                    X_CREATED_BY       =>  FND_GLOBAL.User_id,
                    X_LAST_UPDATE_LOGIN => Fnd_Global.Login_Id
                    );
                END IF;
            END LOOP;

        END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;


        /*** start bug#3618448 do not flush amendment operations during versioning. PO will call
        clear amendment to flush amendment operation code.
            FOR del_rec IN del_cur LOOP
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                    ,'100: Flush Amendment operation:'
                    ||to_char(del_rec.deliverable_id));
                END IF;
                UPDATE okc_deliverables SET amendment_operation = null,
                --amendment_notes = null,
                --last_amendment_date = null,
                last_updated_by= Fnd_Global.User_Id,
                last_update_date = sysdate,
                last_update_login=Fnd_Global.Login_Id
                WHERE deliverable_id = del_rec.deliverable_id;

            END LOOP;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;*** end bug#3618448 **/
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                ,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.version_deliverables');
            END IF;

            x_return_status := l_return_status;
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name
                ,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.version_deliverables with G_EXC_ERROR'||
                substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
       );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name
                ,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.version_deliverables with G_EXC_UNEXPECTED_ERROR'||
                substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name
           ,'100: In when others leaving OKC_DELIVERABLE_PROCESS_PVT.version_deliverables with G_EXC_UNEXPECTED_ERROR'||substr(sqlerrm,1,200));
        END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END version_deliverables;

    /***Invoked From: OKC_TERMS_VERSION_GRP.clear_amendment
    This API is invoked to clear amendment operation,
    summary amend operation code and amendment notes
    on deliverables for a given busdoc.
    Parameter Details:
    p_doc_id :       Business document Id
    p_doc_type :     Business document type
    bug#3618448 new param added
    p_keep_summary:  If set to 'N' all amendment attributes should be cleared.
    If 'Y' then only amendment_operation will be cleared, default is 'N'.
    ***/
    PROCEDURE clear_amendment_operation (
        p_api_version   IN NUMBER,
        p_init_msg_list IN VARCHAR2,
        p_doc_id        IN NUMBER,
        p_doc_type      IN VARCHAR2,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2,
        p_keep_summary  IN VARCHAR2 )

    IS
    CURSOR def_cur IS
    SELECT deliverable_id
    ,amendment_operation
    ,summary_amend_operation_code
    FROM okc_deliverables
    WHERE business_document_id = p_doc_id
    AND   business_document_version = -99
    AND   business_document_type = p_doc_type
    AND   manage_yn = 'N';

    def_rec def_cur%ROWTYPE;
    --TYPE delIdTabType IS TABLE OF NUMBER;
    --delIdTab    delIdTabType;
    l_return_status  VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
    l_api_name      CONSTANT VARCHAR2(30) :='clear_amendment_operation';

    BEGIN

         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,': inside the API');
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,': p_doc_id :'||p_doc_id);
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,': p_doc_type :'||p_doc_type);
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,':p_keep_summary:'||p_keep_summary);
         END IF;
        -- Flush amendment attributes on the definition
        FOR def_rec IN def_cur LOOP
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: deliverable_id: '
                ||to_char(def_rec.deliverable_id));
            END IF;
            IF p_keep_summary = 'N' THEN
                --bug#3630770,3639432 As per the new changes to amendments we hard delete deliverable
                -- if either amendment_operation or summary code is 'DELETED' 20th May 2004
                IF def_rec.amendment_operation = 'DELETED' OR
                    def_rec.summary_amend_operation_code = 'DELETED' THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                        '100: deleted deliverable: '||to_char(def_rec.deliverable_id));
                    END IF;
                    -- delete deleverable definitions which are removed from approved business doc
                    delete from okc_deliverables
                    where   deliverable_id = def_rec.deliverable_id;
                ELSE
                    -- clear all amendment attributes but
                    -- don't clear last_amendment_date this is needed for PO change History
                    -- to enable or disable deliverables link
                    UPDATE okc_deliverables SET amendment_operation = null,
                    summary_amend_operation_code = null,
                    amendment_notes = null,
                    last_updated_by= Fnd_Global.User_Id,
                    last_update_date = sysdate,
                    last_update_login=Fnd_Global.Login_Id
                    WHERE deliverable_id = def_rec.deliverable_id;
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'100: updated deliverable: '||to_char(def_rec.deliverable_id));
                    END IF;
                END IF;

            ELSE -- p_keep_summary = 'Y'
                --bug#3630770, 3639432 As per the new changes to amendments we hard delete deliverable
                -- if either amendment_operation is DELETED or summary code is null
                IF def_rec.amendment_operation = 'DELETED' AND
                    def_rec.summary_amend_operation_code is null THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                        '100: deleted deliverable: '||to_char(def_rec.deliverable_id));
                    END IF;
                    -- delete deleverable definitions which are removed from approved business doc
                    delete from okc_deliverables
                    where   deliverable_id = def_rec.deliverable_id;
                ELSE
                    -- clear only amendment_operation
                    UPDATE okc_deliverables SET amendment_operation = null,
                    last_updated_by= Fnd_Global.User_Id,
                    last_update_date = sysdate,
                    last_update_login=Fnd_Global.Login_Id
                    WHERE deliverable_id = def_rec.deliverable_id;
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                        ,'100: updated deliverable: '||to_char(def_rec.deliverable_id));
                    END IF;
                END IF;

            END IF; -- p_keep_summary
        END LOOP; -- del_cur loop
        -- close any open cursors
        IF def_cur %ISOPEN THEN
          CLOSE def_cur ;
        END IF;
        x_return_status := l_return_status;

    EXCEPTION
    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name
          ,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.clear_amendments with G_EXC_UNEXPECTED_ERROR'||
          substr(sqlerrm,1,200));
       END IF;
        -- close any open cursors
        IF def_cur %ISOPEN THEN
          CLOSE def_cur ;
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END clear_amendment_operation;



    /*** This procedure will disable or turn manage_yn to 'N'
    for a given document type and version ***/
    PROCEDURE disable_deliverables (
        p_api_version       IN  NUMBER,
        p_init_msg_list     IN VARCHAR2,
        p_doc_id            IN  NUMBER,
        p_doc_version       IN  NUMBER,
        p_doc_type          IN VARCHAR2,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2)
    IS
    l_api_name      CONSTANT VARCHAR2(30) :='disable_deliverable';
    CURSOR del_cur IS
    SELECT deliverable_id
    FROM okc_deliverables
    WHERE business_document_id = p_doc_id
    AND   business_document_version =p_doc_version
    AND   business_document_type = p_doc_type
    AND   manage_yn = 'Y';
    TYPE delIdTabType IS TABLE OF NUMBER;
    delIdTab    delIdTabType;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
            ,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.DISABLE_DELIVERABLES');
          END IF;
            OPEN del_cur;
            FETCH del_cur BULK COLLECT INTO delIdTab;
            IF delIdTab.COUNT <> 0 THEN
                FORALL i IN delIdTab.FIRST..delIdTab.LAST
                UPDATE okc_deliverables SET manage_yn = 'N',
                last_updated_by= Fnd_Global.User_Id,
                last_update_date = sysdate,
                last_update_login=Fnd_Global.Login_Id
                WHERE deliverable_id = delIdTab(i);
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
            x_return_status := l_return_status;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.DISABLE_DELIVERABLES with G_EXC_ERROR');
        END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.DISABLE_DELIVERABLES with G_EXC_UNEXPECTED_ERROR');
        END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.DISABLE_DELIVERABLES with G_EXC_UNEXPECTED_ERROR');
        END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END disable_deliverables;

    -- Creates status history for a given deliverable
    PROCEDURE create_del_status_history(
        p_api_version       IN NUMBER,
        p_init_msg_list     IN VARCHAR2,
        p_del_id            IN NUMBER,
        p_deliverable_status    IN VARCHAR2,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2)
    IS

    l_api_name      CONSTANT VARCHAR2(30) :='create_del_status_history';
    l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
    j PLS_INTEGER := 0;


    BEGIN

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside the API');
          END IF;


                    --insert into status history
                    INSERT INTO okc_del_status_history (
                    deliverable_id,
                    deliverable_status,
                    status_changed_by,
                    status_change_date,
                    status_change_notes,
                    object_version_number,
                    created_by,
                    creation_date,
                    last_updated_by,
                    last_update_date,
                    last_update_login)
                    VALUES(
                     p_del_id,
                     p_deliverable_status,
                     null,
                     sysdate,
                     null,
                     1,
                     Fnd_Global.User_Id,
                     sysdate,
                     Fnd_Global.User_Id,
                     sysdate,
                     Fnd_Global.Login_Id);

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving ');
          END IF;
          x_return_status := l_return_status;
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving with G_EXC_ERROR');
          END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving with G_EXC_UNEXPECTED_ERROR');
          END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving with G_EXC_UNEXPECTED_ERROR');
          END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN                                 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END create_del_status_history;

    /***
    This API is invoked from OKC_MANAGE_DELIVERABLES_GRP.activate_deliverables
    and close_deliverables. It changes the status to a given status for a busdoc.
    Creates status history for deliverable.
    ***/
    PROCEDURE change_deliverable_status (
        p_api_version       IN NUMBER,
        p_init_msg_list     IN VARCHAR2,
        p_doc_id            IN NUMBER,
        p_doc_version       IN NUMBER,
        p_doc_type          IN VARCHAR2,
        p_cancel_yn         IN VARCHAR2,
        p_cancel_event_code IN VARCHAR2,
        p_current_status    IN VARCHAR2,
        p_new_status        IN VARCHAR2,
        p_manage_yn         IN VARCHAR2,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2)
    IS
    l_api_name      CONSTANT VARCHAR2(30) :='change_deliverable_status';
    CURSOR del_activate_cur IS
    SELECT deliverable_id
    FROM okc_deliverables
    WHERE business_document_id = p_doc_id
    AND   business_document_version =p_doc_version
    AND   business_document_type = p_doc_type
    AND   deliverable_status = p_current_status
    AND   actual_due_date is not null;

 /*   CURSOR del_cancel_cur IS
    SELECT deliverable_id
    FROM okc_deliverables
    WHERE business_document_id = p_doc_id
    AND   business_document_version =p_doc_version
    AND   business_document_type = p_doc_type
    AND   NVL(relative_st_date_event_id,0) NOT IN (
    select bus_doc_event_id
    from okc_bus_doc_events_v
    where business_event_code = p_cancel_event_code);
*/
    TYPE delIdTabType IS TABLE OF NUMBER;
    delIdTab    delIdTabType;

    TYPE delStsTabType IS TABLE OF okc_del_status_history%ROWTYPE;
    delStsTab   delStsTabType;

    l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
    j PLS_INTEGER := 0;


    BEGIN

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.CHANGE_DELIVERABLE_STATUS');
          END IF;
        IF p_cancel_yn = 'N' THEN
            OPEN del_activate_cur;
            FETCH del_activate_cur BULK COLLECT INTO delIdTab;
            IF delIdTab.COUNT <> 0 THEN
                    delStsTab   := delStsTabType();
            FOR i IN delIdTab.FIRST..delIdTab.LAST LOOP

                    j := j+1;
                    delStsTab.extend;
                    delStsTab(j).deliverable_id := delIdTab(i);
                    delStsTab(j).deliverable_status:= p_new_status;
                    delStsTab(j).status_change_date:= sysdate;
                    delStsTab(j).status_change_notes:= null;
                    delStsTab(j).object_version_number:= 1;
                    delStsTab(j).created_by:= Fnd_Global.User_Id;
                    delStsTab(j).creation_date := sysdate;
                    delStsTab(j).last_updated_by:= Fnd_Global.User_Id;
                    delStsTab(j).last_update_date := sysdate;
                    delStsTab(j).last_update_login := Fnd_Global.Login_Id;
            END LOOP;

                    --Bulk update of status in okc_deliverables
                    FORALL i IN delIdTab.FIRST..delIdTab.LAST
                    UPDATE okc_deliverables
                    SET
                    deliverable_status = p_new_status,
                    manage_yn   = p_manage_yn,
                    last_updated_by= Fnd_Global.User_Id,
                    last_update_date = sysdate,
                    last_update_login = Fnd_Global.Login_Id
                    WHERE deliverable_id = delIdTab(i);
                    --Bulk insert into status history
                        FOR i IN delStsTab.FIRST..delStsTab.LAST LOOP
                /*code changed for 8i compatability bug#3307941
                INSERT INTO okc_del_status_history VALUES delStsTab(i); */
                        INSERT INTO okc_del_status_history
                        (deliverable_id,
                        deliverable_status,
                        STATUS_CHANGED_BY,
                        status_change_date,
                        status_change_notes,
                        object_version_number,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login)
                        VALUES (delStsTab(i).DELIVERABLE_ID
                        ,delStsTab(i).DELIVERABLE_STATUS
                        ,delStsTab(i).STATUS_CHANGED_BY
                        ,delStsTab(i).STATUS_CHANGE_DATE
                        ,delStsTab(i).STATUS_CHANGE_NOTES
                        ,delStsTab(i).OBJECT_VERSION_NUMBER
                        ,delStsTab(i).CREATED_BY
                        ,delStsTab(i).CREATION_DATE
                        ,delStsTab(i).LAST_UPDATED_BY
                        ,delStsTab(i).LAST_UPDATE_DATE
                        ,delStsTab(i).LAST_UPDATE_LOGIN
                        );
                        END LOOP;
            END IF;
            CLOSE del_activate_cur;

        -- If status change is called when any business document is cancelled
        ELSIF p_cancel_yn = 'Y' THEN

/** Updated this procedure - 01/20/2004 by SASETHI
    Commendted out code for changing deliverable status to CANCELLED when canceled
    operation is called from Mng Deliverables GRP.
**/
           -- disable deliverables that are currently being managed.
            -- before activating deliverables on new version
            disable_deliverables (
                 p_api_version      => l_api_version ,
                 p_init_msg_list    => FND_API.G_FALSE ,
                 p_doc_id           => p_doc_id ,
                 p_doc_version      => p_doc_version ,
                 p_doc_type         => p_doc_type ,
                 x_msg_data         => l_msg_data ,
                 x_msg_count        => l_msg_count ,
                 x_return_status    => l_return_status );

/** Status change is not required as per bug # 3369337

            OPEN del_cancel_cur;
            FETCH del_cancel_cur BULK COLLECT INTO delIdTab;

            IF delIdTab.COUNT <> 0 THEN
                delStsTab   := delStsTabType();
                FOR i IN delIdTab.FIRST..delIdTab.LAST LOOP

                    j := j+1;
                    delStsTab.extend;
                    --delStsTab(j).deliverable_id := delIdTab(i).deliverable_id;
                    delStsTab(j).deliverable_id := delIdTab(i);
                    delStsTab(j).deliverable_status:= p_new_status;
                    delStsTab(j).status_change_date:= sysdate;
                    delStsTab(j).status_change_notes:= null;
                    delStsTab(j).object_version_number:= 1;
                    delStsTab(j).created_by:= Fnd_Global.User_Id;
                    delStsTab(j).creation_date := sysdate;
                    delStsTab(j).last_updated_by:= Fnd_Global.User_Id;
                    delStsTab(j).last_update_date := sysdate;
                    delStsTab(j).last_update_login := Fnd_Global.Login_Id;
                END LOOP;

                IF l_return_status = OKC_API.G_RET_STS_SUCCESS THEN
                    -- BULK UPDATE of status
                    FORALL i IN delIdTab.FIRST..delIdTab.LAST
                    UPDATE okc_deliverables
                    SET
                    deliverable_status = p_new_status,
                    manage_yn   = 'N',
                    last_updated_by= Fnd_Global.User_Id,
                    last_update_date = sysdate,
                    last_update_login = Fnd_Global.Login_Id
                    WHERE deliverable_id = delIdTab(i);

                -- BULK INSERT into status history
                FOR i IN delStsTab.FIRST..delStsTab.LAST LOOP
                --code changed for 8i compatability bug#3307941
                --INSERT INTO okc_del_status_history VALUES delStsTab(i);
                INSERT INTO okc_del_status_history
                (deliverable_id,
                deliverable_status,
                STATUS_CHANGED_BY,
                status_change_date,
                status_change_notes,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login)
                VALUES (delStsTab(i).DELIVERABLE_ID
                ,delStsTab(i).DELIVERABLE_STATUS
                ,delStsTab(i).STATUS_CHANGED_BY
                ,delStsTab(i).STATUS_CHANGE_DATE
                ,delStsTab(i).STATUS_CHANGE_NOTES
                ,delStsTab(i).OBJECT_VERSION_NUMBER
                ,delStsTab(i).CREATED_BY
                ,delStsTab(i).CREATION_DATE
                ,delStsTab(i).LAST_UPDATED_BY
                ,delStsTab(i).LAST_UPDATE_DATE
                ,delStsTab(i).LAST_UPDATE_LOGIN
                );
                END LOOP;
                ELSE
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
            END IF;
            CLOSE del_cancel_cur;
**/
        END IF; -- if operation is for CANCELLED

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.CHANGE_DELIVERABLE_STATUS');
          END IF;
          x_return_status := l_return_status;
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.CHANGE_DELIVERABLE_STATUS with G_EXC_ERROR');
          END IF;
        IF del_activate_cur %ISOPEN THEN
          CLOSE del_activate_cur ;
        END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.CHANGE_DELIVERABLE_STATUS with G_EXC_UNEXPECTED_ERROR');
          END IF;
        IF del_activate_cur %ISOPEN THEN
          CLOSE del_activate_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.CHANGE_DELIVERABLE_STATUS with G_EXC_UNEXPECTED_ERROR');
          END IF;
        IF del_activate_cur %ISOPEN THEN
          CLOSE del_activate_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN                                 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END change_deliverable_status;



    /***
    This is the Concurrent Program scheduled to run every day
    to send out notifications about overdue deliverables.
    It internally calls API overdue_del_notifier
    to check for overdue deliverabls and send out notifications
    ***/
    PROCEDURE overdue_deliverable_manager (
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2)
    IS
    l_api_name      CONSTANT VARCHAR2(30) :='overdue_deliverable_manager';
    l_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
    l_init_msg_list   VARCHAR2(3) := 'T';
    E_Resource_Busy   EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy,  -00054);

    BEGIN
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.overdue_deliverable_manager');
          END IF;
    --Initialize the return code
        retcode := 0;
    --Invoke overdue_del_notifier
        overdue_del_notifier(
        p_api_version          => l_api_version ,
        p_init_msg_list        => l_init_msg_list,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data);
           --check return status
            IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;
          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.overdue_deliverable_manager');
          END IF;
    EXCEPTION
    WHEN E_Resource_Busy THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(  FND_LOG.LEVEL_EXCEPTION ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.overdue_deliverable_manager with resource busy state');
          END IF;
      l_return_status := okc_api.g_ret_sts_error;
      RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.overdue_deliverable_manager with G_EXC_UNEXPECTED_ERROR');
          END IF;
      retcode := 2;
      errbuf  := substr(sqlerrm,1,200);
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      IF FND_MSG_PUB.Count_Msg > 0 Then
        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
        END LOOP;
      END IF;
      FND_MSG_PUB.initialize;

    END overdue_deliverable_manager;

    /***
    Invoked by Concurrent Program "overdue_deliverable_manager"
    Picks all deliverables that are overdue
    Invokes Deliverable Notifier to send out notifications
    Update deliverables with overdue_notification_id
    ***/
    PROCEDURE overdue_del_notifier(
    p_api_version                  IN NUMBER ,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2) IS

    l_api_name      CONSTANT VARCHAR2(30) :='overdue_del_notifier';

    CURSOR del_cur IS
      SELECT deliverable_id,
             deliverable_name,
             deliverable_type,
             business_document_id,
             business_document_version,
             business_document_type,
             business_document_number,
             responsible_party,
             external_party_contact_id,
             internal_party_contact_id,
             requester_id
      FROM okc_deliverables
      WHERE manage_yn = 'Y'
      AND   disable_notifications_yn = 'N'
      AND   notify_overdue_yn = 'Y'
      AND   overdue_notification_id is null
      AND   business_document_type <> 'TEMPLATE'
      AND   deliverable_status IN ('OPEN','REJECTED')
      AND   actual_due_date < trunc(sysdate); --  bug#3617906 removed trunc on actual due date

    l_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    l_notification_id NUMBER;
    j  PLS_INTEGER := 0;

    TYPE del_cur_tbl IS TABLE OF del_cur%ROWTYPE;
    selected_dels del_cur_tbl;

    TYPE OverdueNtfIdList IS TABLE OF okc_deliverables.overdue_notification_id%TYPE NOT NULL
        INDEX BY PLS_INTEGER;
    TYPE DeliverableIdList IS TABLE OF okc_deliverables.deliverable_id%TYPE NOT NULL
        INDEX BY PLS_INTEGER;
    overdue_ntf_ids OverdueNtfIdList;
    deliverable_ids DeliverableIdList;

    l_batch_size number(4) := 1000;

	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);


    BEGIN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.overdue_del_notifier');
      END IF;

      -- call start_activity to create savepoint, check comptability
      -- and initialize message list
      l_return_status := OKC_API.START_ACTIVITY(l_api_name
                                                ,p_init_msg_list
                                                ,'_PROCESS'
                                                ,x_return_status);

      -- check if activity started successfully
      IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;


      OPEN del_cur;
      LOOP -- the following statement fetches 1000 rows or less in each iteration

        FETCH del_cur BULK COLLECT INTO selected_dels
        LIMIT l_batch_size;

        EXIT WHEN selected_dels.COUNT = 0;

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: selected_dels.COUNT is :'||to_char(selected_dels.COUNT));
        END IF;


        FOR i IN selected_dels.FIRST..NVL(selected_dels.LAST, -1) LOOP

          -- log messages in concurrent program log file
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Business Document: '||
                      selected_dels(i).business_document_type||'-'||selected_dels(i).business_document_number);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Deliverable Id: '||
                      to_char(selected_dels(i).deliverable_id));

				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_OVERDUE_NTF_SUBJECT',selected_dels(i).business_document_type);

          okc_deliverable_wf_pvt.deliverables_notifier(
                      p_api_version               => 1.0,
                      p_init_msg_list             => FND_API.G_TRUE,
                      p_deliverable_id            => selected_dels(i).deliverable_id,
                      p_deliverable_name          => selected_dels(i).deliverable_name,
                      p_deliverable_type          => selected_dels(i).deliverable_type,
                      p_business_document_id      => selected_dels(i).business_document_id,
                      p_business_document_version => selected_dels(i).business_document_version,
                      p_business_document_type    => selected_dels(i).business_document_type,
                      p_business_document_number  => selected_dels(i).business_document_number,
                      p_resp_party                => selected_dels(i).responsible_party,
                      p_external_contact          => selected_dels(i).external_party_contact_id,
                      p_internal_contact          => selected_dels(i).internal_party_contact_id,
                      p_requester_id              => selected_dels(i).requester_id,
                      --p_msg_code                  => 'OKC_DEL_OVERDUE_NTF_SUBJECT',
                      p_msg_code                  => l_resolved_msg_name,
                      x_notification_id           => l_notification_id,
                      x_msg_data                  => l_msg_data,
                      x_msg_count                 => l_msg_count,
                      x_return_status             => l_return_status);

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: ntf id is :'||to_char(l_notification_id));
          END IF;

          --If notification id is not null then the deliverables_notifier is success
          IF l_notification_id is not null THEN
            -- if return status is success then notification is sent to
            -- internal or external contact so update table with ntf id
            IF l_return_status = 'S' THEN
              j := j+1;
              deliverable_ids(j) := selected_dels(i).deliverable_id;
              overdue_ntf_ids(j) := l_notification_id;
            ELSIF l_return_status <> 'S' THEN
              -- The return status is success because error notification has been
              -- sent to person who launched the concurrent request.
              l_return_status := 'S';
            END IF;
          ELSE
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;

        END LOOP;

      END LOOP;

      CLOSE del_cur;

      IF deliverable_ids.COUNT > 0 THEN
        FORALL i IN deliverable_ids.FIRST..NVL(deliverable_ids.LAST, -1)

          UPDATE okc_deliverables
          SET overdue_notification_id = overdue_ntf_ids(i),
              last_update_date = sysdate,
              last_updated_by = FND_GLOBAL.User_id,
              last_update_login =Fnd_Global.Login_Id
          WHERE deliverable_id = deliverable_ids(i);

        COMMIT;

      END IF;

      OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.overdue_del_notifier');
      END IF;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.overdue_del_notifier with G_EXC_ERROR:'||substr(sqlerrm,1,200));
        END IF;

        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;

        x_return_status := G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.overdue_del_notifier with G_EXC_UNEXPECTED_ERROR:'||substr(sqlerrm,1,200));
        END IF;

        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;

        x_return_status := G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data);

      WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.overdue_del_notifier with G_EXC_UNEXPECTED_ERROR:'||substr(sqlerrm,1,200));
        END IF;

        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;

        x_return_status := G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
        END IF;

        FND_MSG_PUB.Count_And_Get(
          p_count =>  x_msg_count,
          p_data  =>  x_msg_data);
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

    END overdue_del_notifier;


    /***
    This is the Concurrent Program scheduled to run every day
    to send out notifications about beforedue deliverables.
    It internally calls API beforedue_del_notifier
    ***/
    PROCEDURE beforedue_deliverable_manager (
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2)
    IS
    l_api_name      CONSTANT VARCHAR2(30) :='beforedue_deliverable_manager';
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
    l_init_msg_list   VARCHAR2(3) := 'T';
    l_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    E_Resource_Busy   EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy,  -00054);

    BEGIN
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.beforedue_deliverable_manager');
         END IF;
    --Initialize the return code
        retcode := 0;
    --Invoke beforedue_del_notifier
           beforedue_del_notifier (
        p_api_version          => l_api_version ,
        p_init_msg_list        => l_init_msg_list,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data);

           --check return status
            IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.beforedue_deliverable_manager');
         END IF;
    EXCEPTION
    WHEN E_Resource_Busy THEN
      l_return_status := okc_api.g_ret_sts_error;
      RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
      IF FND_MSG_PUB.Count_Msg > 0 Then
        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
        END LOOP;
      END IF;
      FND_MSG_PUB.initialize;
    WHEN OTHERS THEN
      retcode := 2;
      errbuf  := substr(sqlerrm,1,200);
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      IF FND_MSG_PUB.Count_Msg > 0 Then
        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
        END LOOP;
      END IF;
      FND_MSG_PUB.initialize;

    END beforedue_deliverable_manager;


    /***
    Invoked by Concurrent Program "beforedue_deliverable_manager"
    Picks all deliverables eligible for before due date notifications
    Invokes Deliverable Notifier to send out notifications
    Update deliverables with prior_notification_id
    ***/
    PROCEDURE beforedue_del_notifier (
    p_api_version                  IN NUMBER ,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
    IS
    CURSOR del_cur IS
    SELECT *
    FROM okc_deliverables
    WHERE manage_yn = 'Y'
    AND   disable_notifications_yn = 'N'
    AND   notify_prior_due_date_yn = 'Y'
    AND   prior_notification_id is null
    AND   business_document_type <> 'TEMPLATE'
    AND   deliverable_status IN ('OPEN','REJECTED')
    AND   trunc(actual_due_date) > trunc(sysdate);

    l_api_name      CONSTANT VARCHAR2(30) :='beforedue_del_notifier';
    l_notification_date DATE;
    delRecTab   delRecTabType;
    delNtfTab   delRecTabType;
    l_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    l_notification_id NUMBER;
    l_deliverable_id NUMBER;
    j  PLS_INTEGER := 0;
    k  PLS_INTEGER := 0;

	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    BEGIN

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.beforedue_del_notifier');
       END IF;
       -- call start_activity to create savepoint, check comptability
       -- and initialize message list
           l_return_status := OKC_API.START_ACTIVITY(l_api_name
                 ,p_init_msg_list
                 ,'_PROCESS'
                 ,x_return_status
                 );
                 -- check if activity started successfully
                 IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                 END IF;
---------------------------------------------------
        FOR del_rec IN del_cur LOOP
      k := k+1;
      delRecTab(k).deliverable_id := del_rec.deliverable_id;
      delRecTab(k).BUSINESS_DOCUMENT_TYPE:= del_rec.BUSINESS_DOCUMENT_TYPE;
      delRecTab(k).BUSINESS_DOCUMENT_ID:= del_rec.BUSINESS_DOCUMENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_NUMBER:= del_rec.BUSINESS_DOCUMENT_NUMBER;
      delRecTab(k).DELIVERABLE_TYPE:= del_rec.DELIVERABLE_TYPE;
      delRecTab(k).RESPONSIBLE_PARTY:= del_rec.RESPONSIBLE_PARTY;
      delRecTab(k).INTERNAL_PARTY_CONTACT_ID:= del_rec.INTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).EXTERNAL_PARTY_CONTACT_ID:= del_rec.EXTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).DELIVERABLE_NAME:= del_rec.DELIVERABLE_NAME;
      delRecTab(k).DESCRIPTION:= del_rec.DESCRIPTION;
      delRecTab(k).COMMENTS:= del_rec.COMMENTS;
      delRecTab(k).DISPLAY_SEQUENCE:= del_rec.DISPLAY_SEQUENCE;
      delRecTab(k).FIXED_DUE_DATE_YN:= del_rec.FIXED_DUE_DATE_YN;
      delRecTab(k).ACTUAL_DUE_DATE:= del_rec.ACTUAL_DUE_DATE;
      delRecTab(k).PRINT_DUE_DATE_MSG_NAME:= del_rec.PRINT_DUE_DATE_MSG_NAME;
      delRecTab(k).RECURRING_YN:= del_rec.RECURRING_YN;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_UOM:= del_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_YN:= del_rec.NOTIFY_PRIOR_DUE_DATE_YN;
      delRecTab(k).NOTIFY_COMPLETED_YN:= del_rec.NOTIFY_COMPLETED_YN;
      delRecTab(k).NOTIFY_OVERDUE_YN:= del_rec.NOTIFY_OVERDUE_YN;
      delRecTab(k).NOTIFY_ESCALATION_YN:= del_rec.NOTIFY_ESCALATION_YN;
      delRecTab(k).NOTIFY_ESCALATION_VALUE:= del_rec.NOTIFY_ESCALATION_VALUE;
      delRecTab(k).NOTIFY_ESCALATION_UOM:= del_rec.NOTIFY_ESCALATION_UOM;
      delRecTab(k).ESCALATION_ASSIGNEE:= del_rec.ESCALATION_ASSIGNEE;
      delRecTab(k).AMENDMENT_OPERATION:= del_rec.AMENDMENT_OPERATION;
      delRecTab(k).PRIOR_NOTIFICATION_ID:= del_rec.PRIOR_NOTIFICATION_ID;
      delRecTab(k).AMENDMENT_NOTES:= del_rec.AMENDMENT_NOTES;
      delRecTab(k).COMPLETED_NOTIFICATION_ID:= del_rec.COMPLETED_NOTIFICATION_ID;
      delRecTab(k).OVERDUE_NOTIFICATION_ID:= del_rec.OVERDUE_NOTIFICATION_ID;
      delRecTab(k).ESCALATION_NOTIFICATION_ID:= del_rec.ESCALATION_NOTIFICATION_ID;
      delRecTab(k).LANGUAGE:= del_rec.LANGUAGE;
      delRecTab(k).ORIGINAL_DELIVERABLE_ID:= del_rec.ORIGINAL_DELIVERABLE_ID;
      delRecTab(k).REQUESTER_ID:= del_rec.REQUESTER_ID;
      delRecTab(k).EXTERNAL_PARTY_ID:= del_rec.EXTERNAL_PARTY_ID;
      delRecTab(k).EXTERNAL_PARTY_ROLE:= del_rec.EXTERNAL_PARTY_ROLE;
      delRecTab(k).RECURRING_DEL_PARENT_ID:= del_rec.RECURRING_DEL_PARENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_VERSION:= del_rec.BUSINESS_DOCUMENT_VERSION;
      delRecTab(k).RELATIVE_ST_DATE_DURATION:= del_rec.RELATIVE_ST_DATE_DURATION;
      delRecTab(k).RELATIVE_ST_DATE_UOM:= del_rec.RELATIVE_ST_DATE_UOM;
      delRecTab(k).RELATIVE_ST_DATE_EVENT_ID:= del_rec.RELATIVE_ST_DATE_EVENT_ID;
      delRecTab(k).RELATIVE_END_DATE_DURATION:= del_rec.RELATIVE_END_DATE_DURATION;
      delRecTab(k).RELATIVE_END_DATE_UOM:= del_rec.RELATIVE_END_DATE_UOM;
      delRecTab(k).RELATIVE_END_DATE_EVENT_ID:= del_rec.RELATIVE_END_DATE_EVENT_ID;
      delRecTab(k).REPEATING_DAY_OF_MONTH:= del_rec.REPEATING_DAY_OF_MONTH;
      delRecTab(k).REPEATING_DAY_OF_WEEK:= del_rec.REPEATING_DAY_OF_WEEK;
      delRecTab(k).REPEATING_FREQUENCY_UOM:= del_rec.REPEATING_FREQUENCY_UOM;
      delRecTab(k).REPEATING_DURATION:= del_rec.REPEATING_DURATION;
      delRecTab(k).FIXED_START_DATE:= del_rec.FIXED_START_DATE;
      delRecTab(k).FIXED_END_DATE:= del_rec.FIXED_END_DATE;
      delRecTab(k).MANAGE_YN:= del_rec.MANAGE_YN;
      delRecTab(k).INTERNAL_PARTY_ID:= del_rec.INTERNAL_PARTY_ID;
      delRecTab(k).DELIVERABLE_STATUS:= del_rec.DELIVERABLE_STATUS;
      delRecTab(k).STATUS_CHANGE_NOTES:= del_rec.STATUS_CHANGE_NOTES;
      delRecTab(k).CREATED_BY:= del_rec.CREATED_BY;
      delRecTab(k).CREATION_DATE:= del_rec.CREATION_DATE;
      delRecTab(k).LAST_UPDATED_BY:= del_rec.LAST_UPDATED_BY;
      delRecTab(k).LAST_UPDATE_DATE:= del_rec.LAST_UPDATE_DATE;
      delRecTab(k).LAST_UPDATE_LOGIN:= del_rec.LAST_UPDATE_LOGIN;
      delRecTab(k).OBJECT_VERSION_NUMBER:= del_rec.OBJECT_VERSION_NUMBER;
      delRecTab(k).ATTRIBUTE_CATEGORY:= del_rec.ATTRIBUTE_CATEGORY;
      delRecTab(k).ATTRIBUTE1:= del_rec.ATTRIBUTE1;
      delRecTab(k).ATTRIBUTE2:= del_rec.ATTRIBUTE2;
      delRecTab(k).ATTRIBUTE3:= del_rec.ATTRIBUTE3;
      delRecTab(k).ATTRIBUTE4:= del_rec.ATTRIBUTE4;
      delRecTab(k).ATTRIBUTE5:= del_rec.ATTRIBUTE5;
      delRecTab(k).ATTRIBUTE6:= del_rec.ATTRIBUTE6;
      delRecTab(k).ATTRIBUTE7:= del_rec.ATTRIBUTE7;
      delRecTab(k).ATTRIBUTE8:= del_rec.ATTRIBUTE8;
      delRecTab(k).ATTRIBUTE9:= del_rec.ATTRIBUTE9;
      delRecTab(k).ATTRIBUTE10:= del_rec.ATTRIBUTE10;
      delRecTab(k).ATTRIBUTE11:= del_rec.ATTRIBUTE11;
      delRecTab(k).ATTRIBUTE12:= del_rec.ATTRIBUTE12;
      delRecTab(k).ATTRIBUTE13:= del_rec.ATTRIBUTE13;
      delRecTab(k).ATTRIBUTE14:= del_rec.ATTRIBUTE14;
      delRecTab(k).ATTRIBUTE15:= del_rec.ATTRIBUTE15;
      delRecTab(k).DISABLE_NOTIFICATIONS_YN:= del_rec.DISABLE_NOTIFICATIONS_YN;
      delRecTab(k).LAST_AMENDMENT_DATE:= del_rec.LAST_AMENDMENT_DATE;
      delRecTab(k).BUSINESS_DOCUMENT_LINE_ID:= del_rec.BUSINESS_DOCUMENT_LINE_ID;
      delRecTab(k).EXTERNAL_PARTY_SITE_ID:= del_rec.EXTERNAL_PARTY_SITE_ID;
      delRecTab(k).START_EVENT_DATE:= del_rec.START_EVENT_DATE;
      delRecTab(k).END_EVENT_DATE:= del_rec.END_EVENT_DATE;
      delRecTab(k).SUMMARY_AMEND_OPERATION_CODE:= del_rec.SUMMARY_AMEND_OPERATION_CODE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
      delRecTab(k).PAY_HOLD_OVERDUE_YN:=del_rec.PAY_HOLD_OVERDUE_YN;

    END LOOP;


         -- commented as this is not supported by 8i PL/SQL Bug#3307941
          /*OPEN del_cur;
            FETCH del_cur BULK COLLECT INTO delRecTab;*/
            IF delRecTab.COUNT > 0 THEN
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: delRecTab.COUNT is :'||to_char(delRecTab.COUNT));
         END IF;
            FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP

            -- log messages in concurrent program log file
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Business Document: '||
            delRecTab(i).business_document_type||'-'||delRecTab(i).business_document_number);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Deliverable Id: '||
            to_char(delRecTab(i).deliverable_id));
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: del id is :'||to_char(delRecTab(i).deliverable_id));
         END IF;
                IF UPPER(delRecTab(i).NOTIFY_PRIOR_DUE_DATE_UOM) = 'DAY' THEN
                    l_notification_date := trunc(delRecTab(i).actual_due_date)-delRecTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE;
                ELSIF UPPER(delRecTab(i).NOTIFY_PRIOR_DUE_DATE_UOM) = 'WK' THEN
                    l_notification_date :=trunc(delRecTab(i).actual_due_date)-7*delRecTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE;
                ELSIF UPPER(delRecTab(i).NOTIFY_PRIOR_DUE_DATE_UOM) = 'MTH' THEN
                    select add_months(delRecTab(i).actual_due_date,-delRecTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE)
                    INTO l_notification_date from dual;
                END IF;

                IF trunc(l_notification_date) = trunc(sysdate) OR
                   trunc(l_notification_date) < trunc(sysdate) THEN -- call to notifier
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100:Del Id  :'||to_char(delRecTab(i).deliverable_id));
                    END IF;

				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_BEFOREDUE_NTF_SUBJECT',delRecTab(i).business_document_type);

                    okc_deliverable_wf_pvt.deliverables_notifier(
                    p_api_version               => 1.0,
                    p_init_msg_list             => FND_API.G_TRUE,
                    p_deliverable_id            => delRecTab(i).deliverable_id,
                    p_deliverable_name          => delRecTab(i).deliverable_name,
                    p_deliverable_type          => delRecTab(i).deliverable_type,
                    p_business_document_id      => delRecTab(i).business_document_id,
                    p_business_document_version => delRecTab(i).business_document_version,
                    p_business_document_type    => delRecTab(i).business_document_type,
                    p_business_document_number  => delRecTab(i).business_document_number,
                    p_resp_party                => delRecTab(i).responsible_party,
                    p_external_contact          => delRecTab(i).external_party_contact_id,
                    p_internal_contact          => delRecTab(i).internal_party_contact_id,
                    p_notify_prior_due_date_value => delRecTab(i).notify_prior_due_date_value,
                    p_notify_prior_due_date_uom => delRecTab(i).notify_prior_due_date_uom,
                    --p_msg_code                  => 'OKC_DEL_BEFOREDUE_NTF_SUBJECT',
                    p_msg_code                  => l_resolved_msg_name,
                    x_notification_id           => l_notification_id,
                    x_msg_data                  => l_msg_data,
                    x_msg_count                 => l_msg_count,
                    x_return_status             => l_return_status);
                    --check return status
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: ntf id is :'||to_char(l_notification_id));
                    END IF;
                    IF l_notification_id is not null THEN
                        -- if return status is success then notification is sent to
                        -- internal or external contact so update table with ntf id
                        IF l_return_status = 'S' THEN
                            j := j+1;
                            delNtfTab(j) := delRecTab(i);
                            delNtfTab(j).prior_notification_id := l_notification_id;
                            delNtfTab(j).last_update_date := sysdate;
                            delNtfTab(j).last_updated_by := FND_GLOBAL.User_id;
                            delNtfTab(j).last_update_login:=Fnd_Global.Login_Id;
                        ELSIF l_return_status <> 'S' THEN
                        -- The return status is success because error notification has been
                        -- sent to person who launched the concurrent request.
                            l_return_status := 'S';
                        END IF;
                    ELSE
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    END IF;
                END IF; -- call to notifier
            END LOOP;
            END IF;
            IF delNtfTab.COUNT > 0 THEN
                FOR i IN delNtfTab.FIRST..delNtfTab.LAST LOOP
                /** commented as this is not supported by 8i PL/SQL Bug#3307941
                UPDATE okc_deliverables SET ROW = delNtfTab(i)
                where deliverable_id = l_deliverable_id;
                l_deliverable_id := delNtfTab(i).deliverable_id;*/
                UPDATE okc_deliverables
                SET prior_notification_id = delNtfTab(i).prior_notification_id,
                last_update_date = sysdate,
                last_updated_by = FND_GLOBAL.User_id,
                last_update_login =Fnd_Global.Login_Id
                where deliverable_id = delNtfTab(i).deliverable_id;
                END LOOP;
          COMMIT;
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
            x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.beforedue_del_notifier');
       END IF;
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.beforedue_del_notifier with G_EXC_ERROR:'||substr(sqlerrm,1,200));
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.beforedue_del_notifier with G_EXC_UNEXPECTED_ERROR:'||substr(sqlerrm,1,200));
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.beforedue_del_notifier with G_EXC_UNEXPECTED_ERROR:'||substr(sqlerrm,1,200));
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN                                 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

    END beforedue_del_notifier;

    /***
    This is the Concurrent Program scheduled to run every day
    to send out escalated notifications about deliverables.
    It internally calls API escalation_deliverable_notifier
    ***/
    PROCEDURE escalation_deliverable_manager (
    errbuf  OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2)
    IS
    l_api_name      CONSTANT VARCHAR2(30) :='escalation_deliverable_manager';
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
    l_init_msg_list   VARCHAR2(3) := 'T';
    l_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    E_Resource_Busy   EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy,  -00054);

    BEGIN
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.escalation_deliverable_manager');
       END IF;
    --Initialize the return code
        retcode := 0;
    --Invoke escalation_deliverable_notifier
           esc_del_notifier(
        p_api_version          => l_api_version ,
        p_init_msg_list        => l_init_msg_list,
        x_return_status        => l_return_status,
        x_msg_count            => l_msg_count,
        x_msg_data             => l_msg_data);

           --check return status
            IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.escalation_deliverable_manager');
       END IF;
    EXCEPTION
    WHEN E_Resource_Busy THEN
      l_return_status := okc_api.g_ret_sts_error;
      RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
      IF FND_MSG_PUB.Count_Msg > 0 Then
        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
        END LOOP;
      END IF;
      FND_MSG_PUB.initialize;
    WHEN OTHERS THEN
      retcode := 2;
      errbuf  := substr(sqlerrm,1,200);
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      IF FND_MSG_PUB.Count_Msg > 0 Then
        FOR I IN 1..FND_MSG_PUB.Count_Msg LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MSG_PUB.Get(i,p_encoded =>FND_API.G_FALSE ));
        END LOOP;
      END IF;
      FND_MSG_PUB.initialize;

    END escalation_deliverable_manager;


    /***
    Invoked by Concurrent Program "escalation_deliverable_manager"
    Picks all deliverables eligible for escalation
    Invokes Deliverable Notifier to send out notifications only to escalation assignee
    Update deliverables with escalation_notification_id
    ***/
    PROCEDURE esc_del_notifier  (
    p_api_version                  IN NUMBER ,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2)
    IS
    l_api_name      CONSTANT VARCHAR2(30) :='esc_del_notifier';
    CURSOR del_cur IS
    SELECT *
    FROM okc_deliverables
    WHERE manage_yn = 'Y'
    AND   disable_notifications_yn = 'N'
    AND   notify_escalation_yn = 'Y'
    AND   escalation_assignee is not null
    AND   escalation_notification_id is null
    AND   business_document_type <> 'TEMPLATE'
    AND   deliverable_status IN ('OPEN','REJECTED')
    AND   actual_due_date < trunc(sysdate);
    -- OR     actual_due_date = sysdate); bug#3722423
    l_notification_date DATE;
    delRecTab   delRecTabType;
    delNtfTab   delRecTabType;
    l_return_status   VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    l_notification_id NUMBER;
    l_deliverable_id NUMBER;
    j  PLS_INTEGER := 0;
    k  PLS_INTEGER := 0;

	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    BEGIN

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.esc_del_notifier');
       END IF;
       -- call start_activity to create savepoint, check comptability
       -- and initialize message list
           l_return_status := OKC_API.START_ACTIVITY(l_api_name
                 ,p_init_msg_list
                 ,'_PROCESS'
                 ,x_return_status
                 );
                 -- check if activity started successfully
                 IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                 END IF;
---------------------------------------------------
        FOR del_rec IN del_cur LOOP
      k := k+1;
      delRecTab(k).deliverable_id := del_rec.deliverable_id;
      delRecTab(k).BUSINESS_DOCUMENT_TYPE:= del_rec.BUSINESS_DOCUMENT_TYPE;
      delRecTab(k).BUSINESS_DOCUMENT_ID:= del_rec.BUSINESS_DOCUMENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_NUMBER:= del_rec.BUSINESS_DOCUMENT_NUMBER;
      delRecTab(k).DELIVERABLE_TYPE:= del_rec.DELIVERABLE_TYPE;
      delRecTab(k).RESPONSIBLE_PARTY:= del_rec.RESPONSIBLE_PARTY;
      delRecTab(k).INTERNAL_PARTY_CONTACT_ID:= del_rec.INTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).EXTERNAL_PARTY_CONTACT_ID:= del_rec.EXTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).DELIVERABLE_NAME:= del_rec.DELIVERABLE_NAME;
      delRecTab(k).DESCRIPTION:= del_rec.DESCRIPTION;
      delRecTab(k).COMMENTS:= del_rec.COMMENTS;
      delRecTab(k).DISPLAY_SEQUENCE:= del_rec.DISPLAY_SEQUENCE;
      delRecTab(k).FIXED_DUE_DATE_YN:= del_rec.FIXED_DUE_DATE_YN;
      delRecTab(k).ACTUAL_DUE_DATE:= del_rec.ACTUAL_DUE_DATE;
      delRecTab(k).PRINT_DUE_DATE_MSG_NAME:= del_rec.PRINT_DUE_DATE_MSG_NAME;
      delRecTab(k).RECURRING_YN:= del_rec.RECURRING_YN;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_UOM:= del_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_YN:= del_rec.NOTIFY_PRIOR_DUE_DATE_YN;
      delRecTab(k).NOTIFY_COMPLETED_YN:= del_rec.NOTIFY_COMPLETED_YN;
      delRecTab(k).NOTIFY_OVERDUE_YN:= del_rec.NOTIFY_OVERDUE_YN;
      delRecTab(k).NOTIFY_ESCALATION_YN:= del_rec.NOTIFY_ESCALATION_YN;
      delRecTab(k).NOTIFY_ESCALATION_VALUE:= del_rec.NOTIFY_ESCALATION_VALUE;
      delRecTab(k).NOTIFY_ESCALATION_UOM:= del_rec.NOTIFY_ESCALATION_UOM;
      delRecTab(k).ESCALATION_ASSIGNEE:= del_rec.ESCALATION_ASSIGNEE;
      delRecTab(k).AMENDMENT_OPERATION:= del_rec.AMENDMENT_OPERATION;
      delRecTab(k).PRIOR_NOTIFICATION_ID:= del_rec.PRIOR_NOTIFICATION_ID;
      delRecTab(k).AMENDMENT_NOTES:= del_rec.AMENDMENT_NOTES;
      delRecTab(k).COMPLETED_NOTIFICATION_ID:= del_rec.COMPLETED_NOTIFICATION_ID;
      delRecTab(k).OVERDUE_NOTIFICATION_ID:= del_rec.OVERDUE_NOTIFICATION_ID;
      delRecTab(k).ESCALATION_NOTIFICATION_ID:= del_rec.ESCALATION_NOTIFICATION_ID;
      delRecTab(k).LANGUAGE:= del_rec.LANGUAGE;
      delRecTab(k).ORIGINAL_DELIVERABLE_ID:= del_rec.ORIGINAL_DELIVERABLE_ID;
      delRecTab(k).REQUESTER_ID:= del_rec.REQUESTER_ID;
      delRecTab(k).EXTERNAL_PARTY_ID:= del_rec.EXTERNAL_PARTY_ID;
      delRecTab(k).EXTERNAL_PARTY_ROLE:= del_rec.EXTERNAL_PARTY_ROLE;
      delRecTab(k).RECURRING_DEL_PARENT_ID:= del_rec.RECURRING_DEL_PARENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_VERSION:= del_rec.BUSINESS_DOCUMENT_VERSION;
      delRecTab(k).RELATIVE_ST_DATE_DURATION:= del_rec.RELATIVE_ST_DATE_DURATION;
      delRecTab(k).RELATIVE_ST_DATE_UOM:= del_rec.RELATIVE_ST_DATE_UOM;
      delRecTab(k).RELATIVE_ST_DATE_EVENT_ID:= del_rec.RELATIVE_ST_DATE_EVENT_ID;
      delRecTab(k).RELATIVE_END_DATE_DURATION:= del_rec.RELATIVE_END_DATE_DURATION;
      delRecTab(k).RELATIVE_END_DATE_UOM:= del_rec.RELATIVE_END_DATE_UOM;
      delRecTab(k).RELATIVE_END_DATE_EVENT_ID:= del_rec.RELATIVE_END_DATE_EVENT_ID;
      delRecTab(k).REPEATING_DAY_OF_MONTH:= del_rec.REPEATING_DAY_OF_MONTH;
      delRecTab(k).REPEATING_DAY_OF_WEEK:= del_rec.REPEATING_DAY_OF_WEEK;
      delRecTab(k).REPEATING_FREQUENCY_UOM:= del_rec.REPEATING_FREQUENCY_UOM;
      delRecTab(k).REPEATING_DURATION:= del_rec.REPEATING_DURATION;
      delRecTab(k).FIXED_START_DATE:= del_rec.FIXED_START_DATE;
      delRecTab(k).FIXED_END_DATE:= del_rec.FIXED_END_DATE;
      delRecTab(k).MANAGE_YN:= del_rec.MANAGE_YN;
      delRecTab(k).INTERNAL_PARTY_ID:= del_rec.INTERNAL_PARTY_ID;
      delRecTab(k).DELIVERABLE_STATUS:= del_rec.DELIVERABLE_STATUS;
      delRecTab(k).STATUS_CHANGE_NOTES:= del_rec.STATUS_CHANGE_NOTES;
      delRecTab(k).CREATED_BY:= del_rec.CREATED_BY;
      delRecTab(k).CREATION_DATE:= del_rec.CREATION_DATE;
      delRecTab(k).LAST_UPDATED_BY:= del_rec.LAST_UPDATED_BY;
      delRecTab(k).LAST_UPDATE_DATE:= del_rec.LAST_UPDATE_DATE;
      delRecTab(k).LAST_UPDATE_LOGIN:= del_rec.LAST_UPDATE_LOGIN;
      delRecTab(k).OBJECT_VERSION_NUMBER:= del_rec.OBJECT_VERSION_NUMBER;
      delRecTab(k).ATTRIBUTE_CATEGORY:= del_rec.ATTRIBUTE_CATEGORY;
      delRecTab(k).ATTRIBUTE1:= del_rec.ATTRIBUTE1;
      delRecTab(k).ATTRIBUTE2:= del_rec.ATTRIBUTE2;
      delRecTab(k).ATTRIBUTE3:= del_rec.ATTRIBUTE3;
      delRecTab(k).ATTRIBUTE4:= del_rec.ATTRIBUTE4;
      delRecTab(k).ATTRIBUTE5:= del_rec.ATTRIBUTE5;
      delRecTab(k).ATTRIBUTE6:= del_rec.ATTRIBUTE6;
      delRecTab(k).ATTRIBUTE7:= del_rec.ATTRIBUTE7;
      delRecTab(k).ATTRIBUTE8:= del_rec.ATTRIBUTE8;
      delRecTab(k).ATTRIBUTE9:= del_rec.ATTRIBUTE9;
      delRecTab(k).ATTRIBUTE10:= del_rec.ATTRIBUTE10;
      delRecTab(k).ATTRIBUTE11:= del_rec.ATTRIBUTE11;
      delRecTab(k).ATTRIBUTE12:= del_rec.ATTRIBUTE12;
      delRecTab(k).ATTRIBUTE13:= del_rec.ATTRIBUTE13;
      delRecTab(k).ATTRIBUTE14:= del_rec.ATTRIBUTE14;
      delRecTab(k).ATTRIBUTE15:= del_rec.ATTRIBUTE15;
      delRecTab(k).DISABLE_NOTIFICATIONS_YN:= del_rec.DISABLE_NOTIFICATIONS_YN;
      delRecTab(k).LAST_AMENDMENT_DATE:= del_rec.LAST_AMENDMENT_DATE;
      delRecTab(k).BUSINESS_DOCUMENT_LINE_ID:= del_rec.BUSINESS_DOCUMENT_LINE_ID;
      delRecTab(k).EXTERNAL_PARTY_SITE_ID:= del_rec.EXTERNAL_PARTY_SITE_ID;
      delRecTab(k).START_EVENT_DATE:= del_rec.START_EVENT_DATE;
      delRecTab(k).END_EVENT_DATE:= del_rec.END_EVENT_DATE;
      delRecTab(k).SUMMARY_AMEND_OPERATION_CODE:= del_rec.SUMMARY_AMEND_OPERATION_CODE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
      delRecTab(k).PAY_HOLD_OVERDUE_YN:=del_rec.PAY_HOLD_OVERDUE_YN;

    END LOOP;


            -- commented as this is not supported by 8i PL/SQL Bug#3307941
            /*OPEN del_cur;
            FETCH del_cur BULK COLLECT INTO delRecTab;*/
            IF delRecTab.COUNT > 0 THEN
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: delRecTab.COUNT is :'||to_char(delRecTab.COUNT));
         END IF;
            FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
            -- log messages in concurrent program log file
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Business Document: '||
            delRecTab(i).business_document_type||'-'||delRecTab(i).business_document_number);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Deliverable Id: '||
            to_char(delRecTab(i).deliverable_id));
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: del id is :'||to_char(delRecTab(i).deliverable_id));
         END IF;

                IF UPPER(delRecTab(i).NOTIFY_ESCALATION_UOM) = 'DAY' THEN
                    l_notification_date := trunc(delRecTab(i).actual_due_date)+delRecTab(i).NOTIFY_ESCALATION_VALUE;
                ELSIF UPPER(delRecTab(i).NOTIFY_ESCALATION_UOM) = 'WK' THEN
                    l_notification_date :=trunc(delRecTab(i).actual_due_date)+7*delRecTab(i).NOTIFY_ESCALATION_VALUE;
                ELSIF UPPER(delRecTab(i).NOTIFY_ESCALATION_UOM) = 'MTH' THEN
                    select add_months(delRecTab(i).actual_due_date,delRecTab(i).NOTIFY_ESCALATION_VALUE)
                    INTO l_notification_date from dual;
                END IF;

                IF trunc(l_notification_date) = trunc(sysdate) OR
                   trunc(l_notification_date) < trunc(sysdate) THEN -- call to notifier

--Acq Plan Messages Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_ESCALATE_NTF_SUBJECT',delRecTab(i).business_document_type);

                    okc_deliverable_wf_pvt.deliverables_notifier(
                    p_api_version               => 1.0,
                    p_init_msg_list             => FND_API.G_TRUE,
                    p_deliverable_id            => delRecTab(i).deliverable_id,
                    p_deliverable_name          => delRecTab(i).deliverable_name,
                    p_deliverable_type          => delRecTab(i).deliverable_type,
                    p_business_document_id      => delRecTab(i).business_document_id,
                    p_business_document_version => delRecTab(i).business_document_version,
                    p_business_document_type    => delRecTab(i).business_document_type,
                    p_business_document_number  => delRecTab(i).business_document_number,
                    p_resp_party                => delRecTab(i).responsible_party,
                    p_external_contact          => delRecTab(i).external_party_contact_id,
                    p_internal_contact          => delRecTab(i).escalation_assignee,
                    p_requester_id              => delRecTab(i).requester_id,
                    --p_msg_code                  => 'OKC_DEL_ESCALATE_NTF_SUBJECT',
                    p_msg_code                  => l_resolved_msg_name,
                    x_notification_id           => l_notification_id,
                    x_msg_data                  => l_msg_data,
                    x_msg_count                 => l_msg_count,
                    x_return_status             => l_return_status);
           --check return status
         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: ntf id is :'||to_char(l_notification_id));
         END IF;
                IF l_notification_id is not null THEN
                    -- if return status is success then notification is sent to
                    -- internal or external contact so update table with ntf id
                    IF l_return_status = 'S' THEN
                        j := j+1;
                        delNtfTab(j) := delRecTab(i);
                        delNtfTab(j).escalation_notification_id := l_notification_id;
                        delNtfTab(j).last_update_date := sysdate;
                        delNtfTab(j).last_updated_by := FND_GLOBAL.User_id;
                        delNtfTab(j).last_update_login:=Fnd_Global.Login_Id;
                    ELSIF l_return_status <> 'S' THEN
                        -- The return status is success because error notification has been
                        -- sent to person who launched the concurrent request.
                        l_return_status := 'S';
                    END IF;
                ELSE
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                END IF;
                END IF; -- call to notifier
            END LOOP;
            END IF;
            IF delNtfTab.COUNT > 0 THEN
                FOR i IN delNtfTab.FIRST..delNtfTab.LAST LOOP
                /** commented as this is not supported by 8i PL/SQL Bug#3307941
                UPDATE okc_deliverables SET ROW = delNtfTab(i)
                where deliverable_id = l_deliverable_id;
                l_deliverable_id := delNtfTab(i).deliverable_id;*/
                UPDATE okc_deliverables
                SET escalation_notification_id = delNtfTab(i).escalation_notification_id,
                last_update_date = sysdate,
                last_updated_by = FND_GLOBAL.User_id,
                last_update_login =Fnd_Global.Login_Id
                where deliverable_id = delNtfTab(i).deliverable_id;
                END LOOP;
          COMMIT;
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
            x_return_status := l_return_status;
    OKC_API.END_ACTIVITY(l_msg_count, l_msg_data);
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.esc_del_notifier');
       END IF;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.esc_del_notifier with G_EXC_ERROR:'||substr(sqlerrm,1,200));
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.esc_del_notifier with G_EXC_UNEXPECTED_ERROR:'||substr(sqlerrm,1,200));
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.esc_del_notifier with G_EXC_UNEXPECTED_ERROR:'||substr(sqlerrm,1,200));
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN                                 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
    END esc_del_notifier;

    -- checks for attachments and deletes them
    PROCEDURE delete_attachments (
    p_entity_name   IN VARCHAR2
    ,p_pk1_value    IN VARCHAR2
    ,x_result       OUT NOCOPY VARCHAR2
    )
    IS
    l_api_name      CONSTANT VARCHAR2(30) :='delete_attachments';
    l_att_exists    BOOLEAN;
    l_result    VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

    CURSOR att_cur IS
    SELECT att.attached_document_id
    ,doc.datatype_id
    FROM fnd_attached_documents att
    ,fnd_documents doc
    WHERE att.document_id = doc.document_id
    AND   att.entity_name = p_entity_name
    AND   att.pk1_value   = p_pk1_value;
    att_rec   att_cur%ROWTYPE;
    x_return_status  VARCHAR2(1);
    x_msg_count   NUMBER;
    x_msg_data    VARCHAR2(200);

    BEGIN

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.delete_attachments');
       END IF;
                l_att_exists :=  attachment_exists(
                    p_entity_name => p_entity_name
                    ,p_pk1_value    => p_pk1_value );

                IF l_att_exists THEN
                    OPEN att_cur;
                    FETCH att_cur INTO att_rec;

                    --delete attachments
                    fnd_attached_documents3_pkg.delete_row (
                        X_attached_document_id  => att_rec.attached_document_id,
                        X_datatype_id           => att_rec.datatype_id,
                        delete_document_flag    => 'Y' );
                    CLOSE att_cur;
                END IF;
                        x_result := l_result;
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_attachments');
       END IF;
    EXCEPTION
    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_attachments in OTHERS');
       END IF;
        IF att_cur %ISOPEN THEN
          CLOSE att_cur ;
        END IF;
        x_result := G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END delete_attachments;

    /***
    1.  This API performs bulk delete of deliverables for business documents.
        Invoked by OKC_TERMS_UTIL_GRP.purge_documents
    2.  For each doc_type and doc_id in p_doc_table,
        find the deliverables that belong to the business document,
        delete the deliverable, status history and attachments.
    ***/
    PROCEDURE purge_doc_deliverables (
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2:=FND_API.G_FALSE,
    p_doc_table IN OKC_TERMS_UTIL_GRP.doc_tbl_type,
    x_msg_data  OUT NOCOPY  VARCHAR2,
    x_msg_count OUT NOCOPY  NUMBER,
    x_return_status OUT NOCOPY  VARCHAR2)
    IS
    l_api_name      CONSTANT VARCHAR2(30) :='purge_doc_deliverables';
    l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
    l_deliverable_id    NUMBER;
    BEGIN

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.purge_doc_deliverables');
       END IF;
        IF p_doc_table.COUNT <> 0 THEN
        FOR i in 1.. p_doc_table.COUNT LOOP
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Business document Id:'||to_char(p_doc_table(i).doc_id));
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Business document Type:'||p_doc_table(i).doc_type);
            END IF;
                delete_deliverables (
                p_api_version  => l_api_version,
                p_init_msg_list => OKC_API.G_FALSE,
                p_doc_id    => p_doc_table(i).doc_id,
                p_doc_type  => p_doc_table(i).doc_type,
                x_msg_data   => l_msg_data,
                x_msg_count  => l_msg_count,
                x_return_status  => l_return_status);
        END LOOP;
        END IF;
            x_return_status := l_return_status;
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.purge_doc_deliverables');
       END IF;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.purge_doc_deliverables with G_EXC_ERROR');
       END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.purge_doc_deliverables with G_EXC_UNEXPECTED_ERROR');
       END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.purge_doc_deliverables with G_EXC_UNEXPECTED_ERROR');
       END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN                                 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END purge_doc_deliverables;

    /***
    1.  This API is invoked by OKC_TERMS_UTIL_PVT.merge_template_working_copy
    2.  This API will select all deliverables for a given
        business document type and version
    3.  Delete all deliverables along with the attachments and status history
    ***/
    PROCEDURE delete_deliverables (
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_doc_id    IN NUMBER,
    p_doc_type  IN  VARCHAR2,
    p_doc_version IN NUMBER DEFAULT NULL,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2
    ,p_retain_lock_deliverables_yn IN VARCHAR2)
    IS
    CURSOR del_cur IS
    SELECT deliverable_id
    FROM okc_deliverables
    WHERE business_document_id = p_doc_id
    AND   business_document_type = p_doc_type
    AND   ( p_retain_lock_deliverables_yn = 'N'
               OR
           (p_retain_lock_deliverables_yn = 'Y'
            AND amendment_operation IS NULL)
          );

    CURSOR del_version_cur IS
    SELECT deliverable_id
    FROM okc_deliverables
    WHERE business_document_id = p_doc_id
    AND   business_document_type = p_doc_type
    AND   business_document_version = p_doc_version
    AND   ( p_retain_lock_deliverables_yn = 'N'
               OR
           (p_retain_lock_deliverables_yn = 'Y'
            AND amendment_operation IS NULL)
          );


    l_result   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name VARCHAR2(30) :='delete_deliverables';
    TYPE delIdTabType IS TABLE OF NUMBER;
    delIdTab    delIdTabType;
    BEGIN

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.delete_deliverables');
       END IF;
       -- Delete specific version of deliverables or all deliverables
       -- based on p_doc_version
       IF p_doc_version IS NULL THEN
        OPEN del_cur;
        FETCH del_cur BULK COLLECT INTO delIdTab;
       ELSIF p_doc_version IS NOT NULL THEN
        OPEN del_version_cur;
        FETCH del_version_cur BULK COLLECT INTO delIdTab;
       END IF;
        IF delIdTab.COUNT <> 0 THEN
        FOR i in delIdTab.FIRST..delIdTab.LAST LOOP
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Deleting Deliverable Id :'||to_char(delIdTab(i)));
            END IF;
                -- delete deliverables status history
                DELETE FROM okc_del_status_history
                WHERE deliverable_id = delIdTab(i);
                -- delete attachments if any
                delete_attachments (
                    p_entity_name => G_ENTITY_NAME
                    ,p_pk1_value    =>  delIdTab(i)
                    ,x_result       =>  l_result);
                    IF l_result = 'S' THEN
                        -- delete deliverables
                        DELETE FROM okc_deliverables
                        WHERE deliverable_id = delIdTab(i);
                    END IF;
        END LOOP;
        END IF; -- delIdTab.COUNT <> 0
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        IF del_version_cur %ISOPEN THEN
          CLOSE del_version_cur ;
        END IF;
            x_return_status := l_result;
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_deliverables');
       END IF;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_deliverables with G_EXC_ERROR');
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        IF del_version_cur %ISOPEN THEN
          CLOSE del_version_cur ;
        END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_deliverables with G_EXC_UNEXPECTED_ERROR');
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        IF del_version_cur %ISOPEN THEN
          CLOSE del_version_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_deliverables with G_EXC_UNEXPECTED_ERROR');
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        IF del_version_cur %ISOPEN THEN
          CLOSE del_version_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END delete_deliverables;

    /***
    1.  This API is invoked by OKC_TERMS_UTIL_PVT.merge_template_working_copy
    2.  This API will select all deliverables for a given source template id
    3.  Update all deliverables on the target template Id
        set the business_document_id = source template id
    ***/
    PROCEDURE update_del_for_template_merge (
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_base_template_id  IN NUMBER,
    p_working_template_id   IN NUMBER,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2)
    IS
    CURSOR del_cur IS
    SELECT deliverable_id
    FROM okc_deliverables
    WHERE business_document_id = p_working_template_id
    AND   business_document_type = 'TEMPLATE';
    TYPE delIdRecTabType IS TABLE OF NUMBER;
    delIdTab  delIdRecTabType;
    l_api_name      CONSTANT VARCHAR2(30) :='update_del_for_template_merge';
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.update_del_for_template_merge');
       END IF;
            OPEN del_cur;
            FETCH del_cur BULK COLLECT INTO delIdTab;
            IF delIdTab.COUNT <> 0 THEN
                FORALL j IN delIdTab.FIRST..delIdTab.LAST
                UPDATE okc_deliverables
                SET business_document_id = p_base_template_id,
                last_updated_by= Fnd_Global.User_Id,
                last_update_date = sysdate,
                last_update_login=Fnd_Global.Login_Id
                WHERE deliverable_id = delIdTab(j);
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.update_del_for_template_merge');
       END IF;
       x_return_status := l_return_status;
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.update_del_for_template_merge with G_EXC_ERROR');
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: error is:'||substr(sqlerrm,1,200));
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.update_del_for_template_merge with G_EXC_UNEXPECTED_ERROR');
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: error is:'||substr(sqlerrm,1,200));
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.update_del_for_template_merge with G_EXC_UNEXPECTED_ERROR');
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: error is:'||substr(sqlerrm,1,200));
       END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN                                 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END update_del_for_template_merge;

    -- Returns the max date of the last_amendment_date for a busdoc
    -- if the deliverables did not get amended then returns the
    --max last update date
/*** added new signature bug#3192512**/

FUNCTION get_last_amendment_date (
p_api_version      IN  NUMBER
,p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE

,x_return_status    OUT NOCOPY VARCHAR2
,x_msg_data         OUT NOCOPY VARCHAR2
,x_msg_count        OUT NOCOPY NUMBER

,p_busdoc_id        IN    NUMBER
,p_busdoc_type     IN    VARCHAR2
,p_busdoc_version  IN    NUMBER)
RETURN DATE
IS
-- always go by the -99 version as amendments happen only on -99
-- bug#3293314
-- Filter internal deliverables as they are not considered in amendments 20th May 2004.
-- bug#3641366 get max last amend date from across the versions if it is null then get
-- max creation date from across versions
-- updated cursor for bug#4069955
CURSOR del_cur IS
SELECT NVL(MAX(del.last_amendment_date),MAX(del.creation_date))
FROM
 okc_deliverables del
,okc_deliverable_types_b delType
WHERE del.business_document_id = p_busdoc_id
AND   del.business_document_type = p_busdoc_type
AND   del.recurring_del_parent_id is null
--AND   manage_yn = 'N' commented to reproduce the bug#3667445
--AND   business_document_version = -99 commented for bug#3641366
--AND  deliverable_type not like '%INTERNAL%'; --Commented as part of changes for new table okc_deliverable_types_b
AND   del.deliverable_type = delType.deliverable_type_code
AND   delType.internal_flag = 'N';

/*CURSOR create_date_cur IS
SELECT MAX(last_amendment_date)
FROM okc_deliverables
WHERE business_document_id = p_busdoc_id
AND   business_document_type = p_busdoc_type
AND   business_document_version = -99
AND   deliverable_type not like '%INTERNAL%';*/
l_api_name      CONSTANT VARCHAR2(30) :='get_last_amendment_date';
l_date  DATE;

BEGIN


  --  Initialize API return status to success
  x_return_status := OKC_API.G_RET_STS_SUCCESS;


  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.get_last_amendment_date');
  END IF;
  OPEN del_cur;
  FETCH del_cur INTO l_date;
    /*bug# 3641366 IF l_date is null THEN
        OPEN create_date_cur;
        FETCH create_date_cur INTO l_date;
        CLOSE create_date_cur;
    END IF;*/
  IF del_cur %ISOPEN THEN
     CLOSE del_cur ;
  END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.get_last_amendment_date');
  END IF;
    RETURN l_date;

EXCEPTION
WHEN OTHERS THEN
IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'4300: Leaving get_last_amendment_date because of EXCEPTION: '||sqlerrm);
END IF;

     IF del_cur%ISOPEN THEN
       CLOSE del_cur;
     END IF;

    /*bug# 3641366 IF create_date_cur%ISOPEN THEN
        CLOSE create_date_cur;
    END IF;*/
     x_return_status := G_RET_STS_UNEXP_ERROR ;
     IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
     FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
     END IF;
     FND_MSG_PUB.Count_And_Get(p_encoded=>'F'
     , p_count => x_msg_count
     , p_data => x_msg_data );

     RETURN null;
END get_last_amendment_date;


  /**
   * This helper function returns valid day of week for the given date.
   * It makes sure that days sequence is matching the seeded days sequence in
   * DAY_OF_WEEK lookup type, which is standard as per AMERICA territory.
   */
  FUNCTION getStartDayOfWeek(
           p_start_date in date)
  return number is

    l_day_of_week number;
  l_api_name      CONSTANT VARCHAR2(30) :='getStartDayOfWeek';
    BEGIN
        IF TO_CHAR(p_start_date,'DY', 'NLS_DATE_LANGUAGE=AMERICAN') ='SUN' THEN
        return 1;
        ELSIF TO_CHAR(p_start_date,'DY', 'NLS_DATE_LANGUAGE=AMERICAN') ='MON' THEN
        return 2;
        ELSIF TO_CHAR(p_start_date,'DY', 'NLS_DATE_LANGUAGE=AMERICAN') ='TUE' THEN
        return 3;
        ELSIF TO_CHAR(p_start_date,'DY', 'NLS_DATE_LANGUAGE=AMERICAN') ='WED' THEN
        return 4;
        ELSIF TO_CHAR(p_start_date,'DY', 'NLS_DATE_LANGUAGE=AMERICAN') ='THU' THEN
        return 5;
        ELSIF TO_CHAR(p_start_date,'DY', 'NLS_DATE_LANGUAGE=AMERICAN') ='FRI' THEN
        return 6;
        ELSIF TO_CHAR(p_start_date,'DY', 'NLS_DATE_LANGUAGE=AMERICAN') ='SAT' THEN
        return 7;
        END IF;

    EXCEPTION
    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'102: End Date Not Found');
        END IF;
    END getStartDayOfWeek;


  /**
   * This function Returns end date as actual date for given Start date,
   * time unit(DAYS, WEEKS, MONTHS), duration and (B)efore/(A)fter.
   */
  FUNCTION get_actual_date(
    p_start_date in date,
    p_timeunit varchar2,
    p_duration number,
    p_before_after varchar2)
  return date is

  l_end_date date := NULL;
  l_timeunit varchar2(30);
  l_duration number := 0;
  x_return_status     VARCHAR2(1)           := OKC_API.G_RET_STS_SUCCESS;
  l_api_name      CONSTANT VARCHAR2(30) :='get_actual_date';

  begin
   --- check if time unit and duration values are set
   if p_timeunit is NULL and
   p_duration is NULL Then
   return (NULL);
   end if;

   --- if before
   if p_before_after = 'B' then
    l_duration := -1 * p_duration;
   else  --- if after
      l_duration := p_duration;
   end if;

   --- If time unit is MONTHS
   if p_timeunit = 'MTH' then
     if l_duration > 0 then
       l_end_date := add_months(p_start_date,l_duration);
     elsif l_duration < 0 then
       l_end_date := add_months(p_start_date,l_duration);
     elsif l_duration = 0 then
       l_end_date := p_start_date;
     end if;
     return(l_end_date);

   --- If time unit is DAYS
   elsif p_timeunit = 'DAY' then
     if l_duration > 0 then
       l_end_date := p_start_date + l_duration;
     elsif l_duration < 0 then
       l_end_date := p_start_date + l_duration;
     elsif l_duration = 0 then
       l_end_date := p_start_date;
     end if;
     return(l_end_date);

   --- If time unit is WEEKS
   elsif p_timeunit = 'WK' then
     if l_duration > 0 then
       l_end_date := p_start_date + ((l_duration*7));
     elsif l_duration < 0 then
       l_end_date := p_start_date + ((l_duration*7));
     elsif l_duration = 0 then
       l_end_date := p_start_date;
     end if;
     return(l_end_date);
   else
    return(NULL);
   end if;
   EXCEPTION
   WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'102: End Date Not Found');
        END IF;
          RETURN(null);
  END get_actual_date;

  /**
   * Resolve recurring dates for given start date, end date and repeat
   * frequency, day of month, day of week. Returns Table of dates resolved.
   */
  PROCEDURE get_recurring_dates (
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_start_date in date,
    p_end_date in date,
    p_frequency in number,
    p_recurr_day_of_month number,
    p_recurr_day_of_week number,
    x_recurr_dates   OUT NOCOPY recurring_dates_tab_type,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2)
    IS
       --- User defined Exception for handling invalid start date
       INVALID_START_DATE EXCEPTION;
       PRAGMA EXCEPTION_INIT(INVALID_START_DATE, -01839);

       l_daynum_of_week number := 0;
       l_daynum_offset number := 0;
       l_day number := 0;
       l_frequency number := 0;
       l_date date := NULL;
       dates_count number := 0;
       l_api_name      CONSTANT VARCHAR2(30) :='get_recurring_dates';

    BEGIN
     -- check the frequency, if 0 or null, reset to 1
     if p_frequency = 0 OR null THEN
       l_frequency := 1;
     else
       l_frequency := p_frequency;
     end if;

     ---- repeat every WEEK
   if p_recurr_day_of_month is NULL then

       -- find the offset between given day of week and calculated day based on
       -- start date
       -- Fix for bug # 3438381
       l_daynum_of_week := getStartDayOfWeek(p_start_date); -- to_char(p_start_date,'D');
     l_daynum_offset := p_recurr_day_of_week - l_daynum_of_week ;

       --- if offset is less than 0, subtract from 7 (for the week)
     if l_daynum_offset < 0 then
        l_daynum_offset := 7 + l_daynum_offset;
     end if;

     --- Calculate the end date
     l_date := p_start_date + l_daynum_offset;
     if TRUNC(l_date) > TRUNC(p_end_date) then
          x_return_status                := OKC_API.G_RET_STS_SUCCESS;
    return;
     end if;

       -- initialize the count to add into table of records
       dates_count := dates_count +1;

       ---
     while (TRUNC(l_date) <= TRUNC(p_end_date)) loop
         x_recurr_dates(dates_count) := l_date;
       l_date := l_date + (7*l_frequency);
         dates_count := dates_count +1;
     end loop;
     else ---- repeat every MONTH

         -- set the given day of month
         l_day := p_recurr_day_of_month;

         --- if l_day is 99 repeat every last day of month
         if l_day = 99 THEN

            --- get last day of given start date month
            l_date := last_day(p_start_date);

            -- initialize the count to add into table of records
            dates_count := dates_count +1;

            --- Loop through, unles meet end date
            while (TRUNC(l_date) <= TRUNC(p_end_date)) LOOP
               x_recurr_dates(dates_count) := l_date;
               l_date := last_day(add_months(l_date, l_frequency));
               dates_count := dates_count +1;
            END LOOP;
         else --- repeat every given day of month
            begin
        --- The first date based on given day of month
            l_date := to_date(lpad(l_day,2,'0') ||
                       SUBSTR(to_char(p_start_date,'ddmmyyyy'), 3),
                       'ddmmyyyy');
            --- If date is not valid (for e.g. 30 or 29th Feb)
            EXCEPTION
            WHEN INVALID_START_DATE THEN
                 --- set l_Date to the last day of month
                 l_date := last_day(p_start_date);
            end;
          end if;

          --- if calculated day comes out to be less than start date, calulate
          --- the first date here itself
          if TRUNC(l_date) < TRUNC(p_start_date) THEN
               l_date := add_months(l_date, l_frequency);
          end if;

          -- initialize the count to add into table of records
          dates_count := dates_count +1;

          --- Loop through, unles meet end date
          while (TRUNC(l_date) <= TRUNC(p_end_date)) LOOP
               x_recurr_dates(dates_count) := l_date;
               l_date := add_months(l_date, l_frequency);
               dates_count := dates_count +1;
          END LOOP;
     end if;
    EXCEPTION
    WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.get_recurring_dates with OTHER ERROR');
            END IF;
    x_return_status := OKC_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END get_recurring_dates;

FUNCTION internal_contact_valid(
p_contact_id NUMBER
) RETURN VARCHAR2
IS

CURSOR fnd_user_cur IS
select employee_id from fnd_user
where employee_id = p_contact_id;

fnd_user_rec  fnd_user_cur%ROWTYPE;

    CURSOR contact_cur IS
    select email_address
    from per_all_people_f
    where person_id = p_contact_id
    --and trunc(sysdate) < nvl(effective_end_date, trunc(sysdate + 1));
    and trunc(sysdate) between effective_start_date and effective_end_date;


    contact_rec  contact_cur%ROWTYPE;
    l_api_name      CONSTANT VARCHAR2(30) :='internal_contact_valid';


BEGIN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.internal_contact_valid ');
            END IF;
            OPEN fnd_user_cur;
            FETCH fnd_user_cur INTO fnd_user_rec;
            IF fnd_user_cur%FOUND THEN
                --contact person is a fnd user, so it's ok
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'contact is a fnd user, thus returning Y');
                END IF;
                RETURN('Y');
            ELSE
                OPEN contact_cur;
                FETCH contact_cur INTO contact_rec;
                IF contact_cur%FOUND THEN
                    IF(contact_rec.email_address is not null) THEN
                    --contact person is not fnd user, but it has an email address in per_people_all
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'contact is not a fnd user, but has an email address, thus returning Y');
                        END IF;
                        RETURN('Y');
                    ELSE
                    --not a fnd user, no email address either
                        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'contact is not a fnd user, does not have an email address, thus returning N');
                        END IF;
                        RETURN('N');
                    END IF;
                ELSE
                    --not a fnd user, not in per_people_all
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'contact is not in per_people_f also not a fnd user, thus returning N');
                END IF;
                    RETURN('N');
                END IF;
            END IF;
            CLOSE fnd_user_cur;
            CLOSE contact_cur;
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: OKC_DELIVERABLE_PROCESS_PVT.internal_contact_valid');
            END IF;

    EXCEPTION
    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'102: Leaving OKC_DELIVERABLE_PROCESS_PVT.internal_contact_valid with Exception');
        END IF;
        IF fnd_user_cur %ISOPEN THEN
          CLOSE fnd_user_cur ;
        END IF;
        IF contact_cur %ISOPEN THEN
          CLOSE contact_cur ;
        END IF;
          RETURN('N');
    END internal_contact_valid;


/**
 * This function takes a contact_id
 * and check in table per_people_f
 * to see if that contact exists
 * @return true if the contact is found
 *         false  otherwise
 */
FUNCTION internal_contact_exists(
    p_contact_id  NUMBER
    ) RETURN VARCHAR2
    IS
    CURSOR contact_cur IS
    select 'X'
    from per_all_people_f
    where person_id = p_contact_id
    and trunc(sysdate) < nvl(effective_end_date, trunc(sysdate + 1));


    contact_rec  contact_cur%ROWTYPE;
    l_api_name      CONSTANT VARCHAR2(30) :='internal_contact_exists';

    BEGIN

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.internal_contact_exists ');
            END IF;
            OPEN contact_cur;
            FETCH contact_cur INTO contact_rec;
            IF contact_cur%FOUND THEN
                RETURN('Y');
            ELSE
                RETURN('N');
            END IF;
            CLOSE contact_cur;
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: OKC_DELIVERABLE_PROCESS_PVT.internal_contact_exists');
            END IF;
    EXCEPTION
    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'102: Leaving OKC_DELIVERABLE_PROCESS_PVT.internal_contact_exists with Exception');
        END IF;
        IF contact_cur %ISOPEN THEN
          CLOSE contact_cur ;
        END IF;
          RETURN('N');
    END internal_contact_exists;


    /**
      * This function checks if a given contact_id
      * exists in po_supplier_contacts_val_v
      * @return true if a record is found with the given contact_id
      *         false otherwise
      */
    FUNCTION external_contact_valid(
     p_party_id IN NUMBER
    ,p_party_role IN VARCHAR2
    ,p_contact_id  IN NUMBER
    ) RETURN VARCHAR2 IS


    -- 4145213 changed hz_parties select to synch up with ExternalPartyContact LOV query
    -- 4208420 changed hz_parties select to synch up with ExternalPartyContact LOV query

   CURSOR contact_cur IS
   select 'X'
   from
   po_supplier_users_v
   where user_party_id = p_contact_id
   and po_vendor_id = p_party_id
   and 'SUPPLIER_ORG' = p_party_role
   UNION
   SELECT 'X'
   FROM  hz_parties  contact,
   hz_relationships hr
   WHERE hr.subject_id = contact.party_id
   AND 'SUPPLIER_ORG' <> p_party_role
   And hr.object_id = p_party_id
   And contact.party_id = p_contact_id
   AND hr.relationship_type = 'CONTACT'
   AND hr.relationship_code = 'CONTACT_OF'
   and hr.subject_type = 'PERSON'
   and hr.object_type = 'ORGANIZATION'
   and hr.subject_table_name ='HZ_PARTIES'
   and hr.object_table_name ='HZ_PARTIES'
   AND     hr.status = 'A'
   AND     hr.start_date <= sysdate
   AND     nvl(hr.end_date, sysdate + 1) > sysdate;


   contact_rec  contact_cur%ROWTYPE;
   l_api_name      CONSTANT VARCHAR2(30) :='external_contact_valid';

   BEGIN

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module
              ||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.external_contact_valid ');
      END IF;
      OPEN contact_cur;
      FETCH contact_cur INTO contact_rec;
      IF contact_cur%FOUND THEN
        RETURN('Y');
      ELSE
        RETURN('N');
      END IF;
      CLOSE contact_cur;

      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module
           ||l_api_name,'101: OKC_DELIVERABLE_PROCESS_PVT.external_contact_valid');
      END IF;
    EXCEPTION
    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'102: Leaving OKC_DELIVERABLE_PROCESS_PVT.external_contact_valid with Exception');
        END IF;
        IF contact_cur %ISOPEN THEN
          CLOSE contact_cur ;
        END IF;
          RETURN('N');
    END external_contact_valid;

  /**
   * This function returns the meaning of a given
   * fnd lookup type and code
   */
  FUNCTION get_lookup_meaning(
    p_lookup_type   IN VARCHAR2,
    p_lookup_code   IN VARCHAR2
  ) RETURN VARCHAR2

  IS


    l_meaning VARCHAR2(80);
    l_api_name      CONSTANT VARCHAR2(30) :='get_lookup_meaning';

    BEGIN
        select meaning into l_meaning
        from fnd_lookups
        where lookup_type = p_lookup_type
        and lookup_code = p_lookup_code;

        return l_meaning;

    EXCEPTION
    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'102: Leaving OKC_DELIVERABLE_PROCESS_PVT.get_lookup_meaning with exception');
        END IF;

        RETURN '';
    END get_lookup_meaning;


  /**
   * This procedure checks if there is any error related to a given
   * deliverable's notification details
   * @modifies px_qa_result_tbl  table of records that contains validation
   *           errors and warnings
   * @returns  x_return_status OKC_API.G_RET_STS_SUCCESS if succeeds
   *                           OKC_API.G_RET_STS_ERROR if failes
   *                           OKC_API.G_RET_STS_UNEXP_ERROR is unexpected error
   *           x_qa_status     OKC_API.G_RET_STS_SUCCESS if no error/warning is found
   *                           OKC_API.G_RET_STS_ERROR if at least one error/warning is found
   */
  PROCEDURE check_notifications (
    del_rec          IN  OKC_DELIVERABLES%ROWTYPE,
    p_severity          IN VARCHAR2,
    px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
    x_return_status    OUT  NOCOPY VARCHAR2
   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'check_notifications';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qa_result_tbl                 OKC_TERMS_QA_PVT.qa_result_tbl_type;
    l_index                         PLS_INTEGER := 0;
    l_start                         PLS_INTEGER := 0;
    l_message_txt                   VARCHAR2(2000);
    l_doc_type_class                OKC_BUS_DOC_TYPES_B.document_type_class%TYPE;
    l_qa_code                       VARCHAR2(80) := 'CHECK_NOTIFICATIONS';
    l_short_desc                    VARCHAR2(80);

	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);



   BEGIN

   l_qa_result_tbl := px_qa_result_tbl;
   l_index := px_qa_result_tbl.count;
   l_start := px_qa_result_tbl.count;
   l_short_desc := get_lookup_meaning('OKC_TERM_QA_LIST',l_qa_code);

   --if business_document_type is not TEMPLATE, we need to perform the checks
   IF (del_rec.business_document_type <> 'TEMPLATE') THEN

        --check notification
        /*IF(del_rec.notify_prior_due_date_yn = 'Y') THEN
            IF(del_rec.notify_prior_due_date_value is null OR del_rec.notify_prior_due_date_uom is null) THEN
                l_index := l_index+1;
                l_qa_result_tbl(l_index).error_severity := G_QA_STS_ERROR;
                l_qa_result_tbl(l_index).message_name := 'OKC_DEL_NTF_DETAILS_REQUIRED';
                l_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_NTF_DETAILS_REQUIRED',
                                                            p_token1 => 'NOTIFICATION_TYPE',
                                                            p_token1_value => 'prior due',
                                                            p_token2 => 'DELIVERABLE_NAME',
                                                            p_token2_value => del_rec.deliverable_name);
                l_qa_result_tbl(l_index).problem_details := l_message_txt;
                l_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_NTF_DETAILS_REQUIRED_S');
                l_qa_result_tbl(l_index).suggestion := l_message_txt;

            END IF;
        END IF;
        */

        IF(del_rec.notify_escalation_yn = 'Y') THEN
            IF(del_rec.notify_escalation_value is null OR del_rec.notify_escalation_uom is null OR del_rec.escalation_assignee is null) THEN
                l_index := l_index+1;
                l_qa_result_tbl(l_index).error_severity := p_severity;
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_ESCALATE_REQUIRED',del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

                /*l_qa_result_tbl(l_index).message_name := 'OKC_DEL_ESCALATE_REQUIRED';
                l_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_ESCALATE_REQUIRED',
                                                            p_token1 => 'DELIVERABLE_NAME',
                                                            p_token1_value => del_rec.deliverable_name);*/

                l_qa_result_tbl(l_index).message_name := l_resolved_msg_name;
                l_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_resolved_msg_name,
	                                                          p_token1 => 'DEL_TOKEN',
                                                            p_token1_value => l_resolved_token,
                                                            p_token2 => 'DELIVERABLE_NAME',
                                                            p_token2_value => del_rec.deliverable_name);

                l_qa_result_tbl(l_index).problem_details := l_message_txt;
                l_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_REQUIRED_S');
                l_qa_result_tbl(l_index).suggestion := l_message_txt;

            END IF;
        END IF;
    END IF;
   --mass update common attributes
   IF(l_index > l_start) THEN
   --We have some errors
   -- Bug#3369934 changed the l_start to l_start+1 to handle multiple messages
    FOR i IN (l_start+1)..l_index
    LOOP
        l_qa_result_tbl(i).title := del_rec.deliverable_name;
        l_qa_result_tbl(i).deliverable_id := del_rec.deliverable_id;
        l_qa_result_tbl(i).qa_code := l_qa_code;
        l_qa_result_tbl(i).problem_short_desc := l_short_desc;

    END LOOP;
   END IF;

   x_return_status := l_return_status;
   px_qa_result_tbl := l_qa_result_tbl;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_notifications with G_EXC_ERROR');
       END IF;

       x_return_status := G_RET_STS_ERROR;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_notifications with G_EXC_UNEXPECTED_ERROR');
       END IF;

       x_return_status := G_RET_STS_UNEXP_ERROR;


    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_notifications with OTHERS EXCEPTION');
       END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;


   END check_notifications;

  /**
   * This procedure checks if there is any error related to a given
   * deliverable's internal contacts
   * @modifies px_qa_result_tbl  table of records that contains validation
   *           errors and warnings
   * @returns  x_return_status OKC_API.G_RET_STS_SUCCESS if succeeds
   *                           OKC_API.G_RET_STS_ERROR if failes
   *                           OKC_API.G_RET_STS_UNEXP_ERROR is unexpected error
   *           x_qa_status     OKC_API.G_RET_STS_SUCCESS if no error/warning is found
   *                           OKC_API.G_RET_STS_ERROR if at least one error/warning is found
   */
   PROCEDURE check_internal_contacts (
    del_rec          IN  OKC_DELIVERABLES%ROWTYPE,
    p_severity         IN VARCHAR2,
    px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
    x_return_status    OUT  NOCOPY VARCHAR2
   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'check_internal_contacts';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qa_result_tbl                 OKC_TERMS_QA_PVT.qa_result_tbl_type;
    l_index                         PLS_INTEGER := 0;
    l_start                         PLS_INTEGER := 0;
    l_doc_type_class                OKC_BUS_DOC_TYPES_B.document_type_class%TYPE;
    l_contact_exists                VARCHAR2(1);
    l_qa_code                       VARCHAR2(80) := 'CHECK_BUYER_CONTACT';
    l_short_desc                    VARCHAR2(80);

    l_err_message_txt          FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_sugg_message_txt         FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

--Acq Plan Message Cleanup
 --   l_IntContactMissing_err_msg      FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_MISSING_INT_CONTACT';
    l_IntContactMissing_err_msg      FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_MISSING_INT_CONTACT';
--    l_IntContactInvalid_err_msg      FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_INVALID_INT_CONTACT';
    l_IntContactInvalid_err_msg      FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_INVALID_INT_CONTACT';
    l_IntContactInvalid_sugg_msg      FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_INVALID_INT_CONTACT_S';

    l_ContactMissing_sugg_msg      FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_REQUIRED_S';
    l_InvalidRequestor_err_msg       FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_INVALID_REQUESTER';
    l_InvalidRequestor_sugg_msg       FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_INVALID_REQUESTER_S';
    --Acq Plan Message Cleanup
    --l_InvalidEscAssgn_err_msg       FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_INVALID_ESCA_ASSIGNEE';
    l_InvalidEscAssgn_err_msg       FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_INVALID_ESCA_ASSIGNEE';
    l_InvalidEscAssgn_sugg_msg       FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_INVALID_ESCA_S';

    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);


   BEGIN

   l_qa_result_tbl := px_qa_result_tbl;
   l_index := px_qa_result_tbl.count;
   l_start := px_qa_result_tbl.count;

   l_short_desc := get_lookup_meaning('OKC_TERM_QA_LIST',l_qa_code);

   l_doc_type_class := getDocTypeClass(p_bus_doctype => del_rec.business_document_type);

        --if bus doc is not template, then internal contact is required
        IF(l_doc_type_class <> 'TEMPLATE' and del_rec.internal_party_contact_id is null) THEN
            l_index := l_index+1;

            --l_qa_result_tbl(l_index).error_severity := G_QA_STS_ERROR;
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message(l_IntContactMissing_err_msg,del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

/*          l_qa_result_tbl(l_index).message_name := l_IntContactMissing_err_msg;
            l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_IntContactMissing_err_msg,
                                                            p_token1 => 'DELIVERABLE_NAME',
                                                            p_token1_value => del_rec.deliverable_name);   */

            l_qa_result_tbl(l_index).message_name := l_resolved_msg_name;
            l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_resolved_msg_name,
	                                                          p_token1 => 'DEL_TOKEN',
                                                            p_token1_value => l_resolved_token,
                                                            p_token2 => 'DELIVERABLE_NAME',
                                                            p_token2_value => del_rec.deliverable_name);


            l_sugg_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_ContactMissing_sugg_msg);

            l_qa_result_tbl(l_index).problem_details := l_err_message_txt;
            l_qa_result_tbl(l_index).suggestion := l_sugg_message_txt;
        END IF;


        --check if internal contact exists on a bus doc
        IF(l_doc_type_class <> 'TEMPLATE' and del_rec.internal_party_contact_id is not null) THEN
            l_contact_exists := internal_contact_exists(p_contact_id => del_rec.internal_party_contact_id);

            IF l_contact_exists = 'N' THEN
                l_index := l_index+1;
                --l_qa_result_tbl(l_index).error_severity := G_QA_STS_ERROR;

				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message(l_IntContactInvalid_err_msg,del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

/*                l_qa_result_tbl(l_index).message_name := l_IntContactInvalid_err_msg;
                l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_IntContactInvalid_err_msg);*/

                l_qa_result_tbl(l_index).message_name := l_resolved_msg_name;
                l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_resolved_msg_name,
	                                                          p_token1 => 'DEL_TOKEN',
                                                            p_token1_value => l_resolved_token
                                                            );
                l_sugg_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_IntContactInvalid_sugg_msg);

                l_qa_result_tbl(l_index).problem_details := l_err_message_txt;
                l_qa_result_tbl(l_index).suggestion := l_sugg_message_txt;

            END IF;

        END IF;



        --check if requestor exists on a bus doc
        IF(l_doc_type_class <> 'TEMPLATE' and del_rec.requester_id is not null) THEN
            l_contact_exists := internal_contact_exists(p_contact_id => del_rec.requester_id);
            IF(l_contact_exists = 'N') THEN

                l_index := l_index+1;
                --l_qa_result_tbl(l_index).error_severity := G_QA_STS_WARNING;
                --Acq Plan Message Cleanup

                l_resolved_msg_name := OKC_API.resolve_message(l_InvalidRequestor_err_msg,del_rec.business_document_type);
                l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

                l_qa_result_tbl(l_index).message_name := l_resolved_msg_name;
                l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_resolved_msg_name,
                                                            p_token1 => 'DEL_TOKEN',
                                                            p_token1_value => l_resolved_token);

                /*l_qa_result_tbl(l_index).message_name := l_InvalidRequestor_err_msg;
                l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_InvalidRequestor_err_msg);*/
                l_qa_result_tbl(l_index).problem_details := l_err_message_txt;
                l_sugg_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_InvalidRequestor_sugg_msg);
                l_qa_result_tbl(l_index).suggestion := l_sugg_message_txt;

            END IF;
        END IF;

        --check if escalation assignee exists on a bus doc
        IF(l_doc_type_class <> 'TEMPLATE' and del_rec.notify_escalation_yn = 'Y' and del_rec.escalation_assignee is not null) THEN
            l_contact_exists := internal_contact_exists(p_contact_id => del_rec.escalation_assignee);
            IF (l_contact_exists = 'N')  THEN

                l_index := l_index+1;
                --l_qa_result_tbl(l_index).error_severity := G_QA_STS_ERROR;
                --Acq Plan Message Cleanup
                /*l_qa_result_tbl(l_index).message_name := l_InvalidEscAssgn_err_msg;
                l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_InvalidEscAssgn_err_msg);*/

                  l_resolved_msg_name := OKC_API.resolve_message(l_InvalidEscAssgn_err_msg,del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);


                l_qa_result_tbl(l_index).message_name := l_InvalidEscAssgn_err_msg;
                l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_resolved_msg_name,
                                                            p_token1 => 'DEL_TOKEN',
                                                            p_token1_value => l_resolved_token);
                l_qa_result_tbl(l_index).problem_details := l_err_message_txt;
                l_sugg_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_InvalidEscAssgn_sugg_msg);
                l_qa_result_tbl(l_index).suggestion := l_sugg_message_txt;

            END IF;
        END IF;

   --mass update common attributes
   IF(l_index > l_start) THEN
   --We have some errors
   -- Bug#3369934 changed the l_start to l_start+1 to handle multiple messages
    FOR i IN (l_start+1)..l_index
    LOOP
        l_qa_result_tbl(i).title := del_rec.deliverable_name;
        l_qa_result_tbl(i).deliverable_id := del_rec.deliverable_id;
        l_qa_result_tbl(i).qa_code := l_qa_code;
        l_qa_result_tbl(i).problem_short_desc := l_short_desc;
        l_qa_result_tbl(i).error_severity := p_severity;

    END LOOP;
   END IF;

   x_return_status := l_return_status;
   px_qa_result_tbl := l_qa_result_tbl;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_internal_contacts with G_EXC_ERROR');
       END IF;

       x_return_status := G_RET_STS_ERROR;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_internal_contacts with G_EXC_UNEXPECTED_ERROR');
       END IF;

       x_return_status := G_RET_STS_UNEXP_ERROR;


    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_internal_contacts with OTHERS EXCEPTION');
       END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;


   END check_internal_contacts;


     /**
   * This procedure checks if there is any error related to a given
   * deliverable's internal contacts
   * @modifies px_qa_result_tbl  table of records that contains validation
   *           errors and warnings
   * @returns  x_return_status OKC_API.G_RET_STS_SUCCESS if succeeds
   *                           OKC_API.G_RET_STS_ERROR if failes
   *                           OKC_API.G_RET_STS_UNEXP_ERROR is unexpected error
   *           x_qa_status     OKC_API.G_RET_STS_SUCCESS if no error/warning is found
   *                           OKC_API.G_RET_STS_ERROR if at least one error/warning is found
   */
   PROCEDURE check_internal_contacts_valid (
    del_rec          IN  OKC_DELIVERABLES%ROWTYPE,
    p_severity         IN VARCHAR2,
    px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
    x_return_status    OUT  NOCOPY VARCHAR2
   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'check_internal_contacts_valid';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qa_result_tbl                 OKC_TERMS_QA_PVT.qa_result_tbl_type;
    l_index                         PLS_INTEGER := 0;
    l_start                         PLS_INTEGER := 0;
    l_message_txt                   VARCHAR2(2000);
    l_doc_type_class                OKC_BUS_DOC_TYPES_B.document_type_class%TYPE;
    l_contact_valid                 VARCHAR2(1);

    l_qa_code                       VARCHAR2(80) := 'CHECK_INTERNAL_CONTACT_VALID';
    l_short_desc                    VARCHAR2(80);

    l_err_message_txt          FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_sugg_message_txt         FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);

   BEGIN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.check_internal_contacts_valid');
      END IF;
   l_qa_result_tbl := px_qa_result_tbl;
   l_index := px_qa_result_tbl.count;
   l_start := px_qa_result_tbl.count;

   l_short_desc := get_lookup_meaning('OKC_TERM_QA_LIST',l_qa_code);

   l_doc_type_class := getDocTypeClass(p_bus_doctype => del_rec.business_document_type);

        --check if internal contact is a valid fnd user or if it has an email address
        IF(l_doc_type_class <> 'TEMPLATE' and del_rec.internal_party_contact_id is not null) THEN
            l_contact_valid := internal_contact_valid(p_contact_id => del_rec.internal_party_contact_id);
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'internal contact valid (l_contact_valid): '||l_contact_valid);
            END IF;
            IF l_contact_valid = 'N'  THEN
              l_index := l_index+1;

				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_INV_INT_CONT_EMAIL',del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

/*                l_qa_result_tbl(l_index).message_name := 'OKC_DEL_INV_INT_CONT_EMAIL';
                l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_INV_INT_CONT_EMAIL');*/

                l_qa_result_tbl(l_index).message_name := l_resolved_msg_name;
                l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_resolved_msg_name,
																                            p_token1 => 'DEL_TOKEN',
                                                            p_token1_value => l_resolved_token
                                                            );

                l_sugg_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_INV_INT_CONT_EMAIL_S');

                l_qa_result_tbl(l_index).problem_details := l_err_message_txt;
                l_qa_result_tbl(l_index).suggestion := l_sugg_message_txt;

            END IF;

        END IF;

        --check if requester is a valid fnd user or if it has an email address
         IF(l_doc_type_class <> 'TEMPLATE' and del_rec.requester_id is not null) THEN
            l_contact_valid := internal_contact_valid(p_contact_id => del_rec.requester_id);
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'requester valid (l_contact_valid): '||l_contact_valid);
            END IF;
            IF l_contact_valid = 'N'  THEN

                l_index := l_index+1;

				  --Acq Plan Message Cleanup
                l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_INV_REQ_CONT_EMAIL',del_rec.business_document_type);
                l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

/*              l_qa_result_tbl(l_index).message_name := 'OKC_DEL_INV_REQ_CONT_EMAIL';
                l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_INV_REQ_CONT_EMAIL');*/

                l_qa_result_tbl(l_index).message_name := l_resolved_msg_name;
                l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_resolved_msg_name,
																                            p_token1 => 'DEL_TOKEN',
                                                            p_token1_value => l_resolved_token
                                                            );

                l_qa_result_tbl(l_index).problem_details := l_err_message_txt;
                l_sugg_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_INV_INT_CONT_EMAIL_S');
                l_qa_result_tbl(l_index).suggestion := l_sugg_message_txt;

            END IF;
        END IF;

        --check if escalation assignee is a valid fnd user or if it has an email address
        IF(l_doc_type_class <> 'TEMPLATE' and del_rec.notify_escalation_yn = 'Y' and del_rec.escalation_assignee is not null) THEN
            l_contact_valid := internal_contact_valid(p_contact_id => del_rec.escalation_assignee);
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'escalation assignee valid (l_contact_valid): '||l_contact_valid);
            END IF;
            IF l_contact_valid = 'N'  THEN

                l_index := l_index+1;
                l_qa_result_tbl(l_index).message_name := 'OKC_DEL_INV_ESC_CONT_EMAIL';
                l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_INV_ESC_CONT_EMAIL');
                l_qa_result_tbl(l_index).problem_details := l_err_message_txt;
                l_sugg_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_INV_INT_CONT_EMAIL_S');
                l_qa_result_tbl(l_index).suggestion := l_sugg_message_txt;

            END IF;
        END IF;



   --mass update common attributes
   IF(l_index > l_start) THEN
   --We have some errors
   -- Bug#3369934 changed the l_start to l_start+1 to handle multiple messages
    FOR i IN (l_start+1)..l_index
    LOOP
        l_qa_result_tbl(i).title := del_rec.deliverable_name;
        l_qa_result_tbl(i).deliverable_id := del_rec.deliverable_id;
        l_qa_result_tbl(i).qa_code := l_qa_code;
        l_qa_result_tbl(i).problem_short_desc := l_short_desc;
        l_qa_result_tbl(i).error_severity := p_severity;

    END LOOP;
   END IF;

   x_return_status := l_return_status;
   px_qa_result_tbl := l_qa_result_tbl;

   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'leaving check_internal_contacts_valid without error');
   END IF;
   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving check_internal_contacts_valid with G_EXC_ERROR');
       END IF;

       x_return_status := G_RET_STS_ERROR;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_internal_contacts with G_EXC_UNEXPECTED_ERROR');
       END IF;

       x_return_status := G_RET_STS_UNEXP_ERROR;


    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_internal_contacts_valid with OTHERS EXCEPTION');
       END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;


   END check_internal_contacts_valid;





  /**
   * This procedure checks if there is any error related to a given
   * deliverable's external contacts
   * @modifies px_qa_result_tbl  table of records that contains validation
   *           errors and warnings
   * @returns  x_return_status OKC_API.G_RET_STS_SUCCESS if succeeds
   *                           OKC_API.G_RET_STS_ERROR if failes
   *                           OKC_API.G_RET_STS_UNEXP_ERROR is unexpected error
   *           x_qa_status     OKC_API.G_RET_STS_SUCCESS if no error/warning is found
   *                           OKC_API.G_RET_STS_ERROR if at least one error/warning is found
   */
   PROCEDURE check_external_contacts (
    del_rec          IN  OKC_DELIVERABLES%ROWTYPE,
    p_severity         IN VARCHAR2,
    px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
    x_return_status    OUT  NOCOPY VARCHAR2
   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'check_external_contacts';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qa_result_tbl                 OKC_TERMS_QA_PVT.qa_result_tbl_type;
    l_index                         PLS_INTEGER := 0;
    l_start                         PLS_INTEGER := 0;
    l_doc_type_class                OKC_BUS_DOC_TYPES_B.document_type_class%TYPE;
    l_contact_exists                VARCHAR2(1);
    l_contact_valid                 VARCHAR2(1);

    l_qa_code                       VARCHAR2(80) := 'CHECK_SUPPLIER_CONTACT';
    l_short_desc                    VARCHAR2(80);

--Messages for Repository
-- Acq Plan Messages Cleanup
    --l_ExtContact_err_msg   FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_INVALID_EXT_CONTACT';
    l_ExtContact_err_msg   FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_INVALID_EXT_CONTACT';
    l_ExtContact_sugg_msg  FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_DEL_INVALID_EXT_CONTACT_S';

--Messages for PO
    --l_SupplierContact_err_msg VARCHAR2(30) := 'OKC_DEL_INVALID_SUPP_CONTACT';
    l_SupplierContact_err_msg VARCHAR2(30) := 'OKC_DEL_INVALID_SUPP_CONTACT';
    l_SupplierContact_sugg_msg  VARCHAR2(30) := 'OKC_DEL_INVALID_SUPP_CONTACT_S';

    l_err_message_txt   FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
    l_sugg_message_txt   FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

    --Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);


   BEGIN

   l_qa_result_tbl := px_qa_result_tbl;
   l_index := px_qa_result_tbl.count;
   l_start := px_qa_result_tbl.count;

   l_short_desc := get_lookup_meaning('OKC_TERM_QA_LIST',l_qa_code);

   --get the document type class based on deliverable's business document type
   l_doc_type_class := getDocTypeClass(p_bus_doctype => del_rec.business_document_type);

        --check if specified external contact exists on a bus doc
        IF(l_doc_type_class <> 'TEMPLATE' and
           del_rec.external_party_id is not null and
           del_rec.external_party_contact_id is not null) THEN
            l_contact_exists := external_contact_valid(p_party_id => del_rec.external_party_id
                                                      ,p_party_role => del_rec.external_party_role
                                                      ,p_contact_id => del_rec.external_party_contact_id);
            IF (l_contact_exists = 'N') THEN

                l_index := l_index+1;
                --l_qa_result_tbl(l_index).error_severity := G_QA_STS_ERROR;

       If (l_doc_type_class = 'REPOSITORY') THEN
       --Acq Plan Messages Cleanup
                  /*l_qa_result_tbl(l_index).message_name := l_ExtContact_err_msg;
                  l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_ExtContact_err_msg,
                                                            p_token1 => 'DELIVERABLE_NAME',
                                                            p_token1_value => del_rec.deliverable_name);*/

                  l_resolved_msg_name := OKC_API.resolve_message(l_ExtContact_err_msg,del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

                  l_qa_result_tbl(l_index).message_name := l_ExtContact_err_msg;
                  l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_resolved_msg_name,
                                                            p_token1 => 'DEL_TOKEN',
                                                            p_token1_value => l_resolved_token,
                                                            p_token2 => 'DELIVERABLE_NAME',
                                                            p_token2_value => del_rec.deliverable_name);

                  l_sugg_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_ExtContact_sugg_msg);
       ELSE
      --Acq Plan Messages Cleanup

/*                  l_qa_result_tbl(l_index).message_name := l_SupplierContact_err_msg;
                  l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_SupplierContact_err_msg,
                                                            p_token1 => 'DELIVERABLE_NAME',
                                                            p_token1_value => del_rec.deliverable_name);*/
                  l_resolved_msg_name := OKC_API.resolve_message(l_SupplierContact_err_msg,del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

                  l_qa_result_tbl(l_index).message_name := l_resolved_msg_name;
                  l_err_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_resolved_msg_name,
                                                            p_token1 => 'DEL_TOKEN',
                                                            p_token1_value => l_resolved_token,
                                                            p_token2 => 'DELIVERABLE_NAME',
                                                            p_token2_value => del_rec.deliverable_name);

                  l_sugg_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_SupplierContact_sugg_msg);
       End If;

                l_qa_result_tbl(l_index).problem_details := l_err_message_txt;
                l_qa_result_tbl(l_index).suggestion := l_sugg_message_txt;

            END IF;
        END IF;




   --mass update common attributes
   IF(l_index > l_start) THEN
   --We have some errors
   -- Bug#3369934 changed the l_start to l_start+1 to handle multiple messages
    FOR i IN (l_start+1)..l_index
    LOOP
        l_qa_result_tbl(i).title := del_rec.deliverable_name;
        l_qa_result_tbl(i).deliverable_id := del_rec.deliverable_id;
        l_qa_result_tbl(i).qa_code := l_qa_code;
        l_qa_result_tbl(i).problem_short_desc := l_short_desc;
        l_qa_result_tbl(i).error_severity := p_severity;

    END LOOP;
   END IF;

   x_return_status := l_return_status;
   px_qa_result_tbl := l_qa_result_tbl;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_external_contacts with G_EXC_ERROR');
       END IF;

       x_return_status := G_RET_STS_ERROR;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_external_contacts with G_EXC_UNEXPECTED_ERROR');
       END IF;

       x_return_status := G_RET_STS_UNEXP_ERROR;


    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_external_contacts with OTHERS EXCEPTION');
       END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;


   END check_external_contacts;

  /**
   * This procedure checks if there is any error related to a given
   * deliverable's due date details
   * @modifies px_qa_result_tbl  table of records that contains validation
   *           errors and warnings
   * @returns  x_return_status OKC_API.G_RET_STS_SUCCESS if succeeds
   *                           OKC_API.G_RET_STS_ERROR if failes
   *                           OKC_API.G_RET_STS_UNEXP_ERROR is unexpected error
   *           x_qa_status     OKC_API.G_RET_STS_SUCCESS if no error/warning is found
   *                           OKC_API.G_RET_STS_ERROR if at least one error/warning is found
   */
   PROCEDURE check_due_dates (
    del_rec          IN  OKC_DELIVERABLES%ROWTYPE,
    p_severity         IN VARCHAR2,
    p_bus_doc_date_events_tbl   IN OKC_TERMS_QA_GRP.BUSDOCDATES_TBL_TYPE,
    p_doc_type IN VARCHAR2, --Acq plan Messages Cleanup
    px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
    x_return_status    OUT NOCOPY  VARCHAR2
   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'check_due_dates';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qa_result_tbl                 OKC_TERMS_QA_PVT.qa_result_tbl_type;
    l_index                         PLS_INTEGER := 0;
    l_start                         PLS_INTEGER := 0;
    l_message_txt                   VARCHAR2(2000);
    l_qa_code                       VARCHAR2(80) := 'CHECK_DUE_DATES';
    l_short_desc                    VARCHAR2(80);

    l_start_date                    Date;
    l_end_date                      Date;

    l_has_rltv_end_date             VARCHAR2(1);
    l_has_rltv_start_date           VARCHAR2(1);

    l_start_event_full_name OKC_BUS_DOC_EVENTS_TL.meaning%TYPE;
    l_end_event_full_name OKC_BUS_DOC_EVENTS_TL.meaning%TYPE;
    msgCount PLS_INTEGER := 0;
    l_start_not_matched_flag varchar2(1) := 'Y';
    l_end_not_matched_flag varchar2(1) := 'Y';
    l_st_event_code OKC_BUS_DOC_EVENTS_B.business_event_code%TYPE;
    l_end_event_code OKC_BUS_DOC_EVENTS_B.business_event_code%TYPE;

    TYPE QaMessagesTbl IS TABLE OF OKC_BUS_DOC_EVENTS_TL.meaning%TYPE
    INDEX BY BINARY_INTEGER;

    qaMessages QaMessagesTbl;

    --Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);


   BEGIN
   l_qa_result_tbl := px_qa_result_tbl;
   l_index := px_qa_result_tbl.count;
   l_start := px_qa_result_tbl.count;
   l_short_desc := get_lookup_meaning('OKC_TERM_QA_LIST',l_qa_code);
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.check_due_dates ');
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: deliverable_id: '||to_char(del_rec.deliverable_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: deliverable_name: '||del_rec.deliverable_name);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: deliverable_name: '||del_rec.recurring_yn);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: fixed_start_date: '||del_rec.fixed_start_date);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: fixed_end_date: '||del_rec.fixed_end_date);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: start_event_date: '||del_rec.start_event_date);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: end_event_date: '||del_rec.end_event_date);
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: relative_st_date_event_id: '||to_char(del_rec.relative_st_date_event_id));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: relative_end_date_event_id: '||to_char(del_rec.relative_end_date_event_id));
       END IF;

            --single due date field validation
            --check if due date fields are populated
      IF del_rec.fixed_due_date_yn = 'Y' THEN

            IF del_rec.fixed_start_date is null THEN
                  --missing fixed_start_date
                  l_index := l_index+1;

            --Acq Plan Message Cleanup

                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_MISSING_FIXED_ST_DATE',p_doc_type);
                  l_resolved_token := OKC_API.resolve_del_token(p_doc_type);

                    -- set qa message name
                --  l_qa_result_tbl(l_index).message_name := 'OKC_DEL_MISSING_FIXED_ST_DATE';
                  l_qa_result_tbl(l_index).message_name := l_resolved_msg_name;

                    --- set problem long description
                  l_qa_result_tbl(l_index).problem_details :=
                    OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                    --p_msg_name => 'OKC_DEL_MISSING_FIXED_ST_DATE',
                    p_msg_name => l_resolved_msg_name,
                    p_token1 => 'DEL_TOKEN',
                   -- p_token1_value => del_rec.deliverable_name,
                    p_token1_value => l_resolved_token,
                    p_token2 => 'DELIVERABLE_NAME',
                    p_token2_value => del_rec.deliverable_name);

                    -- set suggestion for given qa message
                  l_qa_result_tbl(l_index).suggestion :=
                    OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                    p_msg_name => 'OKC_DEL_REQUIRED_S');

                    -- set return status for calling API to know, that there's a QA message
                  --l_qa_status := OKC_API.G_RET_STS_ERROR;
            END IF;
        ELSE

            --06-FEB-2004 pnayani -- Fix for bug 3369934 Resetting due date attributes during copy
            IF del_rec.recurring_yn = 'Y' THEN
                IF del_rec.fixed_start_date is null THEN
                    IF del_rec.relative_st_date_event_id is null THEN
                  --missing fixed_start_date
                  l_index := l_index+1;
                    -- set qa message name
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_DUE_DATE_ST_INCOMPLETE',del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

/*                  l_qa_result_tbl(l_index).message_name := 'OKC_DEL_DUE_DATE_ST_INCOMPLETE';

                    --- set problem long description
                  l_qa_result_tbl(l_index).problem_details :=
                    OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                    p_msg_name => 'OKC_DEL_DUE_DATE_ST_INCOMPLETE',
                    p_token1 => 'DELIVERABLE_NAME',
                    p_token1_value => del_rec.deliverable_name);*/

                  l_qa_result_tbl(l_index).message_name := l_resolved_msg_name;

                    --- set problem long description
                  l_qa_result_tbl(l_index).problem_details :=
                    OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                    p_msg_name => l_resolved_msg_name,
										p_token1 => 'DEL_TOKEN',
                    p_token1_value => l_resolved_token,
                    p_token2 => 'DELIVERABLE_NAME',
                    p_token2_value => del_rec.deliverable_name);

                    -- set suggestion for given qa message
                  l_qa_result_tbl(l_index).suggestion :=
                    OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                    p_msg_name => 'OKC_DEL_REQUIRED_S');

                    END IF;  -- relative_st_event_id is null
                END IF; -- del_rec.fixed_start_date is null THEN

                IF del_rec.fixed_end_date is null THEN

                    IF del_rec.relative_end_date_event_id is null THEN
                  --missing fixed_start_date
                  l_index := l_index+1;

                    -- set qa message name
				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_DUE_DATE_EN_INCOMPLETE',del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

/*                  l_qa_result_tbl(l_index).message_name := 'OKC_DEL_DUE_DATE_EN_INCOMPLETE';

                    --- set problem long description
                  l_qa_result_tbl(l_index).problem_details :=
                    OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                    p_msg_name => 'OKC_DEL_DUE_DATE_EN_INCOMPLETE',
                    p_token1 => 'DELIVERABLE_NAME',
                    p_token1_value => del_rec.deliverable_name);*/

                  l_qa_result_tbl(l_index).message_name := l_resolved_msg_name;

                    --- set problem long description
                  l_qa_result_tbl(l_index).problem_details :=
                    OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                    p_msg_name => l_resolved_msg_name,
										p_token1 => 'DEL_TOKEN',
                    p_token1_value => l_resolved_token,
                    p_token2 => 'DELIVERABLE_NAME',
                    p_token2_value => del_rec.deliverable_name);
                    -- set suggestion for given qa message
                  l_qa_result_tbl(l_index).suggestion :=
                    OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                    p_msg_name => 'OKC_DEL_REQUIRED_S');


                    END IF;
                END IF;  --del_rec.fixed_end_date is null THEN
            END IF; -- del_rec.recurring_yn = 'Y' THEN

            IF p_bus_doc_date_events_tbl.count > 0 THEN

                -- if deliverable definition is recurring
                IF del_rec.recurring_yn = 'Y' THEN

                    -- in itialize start date
                    l_start_date := NULL;
                    l_end_date   := NULL;

                    -- initialize boolean value which indicates if start date is
                    -- relative or fixed
                    l_has_rltv_start_date := 'N';
                    l_has_rltv_end_date   := 'N';

                    -- check start date, if it is relative to an event, and not fixed
                    IF del_rec.relative_st_date_event_id is not NULL THEN
                       -- set boolean value to Y, indicating that start date is relative
                        l_has_rltv_start_date := 'Y';
                        l_start_date := resolveRelativeDueEvents (
                                        p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                                        p_event_id => del_rec.relative_st_date_event_id,
                                        p_end_event_yn => 'N',
                                        px_event_full_name => l_start_event_full_name,
                                        px_not_matched_flag => l_start_not_matched_flag,
                                        px_event_code => l_st_event_code);

                    END IF; -- if start date is relative

                    -- check end date, if it is relative to an event, and not fixed
                    IF del_rec.relative_end_date_event_id is not NULL THEN
                        -- set boolean value to Y, indicating that start date is relative
                        l_has_rltv_end_date := 'Y';
                        l_end_date := resolveRelativeDueEvents (
                                        p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                                        p_event_id => del_rec.relative_end_date_event_id,
                                        p_end_event_yn => 'Y',
                                        px_event_full_name => l_end_event_full_name,
                                        px_not_matched_flag => l_end_not_matched_flag,
                                        px_event_code => l_end_event_code);
                    END IF; -- if end date is relative

                    --- if start date is relative
                    IF l_has_rltv_start_date = 'Y' THEN

                        -- start date is null on the business document
                        IF l_start_not_matched_flag = 'N' and l_start_date is NULL THEN

                            -- increment the count first
                            msgCount := msgCount + 1;

                            --- set the QA message
                            qaMessages(msgCount) := l_start_event_full_name;
                        END IF; -- is start date is null
                    END IF; -- if start date is relative

                    --- if end date is relative
                    IF l_has_rltv_end_date = 'Y' THEN

                        -- end date is null on the business document
                        IF  l_end_not_matched_flag = 'N' and l_end_date is NULL THEN

                           IF l_has_rltv_start_date = 'Y' THEN

                               -- add this meesage only if start and end events are not same,
                               -- other wise start qa message has lready been added.

                               IF  l_st_event_code <> l_end_event_code THEN
                                   --- increment the count first
                                   msgCount := msgCount + 1;

                                   --- set the QA message
                                   qaMessages(msgCount) := l_end_event_full_name;
                               END IF;
                           ELSE
                                   --- increment the count first
                                   msgCount := msgCount + 1;

                                   --- set the QA message
                                   qaMessages(msgCount) := l_end_event_full_name;

                           END IF;

                        END IF; -- is end date is null
                    END IF; -- if end date is relative

                ELSE -- deliverables is one time and relative

                    -- check start date, if it is relative to an event
                    IF del_rec.relative_st_date_event_id is not NULL THEN

                        -- in itialize start date
                        l_start_date := NULL;

                        -- get start date
                        l_start_date := resolveRelativeDueEvents (
                                        p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                                        p_event_id => del_rec.relative_st_date_event_id,
                                        p_end_event_yn => 'N',
                                        px_event_full_name => l_start_event_full_name,
                                        px_not_matched_flag => l_start_not_matched_flag,
                                        px_event_code => l_st_event_code);

                        -- start date is null on the business document
                        IF  l_start_not_matched_flag = 'N' and l_start_date is NULL THEN

                            -- increment the count first
                            msgCount := msgCount + 1;

                            --- set the QA message
                            qaMessages(msgCount) := l_start_event_full_name;
                        END IF; -- is start date is null
                    END IF; -- if start date is relative for one time deliverable

                END IF; -- if deliverable is recurring

                  --- set qa results.
                  -- if one date is missing
                  IF qaMessages.count > 0 and qaMessages.count = 1 THEN
                    --missing relative date
                    l_index := l_index+1;

                    -- set qa message name
                    l_qa_result_tbl(l_index).message_name := 'OKC_DEL_MISSING_RLTV_DATE';

                    --- set problem long description
                    l_qa_result_tbl(l_index).problem_details := OKC_TERMS_UTIL_PVT.get_message(
                                                                p_app_name => G_OKC,
                                                                p_msg_name => 'OKC_DEL_MISSING_RLTV_DATE',
                                                                p_token1 => 'EVT_DATE_NAME',
                                                                p_token1_value => qaMessages(1),
                                                                p_token2 => 'DELIVERABLE_NAME',
                                                                p_token2_value => del_rec.deliverable_name);

                    -- set suggestion for given qa message
                    l_qa_result_tbl(l_index).suggestion := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                              p_msg_name => 'OKC_DEL_MISSING_RLTV_DATE_S',
                                                              p_token1 => 'EVT_DATE_NAME',
                                                              p_token1_value => qaMessages(1) );

                    -- set return status for calling API to know, that there's a QA message
                    --l_qa_status := OKC_API.G_RET_STS_ERROR;

                  END IF; -- if one date is missing

                  -- if two dates are missing
                  IF qaMessages.count > 0 and qaMessages.count = 2 THEN
                      --missing relative dates (two dates)
                      l_index := l_index+1;

                      -- set qa message name
                      l_qa_result_tbl(l_index).message_name := 'OKC_DEL_MISSING_RLTV_DATES';

                      --- set problem long description
                      l_qa_result_tbl(l_index).problem_details := OKC_TERMS_UTIL_PVT.get_message(
                                                                  p_app_name => G_OKC,
                                                                  p_msg_name => 'OKC_DEL_MISSING_RLTV_DATES',
                                                                  p_token1 => 'EVT_DATE_NAME1',
                                                                  p_token1_value => qaMessages(1),
                                                                  p_token2 => 'EVT_DATE_NAME2',
                                                                  p_token2_value => qaMessages(2),
                                                                  p_token3 => 'DELIVERABLE_NAME',
                                                                  p_token3_value => del_rec.deliverable_name);

                      -- set suggestion for given qa message
                      l_qa_result_tbl(l_index).suggestion := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                                p_msg_name => 'OKC_DEL_MISSING_RLTV_DATES_S',
                                                                p_token1 => 'EVT_DATE_NAME1',
                                                                p_token1_value => qaMessages(1),
                                                                p_token2 => 'EVT_DATE_NAME2',
                                                                p_token2_value => qaMessages(2) );

                      -- set return status for calling API to know, that there's a QA message
                      --l_qa_status := OKC_API.G_RET_STS_ERROR;

                  END IF; -- if two dates are missing
            END IF; -- if dates table of records is not empty
        END IF; --- if deliverables is not fixed due date

    --mass update common attributes
   IF(l_index > l_start) THEN
   --We have some errors
   -- Bug#3369934 changed the l_start to l_start+1 to handle multiple messages
    FOR i IN (l_start+1)..l_index
    LOOP
        l_qa_result_tbl(i).title := del_rec.deliverable_name;
        l_qa_result_tbl(i).deliverable_id := del_rec.deliverable_id;
        l_qa_result_tbl(i).qa_code := l_qa_code;
        l_qa_result_tbl(i).problem_short_desc := l_short_desc;
        l_qa_result_tbl(i).error_severity := p_severity;

    END LOOP;
   END IF;

        -- set out parameters
        x_return_status := l_return_status;
        px_qa_result_tbl := l_qa_result_tbl;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_due_dates with G_EXC_ERROR');
       END IF;
       x_return_status := G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_due_dates with G_EXC_UNEXPECTED_ERROR');
       END IF;

       x_return_status := G_RET_STS_UNEXP_ERROR;


    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_due_dates with OTHERS EXCEPTION');
       END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;

   END check_due_dates;

  /**
   * This procedure checks if there is any error related to a given
   * deliverable's amendments
   * @modifies px_qa_result_tbl  table of records that contains validation
   *           errors and warnings
   * @returns  x_return_status OKC_API.G_RET_STS_SUCCESS if succeeds
   *                           OKC_API.G_RET_STS_ERROR if failes
   *                           OKC_API.G_RET_STS_UNEXP_ERROR is unexpected error
   *           x_qa_status     OKC_API.G_RET_STS_SUCCESS if no error/warning is found
   *                           OKC_API.G_RET_STS_ERROR if at least one error/warning is found
   */
   PROCEDURE check_amendments (
    del_rec          IN  OKC_DELIVERABLES%ROWTYPE,
    p_severity         IN VARCHAR2,
    px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
    x_return_status    OUT  NOCOPY VARCHAR2
   ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'check_amendments';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qa_result_tbl                 OKC_TERMS_QA_PVT.qa_result_tbl_type;
    l_index                         PLS_INTEGER := 0;
    l_start                         PLS_INTEGER := 0;
    l_message_txt                   VARCHAR2(2000);
    l_doc_type_class                OKC_BUS_DOC_TYPES_B.document_type_class%TYPE;
    l_contact_exists                BOOLEAN;
    l_contact_valid                 BOOLEAN;

    l_qa_code                       VARCHAR2(80) := 'CHECK_AMENDMENT';
    l_short_desc                    VARCHAR2(80);

	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);

   BEGIN

   l_qa_result_tbl := px_qa_result_tbl;
   l_index := px_qa_result_tbl.count;
   l_start := px_qa_result_tbl.count;

   l_short_desc := get_lookup_meaning('OKC_TERM_QA_LIST',l_qa_code);



        IF(del_rec.amendment_operation is not null and del_rec.amendment_notes is null) THEN
            l_index := l_index+1;

          	--Acq Plan Message Cleanup

          /*  l_qa_result_tbl(l_index).message_name := 'OKC_DEL_MISSING_AMEND_DESC';
            l_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_MISSING_AMEND_DESC',
                                                            p_token1 => 'DELIVERABLE_NAME',
                                                            p_token1_value => del_rec.deliverable_name);*/

            l_resolved_msg_name := OKC_API.resolve_message('OKC_DEL_MISSING_AMEND_DESC',del_rec.business_document_type);
            l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);


            l_qa_result_tbl(l_index).message_name := l_resolved_msg_name;
            l_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => l_resolved_msg_name,
                                                            p_token1 => 'DEL_TOKEN',
                                                            p_token1_value => l_resolved_token,
                                                            p_token2 => 'DELIVERABLE_NAME',
                                                            p_token2_value => del_rec.deliverable_name);
            l_qa_result_tbl(l_index).problem_details := l_message_txt;
            l_message_txt := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                                                            p_msg_name => 'OKC_DEL_REQUIRED_S');
            l_qa_result_tbl(l_index).suggestion := l_message_txt;

        END IF;



   --mass update common attributes
   IF(l_index > l_start) THEN
   --We have some errors
   -- Bug#3369934 changed the l_start to l_start+1 to handle multiple messages
    FOR i IN (l_start+1)..l_index
    LOOP
        l_qa_result_tbl(i).title := del_rec.deliverable_name;
        l_qa_result_tbl(i).deliverable_id := del_rec.deliverable_id;
        l_qa_result_tbl(i).qa_code := l_qa_code;
        l_qa_result_tbl(i).problem_short_desc := l_short_desc;
        l_qa_result_tbl(i).error_severity := p_severity;

    END LOOP;
   END IF;

   x_return_status := l_return_status;
   px_qa_result_tbl := l_qa_result_tbl;

   EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_amendments with G_EXC_ERROR');
       END IF;

       x_return_status := G_RET_STS_ERROR;


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_amendments with G_EXC_UNEXPECTED_ERROR');
       END IF;

       x_return_status := G_RET_STS_UNEXP_ERROR;


    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_amendments with OTHERS EXCEPTION');
       END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;


   END check_amendments;

       PROCEDURE update_error_table
           (px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
            p_qa_severity IN VARCHAR2,
            p_qa_code IN VARCHAR2,
            p_error_msg_name IN VARCHAR2,
            p_del_variable_name IN VARCHAR2,
            p_article_name IN VARCHAR2,
            p_article_id IN NUMBER,
            p_section_name IN VARCHAR2,
            p_suggestion_msg_name IN VARCHAR2,
            x_return_status OUT NOCOPY VARCHAR2) IS

   l_msg_txt VARCHAR2(2000);
   l_suggestion_txt VARCHAR2(2000);
   l_index NUMBER;
   l_return_status VARCHAR2(1);
   l_short_desc VARCHAR2(80);
   l_api_name CONSTANT  VARCHAR2(30) := 'update_error_table';
   Begin
    l_return_status := G_RET_STS_SUCCESS;
    l_short_desc := get_lookup_meaning('OKC_TERM_QA_LIST',p_qa_code);
    l_msg_txt  := OKC_TERMS_UTIL_PVT.get_message
                                        (p_app_name => G_OKC,
                                         p_msg_name => p_error_msg_name,
                                         p_token1 => 'DELIVERABLE_VARIABLE',
                                         p_token1_value => p_del_variable_name,
                                         p_token2 => 'ARTICLE_NAME',
                                         p_token2_value => p_article_name);

    l_suggestion_txt  := OKC_TERMS_UTIL_PVT.get_message
                                        (p_app_name => G_OKC,
                                         p_msg_name => p_suggestion_msg_name);
    l_index := px_qa_result_tbl.count + 1;
    px_qa_result_tbl(l_index).error_severity := p_qa_severity;
    px_qa_result_tbl(l_index).qa_code := p_qa_code;
    px_qa_result_tbl(l_index).message_name := p_error_msg_name;
    px_qa_result_tbl(l_index).problem_details := l_msg_txt;
    px_qa_result_tbl(l_index).suggestion := l_suggestion_txt;
    px_qa_result_tbl(l_index).title := p_article_name;
    px_qa_result_tbl(l_index).article_id := p_article_id;
    px_qa_result_tbl(l_index).section_name := p_section_name;
    px_qa_result_tbl(l_index).problem_short_desc := l_short_desc;
    x_return_status := l_return_status;
       EXCEPTION
         WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'5002: Leaving update_error_table with unexpected error:'||SQLERRM);
          END IF;
          x_return_status := G_RET_STS_UNEXP_ERROR;

   End update_error_table;


      /* This procedure gets called from validate_deliverables_for_qa routine to check to see if
     there are any variables of type 'D' which don't have deliverables associated
     with them.
  */
     PROCEDURE check_deliverables_var_usage(
            p_severity         IN VARCHAR2,
            p_bus_doc_type     IN VARCHAR2,
            p_bus_doc_id       IN NUMBER,
            px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
            x_return_status    OUT  NOCOPY VARCHAR2) IS

      l_api_version                  CONSTANT NUMBER := 1;
      l_api_name                     CONSTANT VARCHAR2(30) := 'check_deliverables_var_usage';
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_qa_result_tbl                 OKC_TERMS_QA_PVT.qa_result_tbl_type;
      l_index                         PLS_INTEGER := 0;
      l_start                         PLS_INTEGER := 0;
      l_message_txt                   VARCHAR2(2000);
      l_qa_code                       VARCHAR2(80) := 'CHECK_DELIVERABLES_VAR_USAGE';
      l_short_desc                    VARCHAR2(80) ;

      l_old_var_code                okc_k_art_variables.variable_code%TYPE;
      l_old_art_id                  okc_k_articles_b.sav_sae_id%TYPE;
      l_article_name                VARCHAR2(240);

      --variable codes
      l_var_code_int_con            CONSTANT VARCHAR2(40) := 'INTERNAL_CONTRACTUAL_DEL';
      l_var_code_ext_con            CONSTANT VARCHAR2(40) := 'EXTERNAL_CONTRACTUAL_DEL';
      l_var_code_all_con            CONSTANT VARCHAR2(40) := 'ALL_CONTRACTUAL_DEL';

      l_var_code_ext_sourcing       CONSTANT VARCHAR2(40) := 'EXTERNAL_SOURCING_DEL';
      l_var_code_all_sourcing       CONSTANT VARCHAR2(40) := 'ALL_SOURCING_DEL';

      l_contractual                 CONSTANT VARCHAR2(40) := 'CONTRACTUAL';
      l_sourcing                    CONSTANT VARCHAR2(40) := 'SOURCING';

      --l_external                    CONSTANT VARCHAR2(40) := 'EXTERNAL';
      --l_internal                    CONSTANT VARCHAR2(40) := 'INTERNAL';

      l_internal_org                CONSTANT VARCHAR2(40) := 'INTERNAL_ORG';


      l_error_exists                VARCHAR2(1) := 'N';

      DEL_NOT_FOUND_EXCEPTION EXCEPTION;

     CURSOR get_variables_CUR IS
     select
    art.document_id doc_id
    ,art.document_type doc_type
    ,av.variable_code       variable_code
    ,art.sav_sae_id         article_id
    ,art.article_version_id version_id
    ,art.scn_id             section_id
    ,sec.label||' '||sec.heading section_name
    ,variables.variable_name variable_name
    from
    okc_k_art_variables av
    ,okc_k_articles_b art
    ,okc_sections_b sec
    ,okc_bus_variables_v variables
     where
     art.document_id = p_bus_doc_id and
     art.document_type = p_bus_doc_type and
     av.variable_type = 'D' and
     av.cat_id = art.id and --ArtVariables to Articles
     sec.id = art.scn_id and --Sections to Articles
     variables.variable_code = av.variable_code and --Variables to ArtVariables
     nvl (art.amendment_operation_code,'?') <> 'DELETED' and --fix for bug 3710697
     nvl(art.summary_amend_operation_code,'?')<> 'DELETED'
     order by av.variable_code, art.sav_sae_id;



     get_variables_REC get_variables_CUR%ROWTYPE;

     CURSOR check_int_dels_exist_CUR(p_bus_doc_type IN VARCHAR2
                                 ,p_bus_doc_id IN NUMBER
                   ,p_del_type IN VARCHAR2
               ,p_internal_org IN VARCHAR2) IS
     select 'x'
     from
      okc_deliverables del
     where
         del.business_document_type = p_bus_doc_type
     and del.business_document_id = p_bus_doc_id
     and del.deliverable_type = p_del_type
  and del.responsible_party = p_internal_org;

     check_int_dels_exist_REC check_int_dels_exist_CUR%ROWTYPE;


     CURSOR check_ext_dels_exist_CUR(p_bus_doc_type IN VARCHAR2
                                 ,p_bus_doc_id IN NUMBER
                   ,p_del_type IN VARCHAR2
               ,p_internal_org IN VARCHAR2) IS
     select 'x'
     from
      okc_deliverables del
     where
         del.business_document_type = p_bus_doc_type
     and del.business_document_id = p_bus_doc_id
     and del.deliverable_type = p_del_type
  and del.responsible_party <> p_internal_org;

     check_ext_dels_exist_REC check_ext_dels_exist_CUR%ROWTYPE;

    CURSOR check_all_dels_exist_CUR(p_bus_doc_type IN VARCHAR2
                                   ,p_bus_doc_id IN NUMBER
              ,p_del_type IN VARCHAR2) IS
    select 'x'
    from
    okc_deliverables del
    where
    del.business_document_type = p_bus_doc_type
    and del.business_document_id = p_bus_doc_id
    and del.deliverable_type = p_del_type;

    check_all_dels_exist_REC check_all_dels_exist_CUR%ROWTYPE;


    --fix bug 3682452
    --We only check the variable usage for Negotiation type of deliverables
    --on a sourcing document
    --If it's a PO document, we do not check this
    --and we decide if a document is a sourcing document based on the
    --target_response_doc_type
    CURSOR response_doc_type_cur(p_bus_doc_type IN VARCHAR2) IS
    select target_response_doc_type
    from okc_bus_doc_types_b
    where document_type = p_bus_doc_type;

    response_doc_type_rec response_doc_type_cur%ROWTYPE;

    Begin




    l_qa_result_tbl := px_qa_result_tbl;
    l_index := px_qa_result_tbl.count;
    l_start := px_qa_result_tbl.count;
    l_short_desc := get_lookup_meaning('OKC_TERM_QA_LIST',l_qa_code);

    --initialize l_old_var_code and l_old_art_id
    l_old_var_code := 'X';
    l_old_art_id := 0;


    OPEN get_variables_CUR;
    LOOP
    Begin
    Fetch get_variables_CUR into get_variables_REC;
    EXIT WHEN get_variables_CUR%NOTFOUND;

    IF (get_variables_REC.variable_code <> l_old_var_code)THEN

        --as we traverse down the records, if we encounter a different variable_code
        --we should perform the checks
        --if the article_id changes and we already know that the variable_code does not have
        --associated deliverables, we just need to insert the error message
        --without performing the check

        l_error_exists := 'N';



          IF get_variables_REC.variable_code = l_var_code_int_con then


                    OPEN check_int_dels_exist_CUR(
                          p_bus_doc_type => p_bus_doc_type
                                     ,p_bus_doc_id => p_bus_doc_id
                      ,p_del_type => l_contractual
                         ,p_internal_org => l_internal_org);

                    FETCH check_int_dels_exist_CUR into check_int_dels_exist_REC;
                    If check_int_dels_exist_CUR%NOTFOUND then
                        l_error_exists := 'Y';
                        RAISE DEL_NOT_FOUND_EXCEPTION;
                    End If;
                    CLOSE check_int_dels_exist_CUR;

          Elsif get_variables_REC.variable_code = l_var_code_ext_con then

                    OPEN check_ext_dels_exist_CUR(
                          p_bus_doc_type => p_bus_doc_type
                                     ,p_bus_doc_id => p_bus_doc_id
                      ,p_del_type => l_contractual
                         ,p_internal_org => l_internal_org);

                    FETCH check_ext_dels_exist_CUR into check_ext_dels_exist_REC;
                    If check_ext_dels_exist_CUR%NOTFOUND then
                        l_error_exists := 'Y';
                        RAISE DEL_NOT_FOUND_EXCEPTION;
                    End If;
                    CLOSE check_ext_dels_exist_CUR;

          Elsif get_variables_REC.variable_code = l_var_code_all_con then


                OPEN check_all_dels_exist_CUR(p_bus_doc_type => p_bus_doc_type
                        ,p_bus_doc_id => p_bus_doc_id
                     ,p_del_type => l_contractual);

                FETCH check_all_dels_exist_CUR into check_all_dels_exist_REC;
                If check_all_dels_exist_CUR%NOTFOUND then
                    l_error_exists := 'Y';
                    RAISE DEL_NOT_FOUND_EXCEPTION;
                End If;
                CLOSE check_all_dels_exist_CUR;


          Elsif get_variables_REC.variable_code = l_var_code_ext_sourcing then

            --fix bug 3682452
            --We only check the variable usage for Negotiation type of deliverables
            --on a sourcing document
            OPEN response_doc_type_cur(p_bus_doc_type => p_bus_doc_type);
                FETCH response_doc_type_cur into response_doc_type_rec;
                IF response_doc_type_rec.target_response_doc_type IS NOT NULL THEN
                    OPEN check_ext_dels_exist_CUR(
                                      p_bus_doc_type => p_bus_doc_type
                                     ,p_bus_doc_id => p_bus_doc_id
                      ,p_del_type => l_sourcing
                                     ,p_internal_org => l_internal_org);

                    FETCH check_ext_dels_exist_CUR into check_ext_dels_exist_REC;
                    If check_ext_dels_exist_CUR%NOTFOUND then
                        l_error_exists := 'Y';
                        RAISE DEL_NOT_FOUND_EXCEPTION;
                    End If;
                    CLOSE check_ext_dels_exist_CUR;
                END IF;
            CLOSE response_doc_type_cur;


          Elsif get_variables_REC.variable_code = l_var_code_all_sourcing then

            --fix bug 3682452
            --We only check the variable usage for Negotiation type of deliverables
            --on a sourcing document
            OPEN response_doc_type_cur(p_bus_doc_type => p_bus_doc_type);
                FETCH response_doc_type_cur into response_doc_type_rec;
                IF response_doc_type_rec.target_response_doc_type IS NOT NULL THEN

                    OPEN check_all_dels_exist_CUR(
                    p_bus_doc_type => p_bus_doc_type
                                     ,p_bus_doc_id => p_bus_doc_id
                      ,p_del_type => l_sourcing);
                    FETCH check_all_dels_exist_CUR into check_all_dels_exist_REC;
                    If check_all_dels_exist_CUR%NOTFOUND then
                        l_error_exists := 'Y';
                        RAISE DEL_NOT_FOUND_EXCEPTION;
                    End If;
                    CLOSE check_all_dels_exist_CUR;
                END IF;
            CLOSE response_doc_type_cur;

          End IF; --get_variables_REC.variable_code = l_var_code_int_con

    ELSE --current variable_code = old variable_code

        IF(l_error_exists = 'Y')  THEN
            RAISE DEL_NOT_FOUND_EXCEPTION;
        END IF;
    END IF;


        EXCEPTION
         WHEN DEL_NOT_FOUND_EXCEPTION THEN
          IF ( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(  FND_LOG.LEVEL_EXCEPTION ,g_module||l_api_name,'5000: In check_deliverables_var_usage:DEL_NOT_FOUND :'||SQLERRM);
          END IF;

          update_error_table
           (px_qa_result_tbl => l_qa_result_tbl,
            p_qa_severity => p_severity,
            p_qa_code => l_qa_code,
            p_error_msg_name => 'OKC_DEL_VAR_NOT_RESOLVED',
            p_del_variable_name => get_variables_REC.variable_name, -- get_variables_REC.del_variable_name,
            p_article_id => get_variables_REC.article_id,
            p_article_name => okc_terms_util_pvt.get_Article_Name( get_variables_REC.article_id ,get_variables_REC.version_id), -- get_variables_REC.article_name,
            p_section_name => get_variables_REC.section_name,
            p_suggestion_msg_name => 'OKC_DEL_VAR_NOT_RESOLVED_S',
            x_return_status => l_return_status );

          IF check_int_dels_exist_CUR%ISOPEN THEN
            CLOSE check_int_dels_exist_CUR;
          END IF;
          IF check_ext_dels_exist_CUR%ISOPEN THEN
            CLOSE check_ext_dels_exist_CUR;
          END IF;

          IF check_all_dels_exist_CUR%ISOPEN THEN
            CLOSE check_all_dels_exist_CUR;
          END IF;

          IF response_doc_type_cur%ISOPEN THEN
            CLOSE response_doc_type_cur;
          END IF;

     End ; --end exception DEL_NOT_FOUND_EXCEPTION
        --reset the old values
        l_old_var_code := get_variables_REC.variable_code;
        l_old_art_id := get_variables_REC.article_id;

    END LOOP;

    CLOSE get_variables_CUR;

    x_return_status := l_return_status;
    px_qa_result_tbl := l_qa_result_tbl;

       EXCEPTION
         WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'5001: Leaving check_deliverables_var_usage with unexpected error:'||SQLERRM);
          END IF;

          IF get_variables_CUR%ISOPEN THEN
            CLOSE get_variables_CUR;
          END IF;

          IF check_int_dels_exist_CUR%ISOPEN THEN
            CLOSE check_int_dels_exist_CUR;
          END IF;

          IF check_ext_dels_exist_CUR%ISOPEN THEN
            CLOSE check_int_dels_exist_CUR;
          END IF;

          IF check_all_dels_exist_CUR%ISOPEN THEN
            CLOSE check_all_dels_exist_CUR;
          END IF;

          IF response_doc_type_cur%ISOPEN THEN
            CLOSE response_doc_type_cur;
          END IF;
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;


    End check_deliverables_var_usage;

/**********************
PROCEDURE check_external_party_exist:
This API will be invoked by validate_deliverables_for_qa routine during QA check on a
Deliverable. This check should only fire for Deliverables on a document where document_class
is 'REPOSITORY'. This check should not fire for Deliverable types whose INTERNAL_FLAG = 'Y'
 *  @modifies px_qa_result_tbl  table of records that contains validation errors and warnings
 *  @returns  x_return_status OKC_API.G_RET_STS_SUCCESS if succeeds
 *                          OKC_API.G_RET_STS_ERROR if fails
 *                          OKC_API.G_RET_STS_UNEXP_ERROR if unexpected error
 *          x_qa_status     OKC_API.G_RET_STS_SUCCESS if no error/warning is found
 *                          OKC_API.G_RET_STS_ERROR if at least one error/warning is found
***********************/
PROCEDURE check_external_party_exists (
  del_rec          IN  OKC_DELIVERABLES%ROWTYPE,
  p_severity         IN VARCHAR2,
  px_qa_result_tbl   IN OUT NOCOPY OKC_TERMS_QA_PVT.qa_result_tbl_type,
  x_return_status    OUT  NOCOPY VARCHAR2
  ) IS

  l_api_version          CONSTANT NUMBER := 1;
  l_api_name             CONSTANT VARCHAR2(30) := 'check_external_party_exists';
  l_return_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_qa_result_tbl        OKC_TERMS_QA_PVT.qa_result_tbl_type;
  l_index                PLS_INTEGER := 0;
  l_start                PLS_INTEGER := 0;

  l_qa_code               VARCHAR2(80) := 'CHECK_EXTERNAL_PARTY_EXISTS';
  l_short_desc            VARCHAR2(80);
  --Acq Plan Message Cleanup
  --l_error_msg_name        FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_CHECK_EXT_PARTY_EXISTS';
  l_error_msg_name        FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_CHECK_EXT_PARTY_EXISTS';
  --l_suggestion_msg_name   FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_CHECK_EXT_PARTY_EXISTS_S';
  l_suggestion_msg_name   FND_NEW_MESSAGES.MESSAGE_NAME%TYPE := 'OKC_CHECK_EXT_PARTY_EXISTS_S';

  l_deliverable_name_token VARCHAR2(30) := 'DELIVERABLE_NAME';

  l_error_msg_text        FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
  l_suggestion_msg_text   FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

  l_doc_type_class OKC_BUS_DOC_TYPES_B.DOCUMENT_TYPE_CLASS%TYPE;
  l_del_type_int_flag     OKC_DELIVERABLE_TYPES_B.INTERNAL_FLAG%TYPE;

	--Acq Plan Message Cleanup
    l_resolved_msg_name VARCHAR2(30);
    l_resolved_token VARCHAR2(30);

 BEGIN

  l_qa_result_tbl := px_qa_result_tbl;
  l_index := px_qa_result_tbl.count;
  l_start := px_qa_result_tbl.count;

  l_short_desc := get_lookup_meaning('OKC_TERM_QA_LIST',l_qa_code);

  l_doc_type_class := getDocTypeClass(p_bus_doctype => del_rec.business_document_type);
  If (l_doc_type_class IS NULL) then
    RAISE FND_API.G_EXC_ERROR;
  End If;
  l_del_type_int_flag := getDelTypeIntFlag(p_document_type_class => l_doc_type_class
                                          ,p_deliverable_type => del_rec.deliverable_type);
  If (l_del_type_int_flag IS NULL) then
    RAISE FND_API.G_EXC_ERROR;
  End If;

  If (l_doc_type_class = 'REPOSITORY'
     AND l_del_type_int_flag = 'N'
     AND del_rec.external_party_id is NULL) then

     l_index := l_index+1;
  l_qa_result_tbl(l_index).error_severity := G_QA_STS_ERROR;

				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message(l_error_msg_name,del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

  l_error_msg_text := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                         p_msg_name => l_resolved_msg_name,
																                       p_token1 => 'DEL_TOKEN',
                                                       p_token1_value => l_resolved_token,
                                                       p_token2 => l_deliverable_name_token,
                                                       p_token2_value => del_rec.deliverable_name);

  l_qa_result_tbl(l_index).problem_details := l_error_msg_text;

				  --Acq Plan Message Cleanup
                  l_resolved_msg_name := OKC_API.resolve_message(l_suggestion_msg_name,del_rec.business_document_type);
                  l_resolved_token := OKC_API.resolve_del_token(del_rec.business_document_type);

     l_suggestion_msg_text := OKC_TERMS_UTIL_PVT.get_message(p_app_name => G_OKC,
                           p_msg_name => l_resolved_msg_name,
													 p_token1 => 'DEL_TOKEN',
                           p_token1_value => l_resolved_token
                           );

     l_qa_result_tbl(l_index).suggestion := l_suggestion_msg_text;
  l_qa_result_tbl(l_index).title := del_rec.deliverable_name;
  l_qa_result_tbl(l_index).deliverable_id := del_rec.deliverable_id;
  l_qa_result_tbl(l_index).qa_code := l_qa_code;
  l_qa_result_tbl(l_index).problem_short_desc := l_short_desc;
  l_qa_result_tbl(l_index).error_severity := p_severity;

  End If;
      x_return_status := l_return_status;
   px_qa_result_tbl := l_qa_result_tbl;


    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module
        ||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_external_party_exists with G_EXC_ERROR');
    END IF;
      x_return_status := G_RET_STS_ERROR;


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module
      ||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_external_party_exists with G_EXC_UNEXPECTED_ERROR');
    END IF;

        x_return_status := G_RET_STS_UNEXP_ERROR;


       WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module
      ||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.check_external_party_exists with OTHERS EXCEPTION');
       END IF;
       x_return_status := G_RET_STS_UNEXP_ERROR;

       IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
       END IF;


End check_external_party_exists;


   /* This procedure is called from terms QA check API.
   * @requires p_qa_result_tbl  has been initialized
   *           p_doc_type not null
   *           p_doc_id not null
   * @modifies p_qa_result_tbl  table of records that contains validation
   *           errors and warnings
   * @returns  x_return_status OKC_API.G_RET_STS_SUCCESS if succeeds
   *                           OKC_API.G_RET_STS_ERROR if failes
   *                           OKC_API.G_RET_STS_UNEXP_ERROR is unexpected error
   */
PROCEDURE validate_deliverable_for_qa (
                        p_api_version   IN    NUMBER,
                        p_init_msg_list IN   VARCHAR2 := FND_API.G_FALSE,
                        p_doc_type    IN   VARCHAR2,
                        p_doc_id    IN    NUMBER,
                        p_mode    IN     VARCHAR2,
                        p_bus_doc_date_events_tbl   IN OKC_TERMS_QA_GRP.BUSDOCDATES_TBL_TYPE,
                        p_qa_result_tbl IN OUT NOCOPY    OKC_TERMS_QA_PVT.qa_result_tbl_type,
                        x_msg_data  OUT NOCOPY VARCHAR2,
                        x_msg_count   OUT NOCOPY NUMBER,
                        x_return_status   OUT NOCOPY VARCHAR2,
                        x_qa_return_status  IN OUT NOCOPY VARCHAR2)
  IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'validate_deliverable';
    l_qa_severity_warning          CONSTANT VARCHAR2(1) := 'W';
    l_qa_severity_error            CONSTANT VARCHAR2(1) := 'E';

    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qa_result_tbl                 OKC_TERMS_QA_PVT.qa_result_tbl_type;

    l_start                         PLS_INTEGER := 0;
    l_end                           PLS_INTEGER := 0;
    del_cur   del_cur_type;
    del_rec   okc_deliverables%ROWTYPE;
    l_qa_return_status              VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  --  l_due_date_msg                  VARCHAR2(2000) := '';
    l_check_int_contact VARCHAR2(19)  := 'CHECK_BUYER_CONTACT';
    l_check_ext_contact VARCHAR2(22)  := 'CHECK_SUPPLIER_CONTACT';
    l_check_due_dates VARCHAR2(15) := 'CHECK_DUE_DATES';
    l_check_amendments VARCHAR2(20) := 'CHECK_AMENDMENT';
    l_check_var_usage VARCHAR2(40)  := 'CHECK_DELIVERABLES_VAR_USAGE';
    l_check_notifications VARCHAR2(40) := 'CHECK_NOTIFICATIONS';
    --bug 3686334, added CHECK_INTERNAL_CONTACT_VALID
    l_check_int_contact_valid VARCHAR2(30) := 'CHECK_INTERNAL_CONTACT_VALID';
    --bug 3814702, add a variable for Lookup type

    l_check_external_party_exists VARCHAR2(30) := 'CHECK_EXTERNAL_PARTY_EXISTS';

    l_lookup_type FND_LOOKUPS.LOOKUP_TYPE%TYPE :='OKC_TERM_QA_LIST';

    CURSOR check_qa_csr(p_qa_code IN VARCHAR2) IS
    select qa_code, severity_flag,enable_qa_yn
    from okc_doc_qa_lists
    where document_type = p_doc_type
    and qa_code = p_qa_code;

    CURSOR check_lookup_code_csr(p_lookup_code IN VARCHAR2) IS
    select enabled_flag
    from fnd_lookups
    where lookup_type = l_lookup_type --bug 3814702, use variable for lookup_type
    and lookup_code = p_lookup_code;


    l_int_contact_rec check_qa_csr%ROWTYPE;
    l_ext_contact_rec check_qa_csr%ROWTYPE;
    l_due_dates_rec check_qa_csr%ROWTYPE;
    l_amendments_rec check_qa_csr%ROWTYPE;
    l_var_usage_rec check_qa_csr%ROWTYPE;
    l_notifications_rec check_qa_csr%ROWTYPE;
    l_int_contact_valid_rec check_qa_csr%ROWTYPE;
    l_chk_extparty_exists_rec check_qa_csr%ROWTYPE; --ExternalPartyExists check


    l_int_contact_code_rec check_lookup_code_csr%ROWTYPE;
    l_ext_contact_code_rec check_lookup_code_csr%ROWTYPE;
    l_due_dates_code_rec check_lookup_code_csr%ROWTYPE;
    l_amendments_code_rec check_lookup_code_csr%ROWTYPE;
    l_var_usage_code_rec check_lookup_code_csr%ROWTYPE;
    l_notifications_code_rec check_lookup_code_csr%ROWTYPE;
    l_int_contact_valid_code_rec check_lookup_code_csr%ROWTYPE;
    l_chk_extparty_exists_code_rec check_lookup_code_csr%ROWTYPE; --ExternalPartyExists check


    l_check_int_contact_yn VARCHAR2(1);
    l_check_ext_contact_yn VARCHAR2(1);
    l_check_due_dates_yn VARCHAR2(1);
    l_check_amendments_yn VARCHAR2(1);
    l_check_var_usage_yn VARCHAR2(1);
    l_check_notifications_yn VARCHAR2(1);
    l_check_int_contact_valid_yn VARCHAR2(1);
    l_chk_extparty_exists_yn VARCHAR2(1); --ExternalPartyExists check

    l_int_contact_severity VARCHAR2(1);
    l_ext_contact_severity VARCHAR2(1);
    l_due_dates_severity VARCHAR2(1);
    l_amendments_severity VARCHAR2(1);
    l_var_usage_severity VARCHAR2(1);
    l_notifications_severity VARCHAR2(1);
    l_int_contact_valid_severity VARCHAR2(1);
    l_chk_extparty_exists_severity VARCHAR2(1); --ExternalPartyExists check

    l_error_found      VARCHAR2(1) := 'N';
    l_warning_found    VARCHAR2(1) := 'N';
    l_contract_source OKC_TEMPLATE_USAGES.CONTRACT_SOURCE_CODE%TYPE;



  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       okc_debug.Set_Indentation('OKC_DELIVERABLE_PROCESS_PVT');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'21300: Entered validate_deliverable_for_qa');
    END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                             x_return_status);
    IF p_doc_id = NULL THEN
       Okc_Api.Set_Message(G_APP_NAME
                       ,'OKC_DEL_NO_PARAMS');
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF p_doc_type = NULL THEN
       Okc_Api.Set_Message(G_APP_NAME
                       ,'OKC_DEL_NO_PARAMS');
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF p_mode = NULL THEN
       Okc_Api.Set_Message(G_APP_NAME
                       ,'OKC_DEL_NO_PARAMS');
       RAISE FND_API.G_EXC_ERROR;
    END IF;



    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --initialize l_qa_result_tbl
    l_qa_result_tbl := p_qa_result_tbl;

    l_start := l_qa_result_tbl.count;


    --first we check if the lookup_code is enabled in fnd_lookups
    --(1)if the lookup_code is disabled we do not perform the QA check
    --(2)if the lookup_code is enabled we query okc_qa_doc_lists
    --if the enable_qa_yn = 'N' we do not perform the QA check
    --otherwise (including when enable_qa_yn='Y' and when there is no row returned) we perform QA check
    OPEN check_lookup_code_csr(l_check_amendments);
    FETCH check_lookup_code_csr into l_amendments_code_rec;
    IF(check_lookup_code_csr%NOTFOUND OR l_amendments_code_rec.enabled_flag = 'N') THEN
        l_check_amendments_yn := 'N';
    ELSE
        OPEN check_qa_csr(l_check_amendments);
        FETCH check_qa_csr into l_amendments_rec;
        IF(check_qa_csr%NOTFOUND) THEN
            l_check_amendments_yn := 'Y';
            --since there is no row, we cannot get the severity_flag
            --default it to warning
            l_amendments_severity := l_qa_severity_warning;
        ELSE
            IF(l_amendments_rec.enable_qa_yn = 'N') THEN
                l_check_amendments_yn := 'N';
            ELSE
                l_check_amendments_yn := 'Y';
                l_amendments_severity := l_amendments_rec.severity_flag;
            END IF;
        END IF;
        CLOSE check_qa_csr;
    END IF;
    CLOSE check_lookup_code_csr;

    OPEN check_lookup_code_csr(l_check_notifications);
    FETCH check_lookup_code_csr into l_notifications_code_rec;
    IF(check_lookup_code_csr%NOTFOUND OR l_notifications_code_rec.enabled_flag = 'N') THEN
        l_check_notifications_yn := 'N';
    ELSE
        OPEN check_qa_csr(l_check_notifications);
        FETCH check_qa_csr into l_notifications_rec;
        IF(check_qa_csr%NOTFOUND) THEN
            l_check_notifications_yn := 'Y';
            --since there is no row, we cannot get the severity_flag
            --default it to warning
            l_notifications_severity := l_qa_severity_warning;
        ELSE
            IF(l_notifications_rec.enable_qa_yn = 'N') THEN
                l_check_notifications_yn := 'N';
            ELSE
                l_check_notifications_yn := 'Y';
                l_notifications_severity := l_notifications_rec.severity_flag;
            END IF;
        END IF;
        CLOSE check_qa_csr;
    END IF;
    CLOSE check_lookup_code_csr;

    OPEN check_lookup_code_csr(l_check_int_contact);
    FETCH check_lookup_code_csr into l_int_contact_code_rec;
    IF(check_lookup_code_csr%NOTFOUND OR l_int_contact_code_rec.enabled_flag = 'N') THEN
        l_check_int_contact_yn := 'N';
    ELSE
        OPEN check_qa_csr(l_check_int_contact);
        FETCH check_qa_csr into l_int_contact_rec;
        IF(check_qa_csr%NOTFOUND) THEN
            l_check_int_contact_yn := 'Y';
            --since there is no row, we cannot get the severity_flag
            --default it to warning
            l_int_contact_severity := l_qa_severity_warning;
        ELSE
            IF(l_int_contact_rec.enable_qa_yn = 'N') THEN
                l_check_int_contact_yn := 'N';
            ELSE
                l_check_int_contact_yn := 'Y';
                l_int_contact_severity := l_int_contact_rec.severity_flag;
            END IF;
        END IF;
        CLOSE check_qa_csr;
    END IF;
    CLOSE check_lookup_code_csr;


    OPEN check_lookup_code_csr(l_check_int_contact_valid);
    FETCH check_lookup_code_csr into l_int_contact_valid_code_rec;
    IF(check_lookup_code_csr%NOTFOUND OR l_int_contact_valid_code_rec.enabled_flag = 'N') THEN
        l_check_int_contact_valid_yn := 'N';
    ELSE
        OPEN check_qa_csr(l_check_int_contact_valid);
        FETCH check_qa_csr into l_int_contact_valid_rec;
        IF(check_qa_csr%NOTFOUND) THEN
            l_check_int_contact_valid_yn := 'Y';
            --since there is no row, we cannot get the severity_flag
            --default it to warning
            l_int_contact_valid_severity := l_qa_severity_warning;
        ELSE
            IF(l_int_contact_valid_rec.enable_qa_yn = 'N') THEN
                l_check_int_contact_valid_yn := 'N';
            ELSE
                l_check_int_contact_valid_yn := 'Y';
                l_int_contact_valid_severity := l_int_contact_valid_rec.severity_flag;
            END IF;
        END IF;
        CLOSE check_qa_csr;
    END IF;
    CLOSE check_lookup_code_csr;


    OPEN check_lookup_code_csr(l_check_ext_contact);
    FETCH check_lookup_code_csr into l_ext_contact_code_rec;
    IF(check_lookup_code_csr%NOTFOUND OR l_ext_contact_code_rec.enabled_flag = 'N') THEN
        l_check_ext_contact_yn := 'N';
    ELSE
        OPEN check_qa_csr(l_check_ext_contact);
        FETCH check_qa_csr into l_ext_contact_rec;
        IF(check_qa_csr%NOTFOUND) THEN
            l_check_ext_contact_yn := 'Y';
            --since there is no row, we cannot get the severity_flag
            --default it to warning
            l_ext_contact_severity := l_qa_severity_warning;
        ELSE
            IF(l_ext_contact_rec.enable_qa_yn = 'N') THEN
                l_check_ext_contact_yn := 'N';
            ELSE
                l_check_ext_contact_yn := 'Y';
                l_ext_contact_severity := l_ext_contact_rec.severity_flag;
            END IF;
        END IF;
        CLOSE check_qa_csr;
    END IF;
    CLOSE check_lookup_code_csr;

    OPEN check_lookup_code_csr(l_check_due_dates);
    FETCH check_lookup_code_csr into l_due_dates_code_rec;
    IF(check_lookup_code_csr%NOTFOUND OR l_due_dates_code_rec.enabled_flag = 'N') THEN
        l_check_due_dates_yn := 'N';
    ELSE
        OPEN check_qa_csr(l_check_due_dates);
        FETCH check_qa_csr into l_due_dates_rec;
        IF(check_qa_csr%NOTFOUND) THEN
            l_check_due_dates_yn := 'Y';
            --since there is no row, we cannot get the severity_flag
            --default it to warning
            l_due_dates_severity := l_qa_severity_warning;
        ELSE
            IF(l_due_dates_rec.enable_qa_yn = 'N') THEN
                l_check_due_dates_yn := 'N';
            ELSE
                l_check_due_dates_yn := 'Y';
                l_due_dates_severity := l_due_dates_rec.severity_flag;
            END IF;
        END IF;
        CLOSE check_qa_csr;
    END IF;
    CLOSE check_lookup_code_csr;

--Begin ExternalPartyExists cursors---
    OPEN check_lookup_code_csr(l_check_external_party_exists);
    FETCH check_lookup_code_csr into l_chk_extparty_exists_code_rec;
    IF(check_lookup_code_csr%NOTFOUND
     OR l_chk_extparty_exists_code_rec.enabled_flag = 'N') THEN
        l_chk_extparty_exists_yn := 'N';
    ELSE
        OPEN check_qa_csr(l_check_external_party_exists);
        FETCH check_qa_csr into l_chk_extparty_exists_rec;
        IF(check_qa_csr%NOTFOUND) THEN
            l_chk_extparty_exists_yn := 'Y';
            --since there is no row, we cannot get the severity_flag
            --default it to warning
            l_chk_extparty_exists_severity := l_qa_severity_warning;
        ELSE
            IF(l_chk_extparty_exists_rec.enable_qa_yn = 'N') THEN
                l_chk_extparty_exists_yn  := 'N';
            ELSE
                l_chk_extparty_exists_yn := 'Y';
                l_chk_extparty_exists_severity := l_chk_extparty_exists_rec.severity_flag;
            END IF;
        END IF;
        CLOSE check_qa_csr;
    END IF;
    CLOSE check_lookup_code_csr;

--End ExternalPartyExists cursors--
     /*   IF(p_mode = G_AMEND_QA) THEN
        OPEN del_cur FOR
      select *
            from okc_deliverables
            where business_document_type = p_doc_type
            and business_document_id = p_doc_id
            and business_document_version = -99
            and deliverable_type in (select deltypes.deliverable_type_code from okc_bus_doc_types_b doctypes,
                                        --okc_del_bus_doc_combxns deltypes
                okc_deliverable_types_b deltypes
                                        where doctypes.document_type=p_doc_type
                                        and doctypes.document_type_class = deltypes.document_type_class)
            and amendment_operation is not null;



        ELSE
*/
        --to fix bug 3236092
        --I am commenting out the dynamic query
        --so even in Amend mode we check all the deliverables belong to that bus doc
        --this is because even if the deliverable is untouched the bus doc's data might be
        --changed so the deliverable could still fail the QA check

--Repository Change: changed cursor to look at okc_deliverable_types_b
    -- updated cursor for bug#4069955
            OPEN del_cur FOR
            select *
            from okc_deliverables
            where business_document_type = p_doc_type
            and business_document_id = p_doc_id
            and business_document_version = -99
            and (amendment_operation is NULL OR amendment_operation <> 'DELETED')
            and (summary_amend_operation_code is NULL OR summary_amend_operation_code <> 'DELETED')
            and deliverable_type in (select deltypes.deliverable_type_code
                                     from okc_bus_doc_types_b doctypes,
                                     okc_del_bus_doc_combxns deltypes
                                     where doctypes.document_type=p_doc_type
                                     and doctypes.document_type_class = deltypes.document_type_class);


   -- END IF;

    LOOP
        FETCH del_cur INTO del_rec;


        EXIT WHEN del_cur%NOTFOUND;

        IF(l_check_amendments_yn='Y' and p_mode = G_AMEND_QA) THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start checking amendments');
            END IF;
            check_amendments( del_rec  => del_rec,
                                    p_severity => l_amendments_severity,
                                    px_qa_result_tbl  => l_qa_result_tbl,
                                    x_return_status   => l_return_status);
            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished checking amendments');
            END IF;
        END IF;

        IF(l_check_notifications_yn='Y') THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start checking notifications');
            END IF;
            check_notifications( del_rec  => del_rec,
                                    p_severity => l_notifications_severity,
                                    px_qa_result_tbl  => l_qa_result_tbl,
                                    x_return_status   => l_return_status);
            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished checking notifications');
            END IF;
        END IF;

        IF(l_check_int_contact_yn='Y') THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start checking internal contacts');
            END IF;
            check_internal_contacts( del_rec  => del_rec,
                                    p_severity => l_int_contact_severity,
                                    px_qa_result_tbl  => l_qa_result_tbl,
                                    x_return_status   => l_return_status);
            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished checking internal contacts');
            END IF;
        END IF;

        --bug 3686334
        --added call to check_internal_contact_valid
        IF(l_check_int_contact_valid_yn='Y') THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start checking internal contacts valid');
            END IF;
            check_internal_contacts_valid( del_rec  => del_rec,
                                    p_severity => l_int_contact_valid_severity,
                                    px_qa_result_tbl  => l_qa_result_tbl,
                                    x_return_status   => l_return_status);
            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished checking internal contacts valid');
            END IF;
        END IF;


------------External Party Exists check---------------
        IF (l_chk_extparty_exists_yn = 'Y') THEN
      IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module
        ||l_api_name,'start checking external party exists');
      END IF;
      check_external_party_exists(del_rec => del_rec,
                                p_severity => l_chk_extparty_exists_severity,
              px_qa_result_tbl => l_qa_result_tbl,
              x_return_status => l_return_status);

         IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
         ELSIF (l_return_status = G_RET_STS_ERROR) THEN
             RAISE FND_API.G_EXC_ERROR ;
         END IF;

         IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module
       ||l_api_name,'finished checking external party exists');
         END IF;
        END IF;

------------End External Party Exists check------------

        IF(l_check_ext_contact_yn='Y') THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start checking external contacts');
            END IF;
            check_external_contacts( del_rec  => del_rec,
                                    p_severity =>l_ext_contact_severity,
                                    px_qa_result_tbl  => l_qa_result_tbl,
                                    x_return_status   => l_return_status);
            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished checking external contacts');
            END IF;
        END IF;

        IF(l_check_due_dates_yn='Y') THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start checking due dates');
            END IF;
            --Acq Plan Message Cleanup
            check_due_dates( del_rec  => del_rec,
                                    p_severity => l_due_dates_severity,
                                    p_bus_doc_date_events_tbl => p_bus_doc_date_events_tbl,
                                    p_doc_type => p_doc_type,
                                    px_qa_result_tbl  => l_qa_result_tbl,
                                    x_return_status   => l_return_status);
            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished checking due dates');
            END IF;
        END IF;

    END LOOP;

    -- bug# 4118095 check the doc source
    l_contract_source := OKC_TERMS_UTIL_GRP.Get_Contract_Source_Code
                                (p_document_type => p_doc_type,
                                 p_document_id => p_doc_id );

    IF l_contract_source = 'STRUCTURED' THEN

    --Bug Fix for 3249177
    --add an additional check to see if any article has variables defined for deliverables
    OPEN check_lookup_code_csr(l_check_var_usage);
    FETCH check_lookup_code_csr into l_var_usage_code_rec;
    IF(check_lookup_code_csr%NOTFOUND OR l_due_dates_code_rec.enabled_flag = 'N') THEN
        l_check_var_usage_yn := 'N';
    ELSE
        OPEN check_qa_csr(l_check_var_usage);
        FETCH check_qa_csr into l_var_usage_rec;
        IF(check_qa_csr%NOTFOUND) THEN
            l_check_var_usage_yn := 'Y';
            --since there is no row, we cannot get the severity_flag
            --default it to warning
            l_var_usage_severity := l_qa_severity_warning;
        ELSE
            IF(l_var_usage_rec.enable_qa_yn = 'N') THEN
                l_check_var_usage_yn := 'N';
            ELSE
                l_check_var_usage_yn := 'Y';
                l_var_usage_severity := l_var_usage_rec.severity_flag;
            END IF;
        END IF;
        CLOSE check_qa_csr;
    END IF;
    CLOSE check_lookup_code_csr;

    IF(l_check_var_usage_yn = 'Y') THEN

        IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start checking variable usage');
        END IF;

            check_deliverables_var_usage(p_severity => l_var_usage_severity,
                                    p_bus_doc_id => p_doc_id,
                                    p_bus_doc_type => p_doc_type,
                                    px_qa_result_tbl  => l_qa_result_tbl,
                                    x_return_status   => l_return_status);

            IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
            ELSIF (l_return_status = G_RET_STS_ERROR) THEN
                RAISE FND_API.G_EXC_ERROR ;
            END IF;
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'finished checking variable usage');
            END IF;

    END IF;
    END IF; -- l_contract_source = 'STRUCTURED' THEN

    --mass update common attributes
    l_end := l_qa_result_tbl.count;

    IF (l_end > l_start) THEN
        --We found some error or warning
        FOR i IN (l_start+1)..l_end
        LOOP
            l_qa_result_tbl(i).document_type := p_doc_type;
            l_qa_result_tbl(i).document_id := p_doc_id;
            l_qa_result_tbl(i).error_record_type := G_DLV_QA_TYPE;

            l_qa_result_tbl(i).creation_date := sysdate;

            --if the error is due to check_deliverable_var_usage
            --the section_name should be the article's section name
            --otherwise it should be 'DELIVERABLE'
            IF l_qa_result_tbl(i).article_id IS NULL THEN
                l_qa_result_tbl(i).section_name := G_DLV_QA_TYPE;
            END IF;
            --- check if any errors are there.
            IF l_qa_result_tbl(i).error_severity = G_QA_STS_ERROR THEN
                l_error_found := 'Y';
            END IF;
            --- check if any errors are there.
            IF l_qa_result_tbl(i).error_severity = G_QA_STS_WARNING THEN
                l_warning_found := 'Y';
            END IF;

        END LOOP;

        --now get the qa_return_status
        --if there is a record of type "error" found, return "E"
        --otherwise if there is a record of type "warning" found, return "W"
        --else return "S"
        l_qa_return_status := G_QA_STS_SUCCESS;
        IF l_error_found = 'Y' THEN
           l_qa_return_status := G_QA_STS_ERROR;
        ELSIF l_warning_found ='Y' THEN
           l_qa_return_status := G_QA_STS_WARNING;
        END IF;

    END IF;

     IF del_cur%ISOPEN THEN
       CLOSE del_cur;
     END IF;



    p_qa_result_tbl := l_qa_result_tbl;
    x_return_status := l_return_status;
    x_qa_return_status := l_qa_return_status;


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa');
    END IF;

     EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN

       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa with G_EXC_ERROR');
       END IF;
       --close cursors
       IF (del_cur%ISOPEN) THEN
          CLOSE del_cur ;
       END IF;

       IF (check_qa_csr%ISOPEN) THEN
        CLOSE check_qa_csr;
       END IF;

       IF (check_lookup_code_csr%ISOPEN) THEN
        CLOSE check_lookup_code_csr;
       END IF;

       x_return_status := G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa with G_EXC_UNEXPECTED_ERROR');
       END IF;
       --close cursors
       IF (del_cur%ISOPEN) THEN
          CLOSE del_cur ;
       END IF;

       IF (check_qa_csr%ISOPEN) THEN
        CLOSE check_qa_csr;
       END IF;

       IF (check_lookup_code_csr%ISOPEN) THEN
        CLOSE check_lookup_code_csr;
       END IF;


       x_return_status := G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.validate_deliverable_for_qa with OTHERS EXCEPTION');
       END IF;
       --close cursors
       IF (del_cur%ISOPEN) THEN
          CLOSE del_cur ;
       END IF;

       IF (check_qa_csr%ISOPEN) THEN
        CLOSE check_qa_csr;
       END IF;

       IF (check_lookup_code_csr%ISOPEN) THEN
        CLOSE check_lookup_code_csr;
       END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

  END validate_deliverable_for_qa;





  PROCEDURE delete_del_status_hist_attach(
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
    p_deliverable_id IN NUMBER,
    p_bus_doc_id IN NUMBER,
    p_bus_doc_version IN NUMBER,
    p_bus_doc_type IN VARCHAR2,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2)
  IS

  l_api_version                  CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'validate_deliverable';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;



  BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       okc_debug.Set_Indentation('OKC_DELIVERABLE_PROCESS_PVT');
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'21300: Entered validate_deliverable_for_qa');
    END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                             x_return_status);


    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;



    -- delete deliverables status history
    DELETE FROM okc_del_status_history
    WHERE deliverable_id = p_deliverable_id;
    -- delete attachments if any
    delete_attachments (
                    p_entity_name => G_ENTITY_NAME
                    ,p_pk1_value    =>  p_deliverable_id
                    ,x_result       =>  l_return_status);

    x_return_status := l_return_status;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_del_status_hist_attach');
    END IF;

  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_del_status_hist_attach with G_EXC_ERROR');
       END IF;

       x_return_status := G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_del_status_hist_attach with G_EXC_UNEXPECTED_ERROR');
       END IF;

       x_return_status := G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_del_status_hist_attach with OTHERS EXCEPTION');
       END IF;

      x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
  END delete_del_status_hist_attach;

FUNCTION get_ui_bus_doc_event_text(p_event_name IN VARCHAR2,
                                    p_before_after IN VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  fnd_message.clear;
  if p_before_after = 'B' then
    fnd_message.set_name(APPLICATION=>G_OKC,NAME=>'OKC_DEL_BEFORE_BUS_DOC_EVENT');
  else
    fnd_message.set_name(APPLICATION=>G_OKC,NAME=>'OKC_DEL_AFTER_BUS_DOC_EVENT');
  end if;
  fnd_message.set_token(TOKEN => 'EVENT',VALUE => p_event_name);
  return fnd_message.get;
END get_ui_bus_doc_event_text;

/*
Add as part of fix for bug#3458149
Checks Deliverable_Status_History table and returns 'Y' if the Status of a Deliverable was NOT changed by
user since the Deliverable was first resolved, else returns 'N'
*/
Function delStatusUnchanged(p_del_ID IN OKC_DELIVERABLES.deliverable_id%TYPE) RETURN VARCHAR2 IS
 l_open_count NUMBER ;
 l_inactive_count NUMBER ;
 l_others_count NUMBER ;

 CURSOR hist_cur (delid NUMBER) IS
 SELECT deliverable_status
 FROM okc_del_status_history
 where deliverable_id = delid;

 hist_rec   hist_cur%ROWTYPE;
 l_api_name      CONSTANT VARCHAR2(30) :='delStatusUnchanged';

Begin


    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: inside delStatusUnchanged.');
    END IF;

  -- bug#4137831 initialize variables outside the loop
   l_open_count := 0;
   l_inactive_count := 0;
   l_others_count :=0;
  FOR hist_rec IN hist_cur(p_del_id) LOOP

   IF hist_rec.deliverable_status = 'OPEN' THEN
    l_open_count := l_open_count+1;
   ELSIF hist_rec.deliverable_status = 'INACTIVE' THEN
    l_inactive_count := l_inactive_count+1;
   ELSIF (hist_rec.deliverable_status <> 'OPEN' OR
          hist_rec.deliverable_status <> 'INACTIVE') THEN
    l_others_count := l_others_count+1;
   END IF;
  END LOOP;

  If hist_cur%ISOPEN then
    CLOSE hist_cur;
  End If;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Open status count: '||to_char(l_open_count));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inactive status count: '||to_char(l_inactive_count));
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Others status count: '||to_char(l_others_count));
    END IF;

  IF (l_open_count < 1 OR l_open_count = 1   ) AND
     (l_inactive_count < 1 OR l_inactive_count = 1) AND
     (l_others_count = 0) THEN
    RETURN 'Y';
  Else
    RETURN 'N';
  End If;

  EXCEPTION
   WHEN OTHERS THEN
    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,'delStatusUnchanged','102:Leaving delStatusUnchanged with Exception');
    END IF;
    If hist_cur%ISOPEN then
     CLOSE hist_cur;
    End If;
RETURN 'N';

End delStatusUnchanged;



   /*** This API deletes a given set of deliverables, attachments
   and status change history for a busdoc. Used to delete only the instances
   leaving the definition as it is. Called from update_deliverables group API ***/
    PROCEDURE delete_del_instances(
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_doc_id    IN NUMBER,
    p_doc_type  IN  VARCHAR2,
    p_doc_version IN NUMBER DEFAULT NULL,
    p_Conditional_Delete_Flag IN VARCHAR2 DEFAULT 'N',
    p_delid_tab    IN OKC_DELIVERABLE_PROCESS_PVT.delIdTabType,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2)
    IS
    l_del_id   NUMBER;
    l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
    l_result VARCHAR2(1);
    l_api_name      CONSTANT VARCHAR2(30) :='delete_del_instances';

    l_deleteInstances VARCHAR2(1) := 'Y';

    BEGIN

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances');
       END IF;
        FOR i IN p_delid_tab.FIRST..p_delid_tab.LAST LOOP
            l_del_id := p_delid_tab(i);

            -- fix for bug#3458149 do not delete history if deliverables
            -- changed status from OPEN status
            IF (p_Conditional_Delete_Flag = 'Y') then
               If (delStatusUnchanged(p_Del_id => l_del_id) = 'Y') then
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: delStatusUnchanged is Y');
                    END IF;
           l_deleteInstances := 'Y';
         Else
           l_deleteInstances := 'N';
         End If;
      Else
           l_deleteInstances := 'Y';
      End If;


       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: l_deleteInstances:'||l_deleteInstances);
       END IF;
            IF (l_deleteInstances = 'Y') then
                -- delete deliverables status history
                DELETE FROM okc_del_status_history
                WHERE deliverable_id = l_del_id;
                -- delete attachments if any
                delete_attachments (
                    p_entity_name => G_ENTITY_NAME
                    ,p_pk1_value    =>  l_del_id
                    ,x_result       =>  l_result);
                    IF l_result = 'S' THEN
                        -- delete deliverables
                        DELETE FROM okc_deliverables
                        WHERE deliverable_id = l_del_id;
                    END IF;
                x_return_status := l_return_status;
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: deleting status history for deliverable id:'||to_char(l_del_id));
       END IF;
            END IF;


        END LOOP;

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Leaving OKC_DELIVERABLE_PROCESS_PVT.delete_del_instances');
       END IF;

    EXCEPTION
    WHEN OTHERS THEN
        IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'102:Leaving delete_del_instances with Exception');
        END IF;
        x_return_status := G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                                  p_data  =>  x_msg_data);
    END delete_del_instances;


    /**Invoked From: OKC_TERMS_UTIL_GRP.get_document_deviations
    1.  This function returns type of deliverables existing on a Business Document
        for a given version. Invoked by OKC_TERMS_UTIL_GRP.get_document_deviations.
    2.  Select all deliverables for the Business Document. If deliverables exist then
    a.  Check each deliverable type
        i.  If only contractual deliverables exist then return CONTRACTUAL
        ii. If only internal deliverables exist then return INTERNAL
        iii.If both contractual and internal deliverables exist then return
            CONTRACTUAL_AND_INTERNAL
    3.  If no deliverables exist then return NONE**/

/*** added new signature bug#3192512**/

    FUNCTION deliverables_exist(
        p_api_version      IN  NUMBER,
        p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_data         OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,
        p_doctype         IN  VARCHAR2,
        p_docid           IN  NUMBER
        ) RETURN VARCHAR2
    IS
    -- updated cursor for bug#4069955
    CURSOR del_cur IS
    SELECT
     del.deliverable_type
    ,delType.internal_flag
    FROM
     okc_deliverables del
    ,okc_deliverable_types_b delType
    WHERE del.business_document_id = p_docid
    AND   del.business_document_type = p_doctype
    AND   del.business_document_version = -99
    AND   NVL(del.amendment_operation,'NONE') <> 'DELETED'
    AND   NVL(del.summary_amend_operation_code,'NONE') <> 'DELETED'
    AND   delType.deliverable_type_code = del.deliverable_type;

    l_del_rec  del_cur%ROWTYPE;
    l_api_name         CONSTANT VARCHAR2(30) := 'deliverables_exist';
    l_exists    VARCHAR2(60):= 'NONE';
    l_contractual   okc_deliverables.deliverable_type%TYPE;
    l_internal      okc_deliverables.deliverable_type%TYPE;
    l_sourcing      okc_deliverables.deliverable_type%TYPE;

    BEGIN

    --  Initialize API return status to success
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    FOR del_rec IN del_cur LOOP
       If del_rec.internal_flag = 'Y' then
      l_internal := del_rec.deliverable_type;
    Else
         IF UPPER(del_rec.deliverable_type) = 'CONTRACTUAL' THEN
           l_contractual := del_rec.deliverable_type;
         ELSIF UPPER(del_rec.deliverable_type) = 'SOURCING' THEN
           l_sourcing := del_rec.deliverable_type;
         END IF;
    End If;
    END LOOP;

        IF l_contractual is not null THEN
           l_exists := 'CONTRACTUAL';
           IF l_internal is not null THEN
             l_exists := 'CONTRACTUAL_AND_INTERNAL';
               IF l_sourcing is not null THEN
                 l_exists:= 'ALL';
               END IF;
           ELSE
               IF l_sourcing is not null THEN
                 l_exists:= 'CONTRACTUAL_AND_SOURCING';
               END IF;

           END IF;
        ELSE
           IF l_internal is not null THEN
             l_exists := 'INTERNAL';
               IF l_sourcing is not null THEN
                 l_exists:= 'SOURCING_AND_INTERNAL';
               END IF;
           ELSE
               IF l_sourcing is not null THEN
                 l_exists:= 'SOURCING';
               ELSE
                 l_exists := 'NONE';
               END IF;
           END IF;
        END IF;

        RETURN(l_exists);
   EXCEPTION
      WHEN OTHERS THEN
         IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'4300: Leaving deliverables_exist because of EXCEPTION: '||sqlerrm);
         END IF;

         IF del_cur%ISOPEN THEN
           CLOSE del_cur;
         END IF;
         x_return_status := G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
           FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
         END IF;
         FND_MSG_PUB.Count_And_Get(p_encoded=>'F'
         , p_count => x_msg_count
         , p_data => x_msg_data );

         RETURN null;
   END; -- deliverables_exist




    PROCEDURE delete_deliverable (
    p_api_version  IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    p_del_id    IN NUMBER,
    x_msg_data   OUT NOCOPY  VARCHAR2,
    x_msg_count  OUT NOCOPY  NUMBER,
    x_return_status  OUT NOCOPY  VARCHAR2)
    IS

    l_result   VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_api_name VARCHAR2(30) :='delete_deliverable';

    BEGIN

       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.delete_deliverable'||to_char(p_del_id));
       END IF;
                -- delete deliverables status history
                DELETE FROM okc_del_status_history
                WHERE deliverable_id = p_del_id;
                -- delete attachments if any
                delete_attachments (
                    p_entity_name => G_ENTITY_NAME
                    ,p_pk1_value    =>  p_del_id
                    ,x_result       =>  l_result);
                    IF l_result = 'S' THEN
                        -- delete deliverables
                        DELETE FROM okc_deliverables
                        WHERE deliverable_id = p_del_id;
                    END IF;
            x_return_status := l_result;
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_deliverable');
       END IF;

    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_deliverable with G_EXC_ERROR');
       END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_deliverable with G_EXC_UNEXPECTED_ERROR');
       END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_deliverable with G_EXC_UNEXPECTED_ERROR');
       END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END delete_deliverable;

    /*** This procedure will delete all deliverables that have been
    created by applying a particular template on a busdoc.
    It selects all deliverables which have original_deliverable_id
    belonging to the p_template_id and deletes them from the busdoc.
    Parameter Details:
    p_doc_id :       Business document Id
    p_doc_type :     Business document type
    ***/
    PROCEDURE delete_template_deliverables (
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN VARCHAR2,
    p_doc_id            IN  NUMBER,
    p_doc_type          IN VARCHAR2,
    x_msg_data      OUT NOCOPY  VARCHAR2,
    x_msg_count     OUT NOCOPY  NUMBER,
    x_return_status OUT NOCOPY  VARCHAR2)
    IS
-- bug#4075168 changed the select "and original_deliverable_id IN ( select original_deliverable_id"
    CURSOR del_cur IS
    select deliverable_id
    from okc_deliverables
    where business_document_id = p_doc_id
    and business_document_type = p_doc_type
    and business_document_version = -99
    and original_deliverable_id IN (
    select original_deliverable_id
    from okc_deliverables
    where business_document_type = 'TEMPLATE');

    TYPE delIdTabType IS TABLE OF NUMBER;
    delIdTab    delIdTabType;
    l_result  VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
    l_api_name      CONSTANT VARCHAR2(30) :='delete_template_deliverables';
    BEGIN
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: inside OKC_DELIVERABLE_PROCESS_PVT.delete_template_deliverables');
       END IF;
        OPEN del_cur;
        FETCH del_cur BULK COLLECT INTO delIdTab;
        -- bug#3188413 check count before loop
        IF delIdTab.COUNT > 0 THEN
        FOR i IN delIdTab.FIRST..delIdTab.LAST LOOP
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: delId is:'||to_char(delIdTab(i)));
            END IF;
                -- delete attachments if any
                delete_attachments (
                    p_entity_name => G_ENTITY_NAME
                    ,p_pk1_value    =>  delIdTab(i)
                    ,x_result       =>  l_result);
                    IF l_result <> 'S' THEN
                        EXIT;
                    END IF;
        END LOOP;
        IF l_result = 'S' THEN
                FORALL i IN delIdTab.FIRST..delIdTab.LAST
                DELETE FROM okc_deliverables
                WHERE deliverable_id = delIdTab(i);
        END IF;
        END IF;-- delIdTab.COUNT
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        x_return_status := l_result;
       IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_template_deliverables');
       END IF;

    EXCEPTION
    WHEN OTHERS THEN
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.delete_template_deliverables with G_EXC_UNEXPECTED_ERROR');
       END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END delete_template_deliverables;



    /**Invoked From: OKC_TERMS_UTIL_GRP.is_deliverable_amended
    1.  This function returns type of deliverables amended on a Business Document
    2.  Select all deliverables definitions (-99 version) for the Business Document.
    If deliverables exist then
    a.  Check each deliverable type
        i.  If only contractual deliverables amended then return CONTRACTUAL
        ii. If only internal deliverables amended then return INTERNAL
        iii.If both contractual and internal deliverables amended then return
            CONTRACTUAL_AND_INTERNAL
        iv.If both contractual and sourcing deliverables amended then return
            CONTRACTUAL_AND_SOURCING
        v.If both sourcing and internal deliverables amended then return
            SOURCING_AND_INTERNAL
        vi.  If sourcing deliverables are amended then return SOURCING
        vii.  If all deliverables are amended then return ALL
    3.  If no deliverables amended then return NONE
    4.  If error return null**/

/*** added new signature bug#3192512**/

    FUNCTION deliverables_amended(
        p_api_version      IN  NUMBER,
        p_init_msg_list    IN  VARCHAR2 :=  FND_API.G_FALSE,

        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_data         OUT NOCOPY VARCHAR2,
        x_msg_count        OUT NOCOPY NUMBER,

        p_doctype  IN  VARCHAR2,
        p_docid IN NUMBER
        )
    RETURN VARCHAR2 IS
    --do not consider internal deliverables inamendments.
    -- updated the cursor to filter internal deliverables
    -- updated cursor for bug#4069955
    CURSOR del_cur IS
    SELECT
     del.amendment_operation
    ,del.deliverable_type
    ,delType.internal_flag
    FROM
     okc_deliverables del
    ,okc_deliverable_types_b delType
    WHERE del.business_document_id = p_docid
    AND   del.business_document_type = p_doctype
    AND   del.business_document_version = -99
    AND   del.summary_amend_operation_code is not null
    --AND   deliverable_type not like '%INTERNAL%'; --Commented as part of changes for new table okc_deliverable_types_b
    AND   del.deliverable_type       = delType.deliverable_type_code
    AND   delType.internal_flag = 'N';

    l_del_rec  del_cur%ROWTYPE;
    l_amended    VARCHAR2(30):= 'NONE';
    l_contractual   okc_deliverables.deliverable_type%TYPE;
    l_internal      okc_deliverables.deliverable_type%TYPE;
    l_sourcing      okc_deliverables.deliverable_type%TYPE;
    l_api_name         CONSTANT VARCHAR2(30) := 'deliverables_amended';

    BEGIN

     --  Initialize API return status to success
     x_return_status := OKC_API.G_RET_STS_SUCCESS;


           FOR del_rec IN del_cur LOOP
              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: inside OKC_DELIVERABLE_PROCESS_PVT.deliverables_amended :'||del_rec.deliverable_type);
              END IF;

         --Repository change to look at internal_flag in okc_deliverable_types_b
        If (del_rec.internal_flag = 'Y') then
          l_internal := del_rec.deliverable_type;
        Else
               IF UPPER(del_rec.deliverable_type) = 'CONTRACTUAL' THEN
                 l_contractual := del_rec.deliverable_type;
               ELSIF UPPER(del_rec.deliverable_type) = 'SOURCING' THEN
                 l_sourcing := del_rec.deliverable_type;
      END IF;
              END IF;

           END LOOP;

           IF l_contractual is not null THEN
              l_amended := 'CONTRACTUAL';
                IF l_internal is not null THEN
                    l_amended:= 'CONTRACTUAL_AND_INTERNAL';
                        IF l_sourcing is not null THEN
                           l_amended:= 'ALL';
                        END IF;
                ELSIF l_internal is null THEN
                    IF l_sourcing is not null THEN
                       l_amended:= 'SOURCING_AND_CONTRACTUAL';
                    END IF;
                END IF;
            ELSE
                IF l_internal is not null THEN
                   l_amended:= 'INTERNAL';
                       IF l_sourcing is not null THEN
                          l_amended:= 'SOURCING_AND_INTERNAL';
                       END IF;
                ELSE
                   IF l_sourcing is not null THEN
                      l_amended:= 'SOURCING';
                   ELSE
                      l_amended:= 'NONE';
                   END IF;
                END IF;
            END IF;


            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: l_amended is :'||l_amended);
            END IF;
            RETURN(l_amended);

   EXCEPTION
    WHEN OTHERS THEN
           IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'4300: Leaving deliverables_amended because of EXCEPTION: '||sqlerrm);
           END IF;

              IF del_cur%ISOPEN THEN
                 CLOSE del_cur;
              END IF;

              x_return_status := G_RET_STS_UNEXP_ERROR ;

              IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
                   FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
              END IF;
              FND_MSG_PUB.Count_And_Get(p_encoded=>'F'
                 , p_count => x_msg_count
                 , p_data => x_msg_data );

              RETURN null;

    END; -- deliverables_amended

-- This function returns the message text for the print due date message name
-- bug#3272824 resolves tranlation issues with due date messages.
FUNCTION getDueDateMsgText(
p_relative_st_date_event_id    NUMBER
,p_relative_end_date_event_id   NUMBER
,p_relative_st_date_duration    NUMBER
,p_relative_end_date_duration    NUMBER
,p_repeating_day_of_week        VARCHAR2
,p_repeating_day_of_month       VARCHAR2
,p_repeating_duration           NUMBER
,p_print_due_date_msg_name      VARCHAR2
,p_fixed_start_date             DATE
,p_fixed_end_date                DATE
)
RETURN VARCHAR2 IS

l_msg  varchar2(250);
l_st_event                        VARCHAR2(80);
l_end_event                       VARCHAR2(80);
l_day_of_week                       VARCHAR2(80);
l_day_of_month                       VARCHAR2(80);
l_repeating_duration   number;
l_api_name CONSTANT VARCHAR2(30) := 'getDueDateMsgText';



cursor event_cur(x number) is
select TL.meaning
from okc_bus_doc_events_tl TL
where TL.bus_doc_event_id = X
and TL.LANGUAGE = userenv('LANG');
event_rec event_cur%ROWTYPE;



begin

-- get event name
IF p_relative_st_date_event_id is not null THEN
    OPEN event_cur(p_relative_st_date_event_id);
    FETCH event_cur INTO l_st_event;
    CLOSE event_cur;
END IF;
IF p_relative_end_date_event_id is not null THEN
    OPEN event_cur(p_relative_end_date_event_id);
    FETCH event_cur INTO l_end_event;
    CLOSE event_cur;
END IF;

-- get lookup meanings
IF p_repeating_day_of_week is not null THEN
select meaning into l_day_of_week
from fnd_lookups
where lookup_type = 'DAY_OF_WEEK'
and lookup_code = p_repeating_day_of_week;
END IF;

IF p_repeating_day_of_month is not null THEN
select meaning into l_day_of_month
from fnd_lookups
where lookup_type = 'OKC_DAY_OF_MONTH'
and lookup_code = p_repeating_day_of_month;
END IF;

-- If duration is less than or equal to 1 then don't pass the token value
if p_repeating_duration = 1  THEN
    l_repeating_duration := null;
elsif p_repeating_duration = 0  THEN
    l_repeating_duration := null;
else
    l_repeating_duration := p_repeating_duration;
end if;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'message name is : '||p_print_due_date_msg_name);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'DAY_OF_WEEK is : '||p_repeating_day_of_week);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'DAY_OF_MONTH is : '||p_repeating_day_of_month);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'START_NUM is : '||p_relative_st_date_duration);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'END_NUM is : '||p_relative_end_date_duration);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'START_EVENT is : '||l_st_event);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'END_EVENT is : '||l_end_event);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'FREQ_NUM is : '|| l_repeating_duration);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'START_DATE_FIXED is : '|| p_fixed_start_date);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'FIXED_END_DATE is : '|| p_fixed_end_date);
 END IF;
-- bug#3465662 call this API if print due date msg name is not null
IF p_print_due_date_msg_name IS NOT NULL THEN
    l_msg := OKC_TERMS_UTIL_PVT.Get_Message(
                    p_app_name      =>  'OKC'
                    ,p_msg_name     =>  p_print_due_date_msg_name
                    ,p_token1       =>  'DAY_OF_WEEK'
                    ,p_token1_value =>  l_day_of_week
                    ,p_token2       =>  'DAY_OF_MONTH'
                    ,p_token2_value =>  l_day_of_month
                    ,p_token3       =>   'START_NUM'
                    ,p_token3_value =>  p_relative_st_date_duration
                    ,p_token4       =>  'END_NUM'
                    ,p_token4_value =>  p_relative_end_date_duration
                    ,p_token5       =>  'START_EVENT'
                    ,p_token5_value =>  l_st_event
                    ,p_token6       =>  'END_EVENT'
                    ,p_token6_value =>  l_end_event
                    ,p_token7       =>  'FREQ_NUM'
                    ,p_token7_value =>  l_repeating_duration
                    ,p_token8       =>  'START_DATE_FIXED'
                    ,p_token8_value =>  p_fixed_start_date
                    ,p_token9       =>  'FIXED_END_DATE'
                    ,p_token9_value =>  p_fixed_end_date);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'message is : '|| l_msg);
  END IF;

END IF;
        return(l_msg);

EXCEPTION

WHEN OTHERS THEN

  IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'4300: Leaving getDueDateMsgText with EXCEPTION: '||sqlerrm);
  END IF;

  IF event_cur%ISOPEN THEN
   CLOSE event_cur;
  END IF;

              RETURN ' ';
end getDueDateMsgText;

/***
07-APR-2004 pnayani -- bug#3524864 added copy_response_deliverables API
This API is invoked from OKC_TERMS_COPY_GRP.COPY_RESPONSE_DOC.
Initially coded to support proxy bidding functionality in Sourcing.
Copies deliverables from source response doc to target response documents (bid to bid)
The procedure will query deliverables from source response
document.Copies all deliverables and attachments as is on to a new response document.
Parameter Details:
p_source_doc_id :       Source document Id
p_source_doc_type :     Source document type
p_target_doc_id   :     Target document Id
p_target_doc_type :     Target document Type
p_target_doc_number :   Target document Number
***/

    PROCEDURE copy_response_deliverables (
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
        p_source_doc_id             IN NUMBER,
        p_source_doc_type           IN VARCHAR2,
        p_target_doc_id             IN NUMBER,
        p_target_doc_type           IN VARCHAR2,
        p_target_doc_number         IN VARCHAR2,
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count                 OUT NOCOPY NUMBER,
        x_return_status             OUT NOCOPY VARCHAR2)
    IS
    CURSOR del_cur IS
    SELECT *
    FROM OKC_DELIVERABLES
    WHERE business_document_id = p_source_doc_id
    AND   business_document_type = p_source_doc_type
    AND   recurring_del_parent_id is null;
    del_rec  del_cur%ROWTYPE;

    CURSOR del_ins_cur (X number) IS
    SELECT *
    FROM okc_deliverables
    WHERE business_document_id = p_source_doc_id
    AND   business_document_type = p_source_doc_type
    AND   recurring_del_parent_id = X;
    del_ins_rec  del_ins_cur%ROWTYPE;

    delRecTab           delRecTabType;
    delNewTab           delRecTabType;
    delInsTab           delRecTabType;
    TYPE delIdRecType IS RECORD (del_id NUMBER,orig_del_id NUMBER);
    TYPE delIdTabType IS TABLE OF delIdRecType;

    CURSOR delStsHist(Y NUMBER) IS
    SELECT *
    FROM okc_del_status_history
    WHERE deliverable_id = Y;
    delStsHist_rec delStsHist%ROWTYPE;
    delHistTab    delHistTabType;

    delIdTab    delIdTabType;
    j PLS_INTEGER := 0;
    k PLS_INTEGER := 0;
    m PLS_INTEGER := 0;
    l_api_name      CONSTANT VARCHAR2(30) :='copy_response_deliverables';
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_recur_del_parent_id  NUMBER;

    BEGIN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                ,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.copy_response_deliverables');
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                ,'100: target budoc id is:'||to_char(p_target_doc_id));
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name
                ,'100: target budoc id type:'||p_target_doc_type);
            END IF;
                -- initialize the table type variable to strore source and target deliverble
                -- ids to copy attachments.
                delIdTab := delIdTabType();
            -- Build the deliverable definition records
        FOR del_rec IN del_cur LOOP

      k := k+1;
      delRecTab(k).deliverable_id := del_rec.deliverable_id;
      delRecTab(k).BUSINESS_DOCUMENT_TYPE:= del_rec.BUSINESS_DOCUMENT_TYPE;
      delRecTab(k).BUSINESS_DOCUMENT_ID:= del_rec.BUSINESS_DOCUMENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_NUMBER:= del_rec.BUSINESS_DOCUMENT_NUMBER;
      delRecTab(k).DELIVERABLE_TYPE:= del_rec.DELIVERABLE_TYPE;
      delRecTab(k).RESPONSIBLE_PARTY:= del_rec.RESPONSIBLE_PARTY;
      delRecTab(k).INTERNAL_PARTY_CONTACT_ID:= del_rec.INTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).EXTERNAL_PARTY_CONTACT_ID:= del_rec.EXTERNAL_PARTY_CONTACT_ID;
      delRecTab(k).DELIVERABLE_NAME:= del_rec.DELIVERABLE_NAME;
      delRecTab(k).DESCRIPTION:= del_rec.DESCRIPTION;
      delRecTab(k).COMMENTS:= del_rec.COMMENTS;
      delRecTab(k).DISPLAY_SEQUENCE:= del_rec.DISPLAY_SEQUENCE;
      delRecTab(k).FIXED_DUE_DATE_YN:= del_rec.FIXED_DUE_DATE_YN;
      delRecTab(k).ACTUAL_DUE_DATE:= del_rec.ACTUAL_DUE_DATE;
      delRecTab(k).PRINT_DUE_DATE_MSG_NAME:= del_rec.PRINT_DUE_DATE_MSG_NAME;
      delRecTab(k).RECURRING_YN:= del_rec.RECURRING_YN;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_UOM:= del_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
      delRecTab(k).NOTIFY_PRIOR_DUE_DATE_YN:= del_rec.NOTIFY_PRIOR_DUE_DATE_YN;
      delRecTab(k).NOTIFY_COMPLETED_YN:= del_rec.NOTIFY_COMPLETED_YN;
      delRecTab(k).NOTIFY_OVERDUE_YN:= del_rec.NOTIFY_OVERDUE_YN;
      delRecTab(k).NOTIFY_ESCALATION_YN:= del_rec.NOTIFY_ESCALATION_YN;
      delRecTab(k).NOTIFY_ESCALATION_VALUE:= del_rec.NOTIFY_ESCALATION_VALUE;
      delRecTab(k).NOTIFY_ESCALATION_UOM:= del_rec.NOTIFY_ESCALATION_UOM;
      delRecTab(k).ESCALATION_ASSIGNEE:= del_rec.ESCALATION_ASSIGNEE;
      delRecTab(k).AMENDMENT_OPERATION:= del_rec.AMENDMENT_OPERATION;
      delRecTab(k).PRIOR_NOTIFICATION_ID:= del_rec.PRIOR_NOTIFICATION_ID;
      delRecTab(k).AMENDMENT_NOTES:= del_rec.AMENDMENT_NOTES;
      delRecTab(k).COMPLETED_NOTIFICATION_ID:= del_rec.COMPLETED_NOTIFICATION_ID;
      delRecTab(k).OVERDUE_NOTIFICATION_ID:= del_rec.OVERDUE_NOTIFICATION_ID;
      delRecTab(k).ESCALATION_NOTIFICATION_ID:= del_rec.ESCALATION_NOTIFICATION_ID;
      delRecTab(k).LANGUAGE:= del_rec.LANGUAGE;
      delRecTab(k).ORIGINAL_DELIVERABLE_ID:= del_rec.ORIGINAL_DELIVERABLE_ID;
      delRecTab(k).REQUESTER_ID:= del_rec.REQUESTER_ID;
      delRecTab(k).EXTERNAL_PARTY_ID:= del_rec.EXTERNAL_PARTY_ID;
      delRecTab(k).EXTERNAL_PARTY_ROLE:= del_rec.EXTERNAL_PARTY_ROLE;
      delRecTab(k).RECURRING_DEL_PARENT_ID:= del_rec.RECURRING_DEL_PARENT_ID;
      delRecTab(k).BUSINESS_DOCUMENT_VERSION:= del_rec.BUSINESS_DOCUMENT_VERSION;
      delRecTab(k).RELATIVE_ST_DATE_DURATION:= del_rec.RELATIVE_ST_DATE_DURATION;
      delRecTab(k).RELATIVE_ST_DATE_UOM:= del_rec.RELATIVE_ST_DATE_UOM;
      delRecTab(k).RELATIVE_ST_DATE_EVENT_ID:= del_rec.RELATIVE_ST_DATE_EVENT_ID;
      delRecTab(k).RELATIVE_END_DATE_DURATION:= del_rec.RELATIVE_END_DATE_DURATION;
      delRecTab(k).RELATIVE_END_DATE_UOM:= del_rec.RELATIVE_END_DATE_UOM;
      delRecTab(k).RELATIVE_END_DATE_EVENT_ID:= del_rec.RELATIVE_END_DATE_EVENT_ID;
      delRecTab(k).REPEATING_DAY_OF_MONTH:= del_rec.REPEATING_DAY_OF_MONTH;
      delRecTab(k).REPEATING_DAY_OF_WEEK:= del_rec.REPEATING_DAY_OF_WEEK;
      delRecTab(k).REPEATING_FREQUENCY_UOM:= del_rec.REPEATING_FREQUENCY_UOM;
      delRecTab(k).REPEATING_DURATION:= del_rec.REPEATING_DURATION;
      delRecTab(k).FIXED_START_DATE:= del_rec.FIXED_START_DATE;
      delRecTab(k).FIXED_END_DATE:= del_rec.FIXED_END_DATE;
      delRecTab(k).MANAGE_YN:= del_rec.MANAGE_YN;
      delRecTab(k).INTERNAL_PARTY_ID:= del_rec.INTERNAL_PARTY_ID;
      delRecTab(k).DELIVERABLE_STATUS:= del_rec.DELIVERABLE_STATUS;
      delRecTab(k).STATUS_CHANGE_NOTES:= del_rec.STATUS_CHANGE_NOTES;
      delRecTab(k).CREATED_BY:= del_rec.CREATED_BY;
      delRecTab(k).CREATION_DATE:= del_rec.CREATION_DATE;
      delRecTab(k).LAST_UPDATED_BY:= del_rec.LAST_UPDATED_BY;
      delRecTab(k).LAST_UPDATE_DATE:= del_rec.LAST_UPDATE_DATE;
      delRecTab(k).LAST_UPDATE_LOGIN:= del_rec.LAST_UPDATE_LOGIN;
      delRecTab(k).OBJECT_VERSION_NUMBER:= del_rec.OBJECT_VERSION_NUMBER;
      delRecTab(k).ATTRIBUTE_CATEGORY:= del_rec.ATTRIBUTE_CATEGORY;
      delRecTab(k).ATTRIBUTE1:= del_rec.ATTRIBUTE1;
      delRecTab(k).ATTRIBUTE2:= del_rec.ATTRIBUTE2;
      delRecTab(k).ATTRIBUTE3:= del_rec.ATTRIBUTE3;
      delRecTab(k).ATTRIBUTE4:= del_rec.ATTRIBUTE4;
      delRecTab(k).ATTRIBUTE5:= del_rec.ATTRIBUTE5;
      delRecTab(k).ATTRIBUTE6:= del_rec.ATTRIBUTE6;
      delRecTab(k).ATTRIBUTE7:= del_rec.ATTRIBUTE7;
      delRecTab(k).ATTRIBUTE8:= del_rec.ATTRIBUTE8;
      delRecTab(k).ATTRIBUTE9:= del_rec.ATTRIBUTE9;
      delRecTab(k).ATTRIBUTE10:= del_rec.ATTRIBUTE10;
      delRecTab(k).ATTRIBUTE11:= del_rec.ATTRIBUTE11;
      delRecTab(k).ATTRIBUTE12:= del_rec.ATTRIBUTE12;
      delRecTab(k).ATTRIBUTE13:= del_rec.ATTRIBUTE13;
      delRecTab(k).ATTRIBUTE14:= del_rec.ATTRIBUTE14;
      delRecTab(k).ATTRIBUTE15:= del_rec.ATTRIBUTE15;
      delRecTab(k).DISABLE_NOTIFICATIONS_YN:= del_rec.DISABLE_NOTIFICATIONS_YN;
      delRecTab(k).LAST_AMENDMENT_DATE:= del_rec.LAST_AMENDMENT_DATE;
      delRecTab(k).BUSINESS_DOCUMENT_LINE_ID:= del_rec.BUSINESS_DOCUMENT_LINE_ID;
      delRecTab(k).EXTERNAL_PARTY_SITE_ID:= del_rec.EXTERNAL_PARTY_SITE_ID;
      delRecTab(k).START_EVENT_DATE:= del_rec.START_EVENT_DATE;
      delRecTab(k).END_EVENT_DATE:= del_rec.END_EVENT_DATE;
      delRecTab(k).SUMMARY_AMEND_OPERATION_CODE:= del_rec.SUMMARY_AMEND_OPERATION_CODE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
      delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
      delRecTab(k).PAY_HOLD_OVERDUE_YN:=del_rec.PAY_HOLD_OVERDUE_YN;

            END LOOP;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
                IF delRecTab.COUNT <> 0 THEN
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Number of records in delRecTab :'||to_char(delRecTab.COUNT));
                    END IF;
                    -- Build the new deliverable definition table
                FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
                  j := j+1;
                  -- extend table type
                  delIdTab.extend;
                  delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                  delNewTab(j) := delRecTab(i);
                  select okc_deliverable_id_s.nextval
                  INTO delNewTab(j).deliverable_id from dual;
                  delIdTab(j).del_id := delNewTab(j).deliverable_id;
                  -- store current_del_parent_id in local variable
                  --to assign it to the instances
                  l_recur_del_parent_id := delNewTab(j).deliverable_id;
                  -- assign common attributes
                  delNewTab(j).business_document_id := p_target_doc_id;
                  delNewTab(j).business_document_type := p_target_doc_type;
                  delNewTab(j).business_document_number := p_target_doc_number;
                  delNewTab(j).created_by:= Fnd_Global.User_Id;
                  delNewTab(j).creation_date := sysdate;
                  delNewTab(j).last_updated_by:= Fnd_Global.User_Id;
                  delNewTab(j).last_update_date := sysdate;
                  delNewTab(j).last_update_login:=Fnd_Global.Login_Id;
                  -- Check for instances on deliverable definition
                  IF delRecTab(i).recurring_yn = 'Y' THEN

                   --Initialize the table with 0 rows
                   delInsTab.DELETE;
             m := 0;
                   -- Build instances table
               FOR del_ins_rec IN del_ins_cur(delRecTab(i).deliverable_id) LOOP
               m := m+1;
               delInsTab(m).deliverable_id := del_ins_rec.deliverable_id;
               delInsTab(m).BUSINESS_DOCUMENT_TYPE:= del_ins_rec.BUSINESS_DOCUMENT_TYPE;
               delInsTab(m).BUSINESS_DOCUMENT_ID:= del_ins_rec.BUSINESS_DOCUMENT_ID;
               delInsTab(m).BUSINESS_DOCUMENT_NUMBER:= del_ins_rec.BUSINESS_DOCUMENT_NUMBER;
               delInsTab(m).DELIVERABLE_TYPE:= del_ins_rec.DELIVERABLE_TYPE;
               delInsTab(m).RESPONSIBLE_PARTY:= del_ins_rec.RESPONSIBLE_PARTY;
               delInsTab(m).INTERNAL_PARTY_CONTACT_ID:= del_ins_rec.INTERNAL_PARTY_CONTACT_ID;
               delInsTab(m).EXTERNAL_PARTY_CONTACT_ID:= del_ins_rec.EXTERNAL_PARTY_CONTACT_ID;
               delInsTab(m).DELIVERABLE_NAME:= del_ins_rec.DELIVERABLE_NAME;
               delInsTab(m).DESCRIPTION:= del_ins_rec.DESCRIPTION;
               delInsTab(m).COMMENTS:= del_ins_rec.COMMENTS;
               delInsTab(m).DISPLAY_SEQUENCE:= del_ins_rec.DISPLAY_SEQUENCE;
               delInsTab(m).FIXED_DUE_DATE_YN:= del_ins_rec.FIXED_DUE_DATE_YN;
               delInsTab(m).ACTUAL_DUE_DATE:= del_ins_rec.ACTUAL_DUE_DATE;
               delInsTab(m).PRINT_DUE_DATE_MSG_NAME:= del_ins_rec.PRINT_DUE_DATE_MSG_NAME;
               delInsTab(m).RECURRING_YN:= del_ins_rec.RECURRING_YN;
               delInsTab(m).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
               delInsTab(m).NOTIFY_PRIOR_DUE_DATE_UOM:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
               delInsTab(m).NOTIFY_PRIOR_DUE_DATE_YN:= del_ins_rec.NOTIFY_PRIOR_DUE_DATE_YN;
               delInsTab(m).NOTIFY_COMPLETED_YN:= del_ins_rec.NOTIFY_COMPLETED_YN;
               delInsTab(m).NOTIFY_OVERDUE_YN:= del_ins_rec.NOTIFY_OVERDUE_YN;
               delInsTab(m).NOTIFY_ESCALATION_YN:= del_ins_rec.NOTIFY_ESCALATION_YN;
               delInsTab(m).NOTIFY_ESCALATION_VALUE:= del_ins_rec.NOTIFY_ESCALATION_VALUE;
               delInsTab(m).NOTIFY_ESCALATION_UOM:= del_ins_rec.NOTIFY_ESCALATION_UOM;
               delInsTab(m).ESCALATION_ASSIGNEE:= del_ins_rec.ESCALATION_ASSIGNEE;
               delInsTab(m).AMENDMENT_OPERATION:= del_ins_rec.AMENDMENT_OPERATION;
               delInsTab(m).PRIOR_NOTIFICATION_ID:= del_ins_rec.PRIOR_NOTIFICATION_ID;
               delInsTab(m).AMENDMENT_NOTES:= del_ins_rec.AMENDMENT_NOTES;
               delInsTab(m).COMPLETED_NOTIFICATION_ID:= del_ins_rec.COMPLETED_NOTIFICATION_ID;
               delInsTab(m).OVERDUE_NOTIFICATION_ID:= del_ins_rec.OVERDUE_NOTIFICATION_ID;
               delInsTab(m).ESCALATION_NOTIFICATION_ID:= del_ins_rec.ESCALATION_NOTIFICATION_ID;
               delInsTab(m).LANGUAGE:= del_ins_rec.LANGUAGE;
               delInsTab(m).ORIGINAL_DELIVERABLE_ID:= del_ins_rec.ORIGINAL_DELIVERABLE_ID;
               delInsTab(m).REQUESTER_ID:= del_ins_rec.REQUESTER_ID;
               delInsTab(m).EXTERNAL_PARTY_ID:= del_ins_rec.EXTERNAL_PARTY_ID;
               delInsTab(m).EXTERNAL_PARTY_ROLE:= del_ins_rec.EXTERNAL_PARTY_ROLE;
               delInsTab(m).RECURRING_DEL_PARENT_ID:= del_ins_rec.RECURRING_DEL_PARENT_ID;
               delInsTab(m).BUSINESS_DOCUMENT_VERSION:= del_ins_rec.BUSINESS_DOCUMENT_VERSION;
               delInsTab(m).RELATIVE_ST_DATE_DURATION:= del_ins_rec.RELATIVE_ST_DATE_DURATION;
               delInsTab(m).RELATIVE_ST_DATE_UOM:= del_ins_rec.RELATIVE_ST_DATE_UOM;
               delInsTab(m).RELATIVE_ST_DATE_EVENT_ID:= del_ins_rec.RELATIVE_ST_DATE_EVENT_ID;
               delInsTab(m).RELATIVE_END_DATE_DURATION:= del_ins_rec.RELATIVE_END_DATE_DURATION;
               delInsTab(m).RELATIVE_END_DATE_UOM:= del_ins_rec.RELATIVE_END_DATE_UOM;
               delInsTab(m).RELATIVE_END_DATE_EVENT_ID:= del_ins_rec.RELATIVE_END_DATE_EVENT_ID;
               delInsTab(m).REPEATING_DAY_OF_MONTH:= del_ins_rec.REPEATING_DAY_OF_MONTH;
               delInsTab(m).REPEATING_DAY_OF_WEEK:= del_ins_rec.REPEATING_DAY_OF_WEEK;
               delInsTab(m).REPEATING_FREQUENCY_UOM:= del_ins_rec.REPEATING_FREQUENCY_UOM;
               delInsTab(m).REPEATING_DURATION:= del_ins_rec.REPEATING_DURATION;
               delInsTab(m).FIXED_START_DATE:= del_ins_rec.FIXED_START_DATE;
               delInsTab(m).FIXED_END_DATE:= del_ins_rec.FIXED_END_DATE;
               delInsTab(m).MANAGE_YN:= del_ins_rec.MANAGE_YN;
               delInsTab(m).INTERNAL_PARTY_ID:= del_ins_rec.INTERNAL_PARTY_ID;
               delInsTab(m).DELIVERABLE_STATUS:= del_ins_rec.DELIVERABLE_STATUS;
               delInsTab(m).STATUS_CHANGE_NOTES:= del_ins_rec.STATUS_CHANGE_NOTES;
               delInsTab(m).CREATED_BY:= del_ins_rec.CREATED_BY;
               delInsTab(m).CREATION_DATE:= del_ins_rec.CREATION_DATE;
               delInsTab(m).LAST_UPDATED_BY:= del_ins_rec.LAST_UPDATED_BY;
               delInsTab(m).LAST_UPDATE_DATE:= del_ins_rec.LAST_UPDATE_DATE;
               delInsTab(m).LAST_UPDATE_LOGIN:= del_ins_rec.LAST_UPDATE_LOGIN;
               delInsTab(m).OBJECT_VERSION_NUMBER:= del_ins_rec.OBJECT_VERSION_NUMBER;
               delInsTab(m).ATTRIBUTE_CATEGORY:= del_ins_rec.ATTRIBUTE_CATEGORY;
               delInsTab(m).ATTRIBUTE1:= del_ins_rec.ATTRIBUTE1;
               delInsTab(m).ATTRIBUTE2:= del_ins_rec.ATTRIBUTE2;
               delInsTab(m).ATTRIBUTE3:= del_ins_rec.ATTRIBUTE3;
               delInsTab(m).ATTRIBUTE4:= del_ins_rec.ATTRIBUTE4;
               delInsTab(m).ATTRIBUTE5:= del_ins_rec.ATTRIBUTE5;
               delInsTab(m).ATTRIBUTE6:= del_ins_rec.ATTRIBUTE6;
               delInsTab(m).ATTRIBUTE7:= del_ins_rec.ATTRIBUTE7;
               delInsTab(m).ATTRIBUTE8:= del_ins_rec.ATTRIBUTE8;
               delInsTab(m).ATTRIBUTE9:= del_ins_rec.ATTRIBUTE9;
               delInsTab(m).ATTRIBUTE10:= del_ins_rec.ATTRIBUTE10;
               delInsTab(m).ATTRIBUTE11:= del_ins_rec.ATTRIBUTE11;
               delInsTab(m).ATTRIBUTE12:= del_ins_rec.ATTRIBUTE12;
               delInsTab(m).ATTRIBUTE13:= del_ins_rec.ATTRIBUTE13;
               delInsTab(m).ATTRIBUTE14:= del_ins_rec.ATTRIBUTE14;
               delInsTab(m).ATTRIBUTE15:= del_ins_rec.ATTRIBUTE15;
               delInsTab(m).DISABLE_NOTIFICATIONS_YN:= del_ins_rec.DISABLE_NOTIFICATIONS_YN;
               delInsTab(m).LAST_AMENDMENT_DATE:= del_ins_rec.LAST_AMENDMENT_DATE;
               delInsTab(m).BUSINESS_DOCUMENT_LINE_ID:= del_ins_rec.BUSINESS_DOCUMENT_LINE_ID;
               delInsTab(m).EXTERNAL_PARTY_SITE_ID:= del_ins_rec.EXTERNAL_PARTY_SITE_ID;
               delInsTab(m).START_EVENT_DATE:= del_ins_rec.START_EVENT_DATE;
               delInsTab(m).END_EVENT_DATE:= del_ins_rec.END_EVENT_DATE;
               delInsTab(m).SUMMARY_AMEND_OPERATION_CODE:= del_ins_rec.SUMMARY_AMEND_OPERATION_CODE;
               delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
               delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
               delInsTab(m).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_ins_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
               delInsTab(m).PAY_HOLD_OVERDUE_YN:=del_ins_rec.PAY_HOLD_OVERDUE_YN;
               END LOOP; --  del_ins_rec IN del_ins_cur(delRecTab(i).deliverable_id)
                    IF del_ins_cur %ISOPEN THEN
                        CLOSE del_ins_cur ;
                    END IF;
                -- If instances exist then add them to the new deliverables table
                IF delInsTab.COUNT <> 0 THEN
                   FOR n IN delInsTab.FIRST..delInsTab.LAST LOOP
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside Instance cursor loop');
                    END IF;
                        j:=j+1;
                        -- extend table type
                        delIdTab.extend;
                        -- build the id table to copy attachments
                        delIdTab(j).orig_del_id := delInsTab(n).deliverable_id;
                        -- build new version deliverables table
                        delNewTab(j):= delInsTab(n);
                        select okc_deliverable_id_s.nextval
                        INTO delNewTab(j).deliverable_id from dual;
                        delIdTab(j).del_id := delNewTab(j).deliverable_id;
                        delNewTab(j).recurring_del_parent_id :=  l_recur_del_parent_id;
                        -- assign common attributes
                        delNewTab(j).business_document_id := p_target_doc_id;
                        delNewTab(j).business_document_type := p_target_doc_type;
                        delNewTab(j).business_document_number := p_target_doc_number;
                        delNewTab(j).created_by:= Fnd_Global.User_Id;
                        delNewTab(j).creation_date := sysdate;
                        delNewTab(j).last_updated_by:= Fnd_Global.User_Id;
                        delNewTab(j).last_update_date := sysdate;
                        delNewTab(j).last_update_login:=Fnd_Global.Login_Id;

                    END LOOP; -- delInsTab.FIRST..delInsTab.LAST
                  END IF;--delInsTab.COUNT


                  END IF; --recurring_yn = 'Y'
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: New Deliverable Id :'||to_char(delNewTab.COUNT));
                    END IF;
                END LOOP; -- delRecTab.FIRST..delRecTab.LAST
                END IF; -- delRecTab.COUNT

        -- loop through new table and create deliverables for the target document
        IF delNewTab.COUNT <> 0 THEN
                FOR i IN delNewTab.FIRST..delNewTab.LAST LOOP
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: New Deliverable Id :'||to_char(delNewTab(j).deliverable_id));
                    END IF;
                INSERT INTO okc_deliverables
                (DELIVERABLE_ID,
                BUSINESS_DOCUMENT_TYPE      ,
                BUSINESS_DOCUMENT_ID        ,
                BUSINESS_DOCUMENT_NUMBER    ,
                DELIVERABLE_TYPE            ,
                RESPONSIBLE_PARTY           ,
                INTERNAL_PARTY_CONTACT_ID   ,
                EXTERNAL_PARTY_CONTACT_ID   ,
                DELIVERABLE_NAME            ,
                DESCRIPTION                 ,
                COMMENTS                    ,
                DISPLAY_SEQUENCE            ,
                FIXED_DUE_DATE_YN           ,
                ACTUAL_DUE_DATE             ,
                PRINT_DUE_DATE_MSG_NAME     ,
                RECURRING_YN                ,
                NOTIFY_PRIOR_DUE_DATE_VALUE ,
                NOTIFY_PRIOR_DUE_DATE_UOM   ,
                NOTIFY_PRIOR_DUE_DATE_YN    ,
                NOTIFY_COMPLETED_YN         ,
                NOTIFY_OVERDUE_YN           ,
                NOTIFY_ESCALATION_YN        ,
                NOTIFY_ESCALATION_VALUE     ,
                NOTIFY_ESCALATION_UOM       ,
                ESCALATION_ASSIGNEE         ,
                AMENDMENT_OPERATION         ,
                PRIOR_NOTIFICATION_ID       ,
                AMENDMENT_NOTES             ,
                COMPLETED_NOTIFICATION_ID   ,
                OVERDUE_NOTIFICATION_ID     ,
                ESCALATION_NOTIFICATION_ID  ,
                LANGUAGE                    ,
                ORIGINAL_DELIVERABLE_ID     ,
                REQUESTER_ID                ,
                EXTERNAL_PARTY_ID           ,
                EXTERNAL_PARTY_ROLE           ,
                RECURRING_DEL_PARENT_ID      ,
                BUSINESS_DOCUMENT_VERSION   ,
                RELATIVE_ST_DATE_DURATION   ,
                RELATIVE_ST_DATE_UOM        ,
                RELATIVE_ST_DATE_EVENT_ID   ,
                RELATIVE_END_DATE_DURATION  ,
                RELATIVE_END_DATE_UOM       ,
                RELATIVE_END_DATE_EVENT_ID  ,
                REPEATING_DAY_OF_MONTH      ,
                REPEATING_DAY_OF_WEEK       ,
                REPEATING_FREQUENCY_UOM     ,
                REPEATING_DURATION          ,
                FIXED_START_DATE            ,
                FIXED_END_DATE              ,
                MANAGE_YN                   ,
                INTERNAL_PARTY_ID           ,
                DELIVERABLE_STATUS          ,
                STATUS_CHANGE_NOTES         ,
                CREATED_BY                  ,
                CREATION_DATE               ,
                LAST_UPDATED_BY             ,
                LAST_UPDATE_DATE            ,
                LAST_UPDATE_LOGIN           ,
                OBJECT_VERSION_NUMBER       ,
                ATTRIBUTE_CATEGORY          ,
                ATTRIBUTE1                  ,
                ATTRIBUTE2                  ,
                ATTRIBUTE3                  ,
                ATTRIBUTE4                  ,
                ATTRIBUTE5                  ,
                ATTRIBUTE6                  ,
                ATTRIBUTE7                  ,
                ATTRIBUTE8                  ,
                ATTRIBUTE9                  ,
                ATTRIBUTE10                 ,
                ATTRIBUTE11                 ,
                ATTRIBUTE12                 ,
                ATTRIBUTE13                 ,
                ATTRIBUTE14                 ,
                ATTRIBUTE15                 ,
                DISABLE_NOTIFICATIONS_YN    ,
                LAST_AMENDMENT_DATE         ,
                BUSINESS_DOCUMENT_LINE_ID   ,
                EXTERNAL_PARTY_SITE_ID      ,
                START_EVENT_DATE            ,
                END_EVENT_DATE              ,
                SUMMARY_AMEND_OPERATION_CODE,
                PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                PAY_HOLD_PRIOR_DUE_DATE_UOM,
                PAY_HOLD_PRIOR_DUE_DATE_YN,
                PAY_HOLD_OVERDUE_YN
                )
                VALUES (
                delNewTab(i).DELIVERABLE_ID,
                delNewTab(i).BUSINESS_DOCUMENT_TYPE      ,
                delNewTab(i).BUSINESS_DOCUMENT_ID        ,
                delNewTab(i).BUSINESS_DOCUMENT_NUMBER    ,
                delNewTab(i).DELIVERABLE_TYPE            ,
                delNewTab(i).RESPONSIBLE_PARTY           ,
                delNewTab(i).INTERNAL_PARTY_CONTACT_ID   ,
                delNewTab(i).EXTERNAL_PARTY_CONTACT_ID   ,
                delNewTab(i).DELIVERABLE_NAME            ,
                delNewTab(i).DESCRIPTION                 ,
                delNewTab(i).COMMENTS                    ,
                delNewTab(i).DISPLAY_SEQUENCE            ,
                delNewTab(i).FIXED_DUE_DATE_YN           ,
                delNewTab(i).ACTUAL_DUE_DATE             ,
                delNewTab(i).PRINT_DUE_DATE_MSG_NAME     ,
                delNewTab(i).RECURRING_YN                ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_UOM   ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_YN    ,
                delNewTab(i).NOTIFY_COMPLETED_YN         ,
                delNewTab(i).NOTIFY_OVERDUE_YN           ,
                delNewTab(i).NOTIFY_ESCALATION_YN        ,
                delNewTab(i).NOTIFY_ESCALATION_VALUE     ,
                delNewTab(i).NOTIFY_ESCALATION_UOM       ,
                delNewTab(i).ESCALATION_ASSIGNEE         ,
                delNewTab(i).AMENDMENT_OPERATION         ,
                delNewTab(i).PRIOR_NOTIFICATION_ID       ,
                delNewTab(i).AMENDMENT_NOTES             ,
                delNewTab(i).COMPLETED_NOTIFICATION_ID   ,
                delNewTab(i).OVERDUE_NOTIFICATION_ID     ,
                delNewTab(i).ESCALATION_NOTIFICATION_ID  ,
                delNewTab(i).LANGUAGE                    ,
                delNewTab(i).ORIGINAL_DELIVERABLE_ID     ,
                delNewTab(i).REQUESTER_ID                ,
                delNewTab(i).EXTERNAL_PARTY_ID           ,
                delNewTab(i).EXTERNAL_PARTY_ROLE           ,
                delNewTab(i).RECURRING_DEL_PARENT_ID      ,
                delNewTab(i).BUSINESS_DOCUMENT_VERSION   ,
                delNewTab(i).RELATIVE_ST_DATE_DURATION   ,
                delNewTab(i).RELATIVE_ST_DATE_UOM        ,
                delNewTab(i).RELATIVE_ST_DATE_EVENT_ID   ,
                delNewTab(i).RELATIVE_END_DATE_DURATION  ,
                delNewTab(i).RELATIVE_END_DATE_UOM       ,
                delNewTab(i).RELATIVE_END_DATE_EVENT_ID  ,
                delNewTab(i).REPEATING_DAY_OF_MONTH      ,
                delNewTab(i).REPEATING_DAY_OF_WEEK       ,
                delNewTab(i).REPEATING_FREQUENCY_UOM     ,
                delNewTab(i).REPEATING_DURATION          ,
                delNewTab(i).FIXED_START_DATE            ,
                delNewTab(i).FIXED_END_DATE              ,
                delNewTab(i).MANAGE_YN                   ,
                delNewTab(i).INTERNAL_PARTY_ID           ,
                delNewTab(i).DELIVERABLE_STATUS          ,
                delNewTab(i).STATUS_CHANGE_NOTES         ,
                delNewTab(i).CREATED_BY                  ,
                delNewTab(i).CREATION_DATE               ,
                delNewTab(i).LAST_UPDATED_BY             ,
                delNewTab(i).LAST_UPDATE_DATE            ,
                delNewTab(i).LAST_UPDATE_LOGIN           ,
                delNewTab(i).OBJECT_VERSION_NUMBER       ,
                delNewTab(i).ATTRIBUTE_CATEGORY          ,
                delNewTab(i).ATTRIBUTE1                  ,
                delNewTab(i).ATTRIBUTE2                  ,
                delNewTab(i).ATTRIBUTE3                  ,
                delNewTab(i).ATTRIBUTE4                  ,
                delNewTab(i).ATTRIBUTE5                  ,
                delNewTab(i).ATTRIBUTE6                  ,
                delNewTab(i).ATTRIBUTE7                  ,
                delNewTab(i).ATTRIBUTE8                  ,
                delNewTab(i).ATTRIBUTE9                  ,
                delNewTab(i).ATTRIBUTE10                 ,
                delNewTab(i).ATTRIBUTE11                 ,
                delNewTab(i).ATTRIBUTE12                 ,
                delNewTab(i).ATTRIBUTE13                 ,
                delNewTab(i).ATTRIBUTE14                 ,
                delNewTab(i).ATTRIBUTE15                 ,
                delNewTab(i).DISABLE_NOTIFICATIONS_YN    ,
                delNewTab(i).LAST_AMENDMENT_DATE         ,
                delNewTab(i).BUSINESS_DOCUMENT_LINE_ID   ,
                delNewTab(i).EXTERNAL_PARTY_SITE_ID      ,
                delNewTab(i).START_EVENT_DATE            ,
                delNewTab(i).END_EVENT_DATE              ,
                delNewTab(i).SUMMARY_AMEND_OPERATION_CODE,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_UOM,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_YN,
                delNewTab(i).PAY_HOLD_OVERDUE_YN
                );
                END LOOP;
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Done Creating Deliverables ');
               END IF;
        END IF; -- delNewTab.COUNT <> 0
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: New Deliverables COUNT :'||to_char(delIdTab.COUNT));
               END IF;

        -- loop through deliverable ids table and copy existing attachments and status history
        -- from old deliverable to new deliverable
          IF delIdTab.COUNT <> 0 THEN
          FOR i IN delIdTab.FIRST..delIdTab.LAST LOOP

                FOR delStsHist_rec in delStsHist(delIdTab(i).orig_del_id) LOOP
                --insert into status history
                IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: status history for Deliverable Id :'||to_char(delIdTab(i).del_id));
                END IF;
                INSERT INTO okc_del_status_history (
                deliverable_id,
                deliverable_status,
                status_changed_by,
                status_change_date,
                status_change_notes,
                object_version_number,
                created_by,
                creation_date,
                last_updated_by,
                last_update_date,
                last_update_login)
                VALUES(
                delIdTab(i).del_id,
                delStsHist_rec.DELIVERABLE_STATUS,
                delStsHist_rec.STATUS_CHANGED_BY,
                delStsHist_rec.STATUS_CHANGE_DATE,
                delStsHist_rec.STATUS_CHANGE_NOTES,
                delStsHist_rec.OBJECT_VERSION_NUMBER,
                FND_GLOBAL.User_id,
                sysdate,
                FND_GLOBAL.User_id,
                sysdate,
                Fnd_Global.Login_Id);
                END LOOP; -- delStsHist                                                                                                          END LOOP;
                IF delStsHist%ISOPEN THEN
                CLOSE  delStsHist;
                END IF;


            -- check if attachments exists
            IF attachment_exists(p_entity_name => G_ENTITY_NAME
                  ,p_pk1_value    =>  delIdTab(i).orig_del_id) THEN

                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Copy Deliverable Attachments :'||to_char(delIdTab(i).del_id));
                    END IF;
                    -- copy attachments
                    -- bug#3667712 added X_CREATED_BY,X_LAST_UPDATE_LOGIN params
                    fnd_attached_documents2_pkg.copy_attachments(
                        X_from_entity_name =>  G_ENTITY_NAME,
                        X_from_pk1_value   =>  delIdTab(i).orig_del_id,
                        X_to_entity_name   =>  G_ENTITY_NAME,
                        X_to_pk1_value     =>  to_char(delIdTab(i).del_id),
                        X_CREATED_BY       =>  FND_GLOBAL.User_id,
                        X_LAST_UPDATE_LOGIN => Fnd_Global.Login_Id
                        );
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Done Copy Deliverable Attachments ');
                    END IF;
            END IF; --attachment_exists
          END LOOP; -- delIdTab.FIRST..delIdTab.LAST
          END IF; -- delIdTab.COUNT

        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        x_return_status := l_return_status;
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,':leaving ');
            END IF;
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving with G_EXC_ERROR: '||
                substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        IF delStsHist%ISOPEN THEN
            CLOSE  delStsHist;
        END IF;
        IF del_ins_cur %ISOPEN THEN
           CLOSE del_ins_cur ;
        END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name
                ,'leaving with G_EXC_UNEXPECTED_ERROR :'||substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        IF delStsHist%ISOPEN THEN
          CLOSE  delStsHist;
        END IF;
        IF del_ins_cur %ISOPEN THEN
          CLOSE del_ins_cur ;
        END IF;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
            IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,
                'leaving with G_EXC_UNEXPECTED_ERROR :'||substr(sqlerrm,1,200));
            END IF;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        IF delStsHist%ISOPEN THEN
          CLOSE  delStsHist;
        END IF;
        IF del_ins_cur %ISOPEN THEN
          CLOSE del_ins_cur ;
        END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END copy_response_deliverables;


    -- Creates status history for a given deliverable status history table
    PROCEDURE create_del_status_history(
        p_api_version       IN NUMBER,
        p_init_msg_list     IN VARCHAR2,
        p_del_st_hist_tab   IN delHistTabType,
        x_msg_data      OUT NOCOPY  VARCHAR2,
        x_msg_count     OUT NOCOPY  NUMBER,
        x_return_status OUT NOCOPY  VARCHAR2)
    IS

    l_api_name      CONSTANT VARCHAR2(30) :='create_del_status_history';
    l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(1000);
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
    j PLS_INTEGER := 0;

    BEGIN

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside the API');
          END IF;

          IF p_del_st_hist_tab.count > 0 THEN
              FOR i IN p_del_st_hist_tab.FIRST..p_del_st_hist_tab.LAST LOOP
                        INSERT INTO okc_del_status_history
                        (deliverable_id,
                        deliverable_status,
                        STATUS_CHANGED_BY,
                        status_change_date,
                        status_change_notes,
                        object_version_number,
                        created_by,
                        creation_date,
                        last_updated_by,
                        last_update_date,
                        last_update_login)
                        VALUES (p_del_st_hist_tab(i).DELIVERABLE_ID
                        ,p_del_st_hist_tab(i).DELIVERABLE_STATUS
                        ,p_del_st_hist_tab(i).STATUS_CHANGED_BY
                        ,p_del_st_hist_tab(i).STATUS_CHANGE_DATE
                        ,p_del_st_hist_tab(i).STATUS_CHANGE_NOTES
                        ,p_del_st_hist_tab(i).OBJECT_VERSION_NUMBER
                        ,p_del_st_hist_tab(i).CREATED_BY
                        ,p_del_st_hist_tab(i).CREATION_DATE
                        ,p_del_st_hist_tab(i).LAST_UPDATED_BY
                        ,p_del_st_hist_tab(i).LAST_UPDATE_DATE
                        ,p_del_st_hist_tab(i).LAST_UPDATE_LOGIN
                        );
              END LOOP;
          END IF;

          IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: leaving ');
          END IF;
          x_return_status := l_return_status;
    EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
          IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_ERROR ,g_module||l_api_name,'100: leaving with G_EXC_ERROR');
          END IF;
    x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving with G_EXC_UNEXPECTED_ERROR');
          END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    WHEN OTHERS THEN
          IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving with G_EXC_UNEXPECTED_ERROR');
          END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN                                 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );
    END create_del_status_history;



/**
3635916 MODIFYING DELIVERABLE DOES NOT REMOVE RELATED CLAUSE
FROM AMENDMENT SUMMARY
This API will be invoked by
OKC_TERMS_UTIL_PVT.deliverable_amendment_exists()
Parameter Details:
p_bus_doc_id :       document Id
p_bus_doc_type :     document type
p_variable_code:     deliverable variable code
return value is Y or N based on the matching of deliverable
to the variable.
***/
FUNCTION deliverable_amendment_exists (
p_api_version           IN NUMBER,
p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
p_bus_doc_type          IN VARCHAR2,
p_bus_doc_id            IN NUMBER,
p_variable_code         IN VARCHAR2,
x_msg_data              OUT NOCOPY VARCHAR2,
x_msg_count             OUT NOCOPY NUMBER,
x_return_status         OUT NOCOPY VARCHAR2
)
RETURN VARCHAR2
IS

l_api_version   CONSTANT NUMBER := 1;
l_api_name      CONSTANT VARCHAR2(30) := 'deliverable_amendment_exists ';
-- removed reference to docClass in the query bug#4069955
CURSOR del_cur
IS
SELECT
 del.deliverable_type deliverable_type
,del.responsible_party responsible_party
from
 okc_deliverables del
,okc_deliverable_types_b delType
where del.business_document_type = p_bus_doc_type
and   del.business_document_id = p_bus_doc_id
and   del.business_document_version = -99
and   del.summary_amend_operation_code is not null
and   del.deliverable_type = delType.deliverable_type_code
and   delType.internal_flag = 'N';

del_rec  del_cur%ROWTYPE;

l_return_val  VARCHAR2(1);




BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside the API');
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := G_RET_STS_SUCCESS;


    l_return_val := 'N';
    -- loop through the amended deliverables and check if they match
    -- the variable_code. Return Y if they match else return N.
    FOR del_rec IN del_cur LOOP
        IF p_variable_code = 'EXTERNAL_SOURCING_DEL' OR
           p_variable_code = 'ALL_SOURCING_DEL' THEN

           IF del_rec.deliverable_type = 'SOURCING' THEN
               l_return_val := 'Y';
           END IF;

        END IF;

        IF p_variable_code = 'EXTERNAL_CONTRACTUAL_DEL' THEN
           IF del_rec.responsible_party = 'SUPPLIER_ORG' AND
              del_rec.deliverable_type = 'CONTRACTUAL' THEN
                l_return_val := 'Y';
           END IF;
        ELSIF p_variable_code = 'INTERNAL_CONTRACTUAL_DEL' THEN
           IF del_rec.responsible_party = 'INTERNAL_ORG' AND
              del_rec.deliverable_type = 'CONTRACTUAL' THEN
                l_return_val := 'Y';
           END IF;
        ELSIF p_variable_code = 'ALL_CONTRACTUAL_DEL' THEN

           IF del_rec.deliverable_type = 'CONTRACTUAL' THEN

               l_return_val := 'Y';

           END IF;

        END IF;

        IF l_return_val = 'Y' THEN
          RETURN(l_return_val);
        END IF;

    END LOOP;
  IF del_cur%ISOPEN THEN
     CLOSE del_cur;
  END IF;

        RETURN(l_return_val);

EXCEPTION

WHEN OTHERS THEN
  IF del_cur%ISOPEN THEN
     CLOSE del_cur;
  END IF;

  IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Unexpected error leaving '||
    G_PKG_NAME ||'.'||l_api_name);
  END IF;
  x_return_status := G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END IF;
  FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count,
                            p_data  =>  x_msg_data);

        RETURN(l_return_val);
END deliverable_amendment_exists;



/***
Function get_party_name
This API will be invoked by the Create/Update/ViewOnly Deliverable pages to display the
name for an External Party. The External Party could be VENDOR_ID from PO_VENDORS or
PARTY_ID from HZ_PARTIES
Parameter Details:
p_external_party_id: Unique Identifier from PO_VENDORS or HZ_PARTIES
p_external_party_role: Resp_Party_Code from OKC_RESP_PARTIES
24-FEB-2005  pnayani -- bug#4201738 updated get_party_name to return null
***/
FUNCTION get_party_name(
p_external_party_id          IN  NUMBER,
p_external_party_role        IN  VARCHAR2) RETURN VARCHAR2 IS

CURSOR get_vendor_name IS
SELECT vendor_name
from po_vendors
where vendor_id = p_external_party_id;

CURSOR get_party_name IS
SELECT party_name
from hz_parties
where party_id = p_external_party_id;

l_api_name      CONSTANT VARCHAR2(30) := 'get_party_name';
l_party_name VARCHAR2(360);

Begin

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside the API');
    END IF;

 l_party_name := NULL;
IF p_external_party_id is not null AND p_external_party_role is not null THEN
    If p_external_party_role = 'SUPPLIER_ORG' then
        OPEN get_vendor_name;
        FETCH get_vendor_name INTO l_party_name;
        CLOSE get_vendor_name;
    Else
        OPEN get_party_name;
        FETCH get_party_name INTO l_party_name;
        CLOSE get_party_name;
    End If;

END IF; -- p_external_party_id is not null
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'101: party name is :'||l_party_name);
    END IF;

RETURN l_party_name;

EXCEPTION
 WHEN OTHERS THEN
 IF get_vendor_name%ISOPEN THEN
     CLOSE get_vendor_name;
 END IF;
 IF get_party_name%ISOPEN THEN
     CLOSE get_party_name;
 END IF;
 l_party_name := NULL;
  IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'1000: Unexpected error leaving '||
    G_PKG_NAME ||'.'||l_api_name);
  END IF;

 RETURN l_party_name;

End get_party_name;

/**************************/


    -- bug#4075168 New API for Template Revision
    -- bug#4083525 New param p_copy_deliverables
    PROCEDURE CopyDelForTemplateRevision(
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
        p_source_doc_id             IN NUMBER,
        p_source_doc_type           IN VARCHAR2,
        p_target_doc_id             IN NUMBER,
        p_target_doc_type           IN VARCHAR2,
        p_target_doc_number         IN VARCHAR2,
        p_copy_del_attachments_yn   IN VARCHAR2 default 'Y',
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count                 OUT NOCOPY NUMBER,
        x_return_status             OUT NOCOPY VARCHAR2) IS

    CURSOR del_cur IS
    SELECT *
    FROM OKC_DELIVERABLES
    WHERE business_document_id = p_source_doc_id
    AND   business_document_version = -99
    AND   business_document_type = p_source_doc_type
    AND   NVL(amendment_operation,'NONE')<> 'DELETED'
    AND   NVL(summary_amend_operation_code,'NONE')<> 'DELETED'
    AND   recurring_del_parent_id is null;
    delRecTab           delRecTabType;
    delNewTab           delRecTabType;
    TYPE delIdRecType IS RECORD (del_id NUMBER,orig_del_id NUMBER);
    TYPE delIdTabType IS TABLE OF delIdRecType;
    delIdTab    delIdTabType;
    j PLS_INTEGER := 0;
    k PLS_INTEGER := 0;
    l_api_name      CONSTANT VARCHAR2(30) :='CopyDelForTemplateRevision';
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_deliverable_id    NUMBER;
    l_from_pk1_value    VARCHAR2(100);
    l_result            BOOLEAN;
    l_copy              VARCHAR2(1) := 'N';
    l_copy_attachments  VARCHAR2(1) := 'N';


    BEGIN

            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Inside OKC_DELIVERABLE_PROCESS_PVT.CopyDelForTemplateRevision');
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: budoc id is:'||to_char(p_target_doc_id));
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: budoc type:'||p_target_doc_type);
            END IF;
               -- initialize the table type variable
                delIdTab := delIdTabType();

            FOR del_rec IN del_cur LOOP

            k := k+1;
            delRecTab(k).deliverable_id := del_rec.deliverable_id;
            delRecTab(k).BUSINESS_DOCUMENT_TYPE:= del_rec.BUSINESS_DOCUMENT_TYPE;
            delRecTab(k).BUSINESS_DOCUMENT_ID:= del_rec.BUSINESS_DOCUMENT_ID;
            delRecTab(k).BUSINESS_DOCUMENT_NUMBER:= del_rec.BUSINESS_DOCUMENT_NUMBER;
            delRecTab(k).DELIVERABLE_TYPE:= del_rec.DELIVERABLE_TYPE;
            delRecTab(k).RESPONSIBLE_PARTY:= del_rec.RESPONSIBLE_PARTY;
            delRecTab(k).INTERNAL_PARTY_CONTACT_ID:= del_rec.INTERNAL_PARTY_CONTACT_ID;
            delRecTab(k).EXTERNAL_PARTY_CONTACT_ID:= del_rec.EXTERNAL_PARTY_CONTACT_ID;
            delRecTab(k).DELIVERABLE_NAME:= del_rec.DELIVERABLE_NAME;
            delRecTab(k).DESCRIPTION:= del_rec.DESCRIPTION;
            delRecTab(k).COMMENTS:= del_rec.COMMENTS;
            delRecTab(k).DISPLAY_SEQUENCE:= del_rec.DISPLAY_SEQUENCE;
            delRecTab(k).FIXED_DUE_DATE_YN:= del_rec.FIXED_DUE_DATE_YN;
            delRecTab(k).ACTUAL_DUE_DATE:= del_rec.ACTUAL_DUE_DATE;
            delRecTab(k).PRINT_DUE_DATE_MSG_NAME:= del_rec.PRINT_DUE_DATE_MSG_NAME;
            delRecTab(k).RECURRING_YN:= del_rec.RECURRING_YN;
            delRecTab(k).NOTIFY_PRIOR_DUE_DATE_VALUE:= del_rec.NOTIFY_PRIOR_DUE_DATE_VALUE;
            delRecTab(k).NOTIFY_PRIOR_DUE_DATE_UOM:= del_rec.NOTIFY_PRIOR_DUE_DATE_UOM;
            delRecTab(k).NOTIFY_PRIOR_DUE_DATE_YN:= del_rec.NOTIFY_PRIOR_DUE_DATE_YN;
            delRecTab(k).NOTIFY_COMPLETED_YN:= del_rec.NOTIFY_COMPLETED_YN;
            delRecTab(k).NOTIFY_OVERDUE_YN:= del_rec.NOTIFY_OVERDUE_YN;
            delRecTab(k).NOTIFY_ESCALATION_YN:= del_rec.NOTIFY_ESCALATION_YN;
            delRecTab(k).NOTIFY_ESCALATION_VALUE:= del_rec.NOTIFY_ESCALATION_VALUE;
            delRecTab(k).NOTIFY_ESCALATION_UOM:= del_rec.NOTIFY_ESCALATION_UOM;
            delRecTab(k).ESCALATION_ASSIGNEE:= del_rec.ESCALATION_ASSIGNEE;
            delRecTab(k).AMENDMENT_OPERATION:= del_rec.AMENDMENT_OPERATION;
            delRecTab(k).PRIOR_NOTIFICATION_ID:= del_rec.PRIOR_NOTIFICATION_ID;
            delRecTab(k).AMENDMENT_NOTES:= del_rec.AMENDMENT_NOTES;
            delRecTab(k).COMPLETED_NOTIFICATION_ID:= del_rec.COMPLETED_NOTIFICATION_ID;
            delRecTab(k).OVERDUE_NOTIFICATION_ID:= del_rec.OVERDUE_NOTIFICATION_ID;
            delRecTab(k).ESCALATION_NOTIFICATION_ID:= del_rec.ESCALATION_NOTIFICATION_ID;
            delRecTab(k).LANGUAGE:= del_rec.LANGUAGE;
            delRecTab(k).ORIGINAL_DELIVERABLE_ID:= del_rec.ORIGINAL_DELIVERABLE_ID;
            delRecTab(k).REQUESTER_ID:= del_rec.REQUESTER_ID;
            delRecTab(k).EXTERNAL_PARTY_ID:= del_rec.EXTERNAL_PARTY_ID;
      delRecTab(k).EXTERNAL_PARTY_ROLE := del_rec.EXTERNAL_PARTY_ROLE;
            delRecTab(k).RECURRING_DEL_PARENT_ID:= del_rec.RECURRING_DEL_PARENT_ID;
            delRecTab(k).BUSINESS_DOCUMENT_VERSION:= del_rec.BUSINESS_DOCUMENT_VERSION;
            delRecTab(k).RELATIVE_ST_DATE_DURATION:= del_rec.RELATIVE_ST_DATE_DURATION;
            delRecTab(k).RELATIVE_ST_DATE_UOM:= del_rec.RELATIVE_ST_DATE_UOM;
            delRecTab(k).RELATIVE_ST_DATE_EVENT_ID:= del_rec.RELATIVE_ST_DATE_EVENT_ID;
            delRecTab(k).RELATIVE_END_DATE_DURATION:= del_rec.RELATIVE_END_DATE_DURATION;
            delRecTab(k).RELATIVE_END_DATE_UOM:= del_rec.RELATIVE_END_DATE_UOM;
            delRecTab(k).RELATIVE_END_DATE_EVENT_ID:= del_rec.RELATIVE_END_DATE_EVENT_ID;
            delRecTab(k).REPEATING_DAY_OF_MONTH:= del_rec.REPEATING_DAY_OF_MONTH;
            delRecTab(k).REPEATING_DAY_OF_WEEK:= del_rec.REPEATING_DAY_OF_WEEK;
            delRecTab(k).REPEATING_FREQUENCY_UOM:= del_rec.REPEATING_FREQUENCY_UOM;
            delRecTab(k).REPEATING_DURATION:= del_rec.REPEATING_DURATION;
            delRecTab(k).FIXED_START_DATE:= del_rec.FIXED_START_DATE;
            delRecTab(k).FIXED_END_DATE:= del_rec.FIXED_END_DATE;
            delRecTab(k).MANAGE_YN:= del_rec.MANAGE_YN;
            delRecTab(k).INTERNAL_PARTY_ID:= del_rec.INTERNAL_PARTY_ID;
            delRecTab(k).DELIVERABLE_STATUS:= del_rec.DELIVERABLE_STATUS;
            delRecTab(k).STATUS_CHANGE_NOTES:= del_rec.STATUS_CHANGE_NOTES;
            delRecTab(k).CREATED_BY:= del_rec.CREATED_BY;
            delRecTab(k).CREATION_DATE:= del_rec.CREATION_DATE;
            delRecTab(k).LAST_UPDATED_BY:= del_rec.LAST_UPDATED_BY;
            delRecTab(k).LAST_UPDATE_DATE:= del_rec.LAST_UPDATE_DATE;
            delRecTab(k).LAST_UPDATE_LOGIN:= del_rec.LAST_UPDATE_LOGIN;
            delRecTab(k).OBJECT_VERSION_NUMBER:= del_rec.OBJECT_VERSION_NUMBER;
            delRecTab(k).ATTRIBUTE_CATEGORY:= del_rec.ATTRIBUTE_CATEGORY;
            delRecTab(k).ATTRIBUTE1:= del_rec.ATTRIBUTE1;
            delRecTab(k).ATTRIBUTE2:= del_rec.ATTRIBUTE2;
            delRecTab(k).ATTRIBUTE3:= del_rec.ATTRIBUTE3;
            delRecTab(k).ATTRIBUTE4:= del_rec.ATTRIBUTE4;
            delRecTab(k).ATTRIBUTE5:= del_rec.ATTRIBUTE5;
            delRecTab(k).ATTRIBUTE6:= del_rec.ATTRIBUTE6;
            delRecTab(k).ATTRIBUTE7:= del_rec.ATTRIBUTE7;
            delRecTab(k).ATTRIBUTE8:= del_rec.ATTRIBUTE8;
            delRecTab(k).ATTRIBUTE9:= del_rec.ATTRIBUTE9;
            delRecTab(k).ATTRIBUTE10:= del_rec.ATTRIBUTE10;
            delRecTab(k).ATTRIBUTE11:= del_rec.ATTRIBUTE11;
            delRecTab(k).ATTRIBUTE12:= del_rec.ATTRIBUTE12;
            delRecTab(k).ATTRIBUTE13:= del_rec.ATTRIBUTE13;
            delRecTab(k).ATTRIBUTE14:= del_rec.ATTRIBUTE14;
            delRecTab(k).ATTRIBUTE15:= del_rec.ATTRIBUTE15;
            delRecTab(k).DISABLE_NOTIFICATIONS_YN:= del_rec.DISABLE_NOTIFICATIONS_YN;
            delRecTab(k).LAST_AMENDMENT_DATE:= del_rec.LAST_AMENDMENT_DATE;
            delRecTab(k).BUSINESS_DOCUMENT_LINE_ID:= del_rec.BUSINESS_DOCUMENT_LINE_ID;
            delRecTab(k).EXTERNAL_PARTY_SITE_ID:= del_rec.EXTERNAL_PARTY_SITE_ID;
            delRecTab(k).START_EVENT_DATE:= del_rec.START_EVENT_DATE;
            delRecTab(k).END_EVENT_DATE:= del_rec.END_EVENT_DATE;
            delRecTab(k).SUMMARY_AMEND_OPERATION_CODE:= del_rec.SUMMARY_AMEND_OPERATION_CODE;
            delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_VALUE:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_VALUE;
            delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_UOM:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_UOM;
            delRecTab(k).PAY_HOLD_PRIOR_DUE_DATE_YN:=del_rec.PAY_HOLD_PRIOR_DUE_DATE_YN;
            delRecTab(k).PAY_HOLD_OVERDUE_YN:=del_rec.PAY_HOLD_OVERDUE_YN;


            END LOOP;
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        IF p_source_doc_type = 'TEMPLATE' THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Source doc is template');
            END IF;
            -- copy from template to template
            IF p_target_doc_type = 'TEMPLATE' THEN
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: Target doc is template');
            END IF;

            IF delRecTab.COUNT <> 0 THEN
              IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: delRecTab Count :'||to_char(delRecTab.COUNT));
              END IF;
                FOR i IN delRecTab.FIRST..delRecTab.LAST LOOP
                    j := j+1;
                    -- extend table type
                    delIdTab.extend;
                    delIdTab(j).orig_del_id := delRecTab(i).deliverable_id;
                    delNewTab(j) := delRecTab(i);
                    select okc_deliverable_id_s.nextval INTO delNewTab(j).deliverable_id from dual;
                    delIdTab(j).del_id := delNewTab(j).deliverable_id;
                    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                        FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'100: New Deliverable Id :'||to_char(delNewTab(j).deliverable_id));
                    END IF;
                    delNewTab(j).business_document_id := p_target_doc_id;
                    delNewTab(j).business_document_type := p_target_doc_type;
                    delNewTab(j).business_document_number := p_target_doc_number;
                    delNewTab(j).business_document_version := -99;
                    delNewTab(j).created_by:= Fnd_Global.User_Id;
                    delNewTab(j).creation_date := sysdate;
                    delNewTab(j).last_updated_by:= Fnd_Global.User_Id;
                    delNewTab(j).last_update_date := sysdate;
                    delNewTab(j).last_update_login:=Fnd_Global.Login_Id;

                END LOOP;
        -- bug#4083525 CopyDelForTemplateRevision
        IF delNewTab.COUNT <> 0 THEN
                FOR i IN delNewTab.FIRST..delNewTab.LAST LOOP
                INSERT INTO okc_deliverables
                (DELIVERABLE_ID,
                BUSINESS_DOCUMENT_TYPE      ,
                BUSINESS_DOCUMENT_ID        ,
                BUSINESS_DOCUMENT_NUMBER    ,
                DELIVERABLE_TYPE            ,
                RESPONSIBLE_PARTY           ,
                INTERNAL_PARTY_CONTACT_ID   ,
                EXTERNAL_PARTY_CONTACT_ID   ,
                DELIVERABLE_NAME            ,
                DESCRIPTION                 ,
                COMMENTS                    ,
                DISPLAY_SEQUENCE            ,
                FIXED_DUE_DATE_YN           ,
                ACTUAL_DUE_DATE             ,
                PRINT_DUE_DATE_MSG_NAME     ,
                RECURRING_YN                ,
                NOTIFY_PRIOR_DUE_DATE_VALUE ,
                NOTIFY_PRIOR_DUE_DATE_UOM   ,
                NOTIFY_PRIOR_DUE_DATE_YN    ,
                NOTIFY_COMPLETED_YN         ,
                NOTIFY_OVERDUE_YN           ,
                NOTIFY_ESCALATION_YN        ,
                NOTIFY_ESCALATION_VALUE     ,
                NOTIFY_ESCALATION_UOM       ,
                ESCALATION_ASSIGNEE         ,
                AMENDMENT_OPERATION         ,
                PRIOR_NOTIFICATION_ID       ,
                AMENDMENT_NOTES             ,
                COMPLETED_NOTIFICATION_ID   ,
                OVERDUE_NOTIFICATION_ID     ,
                ESCALATION_NOTIFICATION_ID  ,
                LANGUAGE                    ,
                ORIGINAL_DELIVERABLE_ID     ,
                REQUESTER_ID                ,
                EXTERNAL_PARTY_ID           ,
                EXTERNAL_PARTY_ROLE         ,
                RECURRING_DEL_PARENT_ID     ,
                BUSINESS_DOCUMENT_VERSION   ,
                RELATIVE_ST_DATE_DURATION   ,
                RELATIVE_ST_DATE_UOM        ,
                RELATIVE_ST_DATE_EVENT_ID   ,
                RELATIVE_END_DATE_DURATION  ,
                RELATIVE_END_DATE_UOM       ,
                RELATIVE_END_DATE_EVENT_ID  ,
                REPEATING_DAY_OF_MONTH      ,
                REPEATING_DAY_OF_WEEK       ,
                REPEATING_FREQUENCY_UOM     ,
                REPEATING_DURATION          ,
                FIXED_START_DATE            ,
                FIXED_END_DATE              ,
                MANAGE_YN                   ,
                INTERNAL_PARTY_ID           ,
                DELIVERABLE_STATUS          ,
                STATUS_CHANGE_NOTES         ,
                CREATED_BY                  ,
                CREATION_DATE               ,
                LAST_UPDATED_BY             ,
                LAST_UPDATE_DATE            ,
                LAST_UPDATE_LOGIN           ,
                OBJECT_VERSION_NUMBER       ,
                ATTRIBUTE_CATEGORY          ,
                ATTRIBUTE1                  ,
                ATTRIBUTE2                  ,
                ATTRIBUTE3                  ,
                ATTRIBUTE4                  ,
                ATTRIBUTE5                  ,
                ATTRIBUTE6                  ,
                ATTRIBUTE7                  ,
                ATTRIBUTE8                  ,
                ATTRIBUTE9                  ,
                ATTRIBUTE10                 ,
                ATTRIBUTE11                 ,
                ATTRIBUTE12                 ,
                ATTRIBUTE13                 ,
               ATTRIBUTE14                 ,
                ATTRIBUTE15                 ,
                DISABLE_NOTIFICATIONS_YN    ,
                LAST_AMENDMENT_DATE         ,
                BUSINESS_DOCUMENT_LINE_ID   ,
                EXTERNAL_PARTY_SITE_ID      ,
                START_EVENT_DATE            ,
                END_EVENT_DATE              ,
                SUMMARY_AMEND_OPERATION_CODE,
                PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                PAY_HOLD_PRIOR_DUE_DATE_UOM,
                PAY_HOLD_PRIOR_DUE_DATE_YN,
                PAY_HOLD_OVERDUE_YN
                )
                VALUES (
                delNewTab(i).DELIVERABLE_ID,
                delNewTab(i).BUSINESS_DOCUMENT_TYPE      ,
                delNewTab(i).BUSINESS_DOCUMENT_ID        ,
                delNewTab(i).BUSINESS_DOCUMENT_NUMBER    ,
                delNewTab(i).DELIVERABLE_TYPE            ,
                delNewTab(i).RESPONSIBLE_PARTY           ,
                delNewTab(i).INTERNAL_PARTY_CONTACT_ID   ,
                delNewTab(i).EXTERNAL_PARTY_CONTACT_ID   ,
                delNewTab(i).DELIVERABLE_NAME            ,
                delNewTab(i).DESCRIPTION                 ,
                delNewTab(i).COMMENTS                    ,
                delNewTab(i).DISPLAY_SEQUENCE            ,
                delNewTab(i).FIXED_DUE_DATE_YN           ,
                delNewTab(i).ACTUAL_DUE_DATE             ,
                delNewTab(i).PRINT_DUE_DATE_MSG_NAME     ,
                delNewTab(i).RECURRING_YN                ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_VALUE ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_UOM   ,
                delNewTab(i).NOTIFY_PRIOR_DUE_DATE_YN    ,
                delNewTab(i).NOTIFY_COMPLETED_YN         ,
                delNewTab(i).NOTIFY_OVERDUE_YN           ,
                delNewTab(i).NOTIFY_ESCALATION_YN        ,
                delNewTab(i).NOTIFY_ESCALATION_VALUE     ,
                delNewTab(i).NOTIFY_ESCALATION_UOM       ,
                delNewTab(i).ESCALATION_ASSIGNEE         ,
                delNewTab(i).AMENDMENT_OPERATION         ,
                delNewTab(i).PRIOR_NOTIFICATION_ID       ,
                delNewTab(i).AMENDMENT_NOTES             ,
                delNewTab(i).COMPLETED_NOTIFICATION_ID   ,
                delNewTab(i).OVERDUE_NOTIFICATION_ID     ,
                delNewTab(i).ESCALATION_NOTIFICATION_ID  ,
                delNewTab(i).LANGUAGE                    ,
                delNewTab(i).ORIGINAL_DELIVERABLE_ID     ,
                delNewTab(i).REQUESTER_ID                ,
                delNewTab(i).EXTERNAL_PARTY_ID           ,
                delNewTab(i).EXTERNAL_PARTY_ROLE         ,
                delNewTab(i).RECURRING_DEL_PARENT_ID     ,
                delNewTab(i).BUSINESS_DOCUMENT_VERSION   ,
                delNewTab(i).RELATIVE_ST_DATE_DURATION   ,
                delNewTab(i).RELATIVE_ST_DATE_UOM        ,
                delNewTab(i).RELATIVE_ST_DATE_EVENT_ID   ,
                delNewTab(i).RELATIVE_END_DATE_DURATION  ,
                delNewTab(i).RELATIVE_END_DATE_UOM       ,
                delNewTab(i).RELATIVE_END_DATE_EVENT_ID  ,
                delNewTab(i).REPEATING_DAY_OF_MONTH      ,
                delNewTab(i).REPEATING_DAY_OF_WEEK       ,
                delNewTab(i).REPEATING_FREQUENCY_UOM     ,
                delNewTab(i).REPEATING_DURATION          ,
                delNewTab(i).FIXED_START_DATE            ,
                delNewTab(i).FIXED_END_DATE              ,
                delNewTab(i).MANAGE_YN                   ,
                delNewTab(i).INTERNAL_PARTY_ID           ,
                delNewTab(i).DELIVERABLE_STATUS          ,
                delNewTab(i).STATUS_CHANGE_NOTES         ,
                delNewTab(i).CREATED_BY                  ,
                delNewTab(i).CREATION_DATE               ,
                delNewTab(i).LAST_UPDATED_BY             ,
                delNewTab(i).LAST_UPDATE_DATE            ,
                delNewTab(i).LAST_UPDATE_LOGIN           ,
                delNewTab(i).OBJECT_VERSION_NUMBER       ,
                delNewTab(i).ATTRIBUTE_CATEGORY          ,
                delNewTab(i).ATTRIBUTE1                  ,
                delNewTab(i).ATTRIBUTE2                  ,
                delNewTab(i).ATTRIBUTE3                  ,
                delNewTab(i).ATTRIBUTE4                  ,
                delNewTab(i).ATTRIBUTE5                  ,
                delNewTab(i).ATTRIBUTE6                  ,
                delNewTab(i).ATTRIBUTE7                  ,
                delNewTab(i).ATTRIBUTE8                  ,
                delNewTab(i).ATTRIBUTE9                  ,
                delNewTab(i).ATTRIBUTE10                 ,
                delNewTab(i).ATTRIBUTE11                 ,
                delNewTab(i).ATTRIBUTE12                 ,
                delNewTab(i).ATTRIBUTE13                 ,
                delNewTab(i).ATTRIBUTE14                 ,
                delNewTab(i).ATTRIBUTE15                 ,
                delNewTab(i).DISABLE_NOTIFICATIONS_YN    ,
                delNewTab(i).LAST_AMENDMENT_DATE         ,
                delNewTab(i).BUSINESS_DOCUMENT_LINE_ID   ,
                delNewTab(i).EXTERNAL_PARTY_SITE_ID      ,
                delNewTab(i).START_EVENT_DATE            ,
                delNewTab(i).END_EVENT_DATE              ,
                delNewTab(i).SUMMARY_AMEND_OPERATION_CODE,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_VALUE,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_UOM,
                delNewTab(i).PAY_HOLD_PRIOR_DUE_DATE_YN,
                delNewTab(i).PAY_HOLD_OVERDUE_YN
                );
                END LOOP;
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                 '100: Done Creating Deliverables ');
               END IF;
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                 '100: New Deliverables COUNT :'||to_char(delIdTab.COUNT));
               END IF;

        -- copy any existing attachments if allowed
        IF p_copy_del_attachments_yn = 'Y' THEN

          IF delIdTab.COUNT <> 0 THEN
          FOR i IN delIdTab.FIRST..delIdTab.LAST LOOP
            -- check if attachments exists
            IF attachment_exists(p_entity_name => G_ENTITY_NAME
                  ,p_pk1_value    =>  delIdTab(i).orig_del_id) THEN

               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                 '100: Copy Deliverable Attachments :'||to_char(delIdTab(i).del_id));
               END IF;
              -- copy attachments
              -- bug#3667712 added X_CREATED_BY,X_LAST_UPDATE_LOGIN params
              fnd_attached_documents2_pkg.copy_attachments(
                  X_from_entity_name =>  G_ENTITY_NAME,
                  X_from_pk1_value   =>  delIdTab(i).orig_del_id,
                  X_to_entity_name   =>  G_ENTITY_NAME,
                  X_to_pk1_value     =>  to_char(delIdTab(i).del_id),
                  X_CREATED_BY       =>  FND_GLOBAL.User_id,
                  X_LAST_UPDATE_LOGIN => Fnd_Global.Login_Id
                  );
               IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                 FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                 '100: Done Copy Deliverable Attachments ');
               END IF;
            END IF;
          END LOOP;
          END IF;-- delIdTab.COUNT <> 0 THEN
        END IF; -- p_copy_del_attachments_yn = 'Y'
        END IF; -- delNewTab.COUNT <> 0 THEN
        -- bug#4083525 CopyDelForTemplateRevision
       END IF;-- delRecTab.count
       END IF; -- p_target_doc_type = 'TEMPLATE'
     END IF; -- p_source_doc_type = 'TEMPLATE'

        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
        x_return_status := l_return_status;
            IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,
                '100: leaving OKC_DELIVERABLE_PROCESS_PVT.CopyDelForTemplateRevision');
            END IF;


    EXCEPTION
    WHEN OTHERS THEN
        IF del_cur %ISOPEN THEN
          CLOSE del_cur ;
        END IF;
       IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'100: leaving OKC_DELIVERABLE_PROCESS_PVT.CopyDelForTemplateRevision with G_EXC_UNEXPECTED_ERROR');
       END IF;
    x_return_status := G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count =>  x_msg_count,
        p_data  =>  x_msg_data
        );

    END CopyDelForTemplateRevision;


-- Start of comments
--API name      : deleteDeliverables
--Type          : Private.
--Function      : 1.  Deletes deliverables of the current version of the bus doc (-99).
--              : 2.  If p_revert_dels = 'Y",  re-creating deliverables with -99 version
--              :     from the deliverable definitions of the previous bus doc version.
--Usage         : This API is called from Repository while deleting a contract.
--Pre-reqs      : None.
--Parameters    :
--IN            : p_api_version         IN NUMBER       Required
--              : p_init_msg_list       IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_commit              IN VARCHAR2     Optional
--                   Default = FND_API.G_FALSE
--              : p_bus_doc_id          IN NUMBER       Required
--                   Contract ID of the contract to be deleted
--              : p_bus_doc_type        IN VARCHAR2     Required
--                   Type of the contract to be deleted
--              : p_bus_doc_version     IN NUMBER       Required
--                   Version number of the contract to be deleted
--              : p_prev_del_active     IN VARCHAR2     Optional
--                   Flag which tells whether deliverables of the previous business
--                   document version are activated or not
--                   Default = 'N'
--              : p_revert_dels         IN VARCHAR2     Optional
--                   Flag which tells whether to recreate the -99 deliverables from
--                   the previous document version's deliverables. This will be "N" if
--                   the first version of the business document is being deleted
--                   Default = 'N'
--OUT           : x_return_status       OUT  VARCHAR2(1)
--              : x_msg_count           OUT  NUMBER
--              : x_msg_data            OUT  VARCHAR2(2000)
--Note          :
-- End of comments
PROCEDURE deleteDeliverables(
        p_api_version           IN NUMBER,
        p_init_msg_list         IN VARCHAR2:=FND_API.G_FALSE,
        p_commit                IN VARCHAR2:=FND_API.G_FALSE,
        p_bus_doc_id            IN NUMBER,
        p_bus_doc_type          IN VARCHAR2,
        p_bus_doc_version       IN NUMBER,
        p_prev_del_active       IN VARCHAR2 := 'N',
        p_revert_dels           IN VARCHAR2 := 'N',
        x_msg_data              OUT NOCOPY VARCHAR2,
        x_msg_count             OUT NOCOPY NUMBER,
        x_return_status         OUT NOCOPY VARCHAR2)
IS

  -- Cursor to get deliverable id and original deliverable ids of deliverables of
  -- the current version of a business document
  CURSOR cur_vers_del_csr IS
    SELECT deliverable_id,
           original_deliverable_id
    FROM   okc_deliverables
    WHERE  business_document_id = p_bus_doc_id
    AND    business_document_version = -99
    AND    business_document_type = p_bus_doc_type;

  -- Cursor to get deliverables of the previous version of a business document
  CURSOR prev_vers_del_csr IS
    SELECT  deliverable_id,
            business_document_type,
            business_document_id,
            business_document_number,
            deliverable_type,
            responsible_party,
            internal_party_contact_id,
            external_party_contact_id,
            deliverable_name,
            description,
            comments,
            display_sequence,
            fixed_due_date_yn,
            actual_due_date,
            print_due_date_msg_name,
            recurring_yn,
            notify_prior_due_date_value,
            notify_prior_due_date_uom,
            notify_prior_due_date_yn,
            notify_completed_yn,
            notify_overdue_yn,
            notify_escalation_yn,
            notify_escalation_value,
            notify_escalation_uom,
            escalation_assignee,
            amendment_operation,
            prior_notification_id,
            amendment_notes,
            completed_notification_id,
            overdue_notification_id,
            escalation_notification_id,
            language,
            original_deliverable_id,
            requester_id,
            external_party_id,
            recurring_del_parent_id,
            business_document_version,
            relative_st_date_duration,
            relative_st_date_uom,
            relative_st_date_event_id,
            relative_end_date_duration,
            relative_end_date_uom,
            relative_end_date_event_id,
            repeating_day_of_month,
            repeating_day_of_week,
            repeating_frequency_uom,
            repeating_duration,
            fixed_start_date,
            fixed_end_date,
            manage_yn,
            internal_party_id,
            deliverable_status,
            status_change_notes,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login,
            object_version_number,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            disable_notifications_yn,
            last_amendment_date,
            business_document_line_id,
            external_party_site_id,
            start_event_date,
            end_event_date,
            summary_amend_operation_code,
            external_party_role,
            pay_hold_prior_due_date_value,
            pay_hold_prior_due_date_uom,
            pay_hold_prior_due_date_yn,
            pay_hold_overdue_yn
    FROM   okc_deliverables
    WHERE  business_document_id = p_bus_doc_id
    AND    business_document_version = p_bus_doc_version - 1
    AND    business_document_type = p_bus_doc_type
    AND    recurring_del_parent_id IS NULL
    AND    NVL(amendment_operation, ' ') <> 'DELETED';


 --  Fix for bug 13518546 start
  CURSOR cur_del_doc_type(delid NUMBER) IS
    SELECT BUSINESS_DOCUMENT_TYPE FROM okc_deliverables
    WHERE deliverable_id=delid;

    l_business_document_type   okc_deliverables.business_document_type%TYPE;

	 --  Fix for bug 13518546 end

  TYPE cur_vers_del_tbl IS TABLE OF cur_vers_del_csr%ROWTYPE;
  TYPE prev_vers_del_tbl IS TABLE OF prev_vers_del_csr%ROWTYPE;

  cur_vers_del cur_vers_del_tbl;
  prev_vers_del prev_vers_del_tbl;

  l_api_name      CONSTANT VARCHAR2(30) :='deleteDeliverables';
  l_api_version   CONSTANT NUMBER := 1.0;
  l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  l_deliverable_id okc_deliverables.deliverable_id%TYPE;


BEGIN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Enterred OKC_DELIVERABLE_PROCESS_PVT.RestoreDelsToPrevDocVers');
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'p_bus_doc_id: '|| to_char(p_bus_doc_id));
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'p_bus_doc_version: '|| to_char(p_bus_doc_version));
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'p_bus_doc_type: '|| p_bus_doc_type);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'p_prev_del_active: '|| p_prev_del_active);
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'p_revert_dels: '|| p_revert_dels);
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call( l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- If the flag p_revert_dels is "N" then this API is called to delete
  -- deliverables with business document version of -99
  IF (p_revert_dels = 'N') THEN

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
          'Deleting deliverables with document version equal to -99');
    END IF;

    delete_deliverables(p_api_version     => 1.0,
                        p_init_msg_list   => FND_API.G_FALSE,
                        p_doc_id          => p_bus_doc_id,
                        p_doc_type        => p_bus_doc_type,
                        p_doc_version     => -99,
                        x_return_status   => x_return_status,
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data);

    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------------------

  ELSE
    -- If the flag p_revert_dels is not "N" then this API is called to delete
    -- the -99 deliverables and then recreate those deliverables using previous
    -- business document version's deliverables.
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
           'Getting ids of the deliverables with document version number equal to -99');
    END IF;

    OPEN cur_vers_del_csr;
    FETCH cur_vers_del_csr BULK COLLECT INTO cur_vers_del;
    CLOSE cur_vers_del_csr;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
         'Deleting deliverables with document version equal to -99');
    END IF;

    delete_deliverables(p_api_version     => 1.0,
                        p_init_msg_list   => FND_API.G_FALSE,
                        p_doc_id          => p_bus_doc_id,
                        p_doc_type        => p_bus_doc_type,
                        p_doc_version     => -99,
                        x_return_status   => x_return_status,
                        x_msg_count       => x_msg_count,
                        x_msg_data        => x_msg_data);

    -----------------------------------------------------
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------------------------

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Getting deliverables of the previous version');
    END IF;

    OPEN  prev_vers_del_csr;
    FETCH prev_vers_del_csr BULK COLLECT INTO prev_vers_del;
    CLOSE prev_vers_del_csr;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'prev_vers_del.COUNT ' || prev_vers_del.COUNT);
      FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'cur_vers_del.COUNT ' || cur_vers_del.COUNT);
    END IF;

    IF (prev_vers_del.COUNT > 0) THEN

      -- Iterate through the the array of previous business document version deliverables
      -- and clone each row in the array by inserting one deliverable with -99
      -- business document version. So that the state of the deliverables will
      -- be reverted back to that state before creating the new version of the business document
      FOR i IN prev_vers_del.FIRST..NVL(prev_vers_del.LAST, -1) LOOP

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                    'prev_vers_del(' || i || ').original_deliverable_id ' || prev_vers_del(i).original_deliverable_id);
        END IF;

        -- Iterate through the array of -99 deliverables to get corresponding deliverable id of the
        -- deliverable in the context using their original deliverable id
        -- This deliverable id will be used as id for the deliverable being inserted, so that we don't
        -- loose the deliverable id and also to ensure data integrity
    IF (cur_vers_del.COUNT > 0) THEN

        FOR j IN cur_vers_del.FIRST..NVL(cur_vers_del.LAST, -1) LOOP

            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                   'cur_vers_del(' || j || ').original_deliverable_id ' || cur_vers_del(j).original_deliverable_id);
            END IF;

            -- Original deliverable id is used to find corresponding deliverable with -99 version of
            -- the deliverable in the context
            IF (cur_vers_del(j).original_deliverable_id = prev_vers_del(i).original_deliverable_id) THEN
              l_deliverable_id := cur_vers_del(j).deliverable_id;

              IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                  FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                     'l_deliverable_id ' || l_deliverable_id);
              END IF;

              EXIT;
            END IF;

        END LOOP;
	END IF;

        -- Fix for bug 13518546 start
        IF(l_deliverable_id IS NULL) THEN
          OPEN cur_del_doc_type(prev_vers_del(i).original_deliverable_id);
            FETCH cur_del_doc_type INTO l_business_document_type;
          CLOSE cur_del_doc_type;
            IF(l_business_document_type='TEMPLATE') THEN
                select okc_deliverable_id_s.nextval INTO l_deliverable_id from dual;
             ELSE
              l_deliverable_id:=prev_vers_del(i).original_deliverable_id;
             END IF;
        END IF ;
        -- Fix for bug 13518546 end

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
              'Setting default values for some of the columns');
        END IF;

        -- Set default value for some of the columns, which are resolved during amendment process
        -- and whose values are supposed to be NULL or some default value for the current
        -- business document version deliverables i.e. -99 version deliverables
        prev_vers_del(i).actual_due_date := NULL;
        prev_vers_del(i).object_version_number := 0;
        prev_vers_del(i).start_event_date := NULL;
        prev_vers_del(i).end_event_date := NULL;

        IF (p_prev_del_active = 'Y') THEN

        -- Set default value for some more columns as we're using deliverable definitions
        -- of the previous business document version which might have activated and some of
        -- the columns are populated, which are supposed to be either NULL or some default
        -- value for the current business document version deliverables i.e. -99 version deliverables
          prev_vers_del(i).prior_notification_id := NULL;
          prev_vers_del(i).amendment_operation := NULL;
          prev_vers_del(i).completed_notification_id := NULL;
          prev_vers_del(i).overdue_notification_id := NULL;
          prev_vers_del(i).escalation_notification_id := NULL;
          prev_vers_del(i).manage_yn := 'N';
          prev_vers_del(i).deliverable_status := 'INACTIVE';
          prev_vers_del(i).summary_amend_operation_code := NULL;
          prev_vers_del(i).last_amendment_date := NULL;

        END IF;


        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Inserting a Deliverable with deliverable id ' || l_deliverable_id);
        END IF;

        -- Insert a row into okc_deliverables with id of the deleted deliverable
        -- and with other values with its corresponding previous version deliverable
        INSERT INTO okc_deliverables (
                  deliverable_id,
                  business_document_type,
                  business_document_id,
                  business_document_number,
                  deliverable_type,
                  responsible_party,
                  internal_party_contact_id,
                  external_party_contact_id,
                  deliverable_name,
                  description,
                  comments,
                  display_sequence,
                  fixed_due_date_yn,
                  actual_due_date,
                  print_due_date_msg_name,
                  recurring_yn,
                  notify_prior_due_date_value,
                  notify_prior_due_date_uom,
                  notify_prior_due_date_yn,
                  notify_completed_yn,
                  notify_overdue_yn,
                  notify_escalation_yn,
                  notify_escalation_value,
                  notify_escalation_uom,
                  escalation_assignee,
                  amendment_operation,
                  prior_notification_id,
                  amendment_notes,
                  completed_notification_id,
                  overdue_notification_id,
                  escalation_notification_id,
                  language,
                  original_deliverable_id,
                  requester_id,
                  external_party_id,
                  recurring_del_parent_id,
                  business_document_version,
                  relative_st_date_duration,
                  relative_st_date_uom,
                  relative_st_date_event_id,
                  relative_end_date_duration,
                  relative_end_date_uom,
                  relative_end_date_event_id,
                  repeating_day_of_month,
                  repeating_day_of_week,
                  repeating_frequency_uom,
                  repeating_duration,
                  fixed_start_date,
                  fixed_end_date,
                  manage_yn,
                  internal_party_id,
                  deliverable_status,
                  status_change_notes,
                  created_by,
                  creation_date,
                  last_updated_by,
                  last_update_date,
                  last_update_login,
                  object_version_number,
                  attribute_category,
                  attribute1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7,
                  attribute8,
                  attribute9,
                  attribute10,
                  attribute11,
                  attribute12,
                  attribute13,
                  attribute14,
                  attribute15,
                  disable_notifications_yn,
                  last_amendment_date,
                  business_document_line_id,
                  external_party_site_id,
                  start_event_date,
                  end_event_date,
                  summary_amend_operation_code,
                  external_party_role,
                  pay_hold_prior_due_date_value,
                  pay_hold_prior_due_date_uom,
                  pay_hold_prior_due_date_yn,
                  pay_hold_overdue_yn
                  )
        VALUES( l_deliverable_id,
                prev_vers_del(i).business_document_type,
                prev_vers_del(i).business_document_id,
                prev_vers_del(i).business_document_number,
                prev_vers_del(i).deliverable_type,
                prev_vers_del(i).responsible_party,
                prev_vers_del(i).internal_party_contact_id,
                prev_vers_del(i).external_party_contact_id,
                prev_vers_del(i).deliverable_name,
                prev_vers_del(i).description,
                prev_vers_del(i).comments,
                prev_vers_del(i).display_sequence,
                prev_vers_del(i).fixed_due_date_yn,
                prev_vers_del(i).actual_due_date,
                prev_vers_del(i).print_due_date_msg_name,
                prev_vers_del(i).recurring_yn,
                prev_vers_del(i).notify_prior_due_date_value,
                prev_vers_del(i).notify_prior_due_date_uom,
                prev_vers_del(i).notify_prior_due_date_yn,
                prev_vers_del(i).notify_completed_yn,
                prev_vers_del(i).notify_overdue_yn,
                prev_vers_del(i).notify_escalation_yn,
                prev_vers_del(i).notify_escalation_value,
                prev_vers_del(i).notify_escalation_uom,
                prev_vers_del(i).escalation_assignee,
                prev_vers_del(i).amendment_operation,
                prev_vers_del(i).prior_notification_id,
                prev_vers_del(i).amendment_notes,
                prev_vers_del(i).completed_notification_id,
                prev_vers_del(i).overdue_notification_id,
                prev_vers_del(i).escalation_notification_id,
                prev_vers_del(i).language,
                prev_vers_del(i).original_deliverable_id,
                prev_vers_del(i).requester_id,
                prev_vers_del(i).external_party_id,
                prev_vers_del(i).recurring_del_parent_id,
                -99,
                prev_vers_del(i).relative_st_date_duration,
                prev_vers_del(i).relative_st_date_uom,
                prev_vers_del(i).relative_st_date_event_id,
                prev_vers_del(i).relative_end_date_duration,
                prev_vers_del(i).relative_end_date_uom,
                prev_vers_del(i).relative_end_date_event_id,
                prev_vers_del(i).repeating_day_of_month,
                prev_vers_del(i).repeating_day_of_week,
                prev_vers_del(i).repeating_frequency_uom,
                prev_vers_del(i).repeating_duration,
                prev_vers_del(i).fixed_start_date,
                prev_vers_del(i).fixed_end_date,
                prev_vers_del(i).manage_yn,
                prev_vers_del(i).internal_party_id,
                prev_vers_del(i).deliverable_status,
                prev_vers_del(i).status_change_notes,
                prev_vers_del(i).created_by,
                prev_vers_del(i).creation_date,
                prev_vers_del(i).last_updated_by,
                prev_vers_del(i).last_update_date,
                prev_vers_del(i).last_update_login,
                prev_vers_del(i).object_version_number,
                prev_vers_del(i).attribute_category,
                prev_vers_del(i).attribute1,
                prev_vers_del(i).attribute2,
                prev_vers_del(i).attribute3,
                prev_vers_del(i).attribute4,
                prev_vers_del(i).attribute5,
                prev_vers_del(i).attribute6,
                prev_vers_del(i).attribute7,
                prev_vers_del(i).attribute8,
                prev_vers_del(i).attribute9,
                prev_vers_del(i).attribute10,
                prev_vers_del(i).attribute11,
                prev_vers_del(i).attribute12,
                prev_vers_del(i).attribute13,
                prev_vers_del(i).attribute14,
                prev_vers_del(i).attribute15,
                prev_vers_del(i).disable_notifications_yn,
                prev_vers_del(i).last_amendment_date,
                prev_vers_del(i).business_document_line_id,
                prev_vers_del(i).external_party_site_id,
                prev_vers_del(i).start_event_date,
                prev_vers_del(i).end_event_date,
                prev_vers_del(i).summary_amend_operation_code,
                prev_vers_del(i).external_party_role,
                prev_vers_del(i).pay_hold_prior_due_date_value,
                prev_vers_del(i).pay_hold_prior_due_date_uom,
                prev_vers_del(i).pay_hold_prior_due_date_yn,
                prev_vers_del(i).pay_hold_overdue_yn);

        IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Copying attachments from deliverable with id ' || to_char(prev_vers_del(i).deliverable_id) || ' to ' || to_char(l_deliverable_id));
        END IF;

        -- Copy attachments from prev version deliverable to current version deliverable
        fnd_attached_documents2_pkg.copy_attachments(
                          X_from_entity_name  =>  G_ENTITY_NAME,
                          X_from_pk1_value    =>  to_char(prev_vers_del(i).deliverable_id),
                          X_to_entity_name    =>  G_ENTITY_NAME,
                          X_to_pk1_value      =>  to_char(l_deliverable_id),
                          X_CREATED_BY        =>  FND_GLOBAL.User_id,
                          X_LAST_UPDATE_LOGIN =>  Fnd_Global.Login_Id);

      -- Fix for bug 13518546 start
        l_deliverable_id := NULL;
      -- Fix for bug 13518546 end

      END LOOP;

    END IF;

    IF (p_prev_del_active = 'N') THEN

      -- Since the deliverables of the current contract are not yet activated
      --we can safely delete those deliverables with previous business document version number
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                'Deliverables of the current contract are not activated yet');
      END IF;

      -- Delete the deliverables created with previous business document version number
      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
             'Deleting deliverables with document version equal to' || to_char(p_bus_doc_version - 1));
      END IF;

      delete_deliverables(p_api_version     => 1.0,
                          p_init_msg_list   => FND_API.G_FALSE,
                          p_doc_id          => p_bus_doc_id,
                          p_doc_type        => p_bus_doc_type,
                          p_doc_version     => p_bus_doc_version - 1,
                          x_return_status   => x_return_status,
                          x_msg_count       => x_msg_count,
                          x_msg_data        => x_msg_data);

      -----------------------------------------------------
      IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    --------------------------------------------------------

    END IF; -- End of (p_prev_del_active = 'N')

  END IF; -- End of (p_revert_dels = 'N')



  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Leaving OKC_DELIVERABLE_PROCESS_PVT.RestoreDelsToPrevDocVers');
  END IF;


EXCEPTION

  WHEN OTHERS THEN

    IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_UNEXPECTED ,g_module||l_api_name,'Leaving OKC_DELIVERABLE_PROCESS_PVT.RestoreDelsToPrevDocVers with G_EXC_UNEXPECTED_ERROR');
    END IF;

    IF prev_vers_del_csr %ISOPEN THEN
      CLOSE prev_vers_del_csr;
    END IF;

    IF cur_vers_del_csr %ISOPEN THEN
      CLOSE cur_vers_del_csr;
    END IF;

    x_return_status := G_RET_STS_UNEXP_ERROR;

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get(
      p_count =>  x_msg_count,
      p_data  =>  x_msg_data
    );


END deleteDeliverables;


/**************************/

END OKC_DELIVERABLE_PROCESS_PVT;

/
