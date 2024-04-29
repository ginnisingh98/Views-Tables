--------------------------------------------------------
--  DDL for Package Body PAY_CA_BEE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_BEE" AS
/* $Header: pycabee.pkb 115.5 2003/04/23 16:45:18 tclewis ship $ */
/*

 Name          : pay_us_bee
 Description   : Canandian Legislative Hook for BEE.
 Author        : A.Logue
 Date Created  : 05-Jul-99
 Contents      : line_check_supported, validate_line.

 Change List
 -----------
 Date         Name           Vers     Bug No    Description
 +-----------+--------------+--------+---------+-----------------------+
  23-APR-2003 T.Lewis        115.3    2712265   Procedure will now return
                                                success (ie valid) when
                                                checking for base element
                                                if BEE is processing the
                                                a Special Inputs element
                                                and Base element does not
                                                exist.  This is to make it
                                                consistent with EE form.
  07-FEB-2002 R.Sirigiri     115.2              GSCC Compliance
  20-MAR-2001 A.Logue        115.2              Correct derivation of base
                                                element name and assume
                                                legislation_code is 'US'!
  23-JUL-1999 A.Logue        115.1              Added commit.
  05-JUL-1999 A.Logue        115.0              First Created.
                                                No Header validation.
                                                Line Validation: checks
                                                that the base element
                                                entry exists for a
                                                Special Input Entry.
 +-----------+--------------+--------+---------+-----------------------+
*/

function line_check_supported
return number
is
begin
   return (0);
end line_check_supported;

procedure validate_line(batch_line_id in  number,
                        valid         out nocopy number,
                        leg_message   out nocopy varchar2,
                        line_changed  out nocopy number) is

   CURSOR csr_base_entry_exists (p_element_link_id number, p_assignment_id number,
                                 p_effective_date date) IS
   SELECT 'Y'
   FROM   pay_element_entries_f pee
   WHERE  pee.element_link_id = p_element_link_id
   AND    pee.assignment_id = p_assignment_id
   AND    p_effective_date between pee.effective_start_date
                               and pee.effective_end_date;

   g_line_record pay_batch_lines%ROWTYPE;
   g_header_record pay_batch_headers%ROWTYPE;
   l_batch_line_id        NUMBER;
   l_element_name         VARCHAR2(80);
   l_base_element_name    VARCHAR2(80);
   l_base_element_type_id NUMBER;
   l_element_link_id      NUMBER;
   p_entry_exists         VARCHAR2(1);
begin
   -- nb have passed core validation + thus make certain assumptions

   valid := 0;
   line_changed := 1;
   l_batch_line_id := batch_line_id;

   select *
   into g_line_record
   from pay_batch_lines
   where batch_line_id = l_batch_line_id;

   select *
   into g_header_record
   from pay_batch_headers
   where batch_id = g_line_record.batch_id;

   --
   -- Test if element is a Special Input
   -- If so we check that the underlying base element has
   -- an existant entry
   --

   --
   -- Get element name
   --
   if (g_line_record.element_name is null) then

     -- have to use element_type_id to get element_name

       select elt.element_name
       into l_element_name
       from   pay_element_types_f elt
       where  elt.element_type_id = g_line_record.element_type_id
       and    (elt.business_group_id +0 = g_header_record.business_group_id
               or (elt.business_group_id is null
                   and elt.legislation_code = 'CA'))
       and    g_line_record.effective_date between elt.effective_start_date
                               and     elt.effective_end_date;

   else

     l_element_name := g_line_record.element_name;

   end if;
--
   --
   -- Test if element is a Special Input
   --
   IF l_element_name like '% Special Inputs' THEN

      --
      -- If so we check that the underlying base element has
      -- an existant entry
      --
      p_entry_exists := 'N';
      l_base_element_name := substr(l_element_name, 1, instr(l_element_name, ' Special Inputs') -1);

      begin

         select element_type_id
         into l_base_element_type_id
         from pay_element_types_f pet
         where  pet.element_name = l_base_element_name
         and    pet.processing_type = 'R'
         and    (pet.business_group_id = g_header_record.business_group_id
                or (pet.business_group_id IS NULL
                   and pet.legislation_code = 'CA'))
         and    g_line_record.effective_date between pet.effective_start_date
                                                 and pet.effective_end_date;

         l_element_link_id := hr_entry_api.get_link(g_line_record.assignment_id,
                                                    l_base_element_type_id,
                                                    g_line_record.effective_date);

         if l_element_link_id is not null then

            OPEN  csr_base_entry_exists(l_element_link_id, g_line_record.assignment_id,
                                        g_line_record.effective_date);
            FETCH csr_base_entry_exists INTO p_entry_exists;
            CLOSE csr_base_entry_exists;

         end if;

      exception
         when others then
            p_entry_exists := 'N';
      end;

/* bug 2712661 Will return success if this condition is met to be consistent
   with EE form */

/*      IF p_entry_exists <> 'Y' THEN
         leg_message := 'Special Inputs Base Element but does not exist.';
         valid := 1;
      END IF;
*/

   END IF;

end validate_line;

end pay_ca_bee;

/
