--------------------------------------------------------
--  DDL for Package Body IEM_OPERATORS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEM_OPERATORS_PVT" AS
/* $Header: iemvopeb.pls 120.1 2005/06/23 18:15:08 appldev ship $ */
--
--
-- Purpose: Assistant api to Route/Classification/Email Processing Engine.
--
-- MODIFICATION HISTORY
-- Person      Date         Comments
--  Liang Xia   5/29/2001  created
--  Liang Xia   12/6/2002  Fixed GSCC warning: NOCOPY, no G_MISS ..
--  Liang Xia   07/16/2003 Fixed Byte function problem.
--  Liang Xia   01/23/2004 Fixed bug: 3389301
--  Liang Xia   04/06/2005   Fixed GSCC sql.46 ( bug 4256769 )
--  Liang Xia   06/26/2005   Fixed GSCC sql.46 ( bug 4452895 )
-- ---------   ------  ------------------------------------------

FUNCTION satisfied(leftHandSide IN varchar2, operator IN varchar2, rightHandSide IN varchar2, valueDataType IN varchar2)
return boolean is

conditionSatisfied  boolean := false;
timeFormat          VARCHAR2(20):= 'HH24:MI:SS';
dateFormat          VARCHAR2(20):= 'YYYYMMDD';

logMessage          VARCHAR2(2000);
errorMessage        VARCHAR2(2000);

INVALID_DATATYPE    Exception;

Begin

    if( FND_LOG.LEVEL_STATEMENT>= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
        logMessage := '[' || leftHandSide || operator || rightHandSide || valueDataType || ']';
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'IEM.PLSQL.IEM_OPERATORS_PVT.SATISFIED.KEY_VALS', logMessage);
    end if;


    if valueDataType = 'S' then
        if operator = '=' then
            if (upper(leftHandSide) = upper(rightHandSide)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '<>' then
            if (upper(leftHandSide) <> upper(rightHandSide)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = 'CONTAINS' then
            if (instr(upper(leftHandSide), upper(rightHandSide)) <> 0) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = 'NCONTAINS' then
            if ( leftHandSide is null or leftHandSide='') then
                conditionSatisfied := true;
                return conditionSatisfied;
            elsif (instr(upper(leftHandSide), upper(rightHandSide)) = 0) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = 'BEGINS' then
            if (instr(upper(leftHandSide), upper(rightHandSide)) = 1) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = 'NBEGINS' then
            if (instr(upper(leftHandSide), upper(rightHandSide)) <> 1) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
                elsif operator = 'ENDS' then
            if (upper(substr(leftHandSide, length(rightHandSide) * -1, length(rightHandSide))) = upper(rightHandSide)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = 'NENDS' then
            if (upper(substr(leftHandSide, length(rightHandSide) * -1, length(rightHandSide))) <> upper(rightHandSide)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        end if;
    elsif valueDataType = 'N' then
        if operator = '=' then
            if (to_number(leftHandSide) = to_number(rightHandSide)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '<>' then
            if (to_number(leftHandSide) <> to_number(rightHandSide)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '<' then
            if (to_number(leftHandSide) < to_number(rightHandSide)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '>' then
            if (to_number(leftHandSide) > to_number(rightHandSide)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '<=' then
            if (to_number(leftHandSide) <= to_number(rightHandSide)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '>=' then
            if (to_number(leftHandSide) >= to_number(rightHandSide)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        end if;
    elsif valueDataType = 'D' then
        if operator = '=' then
            if (to_date(leftHandSide, dateFormat) = to_date(rightHandSide, dateFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '<>' then
            if (to_date(leftHandSide, dateFormat) <> to_date(rightHandSide, dateFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '<' then
            if (to_date(leftHandSide, dateFormat) < to_date(rightHandSide, dateFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '>' then
            if (to_date(leftHandSide, dateFormat) > to_date(rightHandSide, dateFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '<=' then
            if (to_date(leftHandSide, dateFormat) <= to_date(rightHandSide, dateFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '>=' then
            if (to_date(leftHandSide, dateFormat) >= to_date(rightHandSide, dateFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        end if;
     elsif valueDataType = 'T' then
        if operator = '=' then
            if (to_date(leftHandSide, timeFormat) = to_date(rightHandSide, timeFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '<>' then
            if (to_date(leftHandSide, timeFormat) <> to_date(rightHandSide, timeFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '<' then
            if (to_date(leftHandSide, timeFormat) < to_date(rightHandSide, timeFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '>' then
            if (to_date(leftHandSide,timeFormat) > to_date(rightHandSide, timeFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '<=' then
            if (to_date(leftHandSide, timeFormat) <= to_date(rightHandSide, timeFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        elsif operator = '>=' then
            if (to_date(leftHandSide, timeFormat) >= to_date(rightHandSide, timeFormat)) then
                conditionSatisfied := true;
                return conditionSatisfied;
            end if;
        end if;
    else
        Raise INVALID_DATATYPE;
    end if;

    return conditionSatisfied;

    EXCEPTION
        When INVALID_DATATYPE then
			if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            	errorMessage := '[' || leftHandSide || operator || rightHandSide || valueDataType || ']' || ' Invalid Datatype';
            	FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_OPERATORS_PVT.SATISFIED.INVALID_DATATYPE', errorMessage);
           	end if;

			conditionSatisfied := false;
            return conditionSatisfied;
        When VALUE_ERROR then
			if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            	errorMessage := '[' || leftHandSide || operator || rightHandSide || valueDataType || ']' || ' Invalid Number Format';
            	FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_OPERATORS_PVT.SATISFIED.VALUE_ERROR', errorMessage);
            end if;

			conditionSatisfied := false;
            return conditionSatisfied;
      When others then
	  	   if( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
               errorMessage := '[' || leftHandSide || operator || rightHandSide || valueDataType || '] ' || sqlerrm;
               FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'IEM.PLSQL.IEM_OPERATORS_PVT.SATISFIED.WHEN_OTHERS', errorMessage);
           end if;

		    conditionSatisfied := false;
            return conditionSatisfied;

end satisfied;


END IEM_OPERATORS_PVT;

/
