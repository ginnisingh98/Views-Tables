--------------------------------------------------------
--  DDL for Package Body ENG_WORKFLOW_NTF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_WORKFLOW_NTF_UTIL" AS
/* $Header: ENGUNTFB.pls 120.2 2006/02/18 20:08:46 mkimizuk noship $ */

    G_PKG_NAME  CONSTANT VARCHAR2(30):= 'Eng_Workflow_Ntf_Util' ;

    -- Seeded workflow notification messages
    G_REQUEST_COMMENT_MSG      CONSTANT VARCHAR2(30) := 'REQUEST_COMMENT_MSG' ;
    G_ASSIGN_TO_MSG            CONSTANT VARCHAR2(30) := 'ASSIGN_TO_MSG' ;
    G_PRIORITY_CHANGE_MSG      CONSTANT VARCHAR2(30) := 'PRIORITY_CHANGE_MSG' ;
    G_STATUS_CHANGE_MSG        CONSTANT VARCHAR2(30) := 'STATUS_CHANGE_MSG' ;
    G_REASSIGNMENT_MSG         CONSTANT VARCHAR2(30) := 'REASSIGNMENT_MSG';
    G_FYI_NEW_CHANGE_MSG       CONSTANT VARCHAR2(30) := 'FYI_NEW_CHANGE_MSG';
    G_APPR_STATUS_CHANGE_MSG   CONSTANT VARCHAR2(30) := 'APPR_STATUS_CHANGE_MSG' ;
    G_FYI_CHANGE_MSG           CONSTANT VARCHAR2(30) := 'FYI_CHANGE_MSG';
    G_REQUEST_APPROVAL_MSG     CONSTANT VARCHAR2(30) := 'REQUEST_APPROVAL_MSG' ;
    G_ABORT_ROUTE_MSG          CONSTANT VARCHAR2(30) := 'ABORT_ROUTE_MSG';
    G_ABORT_STEP_MSG           CONSTANT VARCHAR2(30) := 'ABORT_STEP_MSG';

/********************************************************************
* API Type      : Local APIs
* Purpose       : Those APIs are private
*********************************************************************/
FUNCTION GetWFMessageName ( p_nid IN NUMBER )
 RETURN VARCHAR2
IS

    CURSOR c_msg  (p_nid NUMBER)
    IS

        SELECT message_name
        FROM   WF_NOTIFICATIONS
        WHERE  notification_id = p_nid ;

        l_msg_name VARCHAR2(30) ;

BEGIN

    FOR l_msg_rec IN c_msg (p_nid)
    LOOP

        l_msg_name := l_msg_rec.message_name ;

    END LOOP ;

    RETURN l_msg_name ;

END GetWFMessageName ;


PROCEDURE GetMessageMapping
(  p_wf_msg_name        IN  VARCHAR2
 , x_subject_msg_name   OUT NOCOPY VARCHAR2
 , x_text_body_msg_name OUT NOCOPY VARCHAR2
 , x_html_body_msg_name OUT NOCOPY VARCHAR2
)
IS

BEGIN


    IF  p_wf_msg_name =  G_FYI_NEW_CHANGE_MSG
    THEN

        x_subject_msg_name   := 'ENG_FYI_NEW_CHANGE_MSG_S' ;
        x_text_body_msg_name := 'ENG_FYI_NEW_CHANGE_MSG_TB' ;
        x_html_body_msg_name := 'ENG_FYI_NEW_CHANGE_MSG_HB' ;


    ELSIF  p_wf_msg_name =  G_REQUEST_COMMENT_MSG
    THEN

        x_subject_msg_name   := 'ENG_REQUEST_COMMENT_MSG_S' ;
        x_text_body_msg_name := 'ENG_REQUEST_COMMENT_MSG_TB' ;
        x_html_body_msg_name := 'ENG_REQUEST_COMMENT_MSG_HB' ;


    ELSIF p_wf_msg_name =  G_ASSIGN_TO_MSG
    THEN

        x_subject_msg_name   := 'ENG_ASSIGN_TO_MSG_S' ;
        x_text_body_msg_name := 'ENG_ASSIGN_TO_MSG_TB' ;
        x_html_body_msg_name := 'ENG_ASSIGN_TO_MSG_HB' ;

    ELSIF p_wf_msg_name =  G_PRIORITY_CHANGE_MSG
    THEN

        x_subject_msg_name   := 'ENG_PRIORITY_CHANGE_MSG_S' ;
        x_text_body_msg_name := 'ENG_PRIORITY_CHANGE_MSG_TB' ;
        x_html_body_msg_name := 'ENG_PRIORITY_CHANGE_MSG_HB' ;

    ELSIF p_wf_msg_name =  G_STATUS_CHANGE_MSG
    THEN

        x_subject_msg_name   := 'ENG_STATUS_CHANGE_MSG_S' ;
        x_text_body_msg_name := 'ENG_STATUS_CHANGE_MSG_TB' ;
        x_html_body_msg_name := 'ENG_STATUS_CHANGE_MSG_HB' ;

    ELSIF p_wf_msg_name =  G_REASSIGNMENT_MSG
    THEN

        x_subject_msg_name   := 'ENG_REASSIGNMENT_MSG_S' ;
        x_text_body_msg_name := 'ENG_REASSIGNMENT_MSG_TB' ;
        x_html_body_msg_name := 'ENG_REASSIGNMENT_MSG_HB' ;

    END IF ;


END GetMessageMapping ;


FUNCTION CheckToDoNtf ( p_nid IN NUMBER )
RETURN BOOLEAN
IS

    CURSOR c_ntf  (p_nid NUMBER)
    IS

       SELECT 'This is To Do Ntf'
       FROM   WF_NOTIFICATIONS wfn
       WHERE  EXISTS (SELECT null
                      FROM  WF_MESSAGE_ATTRIBUTES wfma
                      WHERE wfma.subtype = 'RESPOND'
                      AND   wfma.message_name = wfn.message_name
                      AND   wfma.message_type = wfn.message_type
                      )
       AND    wfn.notification_id = p_nid ;

    To_Do_Ntf  BOOLEAN := FALSE ;

BEGIN

    FOR l_ntf_rec IN c_ntf (p_nid)
    LOOP

        To_Do_Ntf := TRUE ;

    END LOOP ;

    RETURN To_Do_Ntf ;

END CheckToDoNtf ;


FUNCTION WrapText ( p_text     IN VARCHAR2)
RETURN VARCHAR2
IS

    WRAP_LENGTH   CONSTANT NUMBER := 120 ;
    BR_TAG        CONSTANT VARCHAR2(4) := '<BR>' ;

    l_start_point          NUMBER ;
    l_text_length          NUMBER ;
    l_br_idx               NUMBER ;
    l_prev_text            VARCHAR2(32000) ;
    l_rest_text            VARCHAR2(32000) ;
    x_text                 VARCHAR2(32000) ;


BEGIN
    -- Initialize
    l_start_point := 1 ;
    x_text        := p_text ;

    -- if p_text is null, return
    IF ( x_text IS NULL OR
        LENGTH(x_text) <= WRAP_LENGTH )
    THEN
        return x_text ;
    END IF;

    -- Wrap Text by WRAP_LENGTH
    LOOP

        -- Get current text length and find <BR>
        l_text_length := LENGTH(x_text) ;
        l_br_idx      := INSTR(UPPER(x_text), '<BR>' , l_start_point ) - 1 ;

        IF (l_br_idx < 0 ) THEN
           l_br_idx := l_text_length ;
        END IF ;

        EXIT WHEN (l_text_length - l_start_point)<= WRAP_LENGTH  ;

        IF l_br_idx > ( l_start_point + WRAP_LENGTH - 1 )  THEN

            l_prev_text :=  SUBSTR( x_text, 1, l_start_point + WRAP_LENGTH - 1) ;

            l_rest_text :=  SUBSTR( x_text
                                  , l_start_point + WRAP_LENGTH
                                  , l_text_length - l_start_point + WRAP_LENGTH ) ;
            l_start_point := LENGTH( (l_prev_text ||  BR_TAG ) ) + 1 ;

            -- 32000 is Max
            x_text := substrb( (l_prev_text || BR_TAG || l_rest_text), 1, 32000) ;

        ELSE

            l_start_point := l_br_idx  + LENGTH(BR_TAG) + 1  ;

        END IF ;

    END LOOP ;

    return x_text ;

