--------------------------------------------------------
--  DDL for Package Body HR_AU_TAX_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_AU_TAX_API" AS
/* $Header: hrauwrtx.pkb 120.5.12010000.5 2009/01/05 10:08:45 dduvvuri ship $ */
/*
 +===========================================================================
 |              Copyright (c) 1999 Oracle Corporation Ltd
 |                           All rights reserved.
 +===========================================================================
 |SQL Script File Name : HR AU WR TX . PKB
 |                Name : hr_au_person_tax_api
 |         Description : Person Tax API Wrapper for AU
 |
 |   Name           Date         Version Bug     Text
 |   -------------- ----------   ------- -----   ----
 |   sgoggin        11-JUN-1999  110.0           Created for AU
 |   sclarke        28-APR-2000  115.1   1262179
 |   sparker        30-JUN-2000  115.2   StatUpd Changed "PAYE INFORMATION"->"TAX INFORMATION"
 |   abajpai        30-SEP-2000  115.6   Added SFSS
 |   abajpai        11-OCT-2000  115.7   SFSS Changes Rolledback
 |   rayyadev       30-OCT-2000  115.9   considered the case of SFSS before  31-JUL-2000
 |   rsinghal       27-FEB-2001  115.10  changes for Medicare levy surcharge
     apunekar       30-APR-2001  115.11  Removed the DEFAULT null criteria for
                                         p_rebate_amount,p_dependent_children,
                                         p_tax_variation_amount in
                                         maintain_PAYE_tax_info.
     apunekar       24-APR-2001  115.12  Reintroduced the Default null criteria.
     srussell       28-FEB-2002  115.17  2240759 Add new parameter
                                         p_override_user_ent_chk in calls to
                                         py_element_entry_api.
     shoskatt       30-MAY-2002  115.18  Bug 2145933 - Changed the package to handle
                                         Senior Australian.
     kaverma        26-NOV-2002  115.19  Bug 2601218 - Changed maintain_paye_tax_info and
                                         maintain_super_info procedures.
     kaverma        04-DEC-2002  115.20  Added nocopy for parameters
     vgsriniv       17-DEC-2003  115.21  Bug:3318756. Modified cursor get_passed_tax_field_values
                                         to use fnd_date.chardate_to_date instead of to_date
     srrajago       07-JUN-2004  115.22  Bug: 3648796 - Performance Fix to remove FTS.Assigned the correct element name to the variable
                                         g_paye_element(as in seed).In the cursors csr_paye_element,csr_paye_tax_element(in the procedures
                                         maintain_paye_tax_info and maintain_SUPER_info),removed UPPER function on element_name.Value
                                         assigned to the element_name is also corrected (as in seed).Removed GSCC warnings(File.Sql.35).
     avenkatk       16-SEP-2004  115.23  Bug 3875404 -Procedure - maintain_SUPER_info - Added a new local variable for binding IN parameter.Done to avoid errors
                                         while using NOCOPY params in the Core element entry API.
     sclarke        20-NOV-2004  115.24  4035174 Added input for SFSS in procedure get_paye_input_ids
     JLin           12-JAN-2005  115.25  4108099 Changed the mode to 'CORRECTION' when it calls update_element_entry
                                         if effective_start_date is same as the session date in maintain_PAYE_tax_info
     abhkumar       30-MAR-2005  115.26  4244787 Changed the mode from UPDATE_CHANGE_INSERT to UPDATE if there dosen't exists any future rows
                                         for Tax Information
     abhkumar       08-SEP-2005  115.27  4598178 Changed related to tax variation on bonus enhancement.
     sclarke        25-FEB-2006  115.28  4704141 Added new procedure to create workbench tax info.
     sclarke        10-MAR-2006  115.30  element link for CRP tax information
     abhargav       14-Mar-2007  115.31  Renamed parameter p_hecs_sfss_flag to p_help_sfss_flag in procedure maintain_PAYE_tax_info().
     vaisriva       26-May-2008  115.32  7042960 2008 Statutory Updates - FTA Claim Changes
     keyazawa       11-SEP-2008  115.33  6310002 added set_eev_upd_mode
     keyazawa       29-SEP-2008  115.34          reverted to 115.32 ver
                                                 (removed set_eev_upd_mode, moved to pay_au_tax_info_pkg because of non public)
     dduvvuri       05-JAN-2009  115.35  7664100 'Tax Free Threshold' field in Tax Information element is not getting
                                                  updated when it is null for the first time for an assignment. It
						  should be updated with default of 'No' if it is not checked at all,
						  otherwise the payroll completes with invalid field error.

 |NOTES
 +==========================================================================================
*/
type paye_number_table   is table of number not null index by binary_integer;
g_package                           constant varchar2(33)   := 'hr_au_tax_api.';
g_paye_element                      constant varchar2(60)   := 'Tax Information'; -- Bug: 3648796
g_paye_input1                       constant varchar2(60)   := 'AUSTRALIAN RESIDENT';
g_paye_input2                       constant varchar2(60)   := 'TAX FREE THRESHOLD';
g_paye_input3                       constant varchar2(60)   := 'REBATE AMOUNT';
g_paye_input4                       constant varchar2(60)   := 'FTA CLAIM';
g_paye_input5                       constant varchar2(60)   := 'SAVINGS REBATE';
g_paye_input6                       constant varchar2(60)   := 'HECS';
g_paye_input7                       constant varchar2(60)   := 'DATE DECLARATION SIGNED';
g_paye_input8                       constant varchar2(60)   := 'MEDICARE LEVY VARIATION';
g_paye_input9                       constant varchar2(60)   := 'SPOUSE';
g_paye_input10                      constant varchar2(60)   := 'DEPENDENT CHILDREN';
g_paye_input11                      constant varchar2(60)   := 'TAX VARIATION TYPE';
g_paye_input12                      constant varchar2(60)   := 'TAX VARIATION AMOUNT';
g_paye_input13                      constant varchar2(60)   := 'TAX SCALE';
g_paye_input14                      constant varchar2(60)   := 'TAX FILE NUMBER';
g_paye_input15                      constant varchar2(60)   := 'SFSS';
g_legislation_code                  constant varchar2(2)    := 'AU';

g_debug   boolean := hr_utility.debug_enabled;


PROCEDURE maintain_PAYE_tax_info
(p_validate                         IN      BOOLEAN   DEFAULT FALSE
,p_assignment_id                    IN      NUMBER
,p_effective_start_date             IN OUT nocopy DATE
,p_effective_end_date               IN OUT nocopy DATE
,p_session_date                     IN      DATE
,p_mode                             IN      VARCHAR2
,p_business_group_id                IN      NUMBER
,p_attribute_category               IN      VARCHAR2  DEFAULT NULL
,p_attribute1                       IN      VARCHAR2  DEFAULT NULL
,p_attribute2                       IN      VARCHAR2  DEFAULT NULL
,p_attribute3                       IN      VARCHAR2  DEFAULT NULL
,p_attribute4                       IN      VARCHAR2  DEFAULT NULL
,p_attribute5                       IN      VARCHAR2  DEFAULT NULL
,p_attribute6                       IN      VARCHAR2  DEFAULT NULL
,p_attribute7                       IN      VARCHAR2  DEFAULT NULL
,p_attribute8                       IN      VARCHAR2  DEFAULT NULL
,p_attribute9                       IN      VARCHAR2  DEFAULT NULL
,p_attribute10                      IN      VARCHAR2  DEFAULT NULL
,p_attribute11                      IN      VARCHAR2  DEFAULT NULL
,p_attribute12                      IN      VARCHAR2  DEFAULT NULL
,p_attribute13                      IN      VARCHAR2  DEFAULT NULL
,p_attribute14                      IN      VARCHAR2  DEFAULT NULL
,p_attribute15                      IN      VARCHAR2  DEFAULT NULL
,p_attribute16                      IN      VARCHAR2  DEFAULT NULL
,p_attribute17                      IN      VARCHAR2  DEFAULT NULL
,p_attribute18                      IN      VARCHAR2  DEFAULT NULL
,p_attribute19                      IN      VARCHAR2  DEFAULT NULL
,p_attribute20                      IN      VARCHAR2  DEFAULT NULL
,p_entry_information_category       IN      VARCHAR2  DEFAULT NULL
,p_entry_information1               IN      VARCHAR2  DEFAULT NULL
,p_australian_resident_flag         IN      VARCHAR2
,p_tax_free_threshold_flag          IN      VARCHAR2
,p_rebate_amount                    IN      NUMBER DEFAULT NULL
,p_fta_claim_flag                   IN      VARCHAR2
,p_savings_rebate_flag              IN      VARCHAR2
,p_help_sfss_flag                   IN      VARCHAR2   /* Bug# 5258625  */
,p_declaration_signed_date          IN      VARCHAR2
,p_medicare_levy_variation_code     IN      VARCHAR2
,p_spouse_mls_flag                  IN      VARCHAR2
,p_dependent_children               IN      VARCHAR2 DEFAULT NULL
,p_tax_variation_type               IN      VARCHAR2
,p_tax_variation_amount             IN      NUMBER DEFAULT NULL
,p_tax_file_number                  IN      VARCHAR2
,p_update_warning                      OUT nocopy BOOLEAN
) IS


    type number_table   is table of number not null index by binary_integer;
    type varchar2_table is table of varchar2(60) index by binary_integer;

    l_inp_value_id_table   number_table;
    l_scr_value_table      varchar2_table;

    l_dummy                 NUMBER  := NULL;
    l_element_type_id       NUMBER  :=0;
    l_element_link_id       NUMBER  :=0;
    l_element_entry_id      NUMBER  :=0;
    l_object_version_number NUMBER;

    l_entry_information_category  pay_element_entries_f.entry_information_category%type;
    l_entry_information1          pay_element_entries_f.entry_information1%type;

    l_session_date      DATE;
    l_mode              VARCHAR2(100);

    CURSOR csr_paye_tax_element IS
        SELECT pet.element_type_id
        FROM   pay_element_types_f pet
        WHERE  pet.element_name  = 'Tax Information' -- Bug No: 3648796
        AND    l_session_date BETWEEN pet.effective_start_date AND pet.effective_end_date
        AND    legislation_code = 'AU';


    CURSOR csr_paye_tax_input_values(p_element_type_id pay_input_values_f.element_type_id%TYPE) IS
        SELECT piv.input_value_id
              ,piv.name
        FROM   pay_input_values_f  piv
        WHERE  piv.element_type_id = p_element_type_id
        AND    l_session_date BETWEEN piv.effective_start_date AND piv.effective_end_date;


    CURSOR csr_ele_entry (p_element_link NUMBER, p_inp_val NUMBER)IS
        SELECT  pee.element_entry_id,
                 object_version_number
        FROM    pay_element_entries_f pee,
                pay_element_entry_values_f pev
        WHERE   pee.assignment_id        = p_assignment_id
        AND     l_session_date BETWEEN pee.effective_start_date AND pee.effective_end_date
        AND     pee.element_link_id      = p_element_link
        AND     pev.element_entry_id     = pee.element_entry_id
        AND     l_session_date BETWEEN pev.effective_start_date AND pev.effective_end_date
        AND     pev.input_value_id       = p_inp_val;


