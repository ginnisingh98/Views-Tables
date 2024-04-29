--------------------------------------------------------
--  DDL for Package Body FTE_WF_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_WF_UTIL" AS
/* $Header: FTEWFUTB.pls 115.2 2002/12/03 21:52:07 hbhagava noship $ */

--*******************************************************

PROCEDURE GET_BLOCK_STATUS(itemtype  		in  	VARCHAR2,
                       itemkey   		in  	VARCHAR2,
                       p_workflow_process	in	VARCHAR2,
                       p_block_label		in	VARCHAR2,
                       x_return_status 		out NOCOPY VARCHAR2) IS


l_activity_status      VARCHAR2(8);
l_activity_result_code VARCHAR2(30);

BEGIN

   x_return_status  := 'NA';


   SELECT activity_status
   INTO l_activity_status
   FROM wf_item_activity_statuses
   WHERE item_type 	= itemtype
   AND item_key		= itemkey
   AND process_activity IN (
   	select INSTANCE_ID
	from   WF_PROCESS_ACTIVITIES
	where  PROCESS_ITEM_TYPE = itemtype
	and    PROCESS_NAME      = p_workflow_process
	and    INSTANCE_LABEL    = p_block_label);


   IF (l_activity_status = 'COMPLETE') THEN
      x_return_status  := 'COMPLETE';
      RETURN;
   ELSIF (l_activity_status = 'NOTIFIED') THEN
      x_return_status  := 'NOTIFIED';
      RETURN;
   ELSE
      x_return_status  := 'NA';
      RETURN;
   END IF;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
   	x_return_status := 'NA';
   	RETURN;
   WHEN OTHERS THEN
      x_return_status  := 'E';
      RETURN;

END GET_BLOCK_STATUS;

--*******************************************************

-- ------------------------------------------------------------------------------- --
--                                                                                 --
-- NAME:                GET_ATTRIBUTE_NUMBER                                       --
-- TYPE:                FUNCTION                                                   --
-- PARAMETERS (IN):     p_item_type                  VARCHAR2                      --
--                      p_item_key                   VARCHAR2                      --
--                      p_aname                      VARCHAR2                      --
-- PARAMETERS (OUT):    none                                                       --
-- PARAMETERS (IN OUT): none                                                       --
-- RETURN:              NUMBER   (number attribute value)                          --
-- DESCRIPTION:         This function retrieves a number value from a workflow     --
--                      identified by the passed in item type and item key. The    --
--                      name of the attribute is given by the p_aname parameter.   --
--                                                                                 --
-- CHANGE CONTROL LOG                                                              --
-- ------------------                                                              --
--                                                                                 --
-- DATE        VERSION  BY        BUG      DESCRIPTION                             --
-- ----------  -------  --------  -------  --------------------------------------- --
-- 2002        11.5.8    HBHAGAVA           Created                                 --
--                                                                                 --
-- ------------------------------------------------------------------------------- --
FUNCTION GET_ATTRIBUTE_NUMBER(p_item_type IN VARCHAR2,
                              p_item_key  IN VARCHAR2,
                              p_aname     IN VARCHAR2) RETURN NUMBER IS
lvalue NUMBER;

BEGIN

      select NUMBER_VALUE
      into   lvalue
      from   WF_ITEM_ATTRIBUTE_VALUES
      where  ITEM_TYPE = p_item_type
      and    ITEM_KEY  = p_item_key
      and    NAME      = p_aname;

      return(lvalue);

EXCEPTION
   WHEN OTHERS THEN
      return(null);

END GET_ATTRIBUTE_NUMBER;

END FTE_WF_UTIL;

/