END WrapText ;


FUNCTION ConvertText ( p_text     IN VARCHAR2)
RETURN VARCHAR2
IS

   l_start_point NUMBER ;
   l_httpidx     NUMBER ;
   l_bridx       NUMBER ;
   l_spaceidx    NUMBER ;
   l_text_length NUMBER ;

   x_text        VARCHAR2(32000) ;
   l_prev_text   VARCHAR2(32000) ;
   l_conv_html   VARCHAR2(32000) ;
   l_rest_text   VARCHAR2(32000) ;

BEGIN

    -- Initialize
    l_start_point := 1 ;
    x_text        := p_text ;

    -- if p_text is null, return
    IF x_text IS NULL THEN
       return x_text ;
    END IF;

    -- Replace New Line to <br> Tag
    x_text := REPLACE(x_Text, FND_GLOBAL.NEWLINE, '<br>') ;

    -- Convert_Http_Tag
    LOOP
        -- Get current text length and find http
        l_text_length := LENGTH(x_text) ;
        l_httpidx     := INSTR(UPPER(x_text), 'HTTP://' , l_start_point ) - 1 ;

        IF (l_httpidx < 0 ) THEN
            l_httpidx := INSTR(UPPER(x_text), 'HTTPS://' , l_start_point ) - 1 ;
        END IF ;

        -- Exists when no http or https is found after start_point
        EXIT WHEN  l_httpidx < 0 ;


        l_bridx    := INSTR(UPPER(x_text), '<BR>' , l_httpidx) - 1 ;
        l_spaceidx := INSTR(UPPER(x_text), ' ' , l_httpidx) - 1 ;

        IF (l_bridx > l_httpidx  AND l_bridx < l_spaceidx) THEN
            l_spaceidx := l_bridx ;

        ELSIF (l_spaceidx < l_httpidx  AND l_bridx > l_httpidx ) THEN
             l_spaceidx := l_bridx;

        ELSIF (l_spaceidx < l_httpidx AND l_bridx < l_httpidx ) THEN
            l_spaceidx := l_text_length ;

        END IF ;

        l_prev_text :=  SUBSTR( x_text, 1, l_httpidx ) ;

        l_conv_html :=  '<br><a href="'
                    || SUBSTR( x_text, l_httpidx + 1, l_spaceidx - l_httpidx  )
                    || '">' || WrapText(SUBSTR( x_text, l_httpidx + 1, l_spaceidx - l_httpidx)) || '</a>' ;
        l_rest_text :=  SUBSTR( x_text, l_spaceidx + 1, l_text_length - l_spaceidx ) ;


        l_start_point := LENGTH( (l_prev_text ||  l_conv_html) ) + 1 ;

        -- 32000 is max
        x_text := substrb( (l_prev_text || l_conv_html || l_rest_text), 1, 32000) ;

    END LOOP ;

    return x_text ;

END ConvertText ;


PROCEDURE GetMessageAttributes
(  document_id                 IN  VARCHAR2
 , display_type                IN  VARCHAR2
 , x_mesg_attribute_rec        OUT NOCOPY Change_Mesg_Attribute_Rec_Type
)
IS

    l_index1                    NUMBER;
    l_index2                    NUMBER;

    l_subject_msg_name          VARCHAR2(30) ;
    l_text_body_msg_name        VARCHAR2(30) ;
    l_html_body_msg_name        VARCHAR2(30) ;

    l_persondetail_url          VARCHAR2(480) ;

    /*
    l_headline_msg              VARCHAR2(2000) ;
    l_content_msg               VARCHAR2(2000) ;
    l_how_to_respond_msg        VARCHAR2(2000) ;
    l_detail_link_msg           VARCHAR2(2000) ;
    l_fyi_only_msg              VARCHAR2(2000) ;
    l_thankyou_msg              VARCHAR2(2000) ;
    l_ntf_detail_url            VARCHAR2(2000) ;
    l_detail_url                VARCHAR2(1000);
    */