/* Bug# 4244787 - Cursor added to check whether future element entry exists for Tax Information when the mode
                  is UPDATE_CHANGE_INSERT*/
    CURSOR csr_fut_ele_entry(c_element_entry_id NUMBER, c_effective_date DATE) is
        SELECT pee.effective_start_date, pee.effective_end_date
        FROM pay_element_entries_f pee
        WHERE pee.element_entry_id = c_element_entry_id
        AND pee.effective_start_date > c_effective_date
  ORDER BY pee.effective_start_date;

    cursor csr_leave_loading_flag
    (p_assignment_id            number
    ,p_effective_date           date
    ) is
    select scl.segment2
    from   per_all_assignments_f            asg
    ,      hr_soft_coding_keyflex           scl
    where  scl.soft_coding_keyflex_id       = asg.soft_coding_keyflex_id
    and    asg.effective_start_date         <= p_effective_date
    and    asg.effective_end_date           >= p_effective_date
    and    asg.assignment_id                = p_assignment_id;

   /* Bug No : 2601218 - Cursor to get the database tax detail field values */
    CURSOR get_prev_database_tax_fields(p_element_entry_id               NUMBER,
                                        p_au_res_input_value_id          NUMBER,
                                        p_tax_free_input_value_id        NUMBER,
                                        p_fta_input_value_id             NUMBER,
                                        p_savings_reb_input_value_id     NUMBER,
                                        p_hecs_sfss_input_value_id       NUMBER,
                                        p_dec_date_input_value_id        NUMBER,
                                        p_spouse_input_value_id          NUMBER,
                                        p_tfn_input_value_id             NUMBER,
                                        p_effective_start_date           DATE) IS
       SELECT decode(eev0.SCREEN_ENTRY_VALUE,'YS','Y','YI','Y','YC','Y','NN','N','YN','Y','Y','Y','N','N',Null)  ,
              eev1.SCREEN_ENTRY_VALUE  ,
              DECODE(
               eev2.SCREEN_ENTRY_VALUE,
               'N', 'N',
                   'Y', 'Y',
                   'NF','N',
                   'NP','N',
                   'NC','N',
                   'YF','Y',
                   'YP','Y',
                   'YC','Y',
               'N'
                    ),
              DECODE(
               eev2.SCREEN_ENTRY_VALUE,
                   'Y', 'X',
               'N', 'X',
                   'NF','F',
                   'NP','P',
                   'NC','C',
                   'YF','F',
                   'YP','P',
                   'YC','C',
                   'X'),
              decode(eev4.SCREEN_ENTRY_VALUE,'Y','Y','N','N','YY','Y','NY','N',Null) ,
              decode(eev4.SCREEN_ENTRY_VALUE,'YY','Y','NY','Y','N')  ,
              eev5.SCREEN_ENTRY_VALUE  ,
              decode(decode(eev6.SCREEN_ENTRY_VALUE,'Y','Y','N','N','YY','Y','NY','N','N'),'Y','Y',decode(eev3.SCREEN_ENTRY_VALUE,'Y','Y','N')) ,
              eev7.SCREEN_ENTRY_VALUE  ,
              pee.entry_information1
       FROM  pay_element_entries_f      pee   ,
             pay_element_entry_values_f eev0  ,
             pay_element_entry_values_f eev1  ,
             pay_element_entry_values_f eev2  ,
             pay_element_entry_values_f eev3  ,
             pay_element_entry_values_f eev4  ,
             pay_element_entry_values_f eev5  ,
             pay_element_entry_values_f eev6  ,
             pay_element_entry_values_f eev7  ,
             hr_lookups               hrl0  ,
             hr_lookups               hrl1  ,
             hr_lookups               hrl2  ,
             hr_lookups               hrl3  ,
             hr_lookups               hrl4  ,
             hr_lookups               hrl5
      WHERE  pee.element_entry_id  = p_element_entry_id
      AND    eev0.INPUT_VALUE_ID   = p_au_res_input_value_id
      AND    eev0.ELEMENT_ENTRY_ID = pee.element_entry_id
      AND    hrl0.lookup_type  (+) = 'AU_AUST_RES_SENR_AUS'
      AND    hrl0.lookup_code (+)  = eev0.SCREEN_ENTRY_VALUE
      AND    hrl0.enabled_flag  (+)= 'Y'
      AND    eev1.INPUT_VALUE_ID   = p_tax_free_input_value_id
      AND    eev1.ELEMENT_ENTRY_ID = pee.element_entry_id
      AND    hrl1.lookup_type  (+) = 'YES_NO'
      AND    hrl1.lookup_code (+)  = eev1.SCREEN_ENTRY_VALUE
      AND    hrl1.enabled_flag  (+)= 'Y'
      AND    eev2.INPUT_VALUE_ID   = p_fta_input_value_id
      AND    eev2.ELEMENT_ENTRY_ID = pee.element_entry_id
      AND    hrl2.lookup_type (+)  = 'HR_AU_FTA_PAYMENT_BASIS'
      AND    hrl2.lookup_code  (+) = eev2.SCREEN_ENTRY_VALUE
      AND    hrl2.enabled_flag (+) = 'Y'
      AND    eev3.INPUT_VALUE_ID   = p_savings_reb_input_value_id
      AND    eev3.ELEMENT_ENTRY_ID = pee.element_entry_id
      AND    hrl3.lookup_type(+)   = 'YES_NO'
      AND    hrl3.lookup_code(+)   = eev3.SCREEN_ENTRY_VALUE
      AND    hrl3.enabled_flag (+) = 'Y'
      AND    eev4.INPUT_VALUE_ID   = p_hecs_sfss_input_value_id
      AND    eev4.ELEMENT_ENTRY_ID = pee.element_entry_id
      AND    hrl4.lookup_type(+)   = 'AU_HECS_SFSS'
      AND    hrl4.lookup_code (+)  = eev4.SCREEN_ENTRY_VALUE
      AND    hrl4.enabled_flag (+) = 'Y'
      AND    eev5.INPUT_VALUE_ID   = p_dec_date_input_value_id
      AND    eev5.ELEMENT_ENTRY_ID = pee.element_entry_id
      AND    eev6.INPUT_VALUE_ID   = p_spouse_input_value_id
      AND    eev6.ELEMENT_ENTRY_ID = pee.element_entry_id
      AND    hrl5.lookup_type  (+) = 'AU_SPOUSE_MLS'
      AND    hrl5.lookup_code (+)  = eev6.SCREEN_ENTRY_VALUE
      AND    hrl5.enabled_flag (+) = 'Y'
      AND    eev7.INPUT_VALUE_ID  = p_tfn_input_value_id
      AND    eev7.ELEMENT_ENTRY_ID= pee.element_entry_id
      AND    p_effective_start_date between eev0.effective_start_date and eev0.effective_end_date
      AND    p_effective_start_date between eev1.effective_start_date and eev1.effective_end_date
      AND    p_effective_start_date between eev2.effective_start_date and eev2.effective_end_date
      AND    p_effective_start_date between eev3.effective_start_date and eev3.effective_end_date
      AND    p_effective_start_date between eev4.effective_start_date and eev4.effective_end_date
      AND    p_effective_start_date between eev5.effective_start_date and eev5.effective_end_date
      AND    p_effective_start_date between eev6.effective_start_date and eev6.effective_end_date
      AND    p_effective_start_date between eev7.effective_start_date and eev7.effective_end_date
      AND    p_effective_start_date between pee.effective_start_date and pee.effective_end_date;

   /* Bug 7042960: 2008 Statutory Updates - FTA Claim Changes */
    CURSOR get_fta_claim_flag(p_fta_claim_flag     VARCHAR2) IS
      SELECT DECODE(
                  p_fta_claim_flag,
                 'N', 'N',
                 'Y', 'N',
                 'NF','NF',
                 'NP','NP',
                 'NC','NC',
                 'YF','NF',
                 'YP','NP',
                 'YC','NC',
                 'N'
                  )
       FROM   DUAL
       WHERE rownum=1;

    /* Bug : 2601218 - Cursor to get the tax detail field value from parameters passed */
    /* Bug : 3318756 - Replaced to_date with fnd_date.chardate_to_date in the select
                       statement for p_declaration_signed_date parameter */
    CURSOR get_passed_tax_field_values( p_australian_resident_flag       VARCHAR2
                                       ,p_tax_free_threshold_flag        VARCHAR2
                                       ,p_fta_claim_flag                 VARCHAR2
                                       ,p_savings_rebate_flag            VARCHAR2
                                       ,p_hecs_sfss_flag                 VARCHAR2
                                       ,p_declaration_signed_date        VARCHAR2
                                       ,p_spouse_mls_flag                VARCHAR2
                                       ,p_tax_file_number                VARCHAR2) IS
       SELECT decode(p_australian_resident_flag,'YS','Y','YI','Y','YC','Y','NN','N','YN','Y','Y','Y','N','N',Null)  ,
              p_tax_free_threshold_flag,
              DECODE(
                  p_fta_claim_flag,
                 'N', 'N',
                 'Y', 'Y',
                 'NF','N',
                 'NP','N',
                 'NC','N',
                 'YF','Y',
                 'YP','Y',
                 'YC','Y',
                 'N'
                  ),
              DECODE(
                  p_fta_claim_flag,
                 'Y', 'X',
                 'N', 'X',
                 'NF','F',
                 'NP','P',
                 'NC','C',
                 'YF','F',
                 'YP','P',
                 'YC','C',
                 'X'),
              decode(p_hecs_sfss_flag,'Y','Y','N','N','YY','Y','NY','N',Null) ,
              decode(p_hecs_sfss_flag,'YY','Y','NY','Y','N')  ,
              fnd_date.date_to_canonical(fnd_date.chardate_to_date(p_declaration_signed_date))  ,
              decode(decode(p_spouse_mls_flag,'Y','Y','N','N','YY','Y','NY','N','N'),'Y','Y',decode(p_savings_rebate_flag,'Y','Y','N')) ,
              p_tax_file_number
       FROM   DUAL
       WHERE rownum=1;


    -- Tax scale temp variable
    L_TAX_SCALE         INTEGER         := 2;
    L_lev_lod_flg       VARCHAR2(3);
    l_upd_tax_scale     varchar2(2);

    l_curr_australian_res_flag          VARCHAR2(1);
    l_curr_tax_free_threshold_flag      VARCHAR2(1);
    l_curr_fta_claim_flag               VARCHAR2(1);
    l_curr_basis_of_payment             VARCHAR2(1);
    l_curr_hecs_flag                    VARCHAR2(1);
    l_curr_sfss_flag                    VARCHAR2(1);
    l_curr_declaration_signed_date      VARCHAR2(19);
    l_curr_rebate_flag                  VARCHAR2(1);
    l_curr_tax_file_number              VARCHAR2(11);

    l_fta_claim_flag			VARCHAR2(2); /* Bug 7042960 */

    l_prev_australian_res_flag          VARCHAR2(1);
    l_prev_tax_free_threshold_flag      VARCHAR2(1);
    l_prev_fta_claim_flag               VARCHAR2(1);
    l_prev_basis_of_payment             VARCHAR2(1);
    l_prev_hecs_flag                    VARCHAR2(1);
    l_prev_sfss_flag                    VARCHAR2(1);
    l_prev_declaration_signed_date      VARCHAR2(19);
    l_prev_rebate_flag                  VARCHAR2(1);
    l_prev_tax_file_number              VARCHAR2(11);
    l_prev_entry_information1           VARCHAR2(19);
    l_prev_record_exists                VARCHAR2(1); -- Bug No: 3648796
    l_start_date      DATE; /*Bug# 4244787*/
    l_end_date        DATE; /*Bug# 4244787*/

    l_calling_source                    VARCHAR2(10);

