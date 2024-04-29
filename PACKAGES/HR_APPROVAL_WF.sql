--------------------------------------------------------
--  DDL for Package HR_APPROVAL_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPROVAL_WF" AUTHID CURRENT_USER as
/* $Header: hrapprwf.pkh 115.7 2002/12/06 07:37:34 snachuri ship $ */
-- --------------------------------------------------------------------
-- |--------------------< create_item_attrib_if_notexist >---------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This procedure checks to see if an item attribute exists. If it does
--  not the one is created
procedure create_item_attrib_if_notexist
    (p_item_type in     varchar2
    ,p_item_key  in     varchar2
    ,p_name      in     varchar2) ;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< intialize_item_attributes >--------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--
--  This procedure creates all the activity item attributes required by
--  the approval process and initialises some of them.
--
procedure initialize_item_attributes
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2);
-- --------------------------------------------------------------------
-- |------------------------< set_routing_details1 >------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This procedure sets the item attributes
--      APPROVAL_ROUTING_PERSON_ID1, APPROVAL_ROUTING_USERNAME1,
--      APPROVAL_ROUTING_DISPLAY_NAME1.
--      It calls hr_approval_custom.get_routing_details1 which is
--      where the person ID is defined
--      These can be used to define the performer of a notification activities.
--
procedure set_routing_details1(itemtype in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funmode       in varchar2,
                  result        out nocopy varchar2    );
--
-- --------------------------------------------------------------------
-- |------------------------< set_routing_details2 >------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This procedure sets the item attributes
--      APPROVAL_ROUTING_PERSON_ID2, APPROVAL_ROUTING_USERNAME2,
--      APPROVAL_ROUTING_DISPLAY_NAME2.
--      It calls hr_approval_custom.get_routing_details2 which is
--      where the person ID is defined
--      These can be used to define the performer of a notification activities.
--
procedure set_routing_details2(itemtype in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funmode       in varchar2,
                  result        out nocopy varchar2    );
--
-- --------------------------------------------------------------------
-- |------------------------< set_routing_details3 >------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This procedure sets the item attributes
--      APPROVAL_ROUTING_PERSON_ID3, APPROVAL_ROUTING_USERNAME3,
--      APPROVAL_ROUTING_DISPLAY_NAME3.
--      It calls hr_approval_custom.get_routing_details3 which is
--      where the person ID is defined
--      These can be used to define the performer of a notification activities.
--
procedure set_routing_details3(itemtype in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funmode       in varchar2,
                  result        out nocopy varchar2    );
--
-- --------------------------------------------------------------------
-- |------------------------< set_routing_details4 >------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This procedure sets the item attributes
--      APPROVAL_ROUTING_PERSON_ID4, APPROVAL_ROUTING_USERNAME4,
--      APPROVAL_ROUTING_DISPLAY_NAME4.
--      It calls hr_approval_custom.get_routing_details4 which is
--      where the person ID is defined
--      These can be used to define the performer of a notification activities.
--
procedure set_routing_details4(itemtype in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funmode       in varchar2,
                  result        out nocopy varchar2    );
--
-- --------------------------------------------------------------------
-- |------------------------< set_routing_details5 >------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This procedure sets the item attributes
--      APPROVAL_ROUTING_PERSON_ID5, APPROVAL_ROUTING_USERNAME5,
--      APPROVAL_ROUTING_DISPLAY_NAME5.
--      It calls hr_approval_custom.get_routing_details5 which is
--      where the person ID is defined
--      These can be used to define the performer of a notification activities.
--
procedure set_routing_details5(itemtype in varchar2,
                  itemkey   in varchar2,
                  actid     in number,
                  funmode       in varchar2,
                  result        out nocopy varchar2    );
-- --------------------------------------------------------------------
-- |----------------------------< set_URL1 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL1 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL1
--
procedure set_URL1(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL2 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL2 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL2
--
procedure set_URL2(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL3 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL3 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL3
--
procedure set_URL3(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL4 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL4 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL4
--
procedure set_URL4(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL5 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL5 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL5
--
procedure set_URL5(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL6 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL6 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL6
--
procedure set_URL6(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL7 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL7 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL7
--
procedure set_URL7(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL8 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL8 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL8
--
procedure set_URL8(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL9 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL9 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL9
--
procedure set_URL9(itemtype in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL10 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL10 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL10
--
procedure set_URL10(itemtype    in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL11 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL11 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL11
--
procedure set_URL11(itemtype    in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL12 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL12 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL12
--
procedure set_URL12(itemtype    in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL13 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL13 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL13
--
procedure set_URL13(itemtype    in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);
-- --------------------------------------------------------------------
-- |----------------------------< set_URL14 >---------------------------|
-- --------------------------------------------------------------------
--
-- Description
--
--  This function sets the attribute APPROVAL_URL14 to define
--      a URL for Employee Kiosk. The URL value is obtained from
--  the function hr_approval_custom.get_URL14
--
procedure set_URL14(itemtype    in varchar2,
           itemkey      in varchar2,
           actid        in number,
           funmode      in varchar2,
           result       out nocopy varchar2);

-- ------------------------------------------------------------------------
-- |----------------------< Check_Final_Approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Determine if this person is the final manager in the approval chain
--
--
procedure Check_Final_Approver( itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     );
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_next_approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next approver in the chain
--
--
procedure Get_Next_Approver (   itemtype    in varchar2,
                itemkey     in varchar2,
                actid       in number,
                funmode     in varchar2,
                result      out nocopy varchar2     );
--
-- ------------------------------------------------------------------------
-- |------------------------< Get_next_approver >-------------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Get the next approver in the chain
--  Overloaded method returns the person id of the next approver in the chain
--  or null if no approver exists.
--
--
procedure Get_Next_Approver (   itemtype    in varchar2,
                                itemkey     in varchar2,
                                currentapproverid in per_people_f.person_id%type,
                                personid      out nocopy per_people_f.person_id%type);
-- ------------------------------------------------------------------------
-- |--------------------------< copy_approval_comment >---------------------|
-- ------------------------------------------------------------------------
--
-- Description
--
--  Copies the item attribute APPROVAL_COMMENT into item attribute
--  APPROVAL_COMMENT_COPY so that it cna be displayed in the notification
--
--
procedure copy_approval_comment(    itemtype    in varchar2,
                    itemkey     in varchar2,
                    actid       in number,
                    funmode     in varchar2,
                    result      out nocopy varchar2    );
--
-- ---------------------------------------------------------------------------
-- |-------------------------< set_current_person_to_creator >----------------|
-- ---------------------------------------------------------------------------
--
-- Description
--
--  Sets the value of the attribute CURRENT_PERSON_ID to the value
--  of the attribute CREATOR_PERSON_ID
--
--
procedure set_current_person_to_creator
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2);
-- ---------------------------------------------------------------------------
-- |-------------------------< set_training_admin_person >-------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--
--  gets the value of the training administrator
--
--
procedure set_training_admin_person
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2);

--
-- ---------------------------------------------------------------------------
-- |-------------------------< set_supervisor_id >----------------------------|
-- ---------------------------------------------------------------------------
--
-- Description
--
--  gets the value of the supervisor id
--
--
procedure set_supervisor_id
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2);

--
procedure set_forward_to
  (itemtype in     varchar2
  ,itemkey  in     varchar2
  ,actid    in     number
  ,funmode  in     varchar2
  ,result      out nocopy varchar2);
--
end hr_approval_wf;




 

/