BEGIN

    --
    -- Get item_type, item_key, and notification id
    -- Format is <ITEMTYPE>:<ITEMKEY>:<NTF_ID>
    --
    l_index1   := instr(document_id, ':');
    l_index2   := instr(document_id, ':', 1, 2);

    x_mesg_attribute_rec.item_type := substr(document_id, 1, l_index1 - 1);
    x_mesg_attribute_rec.item_key := substr(document_id, l_index1 + 1, l_index2 - l_index1 -1);

    x_mesg_attribute_rec.notification_id := TO_NUMBER(substr(document_id, l_index2 + 1));


    -- Get Change Object Identifier
    Eng_Workflow_Util.GetChangeObject
    (   p_item_type         => x_mesg_attribute_rec.item_type
     ,  p_item_key          => x_mesg_attribute_rec.item_key
     ,  x_change_id         => x_mesg_attribute_rec.change_id
     ,  x_change_notice     => x_mesg_attribute_rec.change_notice
     ,  x_organization_id   => x_mesg_attribute_rec.organization_id
    ) ;


    begin
        -- Get Change Line Object Identifier
        Eng_Workflow_Util.GetChangeLineObject
        (   p_item_type         => x_mesg_attribute_rec.item_type
         ,  p_item_key          => x_mesg_attribute_rec.item_key
         ,  x_change_line_id    => x_mesg_attribute_rec.change_line_id
        ) ;
    exception
       when others then
           null ;
    end ;

    --
    --  Get Workflow Message Name for this notification
    --
    x_mesg_attribute_rec.wf_msg_name := GetWFMessageName(p_nid => x_mesg_attribute_rec.notification_id) ;

    --
    -- Get FND Message Names for HTML Body associated with Eng Workflow Message Name
    --
    GetMessageMapping(  p_wf_msg_name        => x_mesg_attribute_rec.wf_msg_name
                      , x_subject_msg_name   => l_subject_msg_name
                      , x_text_body_msg_name => l_text_body_msg_name
                      , x_html_body_msg_name => l_html_body_msg_name
                     ) ;

    -- Get Host URL
    Eng_Workflow_Util.GetHostURL
    (  p_item_type         => x_mesg_attribute_rec.item_type
    ,  p_item_key          => x_mesg_attribute_rec.item_key
    ,  x_host_url          => x_mesg_attribute_rec.host_url
    ) ;

    -- Get Style Sheet
    Eng_Workflow_Util.GetStyleSheet
    (  p_item_type         => x_mesg_attribute_rec.item_type
    ,  p_item_key          => x_mesg_attribute_rec.item_key
    ,  x_style_sheet       => x_mesg_attribute_rec.style_sheet
    ) ;


    -- Get Workflow Change Object Info
    Eng_Workflow_Util.GetWFChangeObjectInfo
    ( p_item_type               => x_mesg_attribute_rec.item_type
    , p_item_key                => x_mesg_attribute_rec.item_key
    , x_change_name             => x_mesg_attribute_rec.change_name
    , x_description             => x_mesg_attribute_rec.description
    , x_change_status           => x_mesg_attribute_rec.change_status
    , x_approval_status         => x_mesg_attribute_rec.approval_status
    , x_priority                => x_mesg_attribute_rec.priority
    , x_reason                  => x_mesg_attribute_rec.reason
    , x_change_managemtent_type => x_mesg_attribute_rec.change_management_type
    , x_change_order_type       => x_mesg_attribute_rec.change_order_type
    , x_eco_department          => x_mesg_attribute_rec.eco_department
    , x_assignee                => x_mesg_attribute_rec.assignee
    , x_assignee_company        => x_mesg_attribute_rec.assignee_company
    ) ;


    IF x_mesg_attribute_rec.change_line_id IS NOT NULL AND
       x_mesg_attribute_rec.change_line_id > 0
    THEN

        -- Get Change Line Object Info
        Eng_Workflow_Util.GetWFChangeLineObjectInfo
        ( p_item_type               => x_mesg_attribute_rec.item_type
        , p_item_key                => x_mesg_attribute_rec.item_key
        , x_line_sequence_number    => x_mesg_attribute_rec.line_sequence_number
        , x_line_name               => x_mesg_attribute_rec.line_name
        , x_line_description        => x_mesg_attribute_rec.line_description
        , x_line_status             => x_mesg_attribute_rec.line_status
        , x_line_assignee           => x_mesg_attribute_rec.line_assignee
        , x_line_assignee_company   => x_mesg_attribute_rec.line_assignee_company
        ) ;

        Eng_Workflow_Util.GetChangeLineItemSubjectInfo
        (  p_change_id              => x_mesg_attribute_rec.change_id
         , p_change_line_id         => x_mesg_attribute_rec.change_line_id
         , x_organization_id        => x_mesg_attribute_rec.item_organization_id
         , x_item_id                => x_mesg_attribute_rec.item_id
         , x_item_name              => x_mesg_attribute_rec.item_name
         , x_item_revision_id       => x_mesg_attribute_rec.item_revision_id
         , x_item_revision          => x_mesg_attribute_rec.item_revision
         , x_item_revision_label    => x_mesg_attribute_rec.item_revision_label
        ) ;

    ELSE

        Eng_Workflow_Util.GetChangeItemSubjectInfo
        (  p_change_id              => x_mesg_attribute_rec.change_id
         , x_organization_id        => x_mesg_attribute_rec.item_organization_id
         , x_item_id                => x_mesg_attribute_rec.item_id
         , x_item_name              => x_mesg_attribute_rec.item_name
         , x_item_revision_id       => x_mesg_attribute_rec.item_revision_id
         , x_item_revision          => x_mesg_attribute_rec.item_revision
         , x_item_revision_label    => x_mesg_attribute_rec.item_revision_label
        ) ;


    END IF ;

    begin

    -- Get Action Id
    Eng_Workflow_Util.GetActionId
    (  p_item_type         => x_mesg_attribute_rec.item_type
    ,  p_item_key          => x_mesg_attribute_rec.item_key
    ,  x_action_id         => x_mesg_attribute_rec.action_id
    ) ;

    exception
       when others then
           null ;
    end ;


    IF  x_mesg_attribute_rec.action_id IS NOT NULL  THEN

        Eng_Workflow_Util.GetActionInfo
        ( p_action_id                 => x_mesg_attribute_rec.action_id
        , x_action_desc               => x_mesg_attribute_rec.action_desc
        , x_action_party_id           => x_mesg_attribute_rec.action_party_id
        , x_action_party_name         => x_mesg_attribute_rec.action_party_name
        , x_action_party_company_name => x_mesg_attribute_rec.action_party_company
        ) ;


        l_persondetail_url := '/ego/party/EgoPersonDetail.jsp?partyPersonId='
                               || to_char(x_mesg_attribute_rec.action_party_id)
                               || '&subTabPos=0&app=proddev'  ;

    END IF ;


    begin

    -- Get Route Id
    Eng_Workflow_Util.GetRouteId
    (  p_item_type         => x_mesg_attribute_rec.item_type
    ,  p_item_key          => x_mesg_attribute_rec.item_key
    ,  x_route_id          => x_mesg_attribute_rec.route_id
    ) ;

    exception
       when others then
           null ;
    end ;



    IF  x_mesg_attribute_rec.route_id IS NOT NULL  THEN

        NULL ;
        --
        -- Eng_Workflow_Util.GetRouteInfo
        -- (  p_route_id    => x_mesg_attribute_rec.route_id
        -- , x_XXXX         => x_mesg_attribute_rec.XXX
        -- ) ;
        --

    END IF ;

    begin

    -- Get Step Id
    Eng_Workflow_Util.GetRouteStepId
    (  p_item_type         => x_mesg_attribute_rec.item_type
    ,  p_item_key          => x_mesg_attribute_rec.item_key
    ,  x_route_step_id     => x_mesg_attribute_rec.step_id
    ) ;

    exception
       when others then
           null ;
    end ;


    IF  x_mesg_attribute_rec.step_id  IS NOT NULL  THEN

        Eng_Workflow_Util.GetRouteStepInfo
        ( p_route_step_id        => x_mesg_attribute_rec.step_id
        , x_step_seq_num         => x_mesg_attribute_rec.step_seq_num
        , x_required_date        => x_mesg_attribute_rec.required_date
        , x_condition_type       => x_mesg_attribute_rec.condition_type
        , x_step_instrunction    => x_mesg_attribute_rec.step_instruction
        ) ;


    END IF ;


    /************************************************************************
    -- HTML Message
    -- Not supporting this because WF New Notification Detail Page Std
    -- Get Html Body  Message
    -- IF l_html_body_msg_name IS NOT NULL  THEN

        -- Headline Message
        FND_MESSAGE.SET_NAME('ENG', l_subject_msg_name) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_MGMT_TYPE', x_change_management_type) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_NOTICE', x_change_notice ) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_NAME', x_change_name) ;

        IF x_wf_msg_name = G_PRIORITY_CHANGE_MSG THEN

            FND_MESSAGE.SET_TOKEN('PRIORITY', x_priority) ;

        ELSIF x_wf_msg_name = G_STATUS_CHANGE_MSG THEN

            FND_MESSAGE.SET_TOKEN('STATUS', x_change_status ) ;

        ELSIF x_wf_msg_name = G_REASSIGNMENT_MSG THEN

             FND_MESSAGE.SET_TOKEN('ASSIGNEE_PARTY_NAME', x_assignee ) ;

        END IF ;

        l_headline_msg :=  FND_MESSAGE.GET ;

        -- Content Message
        FND_MESSAGE.SET_NAME('ENG', l_html_body_msg_name) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_MGMT_TYPE', x_change_management_type) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_NOTICE', x_change_notice ) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_NAME', x_change_name) ;
        FND_MESSAGE.SET_TOKEN('BY_PERSON_NAME', x_action_party_name) ;
        FND_MESSAGE.SET_TOKEN('BY_COMPANY_NAME', x_action_party_company) ;

        IF x_wf_msg_name = G_PRIORITY_CHANGE_MSG THEN

            FND_MESSAGE.SET_TOKEN('PRIORITY', x_priority) ;

        ELSIF x_wf_msg_name = G_STATUS_CHANGE_MSG THEN

            FND_MESSAGE.SET_TOKEN('STATUS', x_change_status ) ;

        ELSIF x_wf_msg_name = G_REASSIGNMENT_MSG THEN

            FND_MESSAGE.SET_TOKEN('ASSIGNEE_PARTY_NAME', x_assignee ) ;
            FND_MESSAGE.SET_TOKEN('ASSIGNEE_COMPANY_NAME', x_assignee_company) ;

        END IF ;

        l_content_msg := FND_MESSAGE.GET ;

        -- How to respond or FYI instruction
        IF CheckToDoNtf(p_nid => x_nid ) THEN

            -- l_how_to_respond_msg
            -- This message is put on the ToDo Notifications
            -- TO DO Notifications :
            --
            -- Message : ENG_NTF_HOW_TO_RESPOND_NTF
            -- 'To respond to this notification by email, please select
            --  the link at the bottom of this email message.'

            FND_MESSAGE.SET_NAME('ENG', 'ENG_NTF_HOW_TO_RESP_HTML_MSG') ;
            FND_MESSAGE.SET_TOKEN('NTF_DETAIL_URL', x_ntf_detail_url) ;
            l_how_to_respond_msg :=  FND_MESSAGE.GET ;

        ELSE

            FND_MESSAGE.SET_NAME('ENG', 'ENG_NTF_FYI_INSTRUCTION') ;
            l_fyi_only_msg :=  FND_MESSAGE.GET ;

        END IF ;

        -- Detail Page Link Message
        -- l_detail_link_msg
        -- Message : ENG_CM_SEE_BELOW_DETAILS_NTF
        -- This message is put on every CM Workflow notification
        -- with detail page link
        -- 'You can go to the following URL to view the Change Request details.

        l_detail_url :=  wf_engine.GetItemAttrText
                                         (  x_item_type
                                          , x_item_key
                                          , 'CHANGE_DETAIL_PAGE_URL'
                                         ) ;

        FND_MESSAGE.SET_NAME('ENG', 'ENG_NTF_DETAIL_LINK_HTML_MSG') ;
        FND_MESSAGE.SET_TOKEN('CHANGE_MGMT_TYPE', x_change_management_type) ;
        FND_MESSAGE.SET_TOKEN('DETAIL_URL', l_detail_url) ;
        l_detail_link_msg :=  FND_MESSAGE.GET ;

        -- Thank you message
        -- l_thankyou_msg
        --
        -- message ENG_NTF_THANK_YOU
        -- 'Thank You.'
        FND_MESSAGE.SET_NAME('ENG', 'ENG_NTF_THANK_YOU') ;
        l_thankyou_msg  :=  FND_MESSAGE.GET ;

    END IF ;
    *************************************************************************/



    /************************************************************************
    -- TEXT Message
    -- Not supporting this because WF New Notification Detail Page Std
    -- Get Html Body  Message
    -- IF l_text_body_msg_name_body_msg_name IS NOT NULL  THEN

        -- Headline Message
        FND_MESSAGE.SET_NAME('ENG', l_subject_msg_name) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_MGMT_TYPE', l_change_management_type) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_NOTICE', l_change_notice ) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_NAME', l_change_name) ;

        IF l_wf_msg_name = G_PRIORITY_CHANGE_MSG THEN

            FND_MESSAGE.SET_TOKEN('PRIORITY', l_priority) ;

        ELSIF l_wf_msg_name = G_STATUS_CHANGE_MSG THEN

            FND_MESSAGE.SET_TOKEN('STATUS', l_change_status ) ;

        ELSIF l_wf_msg_name = G_REASSIGNMENT_MSG THEN

             FND_MESSAGE.SET_TOKEN('ASSIGNEE_PARTY_NAME', l_assignee ) ;

        END IF ;

        l_headline_msg :=  FND_MESSAGE.GET ;

        -- Content Message
        FND_MESSAGE.SET_NAME('ENG', l_text_body_msg_name) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_MGMT_TYPE', l_change_management_type) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_NOTICE', l_change_notice ) ;
        FND_MESSAGE.SET_TOKEN('CHANGE_NAME', l_change_name) ;
        FND_MESSAGE.SET_TOKEN('BY_PERSON_NAME', l_action_party_name) ;
        FND_MESSAGE.SET_TOKEN('BY_COMPANY_NAME', l_action_party_company) ;
        FND_MESSAGE.SET_TOKEN('ACTION_DESC', l_action_desc) ;

        IF l_wf_msg_name = G_PRIORITY_CHANGE_MSG THEN

            FND_MESSAGE.SET_TOKEN('PRIORITY', l_priority) ;

        ELSIF l_wf_msg_name = G_STATUS_CHANGE_MSG THEN

            FND_MESSAGE.SET_TOKEN('STATUS', l_change_status ) ;

        ELSIF l_wf_msg_name = G_REASSIGNMENT_MSG THEN

            FND_MESSAGE.SET_TOKEN('ASSIGNEE_PARTY_NAME', l_assignee ) ;
            FND_MESSAGE.SET_TOKEN('ASSIGNEE_COMPANY_NAME', l_assignee_company) ;

        END IF ;

        l_content_msg := FND_MESSAGE.GET ;

        -- How to respond or FYI instruction
        IF CheckToDoNtf(p_nid => l_nid ) THEN

            -- l_how_to_respond_msg
            -- This message is put on the ToDo Notifications
            -- TO DO Notifications :
            --
            -- Message : ENG_NTF_HOW_TO_RESPOND_NTF
            -- 'To respond to this notification by email, please select
            --  the link at the bottom of this email message.'

            FND_MESSAGE.SET_NAME('ENG', 'ENG_NTF_HOW_TO_RESP_MSG') ;
            FND_MESSAGE.SET_TOKEN('NTF_DETAIL_URL', l_ntf_detail_url) ;
            l_how_to_respond_msg :=  FND_MESSAGE.GET ;

        ELSE

            FND_MESSAGE.SET_NAME('ENG', 'ENG_NTF_FYI_INSTRUCTION') ;
            l_fyi_only_msg :=  FND_MESSAGE.GET ;

        END IF ;

        -- Detail Page Link Message
        -- l_detail_link_msg
        -- Message : ENG_CM_SEE_BELOW_DETAILS_NTF
        -- This message is put on every CM Workflow notification
        -- with detail page link
        -- 'You can go to the following URL to view the Change Request details.

        l_detail_url :=  wf_engine.GetItemAttrText
                                         (  l_item_type
                                          , l_item_key
                                          , 'CHANGE_DETAIL_PAGE_URL'
                                         ) ;

        FND_MESSAGE.SET_NAME('ENG', 'ENG_NTF_DETAIL_LINK_TEXT_MSG') ;
        FND_MESSAGE.SET_TOKEN('CHANGE_MGMT_TYPE', l_change_management_type) ;
        FND_MESSAGE.SET_TOKEN('DETAIL_URL', l_detail_url) ;
        l_detail_link_msg :=  FND_MESSAGE.GET ;

        -- Thank you message
        -- l_thankyou_msg
        --
        -- message ENG_NTF_THANK_YOU
        -- 'Thank You.'
        FND_MESSAGE.SET_NAME('ENG', 'ENG_NTF_THANK_YOU') ;
        l_thankyou_msg  :=  FND_MESSAGE.GET ;
    END IF ;
    *************************************************************************/




