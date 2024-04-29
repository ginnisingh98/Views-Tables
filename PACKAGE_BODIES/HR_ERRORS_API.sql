--------------------------------------------------------
--  DDL for Package Body HR_ERRORS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ERRORS_API" as
/* $Header: hrerrapi.pkb 115.15 2002/12/06 15:37:26 hjonnala ship $ */
--
-- ----------------------------------------------------------------------------
-- |--< errorExists >---------------------------------------------------------|
-- ----------------------------------------------------------------------------
function errorExists return boolean is
--
begin
   if nvl(noOfErrorRecords, 0) > 0 then
      return true;
   else
      return false;
   end if;
end;
--
-- ----------------------------------------------------------------------------
-- |--< warningExists >-------------------------------------------------------|
-- ----------------------------------------------------------------------------
function warningExists return boolean is
--
l_counter     number := null;
--
begin
   -- we need to scan through the error records to see if there are any
   -- with the warning flag set.
-- bug # 1641590
   l_counter := g_errorTable.First;
/*
   if g_errorTable.count <> 0 then
     l_counter := 1;
   else
     l_counter := null;
   end if;
*/
   while l_counter is not null loop
      IF g_errorTable(l_counter).warningFlag THEN
         RETURN TRUE;
      END IF;
     l_counter := g_errorTable.Next(l_counter);
   end loop;

   -- If we have reached here then no warnings have been found
   RETURN FALSE;
end;
--
-- ----------------------------------------------------------------------------
-- |--< fieldLevelErrorsExist >-----------------------------------------------|
-- ----------------------------------------------------------------------------
function fieldLevelErrorsExist return boolean is
--
l_counter     number := null;
--
begin
   -- loop through the error table and if we find a field level error return
   -- true - otherwise return false
-- bug # 1641590
   l_counter := g_errorTable.First;
/*
   if g_errorTable.count <> 0 then
     l_counter := 1;
   else
     l_counter := null;
   end if;
*/
   while l_counter is not null loop
      if    ( g_errorTable(l_counter).ErrorField IS NOT NULL OR
              g_errorTable(l_counter).RowNumber > 0 )
        AND NOT g_errorTable(l_counter).warningFlag
      then
         return TRUE;
      end if;
     l_counter := g_errorTable.Next(l_counter);
   end loop;

   -- if we have reached here then no field level errors exist
   return FALSE;
end;
--
-- ----------------------------------------------------------------------------
-- |--< addErrorToTable >-----------------------------------------------------|
-- ----------------------------------------------------------------------------
procedure addErrorToTable(p_errorField    varchar2    default null
                         ,p_errorCode     varchar2    default null
                         ,p_errorMsg      varchar2
                         ,p_warningFlag   boolean     default false
                         ,p_rowNumber     number      default null
                         ,p_email_id      varchar2    default null
                         ,p_email_msg     varchar2    default null
                         ) is
--
begin
--
   -- increment the error count
   -- g_count := g_count + 1;
-- bug # 1641590
   g_count := g_errorTable.Last;
   if g_count is not null then
      g_count := g_count + 1;
   else
      g_count := 1;
   end if;
   --
   -- set the values in the pl/sql table to the stuff thats been passed in!
   --
   g_errorTable(g_count).ErrorField   := p_errorField;
   g_errorTable(g_count).ErrorCode    := p_errorCode;
   g_errorTable(g_count).ErrorMsg     := p_errorMsg;
   g_errorTable(g_count).WarningFlag  := p_warningFlag;
   g_errorTable(g_count).RowNumber    := NVL(p_rowNumber, 0);
   g_errorTable(g_count).EmailId      := p_email_id;
   g_errorTable(g_count).EmailMsg     := p_email_msg;

--
end;
--
-- ----------------------------------------------------------------------------
-- |--< noOfErrorRecords >----------------------------------------------------|
-- ----------------------------------------------------------------------------
function noOfErrorRecords return number is
--
l_error_count    NUMBER;
l_counter        NUMBER := 0;
--
begin
   l_error_count := 0;

   -- loop through the error table counting the errors (ie. not warnings)