BEGIN

   l_prev_record_exists  :=  'Y'; -- Bug No: 3648796
   l_mode := p_mode; -- Bug 4108099

   l_session_date := TRUNC(p_session_date);
   if l_session_date = TRUNC(p_effective_start_date) -- Bug 4108099
       and l_mode = 'UPDATE' then
     l_mode := 'CORRECTION';
   end if;

   -- Get the leave loading flags.
    OPEN  csr_leave_loading_flag (p_assignment_id, l_session_date);
    FETCH csr_leave_loading_flag INTO l_lev_lod_flg;
    CLOSE csr_leave_loading_flag;

    hr_utility.trace('after leave loading');

    --SFSS Value cannot exist before 31-JUL-2000
    -- Bug#5258625
    if ((l_session_date < to_date('31/07/2000','DD/MM/YYYY')) and (substr(P_help_sfss_flag,2,1) is not null)) then
        hr_utility.set_message(801,'HR_AU_SFSS_NOT_VALID');
        hr_utility.raise_error;
    end If;

    -- MLS is not valid before 01-JUL-2000
     if ((l_session_date < to_date('01/07/2000','DD/MM/YYYY')) and (substr(p_spouse_mls_flag,2,1) =
     'Y'))
     then
        hr_utility.set_message(801,'HR_AU_MLS_NOT_VALID');
        hr_utility.raise_error;
     end If;


    -- Derive the tax scale
    L_tax_Scale := hr_au_tax_api.tax_scale
        (
        p_tax_file_number       => p_tax_file_number
        ,p_australian_resident_flag     => p_australian_resident_flag
        ,p_tax_free_threshold_flag      => nvl(p_tax_free_threshold_flag,'N') /* Bug 7664100 */
        ,p_lev_lod_flg                  => l_lev_lod_flg
        ,p_medicare_levy_variation_code => p_medicare_levy_variation_code
        ,p_tax_variation_type           => substr(p_tax_variation_type,1,1) /*Bug 4598178*/
        );
    hr_utility.trace('Tax Scale : '||to_char(L_tax_scale));
    --
    -- Get the element type id for the Tax element
    hr_utility.trace('element_type_id');
    --
    OPEN csr_paye_tax_element;
         fetch csr_paye_tax_element into l_element_type_id;
    IF (csr_paye_tax_element%NOTFOUND)
    THEN
        CLOSE csr_paye_tax_element;
        hr_utility.set_message(801,'HR_AU_NZ_ELE_TYP_NOT_FND');
        hr_utility.raise_error;
    END IF;
    CLOSE csr_paye_tax_element;

    --
    -- Get the Input Value Id for each Tax Input

    hr_utility.trace('input value id');

    --
    FOR rec_paye_tax_element in csr_paye_tax_input_values(l_element_type_id) LOOP
        IF UPPER(rec_paye_tax_element.name) = 'AUSTRALIAN RESIDENT' THEN
            l_inp_value_id_table(1) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'TAX FREE THRESHOLD' THEN
                l_inp_value_id_table(2) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'REBATE AMOUNT' THEN
            l_inp_value_id_table(3) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'FTA CLAIM' THEN
            l_inp_value_id_table(4) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'SAVINGS REBATE' THEN
            l_inp_value_id_table(5) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'HECS' THEN
            l_inp_value_id_table(6) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'DATE DECLARATION SIGNED' THEN
                l_inp_value_id_table(7) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'MEDICARE LEVY VARIATION' THEN
            l_inp_value_id_table(8) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'SPOUSE' THEN
            l_inp_value_id_table(9) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'DEPENDENT CHILDREN' THEN
            l_inp_value_id_table(10) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'TAX VARIATION TYPE' THEN
                    l_inp_value_id_table(11) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'TAX VARIATION AMOUNT' THEN
            l_inp_value_id_table(12) := rec_paye_tax_element.input_value_id;

        ELSIF UPPER(rec_paye_tax_element.name) = 'TAX SCALE' THEN
            l_inp_value_id_table(13) := rec_paye_tax_element.input_value_id;

                ELSIF UPPER(rec_paye_tax_element.name) = 'TAX FILE NUMBER' THEN
            l_inp_value_id_table(14) := rec_paye_tax_element.input_value_id;

        END IF;
    END LOOP;

    --
    -- Get the element link id for the tax information element
    --
       l_element_link_id := hr_entry_api.get_link
                            (p_assignment_id    => p_assignment_id
                            ,p_element_type_id  => l_element_type_id
                            ,p_session_date   => l_session_date);


    IF (l_element_link_id IS NULL OR l_element_link_id = 0)
    THEN
        hr_utility.set_message(801,'HR_AU_ELE_LNK_NOT_FND');
        hr_utility.raise_error;
    END IF;


    IF (l_mode IN ('CORRECTION','UPDATE','UPDATE_CHANGE_INSERT','UPDATE_OVERRIDE')) THEN
        -----------------------------------------------------------------------------
        -- Get the element entry of the tax element entry that is to be updated
        ------------------------------------------------------------------------------
        hr_utility.set_location('hr_au_tax_api.maintain_tax_info' ,7);

        OPEN csr_ele_entry(l_element_link_id, l_inp_value_id_table(1));
        FETCH csr_ele_entry INTO l_element_entry_id,l_object_version_number;
        IF (csr_ele_entry%NOTFOUND) THEN
            CLOSE csr_ele_entry;
            hr_utility.set_message(801,'HR_AU_ELE_ENT_NOT_FND');
            hr_utility.raise_error;
        END IF;
        CLOSE csr_ele_entry;


/*Bug# 4244787 - This piece of code added to change mode from UPDATE_CHANGE_INSERT to UPDATE when there are no
                 future element entry for Tax Information*/
  IF l_mode = 'UPDATE_CHANGE_INSERT' THEN
           OPEN csr_fut_ele_entry(l_element_entry_id, l_session_date);
     FETCH csr_fut_ele_entry INTO l_start_date,l_end_date;
     IF csr_fut_ele_entry%NOTFOUND THEN
        l_mode := 'UPDATE';
     END IF ;
     CLOSE csr_fut_ele_entry;
  END IF ;

        -- Bug 2145933 -- Set the Tax Scales to S,C,I for Tax Scales 11,12,13 respectively

        IF (l_tax_scale = 11 ) THEN
           l_upd_tax_scale := 'S';
        ELSIF (l_tax_scale = 12) THEN
           l_upd_tax_scale := 'I';
        ELSIF (l_tax_scale = 13) THEN
           l_upd_tax_scale := 'C';
        ELSE
           l_upd_tax_scale := l_tax_scale;
        END IF;

        hr_utility.trace('Session Date = '||l_session_date);
        hr_utility.trace('to_date = '||to_date('01/07/2008','DD/MM/YYYY'));

           /* Bug 7042960: 2008 Statutory Updates - FTA Claim Changes */
           IF (l_session_date >= to_date('01/07/2008','DD/MM/YYYY')) THEN
               open get_fta_claim_flag(p_fta_claim_flag);
               fetch get_fta_claim_flag into l_fta_claim_flag;
               close get_fta_claim_flag;
           hr_utility.trace('Inside IF: l_fta_claim_flag Value = '||l_fta_claim_flag);
           ELSE
               l_fta_claim_flag := p_fta_claim_flag;
           hr_utility.trace('Inside ELSE: l_fta_claim_flag Value = '||l_fta_claim_flag);
           END IF;

        -- Check if the API is called from Tax Declaration form or not

        /* Bug No : 2601218 - Check if the any of reportable tax field is changed
          and pass the parameters to the core api accordingly */

        l_calling_source  := pay_au_tfn_magtape.get_value();

        IF  l_calling_source = 'FORM' THEN
           l_entry_information_category  := p_entry_information_category;
           l_entry_information1          := p_entry_information1;
        ELSE

           open get_prev_database_tax_fields(
                                    l_element_entry_id,
                                    l_inp_value_id_table(1),
                                    l_inp_value_id_table(2),
                                    l_inp_value_id_table(4),
                                    l_inp_value_id_table(5),
                                    l_inp_value_id_table(6),
                                    l_inp_value_id_table(7),
                                    l_inp_value_id_table(9),
                                    l_inp_value_id_table(14),
                                    p_effective_start_date);
           fetch get_prev_database_tax_fields into
                                    l_prev_australian_res_flag      ,
                                    l_prev_tax_free_threshold_flag  ,
                                    l_prev_fta_claim_flag           ,
                                    l_prev_basis_of_payment         ,
                                    l_prev_hecs_flag                ,
                                    l_prev_sfss_flag                ,
                                    l_prev_declaration_signed_date  ,
                                    l_prev_rebate_flag              ,
                                    l_prev_tax_file_number          ,
                                    l_prev_entry_information1       ;

           IF get_prev_database_tax_fields%notfound then
              l_prev_record_exists := 'N';
           END IF;

           close get_prev_database_tax_fields;

           open  get_passed_tax_field_values(
                                    p_australian_resident_flag ,
                                    p_tax_free_threshold_flag  ,
                                    l_fta_claim_flag           ,  /* Bug 7042960 */
                                    p_savings_rebate_flag      ,
                                    p_help_sfss_flag           ,  /* Bug#5258625 */
                                    p_declaration_signed_date  ,
                                    p_spouse_mls_flag          ,
                                    p_tax_file_number);

           fetch get_passed_tax_field_values into
                                    l_curr_australian_res_flag      ,
                                    l_curr_tax_free_threshold_flag  ,
                                    l_curr_fta_claim_flag           ,
                                    l_curr_basis_of_payment         ,
                                    l_curr_hecs_flag                ,
                                    l_curr_sfss_flag                ,
                                    l_curr_declaration_signed_date  ,
                                    l_curr_rebate_flag              ,
                                    l_curr_tax_file_number          ;
           close get_passed_tax_field_values;

           IF(l_curr_australian_res_flag      <>  l_prev_australian_res_flag     or
              l_curr_tax_free_threshold_flag  <>  l_prev_tax_free_threshold_flag or
              l_curr_fta_claim_flag           <>  l_prev_fta_claim_flag          or
              l_curr_basis_of_payment         <>  l_prev_basis_of_payment        or
              l_curr_hecs_flag                <>  l_prev_hecs_flag               or
              l_curr_sfss_flag                <>  l_prev_sfss_flag               or
              l_curr_declaration_signed_date  <>  l_prev_declaration_signed_date or
              l_curr_rebate_flag              <>  l_prev_rebate_flag             or
              l_curr_tax_file_number          <>  l_prev_tax_file_number         or
              l_prev_record_exists            = 'N'       ) THEN

              l_entry_information_category := 'AU_TAX DEDUCTIONS';
              l_entry_information1         := fnd_date.date_to_canonical(sysdate);
           ELSE
              l_entry_information_category := 'AU_TAX DEDUCTIONS';
              l_entry_information1         := l_prev_entry_information1;
           END IF;

        END IF;

        -- Pass entry_information1 as null if basis of payment is null
        IF l_curr_basis_of_payment = 'X' THEN
            l_entry_information_category := 'AU_TAX DEDUCTIONS';
            l_entry_information1         := null;
        END IF;

        hr_utility.trace('Upd Tax Scale' || l_upd_tax_scale);
  hr_utility.trace('fta_claim_flag' || p_fta_claim_flag);
        py_element_entry_api.update_element_entry
            (p_validate             => p_validate
            ,p_datetrack_update_mode=> l_mode
            ,p_effective_date       => l_session_date
            ,p_business_group_id    => p_business_group_id
            ,p_element_entry_id     => l_element_entry_id
            ,p_object_version_number=> l_object_version_number
            ,p_attribute_category   => p_attribute_category
            ,p_attribute1           => p_attribute1
            ,p_attribute2           => p_attribute2
            ,p_attribute3           => p_attribute3
            ,p_attribute4           => p_attribute4
            ,p_attribute5           => p_attribute5
            ,p_attribute6           => p_attribute6
            ,p_attribute7           => p_attribute7
            ,p_attribute8           => p_attribute8
            ,p_attribute9           => p_attribute9
            ,p_attribute10          => p_attribute10
            ,p_attribute11          => p_attribute11
            ,p_attribute12          => p_attribute12
            ,p_attribute13          => p_attribute13
            ,p_attribute14          => p_attribute14
            ,p_attribute15          => p_attribute15
            ,p_attribute16          => p_attribute16
            ,p_attribute17          => p_attribute17
            ,p_attribute18          => p_attribute18
            ,p_attribute19          => p_attribute19
            ,p_attribute20          => p_attribute20
            ,p_input_value_id1      => l_inp_value_id_table(1)
            ,p_input_value_id2      => l_inp_value_id_table(2)
            ,p_input_value_id3      => l_inp_value_id_table(3)
            ,p_input_value_id4      => l_inp_value_id_table(4)
            ,p_input_value_id5      => l_inp_value_id_table(5)
            ,p_input_value_id6      => l_inp_value_id_table(6)
            ,p_input_value_id7      => l_inp_value_id_table(7)
            ,p_input_value_id8      => l_inp_value_id_table(8)
            ,p_input_value_id9      => l_inp_value_id_table(9)
            ,p_input_value_id10     => l_inp_value_id_table(10)
            ,p_input_value_id11     => l_inp_value_id_table(11)
            ,p_input_value_id12     => l_inp_value_id_table(12)
            ,p_input_value_id13     => l_inp_value_id_table(13)
            ,p_input_value_id14     => l_inp_value_id_table(14)
            ,p_entry_value1         => p_australian_resident_flag
            ,p_entry_value2         => nvl(p_tax_free_threshold_flag,'N') /* Bug 7664100 */
            ,p_entry_value3         => p_rebate_amount
            ,p_entry_value4         => l_fta_claim_flag          /* Bug 7042960 */
            ,p_entry_value5         => p_savings_rebate_flag
            ,p_entry_value6         => p_help_sfss_flag          /* Bug#5258625 */
            ,p_entry_value7         => p_declaration_signed_date
            ,p_entry_value8         => p_medicare_levy_variation_code
            ,p_entry_value9         => p_spouse_mls_flag
            ,p_entry_value10        => p_dependent_children
            ,p_entry_value11        => p_tax_variation_type
            ,p_entry_value12        => p_tax_variation_amount
            ,p_entry_value13        => l_upd_tax_scale   /* Bug 2145933 */
            ,p_entry_value14        => p_tax_file_number
            ,p_entry_information_category => l_entry_information_category
            ,p_entry_information1   => l_entry_information1
            ,p_override_user_ent_chk   => 'Y'
            ,p_effective_start_date => p_effective_start_date
            ,p_effective_end_date   => p_effective_end_date
            ,p_update_warning       => p_update_warning);
    END IF;