END GetMessageAttributes ;

FUNCTION GetChangeURLType
( p_change_id         IN     NUMBER) RETURN VARCHAR2
IS
   -- return SUMMARY or DETAIL
    l_change_url_type VARCHAR2(20) ;

    CURSOR  c_change_url_type  (p_change_id NUMBER)
    IS
        SELECT EngineeringChangeEO.change_id,
               EngineeringChangeEO.change_mgmt_type_code ,
               ChangeCategory.BASE_CHANGE_MGMT_TYPE_CODE
        FROM ENG_ENGINEERING_CHANGES EngineeringChangeEO,
             ENG_CHANGE_ORDER_TYPES ChangeCategory
        WHERE (  ChangeCategory.BASE_CHANGE_MGMT_TYPE_CODE = 'ATTACHMENT_APPROVAL'
              OR ChangeCategory.BASE_CHANGE_MGMT_TYPE_CODE = 'ATTACHMENT_REVIEW'
              OR NOT EXISTS (select null
                             from eng_change_type_applications type_appl
                             where type_appl.change_type_id = ChangeCategory.change_order_type_id
                             and type_appl.application_id = 431)
                             )
        AND ChangeCategory.type_classification = 'CATEGORY'
        AND ChangeCategory.change_mgmt_type_code = EngineeringChangeEO.change_mgmt_type_code
        AND EngineeringChangeEO.change_id = p_change_id  ;

BEGIN

    FOR l_rec IN c_change_url_type (p_change_id => p_change_id)
    LOOP
        l_change_url_type :=  'SUMMARY' ;
    END LOOP ;

    RETURN l_change_url_type ;

END GetChangeURLType ;



/********************************************************************
* API Type      : Private APIs
* Purpose       : Those APIs are private
*********************************************************************/