-- bug # 1641590
   l_counter := g_errorTable.First;
/*
   if g_errorTable.count <> 0 then
     l_counter := 1;
   else
     l_counter := null;
   end if;
*/

   while l_counter is not null loop
      if NOT g_errorTable(l_counter).warningFlag then
         l_error_count := l_error_count + 1;
      end if;
     l_counter := g_errorTable.Next(l_counter);
   end loop;

   return nvl(l_error_count, 0);
end;
--
-- ----------------------------------------------------------------------------
-- |--< noOfWarnings >--------------------------------------------------------|
-- ----------------------------------------------------------------------------
function noOfWarnings return number is
--
l_warning_count    NUMBER;
l_counter        NUMBER := 0;
--
begin
   l_warning_count := 0;

   -- loop through the error table counting the warnings
-- bug # 1641590
   l_counter := g_errorTable.First;
/*
   if g_errorTable.count <> 0 then
     l_counter := 1;
   else
     l_counter := null;
   end if;
*/

   while l_counter is not null loop
      if g_errorTable(l_counter).warningFlag then
         l_warning_count := l_warning_count + 1;
      end if;
     l_counter := g_errorTable.Next(l_counter);
   end loop;

   return nvl(l_warning_count, 0);
end;
--
-- ----------------------------------------------------------------------------
-- |--< getPageLevelErrors >--------------------------------------------------|
-- ----------------------------------------------------------------------------
function getPageLevelErrors return ErrorRecTable is
--
l_text         varchar2 (32000);
l_errorArray   ErrorRecTable;
l_count        number := 0;

Counter        number := 0;
--
begin
-- bug 1690449
     Counter := g_errorTable.First;

     -- return the text of any errors that do not have a field name
-- bug 1690449
     while Counter is not null
     loop

         if   g_errorTable(Counter).ErrorField is null
          OR  g_errorTable(Counter).ErrorField = ''
          OR  g_errorTable(Counter).warningFlag then
            --
            -- this is a page level error message or a warning (all warnings
            -- are page level)
            --
            -- check if this is not  a row level error
            -- if not then this is a page level or warning
            IF g_errorTable(counter).rownumber = 0 THEN
            l_count := l_count + 1;

            -- add it to the array of errors to return
            l_errorArray(l_count).ErrorField
                                          := g_errorTable(Counter).ErrorField;
            l_errorArray(l_count).ErrorCode
                                          := g_errorTable(Counter).ErrorCode;
            l_errorArray(l_count).ErrorMsg
                                          := g_errorTable(Counter).ErrorMsg;
            l_errorArray(l_count).WarningFlag
                                          := g_errorTable(Counter).WarningFlag;
            l_errorArray(l_count).RowNumber
                                          := g_errorTable(Counter).RowNumber;
            l_errorArray(l_count).EmailId
                                          := g_errorTable(Counter).EmailId;
            l_errorArray(l_count).EmailMsg
                                          := g_errorTable(Counter).EmailMsg;
-- bug # 1641590
            g_errorTable.delete(Counter);
            END IF ;
         end if;
-- bug 1690449
        Counter := g_errorTable.Next(Counter);
     end loop;
   return l_errorArray;
end;
-- ----------------------------------------------------------------------------
-- |--< getRowLevelErrors >---------------------------------------------------|
-- ----------------------------------------------------------------------------
function getRowLevelErrors (p_row_number   varchar2
                            ,p_error_loc     OUT NOCOPY ErrorRecLocTable
                           ) return ErrorTextTable is
--
l_textTable   ErrorTextTable;
l_count       number := 0;
l_row_number  number := null;
l_counter     number := null;

l_err_loc_count number := 0;
--
begin
   if p_row_number is not null then
      l_row_number := to_number(p_row_number);

      -- return the text of any errors that do not have a field name