END maintain_PAYE_tax_info;


PROCEDURE maintain_SUPER_info
    (p_validate                     IN      BOOLEAN  DEFAULT FALSE
    ,p_assignment_id                IN      NUMBER
    ,p_effective_start_date         IN OUT nocopy DATE
    ,p_effective_end_date           IN OUT nocopy DATE
    ,p_session_date                 IN      DATE
    ,p_mode                         IN      VARCHAR2
    ,p_business_group_id            IN      NUMBER
    ,p_attribute_category           IN      VARCHAR2  DEFAULT NULL
    ,p_attribute1                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute2                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute3                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute4                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute5                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute6                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute7                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute8                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute9                   IN      VARCHAR2  DEFAULT NULL
    ,p_attribute10                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute11                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute12                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute13                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute14                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute15                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute16                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute17                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute18                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute19                  IN      VARCHAR2  DEFAULT NULL
    ,p_attribute20                  IN      VARCHAR2  DEFAULT NULL
    ,p_tfn_for_super_flag           IN      VARCHAR2  DEFAULT NULL
    ,p_update_warning                  OUT nocopy BOOLEAN
    ) IS


      type number_table   is table of number not null index by binary_integer;
      type varchar2_table is table of varchar2(60) index by binary_integer;

    l_inp_value_id_table   number_table;
    l_scr_value_table      varchar2_table;

    l_dummy                 NUMBER  := NULL;
    l_element_type_id       NUMBER  :=0;
    l_element_link_id       NUMBER  :=0;
    l_element_entry_id      NUMBER  :=0;
    l_object_version_number NUMBER;
    l_session_date      DATE;

    l_prev_spr_flag_value        VARCHAR2(1);
    l_calling_source             VARCHAR2(10);
    l_paye_element_entry_id      NUMBER;
    l_paye_object_version_number NUMBER;
    l_paye_effective_start_date  DATE;
    l_paye_effective_end_date    DATE;

-- Bug 3875404 - Local Variable added to l_tax_effective_date to support NOCOPY construct.
      l_tax_effective_date  DATE;

    CURSOR csr_paye_tax_element IS
        SELECT pet.element_type_id
        FROM   pay_element_types_f pet
        WHERE  pet.element_name  = 'Superannuation Guarantee Information'  -- Bug No: 3648796
        AND    l_session_date BETWEEN pet.effective_start_date AND pet.effective_end_date
        AND    legislation_code = 'AU';


    CURSOR csr_paye_tax_input_values(p_element_type_id pay_input_values_f.element_type_id%TYPE) IS
        SELECT piv.input_value_id
              ,piv.name
        FROM   pay_input_values_f  piv
        WHERE  piv.element_type_id = p_element_type_id
        AND    l_session_date BETWEEN piv.effective_start_date AND piv.effective_end_date;


    CURSOR csr_ele_entry (p_element_link NUMBER, p_inp_val NUMBER)IS
        SELECT  pee.element_entry_id
                 ,object_version_number
        FROM    pay_element_entries_f pee,
                pay_element_entry_values_f pev
        WHERE   pee.assignment_id        = p_assignment_id
        AND     l_session_date BETWEEN pee.effective_start_date AND pee.effective_end_date
        AND     pee.element_link_id      = p_element_link
        AND     pev.element_entry_id     = pee.element_entry_id
        AND     l_session_date BETWEEN pev.effective_start_date AND pev.effective_end_date
        AND     pev.input_value_id       = p_inp_val;

    /* Bug 2601218 : Cursor to get the database value of Superannuation flag */

    CURSOR get_prev_tfn_super_value(p_element_entry_id         NUMBER,
                                    p_spr_flag_input_value_id  NUMBER,
                                    p_effective_start_date     DATE) IS
        SELECT nvl(screen_entry_value,'N')
        FROM   pay_element_entry_values_f
        WHERE  element_entry_id = p_element_entry_id
        AND    input_value_id   = p_spr_flag_input_value_id
        AND    p_effective_start_date between effective_start_date and effective_end_date;

    /* Bug 2601218 : Cursor to get the 'Tax Information' element entry details
       for the current where Superannuation is updated */

    CURSOR get_tax_info_to_update(p_effective_start_date DATE,
                                  p_assignment_id        NUMBER) IS
        SELECT pee.element_entry_id,
               pee.object_version_number,
               pee.effective_start_date,
               pee.effective_end_date
        FROM   pay_element_types_f   pet,
               pay_element_links_f   pel,
               pay_element_entries_f pee
        WHERE  pet.element_name      = 'Tax Information'
        AND    pel.element_type_id   = pet.element_type_id
        AND    pee.element_link_id   = pel.element_link_id
        AND    pee.assignment_id     = p_assignment_id
        AND    pel.effective_start_date between pet.effective_start_date and pet.effective_end_date
        AND    p_effective_start_date   between pee.effective_start_date and pee.effective_end_date;


  BEGIN
    l_session_date := TRUNC(p_session_date);

    --
    -- Get the element type id for the Tax element
    --
    OPEN csr_paye_tax_element;
    FETCH csr_paye_tax_element INTO l_element_type_id;
    IF (csr_paye_tax_element%NOTFOUND)
    THEN
        CLOSE csr_paye_tax_element;
        hr_utility.set_message(801,'HR_AU_NZ_ELE_TYP_NOT_FND');
        hr_utility.raise_error;
    END IF;
    CLOSE csr_paye_tax_element;

    --
    -- Get the Input Value Id for each Tax Input
    --
    FOR rec_paye_tax_element in csr_paye_tax_input_values(l_element_type_id) LOOP
        IF UPPER(rec_paye_tax_element.name) = 'TFN FOR SUPERANNUATION' THEN
            l_inp_value_id_table(1) := rec_paye_tax_element.input_value_id;
        END IF;
    END LOOP;

    --
    -- Get the element link id for the tax information element
    --
    l_element_link_id := hr_entry_api.get_link
                            (p_assignment_id    => p_assignment_id
                            ,p_element_type_id  => l_element_type_id
                            ,p_session_date     => l_session_date);
    IF (l_element_link_id IS NULL OR l_element_link_id = 0)
    THEN
        hr_utility.set_message(801,'HR_AU_ELE_LNK_NOT_FND');
        hr_utility.raise_error;
    END IF;

    IF (p_mode IN ('CORRECTION','UPDATE','UPDATE_CHANGE_INSERT','UPDATE_OVERRIDE')) THEN

        -----------------------------------------------------------------------------
        -- Get the element entry of the tax element entry that is to be updated
        ------------------------------------------------------------------------------

        hr_utility.set_location('hr_au_tax_api.maintain_tax_info' ,7);

        OPEN csr_ele_entry(l_element_link_id, l_inp_value_id_table(1));
        FETCH csr_ele_entry INTO l_element_entry_id,l_object_version_number;
        IF (csr_ele_entry%NOTFOUND) THEN
            CLOSE csr_ele_entry;
            hr_utility.set_message(801,'HR_AU_ELE_ENT_NOT_FND');
            hr_utility.raise_error;
        END IF;
        CLOSE csr_ele_entry;

        -- Bug 2601218 : Update 'Tax Information' segment 1 as last update date

        l_calling_source  := pay_au_tfn_magtape.get_value();

        IF l_calling_source <> 'FORM' THEN

            OPEN get_prev_tfn_super_value(
                          l_element_entry_id ,
                          l_inp_value_id_table(1),
                          p_effective_start_date );
            FETCH get_prev_tfn_super_value INTO l_prev_spr_flag_value;
            CLOSE get_prev_tfn_super_value;

            IF nvl(p_tfn_for_super_flag,'N') <> nvl(l_prev_spr_flag_value,'N') THEN

               OPEN get_tax_info_to_update(p_effective_start_date ,
                                           p_assignment_id );
               FETCH get_tax_info_to_update INTO l_paye_element_entry_id,
                                                 l_paye_object_version_number,
                                                 l_paye_effective_start_date,
                                                 l_paye_effective_end_date;
               CLOSE get_tax_info_to_update;

