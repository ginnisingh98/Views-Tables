--------------------------------------------------------
--  DDL for Package Body QLTINVCB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QLTINVCB" as
/* $Header: qltinvcb.plb 115.2 2002/11/27 19:26:32 jezheng ship $ */
-- 5/20/96 - created
-- Paul Mishkin

FUNCTION NO_NEG_BALANCE(RESTRICT_FLAG NUMBER,
                        NEG_FLAG NUMBER,
                        ACTION NUMBER) RETURN BOOLEAN IS
   VALUE   VARCHAR2(30);
   DO_NOT  BOOLEAN;
BEGIN
     if (restrict_flag = 2 or restrict_flag IS NULL) then
       if (neg_flag = 2) THEN
         if (action = 1 OR action = 2 or action = 3 or
             action = 21 or action = 30 or action = 32) then
             DO_NOT := TRUE;
         else
             DO_NOT := FALSE;
         end if;
       else
         DO_NOT := FALSE;
       end if;
     elsif (restrict_flag = 1) then
       DO_NOT := TRUE;
     end if;
     return DO_NOT;
END NO_NEG_BALANCE;


FUNCTION CONTROL (ORG_CONTROL NUMBER DEFAULT NULL,
                  SUB_CONTROL NUMBER DEFAULT NULL,
                  ITEM_CONTROL NUMBER DEFAULT NULL,
                  RESTRICT_FLAG NUMBER DEFAULT NULL,
                  NEG_FLAG NUMBER DEFAULT NULL,
                  ACTION NUMBER DEFAULT NULL) RETURN NUMBER IS
   VALUE            VARCHAR2(30);
   LOCATOR_CONTROL  NUMBER;
BEGIN
       if (org_control = 1) then
       locator_control := 1;
    elsif (org_control = 2) then
       locator_control := 2;
    elsif (org_control = 3) then
       locator_control := 3;
       if (qltinvcb.no_neg_balance(restrict_flag,
            neg_flag,action)) then
         locator_control := 2;
       end if;
    elsif (org_control = 4) then
      if (sub_control = 1) then
         locator_control := 1;
      elsif (sub_control = 2) then
         locator_control := 2;
      elsif (sub_control = 3) then
         locator_control := 3;
         if (qltinvcb.no_neg_balance(restrict_flag,
              neg_flag,action)) then
           locator_control := 2;
         end if;
      elsif (sub_control = 5) then
        if (item_control = 1) then
           locator_control := 1;
        elsif (item_control = 2) then
           locator_control := 2;
        elsif (item_control = 3) then
           locator_control := 3;
           if (qltinvcb.no_neg_balance(restrict_flag,
                neg_flag,action)) then
             locator_control := 2;
           end if;
        elsif (item_control IS NULL) then
           locator_control := sub_control;
        end if;
      end if;
    end if;
    return locator_control;

END CONTROL;


END QLTINVCB;


/