--  API name   : GetMessageTextBody
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Workflow PL/SQL CLOB Document API to get ntf text message body
--  Parameters : p_document_id           IN  VARCHAR2     Required
--                                       Format:
--                                       <wf item type>:<wf item key>:<&#NID>
--
PROCEDURE GetMessageTextBody
(  document_id    IN      VARCHAR2
 , display_type   IN      VARCHAR2
 , document       IN OUT  NOCOPY CLOB
 , document_type  IN OUT  NOCOPY VARCHAR2
)
IS
    l_mesg_attribute_rec        Change_Mesg_Attribute_Rec_Type ;
    l_index1                    NUMBER;
    l_index2                    NUMBER;

    l_doc                       VARCHAR2(32000) ;

    /*
    l_item_type                 VARCHAR2(8);
    l_item_key                  VARCHAR2(240) ;
    l_nid                       NUMBER;
    l_change_id                 NUMBER ;
    l_change_notice             VARCHAR2(10) ;
    l_organization_id           NUMBER ;
    l_organization_code         VARCHAR2(3) ;
    l_change_management_type    VARCHAR2(40) ;
    l_change_name               VARCHAR2(240) ;
    l_description               VARCHAR2(2000) ;
    l_change_order_type         VARCHAR2(10) ;
    l_organization_name         VARCHAR2(60) ;
    l_eco_department            VARCHAR2(60) ;
    l_change_status             VARCHAR2(80) ;
    l_approval_status           VARCHAR2(80) ;
    l_priority                  VARCHAR2(50) ;
    l_reason                    VARCHAR2(50) ;
    l_assignee                  VARCHAR2(360) ;
    l_assignee_company          VARCHAR2(360) ;

    l_action_id                 NUMBER ;
    l_action_party_id           NUMBER ;
    l_action_party_name         VARCHAR2(360) ;
    l_action_party_company      VARCHAR2(360) ;
    l_action_desc               VARCHAR2(5000) ;

    l_route_id                  NUMBER ;
    l_step_id                   NUMBER ;
    l_step_seq_num              NUMBER ;
    l_required_date             DATE ;
    l_condition_type            VARCHAR2(80) ;
    l_step_instruction          VARCHAR2(5000) ;

    l_wf_msg_name               VARCHAR2(30) ;
    l_subject_msg_name          VARCHAR2(30) ;
    l_text_body_msg_name        VARCHAR2(30) ;
    l_html_body_msg_name        VARCHAR2(30) ;

    l_host_url                  VARCHAR2(480) ;
    l_style_sheet               VARCHAR2(100) ;

    */

    /*
    l_headline_msg              VARCHAR2(2000) ;
    l_content_msg               VARCHAR2(2000) ;
    l_how_to_respond_msg        VARCHAR2(2000) ;
    l_detail_link_msg           VARCHAR2(2000) ;
    l_fyi_only_msg              VARCHAR2(2000) ;
    l_thankyou_msg              VARCHAR2(2000) ;
    l_persondetail_url          VARCHAR2(480) ;
    l_ntf_detail_url            VARCHAR2(2000) ;
    l_detail_url                VARCHAR2(1000);
    */

    NL VARCHAR2(1) ;

BEGIN

    -- Init Var
    NL := FND_GLOBAL.NEWLINE;


-- For Test/Debug
-- Eng_Workflow_Util.Open_Debug_Session( '/sqlcom/log/plm115d' , 'GetMessageTextBody' ) ;
-- Eng_Workflow_Util.Write_Debug('document id ' || document_id );
-- Eng_Workflow_Util.Write_Debug('display_type ' || display_type);
-- Eng_Workflow_Util.Write_Debug('document_type ' || document_type);


    -- Call GetMessageHTMLBody if display type is text/plain
    IF (display_type = WF_NOTIFICATION.DOC_HTML ) THEN

       GetMessageHTMLBody
       (  document_id    => document_id
        , display_type   => display_type
        , document       => document
        , document_type  => document_type
       ) ;

       RETURN ;

    END IF;

    GetMessageAttributes
    (  document_id                 => document_id
     , display_type                => display_type
     , x_mesg_attribute_rec        => l_mesg_attribute_rec
    ) ;


-- Eng_Workflow_Util.Close_Debug_Session;

    -- We are not supporting text message notification by default
    -- WF_NOTIFICATION.WriteToClob( document , l_doc);

    --  Executing Custom Hook: Eng_Workflow_Ext.GetCustomMessageSubject. . .');
    Eng_Workflow_Ext.GetCustomMessageBody
    (  document_id    => document_id
     , display_type   => display_type
     , document       => document
     , document_type  => document_type
    ) ;

END GetMessageTextBody ;


--  API name   : GetMessageHTMLBody
--  Type       : Private
--  Pre-reqs   : None.
--  Function   : Workflow PL/SQL CLOB Document API to get ntf HTML message body
--  Parameters : p_document_id  IN  VARCHAR2     Required
--                              Format:
--                              <wf item type>:<wf item key>:<&#NID>
--
PROCEDURE GetMessageHTMLBody
(  document_id    IN      VARCHAR2
 , display_type   IN      VARCHAR2
 , document       IN OUT  NOCOPY CLOB
 , document_type  IN OUT  NOCOPY VARCHAR2
)
IS

    l_index1               NUMBER;
    l_index2               NUMBER;

    l_doc                  VARCHAR2(32000) ;

    l_mesg_attribute_rec   Change_Mesg_Attribute_Rec_Type ;

    l_persondetail_url     VARCHAR2(480) ;

    l_item_url             VARCHAR2(480) ;
    l_item_revision_url    VARCHAR2(480) ;
    l_change_url_type      VARCHAR2(20) ;
    l_change_detail_url    VARCHAR2(480) ;
    l_change_detail_link   VARCHAR2(200) ;

    l_change_name          VARCHAR2(240) ;
    l_change_description   VARCHAR2(5000) ;

    -- Sub Header
    l_additional_info_subh VARCHAR2(80) ;

    -- Message prompt
    l_change_name_p        VARCHAR2(80) ;
    l_change_desc_p        VARCHAR2(80) ;
    l_item_p               VARCHAR2(80) ;
    l_item_revision_p      VARCHAR2(80) ;
    l_instrunctions_p      VARCHAR2(80) ;
    l_action_p             VARCHAR2(80) ;

    l_item_revision_label  VARCHAR2(400) ;

    NL VARCHAR2(1) ;

    -- Html Tag Constant Variables
    SPACE_JAVA_SCRIPT  CONSTANT VARCHAR2(2000)
        := '<!-- Space Script --> '||  NL
          || '<script>function t(width,height){document.write(''<img src="/OA_HTML/cabo/images/t.gif"'');'
          || 'if (width!=void 0)document.write('' width="'' + width + ''"''); '
          || 'if (height!=void 0)document.write('' height="'' + height + ''"'');document.write(''>'');}'
          || '</script>' || NL  ;

    OPEN_TAB_100 CONSTANT VARCHAR2(200)
         := '<table width="100%" bgcolor="" border="0" cellspacing="0" cellpadding="0">' ;

    OPEN_TAB CONSTANT VARCHAR2(200)
         := '<table bgcolor="" border="0" cellspacing="0" cellpadding="0">' ;

    CLOSE_TAB  CONSTANT VARCHAR2(10)
         := '</table>' ;

    OPEN_TR  CONSTANT VARCHAR2(5)
         := '<tr>' ;

    CLOSE_TR  CONSTANT VARCHAR2(8)
         := '</tr>' ;

    OPEN_TD  CONSTANT VARCHAR2(100)
         := '<td>' ;

    OPEN_PROMPT_TD CONSTANT VARCHAR2(80)
         := '<td align="right" valign="top" nowrap>'  ;

    CLOSE_TD  CONSTANT VARCHAR2(8)
         := '</td>' ;

    CELL_SPACE CONSTANT VARCHAR2(100)
         := '<td width="12"><script>t(''12'')</script></td>' ;

    TREE_ROW_SPACE CONSTANT VARCHAR2(100)
         := '<tr><td height="3"></td><td></td><td></td></tr>' ;


    FUNCTION CLOSE_PROMPT_TD( p_prompt_text IN VARCHAR2)
    RETURN VARCHAR2
    IS

    BEGIN

        RETURN '<span class="OraPromptText">' || p_prompt_text || '</span></td>' ;

    END CLOSE_PROMPT_TD ;


    FUNCTION CLOSE_SINGLE_DATA_TD( p_data_text IN VARCHAR2)
    RETURN VARCHAR2
    IS

    BEGIN

        RETURN '<span class="OraDataText">' || p_data_text || '</span></td>' ;

    END  CLOSE_SINGLE_DATA_TD ;



    FUNCTION HREF_URL( p_URL          IN VARCHAR2
                     , p_display_text IN VARCHAR2)
    RETURN VARCHAR2
    IS

    BEGIN

        RETURN '<a href="' || p_URL || '">' || p_display_text || '</a>' ;

    END  HREF_URL;


    FUNCTION SPACE_TR ( p_height IN NUMBER )
    RETURN VARCHAR2
    IS

    BEGIN

        RETURN '<tr><td height="' ||  TO_CHAR(p_height) || '"></td></tr>';

    END  SPACE_TR ;


    FUNCTION SUBHEADER ( p_subheader IN VARCHAR2)
    RETURN VARCHAR2
    IS

    BEGIN

        RETURN '<tr><td rowspan="3" width="20"><IMG src="/OA_HTML/cabo/images/t.gif" width="20" height="1"></td>' ||
               '<td><table cellpadding="0" cellspacing="0" border="0" width="100%">' ||
                    '<tr><td width="100%" class="OraHeaderSub">' || p_subheader || '</td></tr>'||
                    '<tr><td class="OraBGAccentDark"><img src="/OA_HTML/cabo/images/t.gif"></td></tr>' ||
                    '</table>' ||
               '</td></tr>' ;

    END SUBHEADER ;