-- Bug 3875404 - Stored the Value in a temporary variable for IN parameter binding.
           l_tax_effective_date := l_paye_effective_start_date ;

               py_element_entry_api.update_element_entry
                 (p_validate                 => p_validate
                 ,p_datetrack_update_mode    => 'CORRECTION'
                 ,p_effective_date           => l_tax_effective_date
                 ,p_business_group_id        => p_business_group_id
                 ,p_element_entry_id         => l_paye_element_entry_id
                 ,p_object_version_number    => l_paye_object_version_number
                 ,p_entry_information_category => 'AU_TAX_DEDUCTIONS'
                 ,p_entry_information1       => fnd_date.date_to_canonical(sysdate)
                 ,p_override_user_ent_chk    => 'Y'
                 ,p_effective_start_date     => l_paye_effective_start_date
                 ,p_effective_end_date       => l_paye_effective_end_date
                 ,p_update_warning           => p_update_warning);

            END IF;

        END IF;

        py_element_entry_api.update_element_entry
            (p_validate                 => p_validate
            ,p_datetrack_update_mode    => p_mode
            ,p_effective_date           => l_session_date
            ,p_business_group_id        => p_business_group_id
            ,p_element_entry_id         => l_element_entry_id
            ,p_object_version_number    => l_object_version_number
            ,p_attribute_category       => p_attribute_category
            ,p_attribute1               => p_attribute1
            ,p_attribute2               => p_attribute2
            ,p_attribute3               => p_attribute3
            ,p_attribute4               => p_attribute4
            ,p_attribute5               => p_attribute5
            ,p_attribute6               => p_attribute6
            ,p_attribute7               => p_attribute7
            ,p_attribute8               => p_attribute8
            ,p_attribute9               => p_attribute9
            ,p_attribute10              => p_attribute10
            ,p_attribute11              => p_attribute11
            ,p_attribute12              => p_attribute12
            ,p_attribute13              => p_attribute13
            ,p_attribute14              => p_attribute14
            ,p_attribute15              => p_attribute15
            ,p_attribute16              => p_attribute16
            ,p_attribute17              => p_attribute17
            ,p_attribute18              => p_attribute18
            ,p_attribute19              => p_attribute19
            ,p_attribute20              => p_attribute20
            ,p_input_value_id1          => l_inp_value_id_table(1)
            ,p_entry_value1             => p_tfn_for_super_flag
            ,p_override_user_ent_chk    => 'Y'
            ,p_effective_start_date     => p_effective_start_date
            ,p_effective_end_date       => p_effective_end_date
            ,p_update_warning           => p_update_warning);

    END IF;
END maintain_SUPER_info;


FUNCTION tax_scale
         (p_tax_file_number               IN    VARCHAR2
         ,p_australian_resident_flag      IN    VARCHAR2
         ,p_tax_free_threshold_flag       IN    VARCHAR2
         ,p_lev_lod_flg                   IN    VARCHAR2
         ,p_medicare_levy_variation_code  IN    VARCHAR2
         ,p_tax_variation_type            IN    VARCHAR2
         )
RETURN INTEGER IS

    L_valid_tfn_provided    BOOLEAN := FALSE;
    L_tax_scale             INTEGER; -- Bug No: 3648796
    l_procedure             varchar2(60); -- Bug No: 3648796

BEGIN
    l_procedure  :=  'tax_scale'; -- Bug No: 3648796
    L_tax_scale  := -1; -- Bug No: 3648796

    hr_utility.set_location(g_package||l_procedure, 1);
    hr_utility.trace('p_tax_file_number              - '||p_tax_file_number);
    hr_utility.trace('p_australian_resident_flag     - '||p_australian_resident_flag);
    hr_utility.trace('p_tax_free_threshold_flag      - '||p_tax_free_threshold_flag);
    hr_utility.trace('p_lev_lod_flg                  - '||p_lev_lod_flg);
    hr_utility.trace('p_medicare_levy_variation_code - '||p_medicare_levy_variation_code);
    hr_utility.trace('p_tax_variation_type           - '||p_tax_variation_type);
    --
    -- Check if a valid TFN has been supplied
    IF nvl(P_Tax_File_number,'000 000 000') ='000 000 000' THEN
        L_valid_tfn_provided := FALSE;
    ELSE
        L_valid_tfn_provided := TRUE;
    END IF;

    -- TAX SCALE 8
    IF P_tax_variation_Type = 'E' THEN
        L_tax_scale := 8;

        -- No further processing needed.
        -- Bug 980658
        hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
        return (L_tax_scale);
    END IF;

    -- TAX SCALE 9
    IF P_tax_variation_Type = 'P' THEN
        L_tax_scale := 9;
        -- No further processing needed.
        -- Bug 980658
        hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
        return (L_tax_scale);
    END IF;

    -- TAX SCALE 10
    IF P_tax_variation_Type = 'F' THEN
        L_tax_scale := 10;
        -- No further processing needed.
        -- Bug 980658
        hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
        return (L_tax_scale);
    END IF;

    -- TAX SCALE 4
    IF not L_valid_tfn_provided THEN

        L_tax_scale := 4;

        -- No further processing necessary,  is no valid TFN supplied
        -- then always scale 4. Refer to bug 971984
        hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
        return (L_tax_scale);
    END IF;

    -- TAX SCALE 3
    IF   L_valid_tfn_provided
    AND substr(P_australian_resident_flag,1,1)  = 'N' THEN /* Bug 2145933 */
        L_tax_scale := 3;

        -- No further processing needed.
        -- If a person has a TFN and is non resident the scale is
        -- always 3,   refer to bug 971982
        hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
        return (L_tax_scale);
    END IF;

    -- TAX SCALE 1
    IF  L_valid_tfn_provided
    AND P_tax_free_threshold_flag = 'N'
    AND substr(P_australian_resident_flag,1,1)  = 'Y' THEN /* Bug 2145933 */
        L_tax_scale := 1;

        -- No further processing needed.
        -- Bug 971980
        hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
        return (L_tax_scale);
    END IF;

    -- Bug 2145933 - Tax Scales 11 - 13 based on Tax Scales C,S,I

    IF   L_valid_tfn_provided
    AND  substr(p_australian_resident_flag,2,1) = 'S' THEN
       L_tax_scale := 11;
       hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
       return(L_tax_scale);
    END IF;

    IF   L_valid_tfn_provided
    AND  substr(p_australian_resident_flag,2,1) = 'I' THEN
       L_tax_scale := 12;
       hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
       return(L_tax_scale);
    END IF;

    IF   L_valid_tfn_provided
    AND  substr(p_australian_resident_flag,2,1) = 'C' THEN
       L_tax_scale := 13;
       hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
       return(L_tax_scale);
    END IF;


    -- TAX SCALE 5
    IF  L_valid_tfn_provided
    AND substr(P_australian_resident_flag,1,1)  = 'Y'  /* Bug 2145933 */
    AND P_tax_free_threshold_flag = 'Y'
    AND P_medicare_levy_variation_code = 'F' THEN
        L_tax_scale := 5;
        -- No further processing needed.
        -- Bug 971978
        hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
        return (L_tax_scale);
    END IF;

    -- TAX SCALE 6
    IF  L_valid_tfn_provided
    AND substr(P_australian_resident_flag,1,1)  = 'Y'  /* Bug 2145933 */
    AND P_tax_free_threshold_flag = 'Y'
    AND p_medicare_levy_variation_code in ('H','HA') THEN
        L_tax_scale := 6;
        hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
        return (L_tax_scale);
    END IF;

    -- TAX SCALE 2
    IF  L_valid_tfn_provided
    AND substr(P_australian_resident_flag,1,1)  = 'Y'  /* Bug 2145933 */
    AND P_tax_free_threshold_flag = 'Y'
    AND P_lev_lod_flg               = 'Y' THEN
        L_tax_scale := 2;
        hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
        return (L_tax_scale);
    END IF;

    -- TAX SCALE 7
    IF  L_valid_tfn_provided
    AND substr(P_australian_resident_flag,1,1)  = 'Y' /* Bug 2145933 */
    AND P_tax_free_threshold_flag = 'Y'
    AND P_lev_lod_flg               = 'N' THEN
        L_tax_scale := 7;
        hr_utility.trace('tax_scale - '||to_char(l_tax_scale));
        return (L_tax_scale);
    END IF;

    return (L_tax_scale);

END tax_scale;
--
-- Function to validate the national identifier
--  REturn Codes
--          TRUE  - VALID
--          FALSE - INVALID
PROCEDURE  Validate_TFN
           (p_tax_file_number IN    VARCHAR2)
IS
    L_VALID             BOOLEAN := FALSE;
    L_Weighted_result   NUMBER;
    L_Remainder         NUMBER;