-- bug # 1641590
      l_counter := g_errorTable.First;
  /*
      if g_errorTable.count <> 0 then
       l_counter := 1;
      else
       l_counter := null;
      end if;
  */

      while l_counter is not null loop
          if (   g_errorTable(l_counter).ErrorField is null
              or g_errorTable(l_counter).ErrorField = '' )
             and NOT g_errorTable(l_counter).warningFlag
             and g_errorTable(l_counter).RowNumber = l_row_number then
             --
             l_count := l_count + 1;

             IF g_errorTable(l_counter).ErrorCode IS NOT NULL THEN
                l_textTable(l_count) := g_errorTable(l_counter).ErrorMsg ||
                                        ' (' ||
                                        g_errorTable(l_counter).ErrorCode ||
                                        ')';
             ELSE
                l_textTable(l_count) := g_errorTable(l_counter).ErrorMsg;
             END IF;
-- bug # 1641590 1690449
             --g_errorTable.delete(l_counter);
             l_err_loc_count := l_err_loc_count + 1;
             p_error_loc(l_err_loc_count) := l_counter;
          end if;
          l_counter := g_errorTable.Next(l_counter);
      end loop;
      --
   end if;
   --
   return l_textTable;
   Exception
   when others then
   p_error_loc.delete;
   raise;
end;
--
-- ----------------------------------------------------------------------------
-- |--< getFieldLevelErrors >-------------------------------------------------|
-- ----------------------------------------------------------------------------
function getFieldLevelErrors(p_field_name    varchar2
                            ,p_row_number    varchar2     default null
                            ,p_error_loc     OUT NOCOPY ErrorRecLocTable
                            ) return ErrorTextTable is
--
l_textTable   ErrorTextTable;
l_count       number := 0;
l_row_number  number := null;
l_counter     number := null;

l_err_loc_count number := 0;
--
begin
   if p_row_number is not null then
      l_row_number := to_number(p_row_number);
   end if;

   -- scan the pl/sql table to see if there are matches with the field name
   -- passed in
-- bug # 1641590
   l_counter := g_errorTable.First;
/*
   if g_errorTable.count <> 0 then
     l_counter := 1;
   else
     l_counter := null;
   end if;
*/

   while l_counter is not null loop
       if upper(g_errorTable(l_counter).ErrorField) = upper(p_field_name)
           AND NOT g_errorTable(l_counter).warningFlag
           AND (     (g_errorTable(l_counter).RowNumber = p_row_number)
                 OR  p_row_number is null) then
          --
          l_count := l_count + 1;
          --
          IF g_errorTable(l_counter).ErrorCode IS NOT NULL THEN
             l_textTable(l_count) := g_errorTable(l_counter).ErrorMsg ||
                                     ' (' ||
                                     g_errorTable(l_counter).ErrorCode ||
                                     ')';
          ELSE
             l_textTable(l_count) := g_errorTable(l_counter).ErrorMsg;
          END IF;
-- bug # 1641590 1690449
          --g_errorTable.delete(l_counter);
          l_err_loc_count := l_err_loc_count + 1;
          p_error_loc(l_err_loc_count) := l_counter;
       end if;
      l_counter := g_errorTable.Next(l_counter);
   end loop;

   return l_textTable;
   Exception
   when others then
   p_error_loc.delete;
   raise;
end;
--
-- ----------------------------------------------------------------------------
-- |--< encryptErrorTable >---------------------------------------------------|
-- ----------------------------------------------------------------------------
function encryptErrorTable return varchar2 is
--
l_string    varchar2 (32000);
l_id        varchar2 (2000) default '';
l_tmpflag   varchar2 (1);