BEGIN

    -- Init Var
    NL := FND_GLOBAL.NEWLINE;

-- For Test/Debug
-- Eng_Workflow_Util.Open_Debug_Session( '/sqlcom/log/plm115d' , 'GetMessageHTMLBody' ) ;
-- Eng_Workflow_Util.Write_Debug('document id ' || document_id );
-- Eng_Workflow_Util.Write_Debug('display_type ' || display_type);
-- Eng_Workflow_Util.Write_Debug('document_type ' || document_type);


    /* Not supporting text
    -- Call GetMessageHTMLBody if display type is text/plain
    IF (display_type = WF_NOTIFICATION.DOC_TEXT ) THEN

       GetMessageTextBody
       (  document_id    => document_id
        , display_type   => display_type
        , document       => document
        , document_type  => document_type
       ) ;

       RETURN ;

    END IF;
    */


    GetMessageAttributes
    (  document_id                 => document_id
     , display_type                => display_type
     , x_mesg_attribute_rec        => l_mesg_attribute_rec
    ) ;

    -- Convert the Text to HTML Text
    l_mesg_attribute_rec.description := ConvertText(l_mesg_attribute_rec.description) ;
    l_mesg_attribute_rec.line_description := ConvertText(l_mesg_attribute_rec.line_description) ;
    l_mesg_attribute_rec.step_instruction := ConvertText(l_mesg_attribute_rec.step_instruction) ;
    l_mesg_attribute_rec.action_desc := ConvertText(l_mesg_attribute_rec.action_desc) ;



    -- Get Field Prompt
    FND_MESSAGE.SET_NAME('ENG', 'ENG_CHANGE_NAME') ;
    l_change_name_p   :=  FND_MESSAGE.GET ;

    FND_MESSAGE.SET_NAME('ENG', 'ENG_CHANGE_DESCRIPTION') ;
    l_change_desc_p   :=  FND_MESSAGE.GET ;


    IF l_mesg_attribute_rec.item_id IS NOT NULL THEN

        FND_MESSAGE.SET_NAME('ENG', 'ENG_SUBJECT_ITEM') ;
        l_item_p          :=  FND_MESSAGE.GET ;

        FND_MESSAGE.SET_NAME('ENG', 'ENG_SUBJECT_ITEM_REVISION') ;
        l_item_revision_p :=  FND_MESSAGE.GET ;


        -- if item revision label is not null
        -- revision field value should be 'revision - revision_lable'
        -- defined in message ENG_CHANGE_ITEM_REV_LABEL
        IF l_mesg_attribute_rec.item_revision_label IS NOT NULL
        THEN

            FND_MESSAGE.SET_NAME('ENG', 'ENG_CHANGE_ITEM_REV_LABEL') ;
            FND_MESSAGE.SET_TOKEN('REVISION_CODE', l_mesg_attribute_rec.item_revision) ;
            FND_MESSAGE.SET_TOKEN('REVISION_LABEL', l_mesg_attribute_rec.item_revision_label) ;
            l_item_revision_label := FND_MESSAGE.GET ;

        ELSE

            l_item_revision_label := l_mesg_attribute_rec.item_revision ;

        END IF ;


        -- Item Detail URL
        -- Ex) /OA_HTML/OA.jsp?OAFunc=EGO_ITEM_OVERVIEW&inventoryItemId=999&organizationId=999
        l_item_url := '/OA_HTML/'
                      || Eng_Workflow_Util.GetFunctionWebHTMLCall
                         (p_function_name => 'EGO_ITEM_OVERVIEW' )
                      || '&inventoryItemId='
                      || TO_CHAR(l_mesg_attribute_rec.item_id)
                      || '&organizationId='
                      || TO_CHAR(l_mesg_attribute_rec.item_organization_id)
                      || '&OAFunc=EGO_ITEM_OVERVIEW'  ;

        -- Item Revision Detail URL
        -- Ex) /OA_HTML/OA.jsp?OAFunc=EGO_ITEM_REVISIONS&inventoryItemId=999&organizationId=999&revisionCode=A
        l_item_revision_url := '/OA_HTML/'
                      || Eng_Workflow_Util.GetFunctionWebHTMLCall
                         (p_function_name => 'EGO_ITEM_REVISIONS' )
                      || '&inventoryItemId='
                      || TO_CHAR(l_mesg_attribute_rec.item_id)
                      || '&organizationId='
                      || TO_CHAR(l_mesg_attribute_rec.item_organization_id)
                      || '&revisionCode='
                      || l_mesg_attribute_rec.item_revision
                      || '&OAFunc=EGO_ITEM_REVISIONS'  ;


    END IF ;



    IF l_mesg_attribute_rec.step_id IS NOT NULL AND
       l_mesg_attribute_rec.item_type  = Eng_Workflow_Util.G_CHANGE_ROUTE_STEP_ITEM_TYPE AND
       l_mesg_attribute_rec.wf_msg_name <>  G_ABORT_STEP_MSG
    THEN

        FND_MESSAGE.SET_NAME('ENG', 'ENG_STEP_INSTRUCTIONS') ;
        l_instrunctions_p := FND_MESSAGE.GET ;

    END IF ;

    IF l_mesg_attribute_rec.action_id IS NOT NULL AND
       ( l_mesg_attribute_rec.item_type = Eng_Workflow_Util.G_CHANGE_ACTION_ITEM_TYPE
         OR l_mesg_attribute_rec.item_type = Eng_Workflow_Util.G_CHANGE_LINE_ACTION_ITEM_TYPE )
    THEN

        IF l_mesg_attribute_rec.wf_msg_name =  G_REQUEST_COMMENT_MSG
        THEN

            FND_MESSAGE.SET_NAME('ENG', 'ENG_SUBJECT') ;
            l_action_p       :=  FND_MESSAGE.GET ;

        ELSE

            FND_MESSAGE.SET_NAME('ENG', 'ENG_COMMENT') ;
            l_action_p       :=  FND_MESSAGE.GET ;

        END IF ;

    END IF ;


    IF   l_mesg_attribute_rec.change_id IS NOT NULL AND
         l_mesg_attribute_rec.change_line_id IS NULL
    THEN

        l_change_name := l_mesg_attribute_rec.change_name ;
        l_change_description := l_mesg_attribute_rec.description ;


        l_change_url_type := GetChangeURLType(p_change_Id => l_mesg_attribute_rec.change_id ) ;

        IF l_change_url_type = 'SUMMARY'
        THEN

            l_change_detail_url  := '/OA_HTML/'
                                    || Eng_Workflow_Util.GetFunctionWebHTMLCall
                                      (p_function_name => 'ENG_CHANGE_SUMMARY_PAGE' )
                                    || '&changeId='
                                    || TO_CHAR(l_mesg_attribute_rec.change_id)
                                    || '&OAFunc=ENG_CHANGE_SUMMARY_PAGE' ;


        ELSE

            l_change_detail_url  := '/OA_HTML/'
                                    || Eng_Workflow_Util.GetFunctionWebHTMLCall
                                      (p_function_name => 'ENG_CHANGE_DETAIL_PAGE' )
                                    || '&changeId='
                                    || TO_CHAR(l_mesg_attribute_rec.change_id)
                                    || '&OAFunc=ENG_CHANGE_DETAIL_PAGE' ;

        END IF ;

        -- Get Sub Header
        FND_MESSAGE.SET_NAME('ENG', 'ENG_CHANGE_SUMMARY') ;
        FND_MESSAGE.SET_TOKEN('CHANGE_MGMT_TYPE', l_mesg_attribute_rec.change_management_type) ;
        l_additional_info_subh := FND_MESSAGE.GET ;

        -- Get Detail Url Link
        FND_MESSAGE.SET_NAME('ENG', 'ENG_CHANGE_DETAIL_LINK_NTF') ;
        FND_MESSAGE.SET_TOKEN('CHANGE_MGMT_TYPE', l_mesg_attribute_rec.change_management_type) ;
        l_change_detail_link := FND_MESSAGE.GET ;

    ELSIF l_mesg_attribute_rec.change_line_id IS NOT NULL
    THEN
        l_change_name := l_mesg_attribute_rec.line_name ;
        l_change_description := l_mesg_attribute_rec.line_description ;
        l_change_detail_url  := '/OA_HTML/'
                                || Eng_Workflow_Util.GetFunctionWebHTMLCall
                                   (p_function_name => 'ENG_CHANGE_LINE_DETAIL_PAGE' )
                                || '&changeLineId='
                                || TO_CHAR(l_mesg_attribute_rec.change_line_id)
                                || '&OAFunc=ENG_CHANGE_LINE_DETAIL_PAGE'  ;

        -- Get Sub Header
        FND_MESSAGE.SET_NAME('ENG', 'ENG_CHANGE_LINE_SUMMARY') ;
        FND_MESSAGE.SET_TOKEN('CHANGE_MGMT_TYPE', l_mesg_attribute_rec.change_management_type) ;
        l_additional_info_subh := FND_MESSAGE.GET ;


        -- Get Detail Url Link
        FND_MESSAGE.SET_NAME('ENG', 'ENG_LINE_DETAIL_LINK_NTF') ;
        FND_MESSAGE.SET_TOKEN('CHANGE_MGMT_TYPE', l_mesg_attribute_rec.change_management_type) ;
        l_change_detail_link := FND_MESSAGE.GET ;


    END IF ;


    --
    -- Generating CM HTML Notification
    -- this contents is put on under 115i9 Workflow Ntf Header
    --
    l_doc := l_doc || '<!-- Base Href URL -->' || NL;
    l_doc := l_doc || '<base href="' || l_mesg_attribute_rec.host_url || '"> ' || NL;
    l_doc := l_doc || '<!-- Style Sheet Link -->' || NL;
    l_doc := l_doc || '<link rel="stylesheet"  href="' || l_mesg_attribute_rec.style_sheet || '" type="text/css">' || NL;
    -- We mihgt need charset="UTF-8" in this tag

    l_doc := l_doc || SPACE_JAVA_SCRIPT || NL;

    -- begin of additional info master table
    l_doc := l_doc || OPEN_TAB_100 || NL ;
    l_doc := l_doc || SPACE_TR(17) || NL ;
    l_doc := l_doc || SUBHEADER(l_additional_info_subh) || NL ;
    l_doc := l_doc || SPACE_TR(2) || NL ;

    -- begin of content record
    l_doc := l_doc || OPEN_TR || OPEN_TD || NL ;

    -- begin of content table
    l_doc := l_doc || '  '|| OPEN_TAB_100 || NL ;
    l_doc := l_doc || '  '|| OPEN_TR || OPEN_TD || NL ;

    -- begin of content child table
    l_doc := l_doc || '  '|| OPEN_TAB_100  || NL ;
    l_doc := l_doc || '  '|| OPEN_TR || NL ;

    -- Left side intenstion
    l_doc := l_doc || '  '|| CELL_SPACE || NL ;

    -- Right side content td
    l_doc := l_doc || '  '|| '<TD VALIGN="top">'|| NL ;
    l_doc := l_doc || '  '|| OPEN_TAB || NL ;

    l_doc := l_doc || '     <!-- Change Object/Line Name --> ' || NL ;
    l_doc := l_doc || '    '|| OPEN_TR || NL ;
    l_doc := l_doc || '      ' || OPEN_PROMPT_TD || NL ;
    l_doc := l_doc || '      ' || CLOSE_PROMPT_TD(l_change_name_p) || NL ;
    l_doc := l_doc || '      ' || CELL_SPACE  || NL ;
    l_doc := l_doc || '      ' || OPEN_TD || NL ;
    l_doc := l_doc || '      ' || CLOSE_SINGLE_DATA_TD(l_change_name) || NL ;
    l_doc := l_doc || '    '|| CLOSE_TR || NL ;

    l_doc := l_doc || '    '|| TREE_ROW_SPACE || NL ;
    l_doc := l_doc || '     <!-- Change Object/Line Description --> ' || NL ;
    l_doc := l_doc || '    '|| OPEN_TR || NL ;
    l_doc := l_doc || '      ' || OPEN_PROMPT_TD || NL ;
    l_doc := l_doc || '      ' || CLOSE_PROMPT_TD(l_change_desc_p) || NL ;
    l_doc := l_doc || '      ' || CELL_SPACE  || NL ;
    l_doc := l_doc || '      ' || OPEN_TD || NL ;
    l_doc := l_doc || '      ' || CLOSE_SINGLE_DATA_TD(l_change_description) || NL ;
    l_doc := l_doc || '    '|| CLOSE_TR || NL ;

    IF l_mesg_attribute_rec.item_id IS NOT NULL THEN

    l_doc := l_doc || '    '|| TREE_ROW_SPACE || NL ;
    l_doc := l_doc || '     <!-- Change Object/Line Item Subject Info --> ' || NL ;
    l_doc := l_doc || '    '|| OPEN_TR || NL ;
    l_doc := l_doc || '      ' || OPEN_PROMPT_TD || NL ;
    l_doc := l_doc || '      ' || CLOSE_PROMPT_TD(l_item_p) || NL ;
    l_doc := l_doc || '      ' || CELL_SPACE  || NL ;
    l_doc := l_doc || '      ' || OPEN_TD || NL ;
    l_doc := l_doc || '        ' || OPEN_TAB || NL ;
    l_doc := l_doc || '        ' || OPEN_TR || NL ;
    l_doc := l_doc || '        ' || '<td width="10%" nowrap>' || HREF_URL(l_item_url, l_mesg_attribute_rec.item_name) || NL;
    l_doc := l_doc || '        ' || CLOSE_TD || NL ;
    l_doc := l_doc || '        ' || CELL_SPACE  || NL ;
    l_doc := l_doc || '        ' || '<td align="left" valign="top">' || NL ;
    l_doc := l_doc || '          ' || OPEN_TAB || OPEN_TR || NL ;
    l_doc := l_doc || '            ' || OPEN_PROMPT_TD || NL ;
    l_doc := l_doc || '            ' || CLOSE_PROMPT_TD(l_item_revision_p) || NL ;
    l_doc := l_doc || '            ' || CELL_SPACE  || NL ;
    l_doc := l_doc || '            ' || OPEN_TD || HREF_URL(l_item_revision_url, l_item_revision_label ) || NL;
    l_doc := l_doc || '            ' || CLOSE_TD || NL ;
    l_doc := l_doc || '            ' || CLOSE_TR || CLOSE_TAB || NL  ;
    l_doc := l_doc || '         ' || CLOSE_TD || NL ;
    l_doc := l_doc || '         ' || CLOSE_TR || NL ;
    l_doc := l_doc || '         ' || CLOSE_TAB || NL ;
    l_doc := l_doc || '      ' || CLOSE_TD || NL ;
    l_doc := l_doc || '    '|| CLOSE_TR || NL ;

    END IF ;

    IF l_instrunctions_p IS NOT NULL THEN

    l_doc := l_doc || '    '|| TREE_ROW_SPACE || NL ;
    l_doc := l_doc || '     <!-- Instrunction Subject info --> ' || NL ;
    l_doc := l_doc || '    '|| OPEN_TR || NL ;
    l_doc := l_doc || '      ' || OPEN_PROMPT_TD || NL ;
    l_doc := l_doc || '      ' || CLOSE_PROMPT_TD(l_instrunctions_p) || NL ;
    l_doc := l_doc || '      ' || CELL_SPACE  || NL ;
    l_doc := l_doc || '      ' || OPEN_TD || NL ;
    l_doc := l_doc || '      ' || CLOSE_SINGLE_DATA_TD(l_mesg_attribute_rec.step_instruction) || NL ;
    l_doc := l_doc || '    '|| CLOSE_TR || NL ;

    END IF ;


    IF l_action_p IS NOT NULL AND l_mesg_attribute_rec.action_desc IS NOT NULL THEN

    l_doc := l_doc || '    '|| TREE_ROW_SPACE || NL ;
    l_doc := l_doc || '     <!-- Comment Request Subject info --> ' || NL ;
    l_doc := l_doc || '    '|| OPEN_TR || NL ;
    l_doc := l_doc || '      ' || OPEN_PROMPT_TD || NL ;
    l_doc := l_doc || '      ' || CLOSE_PROMPT_TD(l_action_p) || NL ;
    l_doc := l_doc || '      ' || CELL_SPACE  || NL ;
    l_doc := l_doc || '      ' || OPEN_TD || NL ;
    l_doc := l_doc || '      ' || CLOSE_SINGLE_DATA_TD(l_mesg_attribute_rec.action_desc) || NL ;
    l_doc := l_doc || '    '|| CLOSE_TR || NL ;

    END IF ;


    -- end of right side content table
    l_doc := l_doc || '  '|| CLOSE_TAB  || NL ;
    l_doc := l_doc || '  '|| CLOSE_TD || NL ;

    -- end of content child table
    l_doc := l_doc || '  '|| CLOSE_TR || NL ;
    l_doc := l_doc || '  '|| CLOSE_TAB  || NL ;

    -- end of content table
    l_doc := l_doc || CLOSE_TD || CLOSE_TR || NL ;
    l_doc := l_doc || CLOSE_TAB  || NL ;

    -- end of content record
    l_doc := l_doc || CLOSE_TR || CLOSE_TD || NL ;

    -- end of additional info master table
    l_doc := l_doc || CLOSE_TAB || NL ;

    --
    -- begin of detail link table
    l_doc := l_doc || OPEN_TAB_100 || NL ;
    l_doc := l_doc || SPACE_TR(7) || NL ;
    l_doc := l_doc || OPEN_TR || NL ;
    l_doc := l_doc || OPEN_TD || NL ;

    -- begin of detail Page Link table
    l_doc := l_doc || '  <!-- Change Object Detail Page Link -->' || NL ;
    l_doc := l_doc || '  '|| OPEN_TAB_100  || NL ;
    l_doc := l_doc || '    '|| OPEN_TR || NL ;
    l_doc := l_doc || '      <td align="right">' || NL ;
    L_doc := l_doc || '        <a href="' || l_change_detail_url ||  '">' || l_change_detail_link ||  '</a></td>' || NL ;
    l_doc := l_doc || '    '|| CLOSE_TR || NL ;
    l_doc := l_doc || '  '|| CLOSE_TAB  || NL ;
    -- end of detail Page Link table

    -- end of detail link table
    l_doc := l_doc || CLOSE_TD || NL ;
    l_doc := l_doc || CLOSE_TR || NL ;
    l_doc := l_doc || CLOSE_TAB  || NL ;