BEGIN

    -- Check the format of the TFN is 111 111 111
    -- Check length is 11 characters
    L_VALID := length (P_Tax_File_Number) <= 11;

    -- Check space is in position 4
    IF L_VALID THEN
        L_VALID := substr (P_tax_file_number,4,1) = ' ';
    END IF;

    -- Check space is in position 8
    IF L_VALID THEN
            L_VALID := substr (P_tax_file_number,8,1) = ' ';
    END IF;

    -- Obtain the weighted result
    l_weighted_result :=
        TO_NUMBER (substr (p_tax_file_number,1,1) ) * 10 +
       TO_NUMBER (substr (p_tax_file_number,2,1) ) * 7 +
       TO_NUMBER (substr (p_tax_file_number,3,1) ) * 8 +
       TO_NUMBER (substr (p_tax_file_number,5,1) ) * 4 +
       TO_NUMBER (substr (p_tax_file_number,6,1) ) * 6 +
       TO_NUMBER (substr (p_tax_file_number,7,1) ) * 3+
       TO_NUMBER (substr (p_tax_file_number,9,1) ) * 5 +
       TO_NUMBER (substr (p_tax_file_number,10,1) ) * 2 +
      TO_NUMBER (substr (p_tax_file_number,11,1)
      );

   l_weighted_result := l_weighted_result/11;

   l_remainder := l_weighted_result - trunc(l_weighted_result,0);


   -- IF OK then return true
   IF l_valid and (l_remainder = 0) THEN
    null;

   -- If a valid format and one of the secret nos then this is OK
   ELSIF l_valid and p_tax_file_number in ('111 111 111','333 333 333',
                                                    '444 444 444','987 654 321',
                                                    '222 222 222' ) THEN
    null;

   ELSE
    hr_utility.set_message(801, 'HR_AU_INVALID_NATIONAL_ID');
        hr_utility.raise_error;

   END IF;
   EXCEPTION WHEN OTHERS THEN
    hr_utility.set_message(801, 'HR_AU_INVALID_NATIONAL_ID');
        hr_utility.raise_error;

END VALIDATE_TFN;
--
--
---------------------------------------------------------------------------------------------
--          PRIVATE PROCEDURE get_paye_input_ids
---------------------------------------------------------------------------------------------
--
procedure get_paye_input_ids
(p_effective_date           in      date
,p_element_type_id          in out nocopy number
,p_inp_value_id_table       in out nocopy paye_number_table
) is
  --
  l_procedure                       constant varchar2(60)   := 'get_paye_input_ids';
  --
  cursor csr_paye_input_values
  (p_element_type_id  pay_input_values_f.element_type_id%type
  ,p_effective_date   date
  ) is
  select piv.input_value_id
  ,      piv.name
  from   pay_input_values_f         piv
  where  piv.element_type_id        = p_element_type_id
  and    p_effective_date           between piv.effective_start_date and piv.effective_end_date
  order  by piv.display_sequence;
  --
  cursor csr_paye_element
  (p_effective_date         date
  ) is
  select pet.element_type_id
  from   pay_element_types_f        pet
  where  pet.element_name      = g_paye_element -- Bug No: 3648796
  and    p_effective_date      between pet.effective_start_date and pet.effective_end_date
  and    legislation_code      = g_legislation_code;
  --
begin
  --
  -- get the element type id for the paye element
  --
  hr_utility.set_location(g_package||l_procedure, 1);
  --
  open csr_paye_element(p_effective_date);
  fetch csr_paye_element
  into p_element_type_id;
  if (csr_paye_element%notfound)
  then
    close csr_paye_element;
    hr_utility.trace('p_effective_date: '||to_char(p_effective_date,'MM/DD/YYYY'));
    hr_utility.set_message(801,'HR_AU_NZ_ELE_TYP_NOT_FND');
    hr_utility.raise_error;
  end if;
  close csr_paye_element;
  --
  -- get the input value id for each tax input
  --
  for rec_paye_element in csr_paye_input_values(p_element_type_id, p_effective_date)
  loop
    if upper(rec_paye_element.name) = g_paye_input1
    then
      p_inp_value_id_table(1) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input2
    then
      p_inp_value_id_table(2) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input3
    then
      p_inp_value_id_table(3) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input4
    then
      p_inp_value_id_table(4) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input5
    then
      p_inp_value_id_table(5) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input6
    then
      p_inp_value_id_table(6) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input7
    then
      p_inp_value_id_table(7) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input8
    then
      p_inp_value_id_table(8) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input9
    then
      p_inp_value_id_table(9) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input10
    then
      p_inp_value_id_table(10) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input11
    then
      p_inp_value_id_table(11) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input12
    then
      p_inp_value_id_table(12) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input13
    then
      p_inp_value_id_table(13) := rec_paye_element.input_value_id;
      --
    elsif upper(rec_paye_element.name) = g_paye_input14
    then
      p_inp_value_id_table(14) := rec_paye_element.input_value_id;
      --


    elsif upper(rec_paye_element.name) = g_paye_input15
    then
      p_inp_value_id_table(15) := rec_paye_element.input_value_id;      --

    else
      hr_utility.trace('p_element_type_id: '||to_char(p_element_type_id));
      hr_utility.trace('Input name: '||rec_paye_element.name);
      hr_utility.trace('p_effective_date: '||to_char(p_effective_date,'MM/DD/YYYY'));
      hr_utility.set_message(801,'HR_NZ_INPUT_VALUE_NOT_FOUND');
      hr_utility.raise_error;
    end if;
  end loop;
  --
  hr_utility.set_location(g_package||l_procedure, 10);
  --
end get_paye_input_ids;
--
---------------------------------------------------------------------------------------------
--              PRIVATE FUNCTION valid_business_group
---------------------------------------------------------------------------------------------
--
function valid_business_group
(p_business_group_id    number
) return boolean is
  --
  l_procedure           constant varchar2(60)   := 'valid_business_group';
  l_legislation_code    varchar2(30);
  --
  cursor csr_per_business_groups
  is
  select legislation_code
  from   per_business_groups
  where  business_group_id      = p_business_group_id;
  --
begin
  hr_utility.set_location(g_package||l_procedure, 1);
  open csr_per_business_groups;
  fetch csr_per_business_groups
  into l_legislation_code;
  if csr_per_business_groups%notfound
  then
    close csr_per_business_groups;
    hr_utility.set_location(g_package||l_procedure, 2);
    hr_utility.trace('p_business_group_id: '||to_char(p_business_group_id));
    return false;
  end if;
  close csr_per_business_groups;
  --
  hr_utility.set_location(g_package||l_procedure, 10);
  if l_legislation_code = g_legislation_code
  then
    return true;
  else
    return false;
  end if;
  --
end valid_business_group;
--
---------------------------------------------------------------------------------------------
--      PUBLIC PROCEDURE create_paye_tax_info
---------------------------------------------------------------------------------------------
--
procedure create_paye_tax_info
(p_validate                         in      boolean     default false
,p_effective_date                   in      date
,p_business_group_id                in      number
,p_original_entry_id                in      number      default null
,p_assignment_id                    in      number
,p_entry_type                       in      varchar2
,p_cost_allocation_keyflex_id       in      number      default null
,p_updating_action_id               in      number      default null
,p_comment_id                       in      number      default null
,p_reason                           in      varchar2    default null
,p_target_entry_id                  in      number      default null
,p_subpriority                      in      number      default null
,p_date_earned                      in      date        default null
,p_attribute_category               in      varchar2    default null
,p_attribute1                       in      varchar2    default null
,p_attribute2                       in      varchar2    default null
,p_attribute3                       in      varchar2    default null
,p_attribute4                       in      varchar2    default null
,p_attribute5                       in      varchar2    default null
,p_attribute6                       in      varchar2    default null
,p_attribute7                       in      varchar2    default null
,p_attribute8                       in      varchar2    default null
,p_attribute9                       in      varchar2    default null
,p_attribute10                      in      varchar2    default null
,p_attribute11                      in      varchar2    default null
,p_attribute12                      in      varchar2    default null
,p_attribute13                      in      varchar2    default null
,p_attribute14                      in      varchar2    default null
,p_attribute15                      in      varchar2    default null
,p_attribute16                      in      varchar2    default null
,p_attribute17                      in      varchar2    default null
,p_attribute18                      in      varchar2    default null
,p_attribute19                      in      varchar2    default null
,p_attribute20                      in      varchar2    default null
,p_australian_resident_flag         in      varchar2
,p_tax_free_threshold_flag          in      varchar2
,p_rebate_amount                    in      number      default null
,p_fta_claim_flag                   in      varchar2
,p_savings_rebate_flag              in      varchar2
,p_hecs_sfss_flag                   in      varchar2
,p_declaration_signed_date          in      varchar2
,p_medicare_levy_variation_code     in      varchar2
,p_spouse_mls_flag                  in      varchar2
,p_dependent_children               in      varchar2    default null
,p_tax_variation_type               in      varchar2
,p_tax_variation_amount             in      number      default null
,p_tax_file_number                  in      varchar2
,p_effective_start_date                out nocopy date
,p_effective_end_date                  out nocopy date
,p_element_entry_id                    out nocopy number
,p_object_version_number               out nocopy number
,p_create_warning                      out nocopy boolean
) is
  --
  type varchar2_table is table of varchar2(60) index by binary_integer;
  --
  l_procedure                   varchar2(33); -- Bug No: 3648796
  l_inp_value_id_table          paye_number_table;
  l_effective_start_date        date;
  l_effective_end_date          date;
  l_element_entry_id            number;
  l_object_version_number       number;
  l_create_warning              boolean;
  l_element_type_id             number;
  l_element_link_id             number;
  --
  -- tax scale temp variable
  l_update_warning    boolean;
  --