Counter     number := 0;
--
begin
  if g_errorTable.count > 0 then
     l_string := hr_general_utilities.Add_Separators
                  ( p_instring => to_char(g_errorTable.count)
                  , p_start => TRUE
                  );
     --
     Counter := g_errorTable.First;
     while Counter is not null
     loop
         if g_errorTable(Counter).WarningFlag = true then
            l_tmpflag := 'Y';
         else
            l_tmpflag := 'N';
         end if;

         l_string := l_string
                     || hr_general_utilities.Add_Separators
                           ( p_instring => g_errorTable(Counter).ErrorField)
                     || hr_general_utilities.Add_Separators
                           ( p_instring => g_errorTable(Counter).ErrorCode)
                     || hr_general_utilities.Add_Separators
                           ( p_instring => g_errorTable(Counter).ErrorMsg)
                     || hr_general_utilities.Add_Separators
                           ( p_instring => l_tmpflag)
                     || hr_general_utilities.Add_Separators
                       (p_instring => to_char(g_errorTable(Counter).RowNumber))
                     || hr_general_utilities.Add_Separators
                      ( p_instring => g_errorTable(Counter).EmailId)
                     || hr_general_utilities.Add_Separators
                      ( p_instring => g_errorTable(Counter).EmailMsg);
     Counter := g_errorTable.Next(Counter);
     end loop;
   end if;
   --
   if l_string is not null then
      -- encrypt the string
      l_id := hr_general_utilitieS.EPFS
              ( p_string => l_string
              , p_type => 'G'
              );
   else
      l_id := '';
   end if;

   return l_id;
end;
--
-- ----------------------------------------------------------------------------
-- |--< decryptErrorTable >---------------------------------------------------|
-- ----------------------------------------------------------------------------
procedure decryptErrorTable(p_encrypt varchar2
                          ) is
--
l_index    number;
l_tmpflag  varchar2(1);
l_tmpstring varchar2(32000);
--
begin
-- bug # 1615428
   hr_general_utilities.reset_g_cache;

--
   if p_encrypt is not null then
      -- decrypt the string

-- bug # 1615428
-- cache initialization is moved up and made us the first call in this procedure
--
--
      hr_general_utilities.DEXL (i => p_encrypt);

      l_tmpString := hr_general_utilities.REGS (p_index => 1);
      -- extract the record count
      g_count := to_number
                     (hr_general_utilities.Find_Item_In_String
                        ( p_item    => 1
                        , p_string  => l_tmpString
                        ));
      --
      -- loop through the string reassigning the record values
      --
      if g_count >= 1 then
         FOR Counter IN 1 .. g_count
         LOOP
            l_index := ((Counter - 1) * 7) + 1;

            g_errorTable(Counter).ErrorField :=
             hr_general_utilities.Find_Item_In_String
                ( p_item                => l_index + 1
                , p_string              => l_tmpString
                ) ;

            g_errorTable(Counter).ErrorCode :=
              hr_general_utilities.Find_Item_In_String
                ( p_item                => l_index + 2
                , p_string              => l_tmpString
                ) ;

            g_errorTable(Counter).ErrorMsg :=
              hr_general_utilities.Find_Item_In_String
                ( p_item                => l_index + 3
                , p_string              => l_tmpString
                ) ;

            l_tmpflag :=
               hr_general_utilities.Find_Item_In_String
                ( p_item                => l_index + 4
                , p_string              => l_tmpString
                );

            if l_tmpflag = 'Y' then
               g_errorTable(Counter).WarningFlag := true;
            else
               g_errorTable(Counter).WarningFlag := false;
            end if;

            g_errorTable(Counter).RowNumber :=
              to_number
                ( hr_general_utilities.Find_Item_In_String
                    ( p_item            => l_index + 5
                    , p_string          => l_tmpString
                    )
                );

         g_errorTable(Counter).EmailId :=
                hr_general_utilities.Find_Item_In_String
                    ( p_item            => l_index + 6
                    , p_string          => l_tmpString
                    );
         g_errorTable(Counter).EmailMsg :=
                hr_general_utilities.Find_Item_In_String
                    ( p_item            => l_index + 7
                    , p_string          => l_tmpString
                    );

         end loop;
      end if;
   end if;
end;
--
-- bug 1690449
-- ----------------------------------------------------------------------------
-- |--< deleteErrorRec >---------------------------------------------------|
-- ----------------------------------------------------------------------------
procedure deleteErrorRec(p_error_loc ErrorRecLocTable
                          ) is
--
Begin
     for Counter in 1 .. p_error_loc.count
     loop
        g_errorTable.delete(p_error_loc(Counter));
     end loop;
end;

--
end hr_errors_api;

/