-- Eng_Workflow_Util.Close_Debug_Session;

    WF_NOTIFICATION.WriteToClob( document , l_doc);

    --  Executing Custom Hook: Eng_Workflow_Ext.GetCustomMessageSubject
    Eng_Workflow_Ext.GetCustomMessageBody
    (  document_id    => document_id
     , display_type   => display_type
     , document       => document
     , document_type  => document_type
    ) ;


END GetMessageHTMLBody ;







FUNCTION GetRunFuncURL
( p_function_name     IN     VARCHAR2
, p_resp_appl_id      IN     NUMBER    DEFAULT NULL
, p_resp_id           IN     NUMBER    DEFAULT NULL
, p_security_group_id IN     NUMBER    DEFAULT NULL
, p_parameters        IN     VARCHAR2  DEFAULT NULL
) RETURN VARCHAR2
IS

   l_function_id       NUMBER ;
   l_resp_appl_id      NUMBER ;
   l_resp_id           NUMBER ;
   l_security_group_id NUMBER ;

BEGIN

    l_function_id := fnd_function.get_function_id(p_function_name) ;


    IF p_resp_appl_id IS NULL THEN
        l_resp_appl_id := -1 ;
    END IF ;


    IF p_resp_id IS NULL THEN
        l_resp_id := -1 ;
    END IF ;

    IF p_security_group_id IS NULL THEN
        l_security_group_id := -1 ;
    END IF ;

    -- Call Fnd API
    RETURN fnd_run_function.get_run_function_url
                            ( p_function_id       => l_function_id
                            , p_resp_appl_id      => l_resp_appl_id
                            , p_resp_id           => l_resp_id
                            , p_security_group_id => l_security_group_id
                            , p_parameters        => p_parameters ) ;