begin
  l_procedure  :=  'create_paye_tax_info'; -- Bug No: 3648796

  hr_utility.set_location(g_package||l_procedure, 1);
  --
  -- Ensure business group supplied is Australian
  --
  if not valid_business_group(p_business_group_id)
  then
    hr_utility.set_location(g_package||l_procedure, 2);
    hr_utility.set_message(801,'HR_7208_API_BUS_GRP_INVALID');
    hr_utility.raise_error;
  end if;
  --
  -- Get Element type id and input value ids
  --
  get_paye_input_ids(p_effective_date, l_element_type_id, l_inp_value_id_table);
  --
  -- Get the element link id for the Superannuation Contribution element
  --
  l_element_link_id     := hr_entry_api.get_link
                           (p_assignment_id     => p_assignment_id
                           ,p_element_type_id   => l_element_type_id
                           ,p_session_date      => p_effective_date
                           );
  if (l_element_link_id is null or l_element_link_id = 0)
  then
    hr_utility.set_message(801,'HR_AU_NZ_ELE_LNK_NOT_FND');
    hr_utility.raise_error;
  end if;
  --
  validate_tfn(p_tax_file_number);
  --
  py_element_entry_api.create_element_entry
  (p_validate                      => p_validate
  ,p_effective_date                => p_effective_date
  ,p_business_group_id             => p_business_group_id
  ,p_original_entry_id             => p_original_entry_id
  ,p_assignment_id                 => p_assignment_id
  ,p_element_link_id               => l_element_link_id
  ,p_entry_type                    => p_entry_type
  ,p_cost_allocation_keyflex_id    => p_cost_allocation_keyflex_id
  ,p_updating_action_id            => p_updating_action_id
  ,p_comment_id                    => p_comment_id
  ,p_reason                        => p_reason
  ,p_target_entry_id               => p_target_entry_id
  ,p_subpriority                   => p_subpriority
  ,p_date_earned                   => p_date_earned
  ,p_attribute_category            => p_attribute_category
  ,p_attribute1                    => p_attribute1
  ,p_attribute2                    => p_attribute2
  ,p_attribute3                    => p_attribute3
  ,p_attribute4                    => p_attribute4
  ,p_attribute5                    => p_attribute5
  ,p_attribute6                    => p_attribute6
  ,p_attribute7                    => p_attribute7
  ,p_attribute8                    => p_attribute8
  ,p_attribute9                    => p_attribute9
  ,p_attribute10                   => p_attribute10
  ,p_attribute11                   => p_attribute11
  ,p_attribute12                   => p_attribute12
  ,p_attribute13                   => p_attribute13
  ,p_attribute14                   => p_attribute14
  ,p_attribute15                   => p_attribute15
  ,p_attribute16                   => p_attribute16
  ,p_attribute17                   => p_attribute17
  ,p_attribute18                   => p_attribute18
  ,p_attribute19                   => p_attribute19
  ,p_attribute20                   => p_attribute20
  ,p_override_user_ent_chk         => 'Y'
  ,p_effective_start_date          => p_effective_start_date
  ,p_effective_end_date            => p_effective_end_date
  ,p_element_entry_id              => l_element_entry_id
  ,p_object_version_number         => l_object_version_number
  ,p_create_warning                => l_create_warning
  );
  --
  maintain_PAYE_tax_info
  (p_validate                         => p_validate
  ,p_assignment_id                    => p_assignment_id
  ,p_effective_start_date             => l_effective_start_date
  ,p_effective_end_date               => l_effective_end_date
  ,p_session_date                     => p_effective_date
  ,p_mode                             => 'CORRECTION'
  ,p_business_group_id                => p_business_group_id
  ,p_attribute_category               => p_attribute_category
  ,p_attribute1                       => p_attribute1
  ,p_attribute2                       => p_attribute2
  ,p_attribute3                       => p_attribute3
  ,p_attribute4                       => p_attribute4
  ,p_attribute5                       => p_attribute5
  ,p_attribute6                       => p_attribute6
  ,p_attribute7                       => p_attribute7
  ,p_attribute8                       => p_attribute8
  ,p_attribute9                       => p_attribute9
  ,p_attribute10                      => p_attribute10
  ,p_attribute11                      => p_attribute11
  ,p_attribute12                      => p_attribute12
  ,p_attribute13                      => p_attribute13
  ,p_attribute14                      => p_attribute14
  ,p_attribute15                      => p_attribute15
  ,p_attribute16                      => p_attribute16
  ,p_attribute17                      => p_attribute17
  ,p_attribute18                      => p_attribute18
  ,p_attribute19                      => p_attribute19
  ,p_attribute20                      => p_attribute20
  ,p_entry_information_category       => 'AU_TAX DEDUCTIONS'
  ,p_entry_information1               => fnd_date.date_to_canonical(sysdate)
  ,p_australian_resident_flag         => p_australian_resident_flag
  ,p_tax_free_threshold_flag          => p_tax_free_threshold_flag
  ,p_rebate_amount                    => p_rebate_amount
  ,p_fta_claim_flag                   => p_fta_claim_flag
  ,p_savings_rebate_flag              => p_savings_rebate_flag
  ,p_help_sfss_flag                   => p_hecs_sfss_flag    /* Bug#5258625 */
  ,p_declaration_signed_date          => p_declaration_signed_date
  ,p_medicare_levy_variation_code     => p_medicare_levy_variation_code
  ,p_spouse_mls_flag                  => p_spouse_mls_flag
  ,p_dependent_children               => p_dependent_children
  ,p_tax_variation_type               => p_tax_variation_type
  ,p_tax_variation_amount             => p_tax_variation_amount
  ,p_tax_file_number                  => p_tax_file_number
  ,p_update_warning                   => l_update_warning
  );
  --
  hr_utility.set_location(g_package||l_procedure, 30);

end create_paye_tax_info;

---------------------------------------------------------------------------------------------
--      PUBLIC PROCEDURE update_adi_tax_crp
---------------------------------------------------------------------------------------------