END GetRunFuncURL ;



FUNCTION GetChangeRunFuncURL
( p_change_id IN     NUMBER)
RETURN VARCHAR2
IS

BEGIN

    RETURN GetRunFuncURL
           ( p_function_name => 'ENG_CHANGE_DETAIL_PAGE'
           , p_parameters    => '&changeId=' || TO_CHAR(p_change_id) ) ;

END GetChangeRunFuncURL ;



FUNCTION GetChangeSummaryRunFuncURL
( p_change_id IN     NUMBER)
RETURN VARCHAR2
IS

BEGIN

    RETURN GetRunFuncURL
           ( p_function_name => 'ENG_CHANGE_SUMMARY_PAGE'
           , p_parameters    => '&changeId=' || TO_CHAR(p_change_id) ) ;

END GetChangeSummaryRunFuncURL ;


PROCEDURE GetNtfRecipient
( p_notification_id  IN NUMBER
, x_party_id         OUT NOCOPY NUMBER
, x_party_name       OUT NOCOPY VARCHAR2
, x_user_id          OUT NOCOPY NUMBER
, x_user_name        OUT NOCOPY VARCHAR2
)
IS

    CURSOR c_ntf_party  (c_ntf_id NUMBER)
    IS
        SELECT u.USER_NAME
             , u.USER_ID
             , u.PARTY_ID
             , u.PARTY_NAME
        FROM   EGO_USER_V u
             , WF_NOTIFICATIONS wn
        WHERE u.USER_NAME = wn.RECIPIENT_ROLE
        AND   wn.NOTIFICATION_ID = c_ntf_id ;

BEGIN

    FOR person_rec IN c_ntf_party(c_ntf_id => p_notification_id)
    LOOP
        x_user_name  := person_rec.USER_NAME ;
        x_user_id    := person_rec.USER_ID ;
        x_party_name := person_rec.PARTY_NAME ;
        x_party_id   := person_rec.PARTY_ID ;
    END LOOP ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        null ;
END  GetNtfRecipient ;



/********************************************************************
* API Type      : Public APIs
* Purpose       : Those APIs are public
*********************************************************************/
-- None

END Eng_Workflow_Ntf_Util ;

/