procedure update_adi_tax_crp
  (p_validate                     in         boolean     default false
  ,p_assignment_id                in         number
  ,p_hire_date                    in         date
  ,p_business_group_id            in         number
  ,p_payroll_id                   in         number
  ,p_legal_employer               in varchar2
  ,p_tax_file_number              in varchar2
  ,p_tax_free_threshold           in varchar2
  ,p_australian_resident          in varchar2
  ,p_hecs                         in varchar2
  ,p_sfss                         in varchar2
  ,p_leave_loading                in varchar2
  ,p_basis_of_payment             in varchar2
  ,p_declaration_signed_date      in varchar2
  ,p_medicare_levy_surcharge      in varchar2
  ,p_medicare_levy_exemption      in varchar2
  ,p_medicare_levy_dep_children   in varchar2    default null
  ,p_medicare_levy_spouse         in varchar2
  ,p_tax_variation_type           in varchar2
  ,p_tax_variation_amount         in number      default null
  ,p_tax_variation_bonus          in varchar2
  ,p_rebate_amount                in number      default null
  ,p_savings_rebate               in varchar2
  ,p_ftb_claim                    in varchar2
  ,p_senior_australian            in varchar2
  ,p_effective_date               in date        default null
  ) IS
    cursor csr_tax_element is
    select pet.element_type_id
    from   pay_element_types_f   pet
    where  pet.element_name      = g_paye_element
    and    p_hire_date      between pet.effective_start_date and pet.effective_end_date
    and    legislation_code      = g_legislation_code;
    --
    cursor csr_asg_version is
    select object_version_number
    from per_assignments_f
    where assignment_id     = p_assignment_id
    and   business_group_id = p_business_group_id;
    --
    cursor csr_element_entry(p_element_link_id number) is
    select element_entry_id
    from   pay_element_entries_f
    where  assignment_id     = p_assignment_id
    and    element_link_id   = p_element_link_id;
    --
    -- Cursor to check the element links.
    -- Checks if the element is linked to a payroll or linked to all payrolls
    --
    cursor csr_element_link
    (p_element_type_id pay_element_types_f.element_type_id%type
    ,p_payroll_id      pay_element_links_f.payroll_id%type
    ,p_business_group_id pay_element_links_f.business_group_id%type
    ,p_hire_date       date
    )  is
    select element_link_id
    ,      object_version_number
    from   pay_element_links_f
    where  element_type_id    = p_element_type_id
    and    business_group_id  = p_business_group_id
    and    (payroll_id         = p_payroll_id or link_to_all_payrolls_flag is not null)
    and    p_hire_date between effective_start_date and effective_end_date;
    --
    l_procedure                     varchar2(100) := g_package||'update_adi_tax_crp';
    --
    l_effective_start_date          per_all_assignments_f.effective_start_date%type;
    l_effective_end_date            per_all_assignments_f.effective_end_date%type;
    l_element_entry_id              pay_element_entries_f.element_entry_id%type;
    l_element_type_id               pay_element_types_f.element_type_id%type;
    l_element_link_id               pay_element_links_f.element_link_id%type;
    l_object_version_number         per_all_assignments_f.object_version_number%type;
    l_create_warning                boolean;
    l_update_warning                boolean;
    l_cagr_grade_def_id             number;
    l_cagr_concatenated_segments    varchar2(2000);
    l_comment_id                    number;
    l_soft_coding_keyflex_id        per_all_assignments_f.soft_coding_keyflex_id%type;
    l_concatenated_segments         hr_soft_coding_keyflex.concatenated_segments%TYPE;
    l_no_managers_warning           boolean;
    l_other_manager_warning         boolean;
    l_special_ceiling_step_id       per_all_assignments_f.special_ceiling_step_id%type;
    l_people_group_id               per_all_assignments_f.people_group_id%type;
    l_group_name                    pay_people_groups.group_name%type;
    l_org_now_no_manager_warning    boolean;
    l_spp_delete_warning            boolean;
    l_entries_changed_warning       varchar2(1);
    l_tax_district_changed_warning  boolean;
    l_australian_resident_flag      varchar2(20);
    l_hecs_sfss_flag                varchar2(10);
    l_fta_claim_flag                varchar2(10);
    l_spouse_mls_flag               varchar2(20);
    l_tax_variation_type            varchar2(20);
    --
  begin
  g_debug := hr_utility.debug_enabled;
    if g_debug then
      hr_utility.set_location(l_procedure,10);
      hr_utility.trace('p_assignment_id     => '||p_assignment_id);
      hr_utility.trace('p_business_group_id => '||p_business_group_id);
      hr_utility.trace('p_hire_date    => '||p_hire_date);
      hr_utility.trace('p_payroll_id               => '||to_char(p_payroll_id));
    END if;
    --
    -- Need the object_version_number to update the assignment
    --
    open csr_asg_version;
    fetch csr_asg_version into l_object_version_number;
    close csr_asg_version;
    --
    -- Update assignment with leave loading flag and Legal Employer.
    -- We are able to pass on the variables as is here since they are not overloaded
    -- for this API.
    -- The main purpose of this API is to enter field related to Australian Tax
    -- therefore additional fields (e.g. descriptive flex) are not provided.
    --
    hr_au_assignment_api.update_au_emp_asg
    (p_validate                     => p_validate
    ,p_effective_date               => p_hire_date
    ,p_datetrack_update_mode        => 'CORRECTION'        -- hard code this mode since we only use this API for RI
    ,p_assignment_id                => p_assignment_id
    ,p_object_version_number        => l_object_version_number  -- out parameter
    ,p_legal_employer_id            => p_legal_employer
    ,p_lev_lod_flg                  => p_leave_loading
    ,p_cagr_grade_def_id            => l_cagr_grade_def_id      -- out parameter
    ,p_cagr_concatenated_segments   => l_cagr_concatenated_segments               -- out parameter
    ,p_comment_id                   => l_comment_id                               -- out parameter
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id                   -- out parameter
    ,p_effective_start_date         => l_effective_start_date                     -- out parameter
    ,p_effective_end_date           => l_effective_end_date                       -- out parameter
    ,p_concatenated_segments        => l_concatenated_segments                    -- out parameter
    ,p_no_managers_warning          => l_no_managers_warning                      -- out parameter
    ,p_other_manager_warning        => l_other_manager_warning                   -- out parameter
    );
    IF g_debug THEN
      hr_utility.set_location(l_procedure,20);
      hr_utility.trace('l_object_version_number => '||l_object_version_number);
    END if;

    --
    -- The intended use of the following API call is to allow the update of
    -- payroll only ,for the assignment on implementation (creation) of employee
    -- tax information.  This means that the majority
    -- of the out parameters will not need to be returned.
    --
    hr_assignment_api.update_emp_asg_criteria
    (p_effective_date               => p_hire_date
    ,p_datetrack_update_mode        => 'CORRECTION'
    ,p_assignment_id                => p_assignment_id
    ,p_validate                     => p_validate
    ,p_payroll_id                   => p_payroll_id
    ,p_object_version_number        => l_object_version_number  -- from when we updated the asg earlier
    ,p_special_ceiling_step_id      => l_special_ceiling_step_id
    ,p_people_group_id              => l_people_group_id
    ,p_soft_coding_keyflex_id       => l_soft_coding_keyflex_id
    ,p_group_name                   => l_group_name
    ,p_effective_start_date         => l_effective_start_date
    ,p_effective_end_date           => l_effective_end_date
    ,p_org_now_no_manager_warning   => l_org_now_no_manager_warning
    ,p_other_manager_warning        => l_other_manager_warning
    ,p_spp_delete_warning           => l_spp_delete_warning
    ,p_entries_changed_warning      => l_entries_changed_warning
    ,p_tax_district_changed_warning => l_tax_district_changed_warning
    ,p_concatenated_segments        => l_concatenated_segments
    );

    IF g_debug THEN
      hr_utility.set_location(l_procedure,30);
      hr_utility.trace('p_australian_resident_flag => '||p_australian_resident);
      hr_utility.trace('p_senior_australian        => '||p_senior_australian);
      hr_utility.trace('p_payroll_id               => '||to_char(p_payroll_id));

    END if;

    --
    -- Create the "Tax Information"
    -- We call the existing API since it already encapsulates the tax business logic and therefore
    -- it will be contained in a single location.
    -- Parameters (ie. Input Values) are overloaded for "Tax Information" so we need
    -- to "translate" the appropriate values before calling the main API.
    --
    -- ---------------------------------------
    -- AUSTRALIAN RESIDENT and SENIOR
    -- ---------------------------------------
    --p_austrlian_resident_flag values Y or N
    --p_seniour                 values C,I,N,S
    --p_australian_resident_flag values NN,YC,YI,YN,YS,N,Y
    --
    -- Senior flag cannot be set if not an Australian resident
    --
    if p_australian_resident = 'N' then
      l_australian_resident_flag := p_australian_resident;
    else
      l_australian_resident_flag := p_australian_resident || p_senior_australian;
    end if;
    if g_debug then
      hr_utility.set_location(l_procedure,31);
    end if;

    -- ---------------------------------------
    -- PAYMENT BASIS and FTB CLAIM
    -- ---------------------------------------
    --p_ftb_claim_flag values Y or N
    --p_basis_of_payment values C,F,P
    --l_fta_claim_flag values N,NC,NF,NP,Y,YC,YF,YP
    --
    l_fta_claim_flag :=  p_ftb_claim || p_basis_of_payment;
    if g_debug then
      hr_utility.set_location(l_procedure,32);
    end if;

    -- ---------------------------------------
    -- HECS and SFSS
    -- ---------------------------------------
    --p_hecs_flag values Y,N
    --p_sfss_flag values Y,N
    --l_hecs_sfss_flag values NY,YY,N,Y
    --
    if p_sfss = 'N' then
      l_hecs_sfss_flag := p_hecs;
    else
      l_hecs_sfss_flag := p_hecs || p_sfss;
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_procedure,33);
    end if;

    -- ---------------------------------------
    -- SPOUSE and MLS
    -- ---------------------------------------
    --p_spouse_flag values Y,N
    --p_medicare_levy_surcharge_flag values Y,N
    --p_spouse_mls_flag values Y,N,NY,YY
    --
    if p_medicare_levy_surcharge = 'N' then
      l_spouse_mls_flag := p_medicare_levy_spouse;
    else
      l_spouse_mls_flag := p_medicare_levy_spouse || p_medicare_levy_surcharge;
    end if;

    -- ---------------------------------------
    -- TAX VARIATION and BONUS
    -- ---------------------------------------
    -- p_tax_variation_type values E,N,F,P
    -- p_tax_variation_bonus values Y,N
    -- l_tax_variation_type values E,EN,EY,F,FN,FY,N,P,PN,PY
    --
    if p_tax_variation_type = 'N' then
      l_tax_variation_type := p_tax_variation_type;
    else
      l_tax_variation_type := p_tax_variation_type || p_tax_variation_bonus;
    end if;

    if g_debug then
      hr_utility.set_location(l_procedure,40);
      hr_utility.trace('l_australian_resident_flag => '||l_australian_resident_flag);
      hr_utility.trace('l_fta_claim_flag           => '||l_fta_claim_flag);
      hr_utility.trace('l_hecs_sfss_flag           => '||l_hecs_sfss_flag);
      hr_utility.trace('l_spouse_mls_flag          => '||l_spouse_mls_flag);
      hr_utility.trace('l_tax_variation_type       => '||l_tax_variation_type);
    end if;

    -- If the Tax Information already exists for this assignment then
    -- call maintain_paye_tax_info... otherwise call call create_paye_tax_info.
    -- (After updating the payroll against the assignment the Tax element entry
    -- gets automatically created since it is a standard element.  However we
    -- still allow for case when it does not exist.
    --
    -- First need to get the element_type_id to then find the element_link_id
    open csr_tax_element;
    fetch csr_tax_element
    into l_element_type_id;
    if (csr_tax_element%notfound)
    then
      close csr_tax_element;
      IF g_debug THEN
        hr_utility.set_location(l_procedure, 50);
        hr_utility.trace('p_effective_date: '||to_char(p_hire_date,'MM/DD/YYYY'));
      END if;
      hr_utility.set_message(801,'HR_AU_NZ_ELE_TYP_NOT_FND');
      hr_utility.raise_error;
    end if;
    close csr_tax_element;

    if g_debug then
      hr_utility.set_location(l_procedure,60);
      hr_utility.trace('p_assignment_id   => '||p_assignment_id);
      hr_utility.trace('l_element_type_id => '||l_element_type_id);
    end if;
    --
    -- Got the element_type_id so can now get the element_link_id
    l_element_link_id     := hr_entry_api.get_link
                             (p_assignment_id     => p_assignment_id
                             ,p_element_type_id   => l_element_type_id
                             ,p_session_date      => p_hire_date
                             );
    if (l_element_link_id is null or l_element_link_id = 0)
    then
      if g_debug then
        hr_utility.set_location(l_procedure, 61);
      end if;
      --
      -- It is possible that the current assignment is on a payroll for which an element link does
      -- not exist, therefore we need to check the link before we create.
      --
      open csr_element_link(l_element_type_id, p_payroll_id, p_business_group_id, p_hire_date);
      fetch csr_element_link
      into l_element_link_id
      , l_object_version_number;
      if csr_element_link%notfound then
        --
        -- Create the element link
        pay_element_link_api.CREATE_ELEMENT_LINK
        (P_EFFECTIVE_DATE               => p_hire_date
        ,P_ELEMENT_TYPE_ID              => l_element_type_id
        ,P_BUSINESS_GROUP_ID            => p_business_group_id
        ,P_COSTABLE_TYPE                => 'N'
        ,P_PAYROLL_ID                   => p_payroll_id
        ,P_LINK_TO_ALL_PAYROLLS_FLAG    => 'N'
        ,P_STANDARD_LINK_FLAG           => 'Y'
        ,P_COST_CONCAT_SEGMENTS         => null
        ,P_BALANCE_CONCAT_SEGMENTS      => null
        ,P_ELEMENT_LINK_ID              => l_element_link_id
        ,P_COMMENT_ID                   => l_comment_id
        ,P_OBJECT_VERSION_NUMBER        => l_object_version_number
        ,P_EFFECTIVE_START_DATE         => l_effective_start_date
        ,P_EFFECTIVE_END_DATE           => l_effective_end_date
        );

      end if;
      --hr_utility.set_message(801,'HR_AU_NZ_ELE_LNK_NOT_FND');
      --hr_utility.raise_error;
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_procedure, 62);
      hr_utility.trace('l_element_link_id = '||to_char(l_element_link_id));
    end if;
    --
    -- Verify whether an element entry exists.
    -- (This is where to use the element_link_id)
    --
    open csr_element_entry(l_element_link_id);
    fetch csr_element_entry into l_element_entry_id;
    if csr_element_entry%notfound then
      if g_debug then
        hr_utility.set_location(l_procedure,70);
      end if;
      --
      -- The element entry does not exist so call the CREATE API
      --
      close csr_element_entry;
      hr_au_tax_api.create_paye_tax_info
      (p_validate                         => false
      ,p_effective_date                   => p_hire_date
      ,p_business_group_id                => p_business_group_id
      ,p_assignment_id                    => p_assignment_id
      ,p_entry_type                       => 'E'                                 --p_entry_type
      ,p_australian_resident_flag         => l_australian_resident_flag           --AU_AUST_RES_SENR_AUS
      ,p_tax_free_threshold_flag          => p_tax_free_threshold
      ,p_rebate_amount                    => p_rebate_amount
      ,p_fta_claim_flag                   => l_fta_claim_flag
      ,p_savings_rebate_flag              => p_savings_rebate
      ,p_hecs_sfss_flag                   => l_hecs_sfss_flag
      ,p_declaration_signed_date          => p_declaration_signed_date
      ,p_medicare_levy_variation_code     => p_medicare_levy_exemption
      ,p_spouse_mls_flag                  => l_spouse_mls_flag
      ,p_dependent_children               => p_medicare_levy_dep_children
      ,p_tax_variation_type               => l_tax_variation_type
      ,p_tax_variation_amount             => p_tax_variation_amount
      ,p_tax_file_number                  => p_tax_file_number
      ,p_effective_start_date             => l_effective_start_date
      ,p_effective_end_date               => l_effective_end_date
      ,p_element_entry_id                 => l_element_entry_id
      ,p_object_version_number            => l_object_version_number
      ,p_create_warning                   => l_create_warning
      );
    else
      if g_debug then
        hr_utility.set_location(l_procedure,80);
        hr_utility.trace('dep children = '||p_medicare_levy_dep_children);

      end if;
      --
      -- The element entry exists so call the UPDATE API
      --
      close csr_element_entry;
      maintain_PAYE_tax_info
      (p_validate                         => false
      ,p_assignment_id                    => p_assignment_id
      ,p_effective_start_date             => l_effective_start_date
      ,p_effective_end_date               => l_effective_end_date
      ,p_session_date                     => p_hire_date
      ,p_mode                             => 'CORRECTION'
      ,p_business_group_id                => p_business_group_id
      ,p_entry_information_category       => 'AU_TAX DEDUCTIONS'
      ,p_entry_information1               => fnd_date.date_to_canonical(sysdate)
      ,p_australian_resident_flag         => l_australian_resident_flag
      ,p_tax_free_threshold_flag          => p_tax_free_threshold
      ,p_rebate_amount                    => p_rebate_amount
      ,p_fta_claim_flag                   => l_fta_claim_flag
      ,p_savings_rebate_flag              => p_savings_rebate
      ,p_help_sfss_flag                   => l_hecs_sfss_flag  /* Bug#5258625 */
      ,p_declaration_signed_date          => p_declaration_signed_date
      ,p_medicare_levy_variation_code     => p_medicare_levy_exemption
      ,p_spouse_mls_flag                  => l_spouse_mls_flag
      ,p_dependent_children               => p_medicare_levy_dep_children
      ,p_tax_variation_type               => l_tax_variation_type
      ,p_tax_variation_amount             => p_tax_variation_amount
      ,p_tax_file_number                  => p_tax_file_number
      ,p_update_warning                   => l_update_warning
      );
    end if;
    --
    if g_debug then
      hr_utility.set_location(l_procedure,90);
    end if;
  end update_adi_tax_crp;

END hr_au_tax_api ;

/
