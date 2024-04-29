--------------------------------------------------------
--  DDL for Package Body PY_ZA_CDV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ZA_CDV" as
/* $Header: pyzacdv1.pkb 120.2.12010000.2 2008/09/26 07:43:03 rbabla ship $ */

function common_validation
(
   x_branch_code    in varchar2,
   x_account_number in varchar2,
   x_account_type   in number
)  return varchar2 as

cursor c1 is
   select *
   from   pay_za_bank_address_v
   where  branch_code  = x_branch_code
   and    account_type = x_account_type;

bank_record          c1%rowtype;
acct_prod            number;
acct_mod             number;
comp_number          varchar2(16);
wsum                 number;
x_acct_is_valid      varchar2(5);
check_account_number varchar2(11);
f_acct_1             number;
f_acct_2             number;

begin

   open c1;
   fetch c1 into bank_record;

   if c1%notfound then
      x_acct_is_valid := 'FALSE';
      return x_acct_is_valid;
   end if;

   if bank_record.stream_code >= 50 and bank_record.stream_code <= 99 then

      -- Branch is not computerised
      if bank_record.account_indicator in (0, 1, 2) then
         x_acct_is_valid := 'TRUE';
         return x_acct_is_valid;
         -- CDV not possible
      end if;

   else

      if bank_record.account_indicator in (0) then
         x_acct_is_valid := 'TRUE';
         return x_acct_is_valid;
         -- CDV not possible
      end if;

   end if;

   -- Getting this far means that the account number is check digit verifiable.
   check_account_number := lpad(x_account_number, 11, 0);

   acct_prod := nvl(to_number(substr(check_account_number,  1, 1)), 0) * nvl(bank_record.cdv_weighting1,  0) +
                nvl(to_number(substr(check_account_number,  2, 1)), 0) * nvl(bank_record.cdv_weighting2,  0) +
                nvl(to_number(substr(check_account_number,  3, 1)), 0) * nvl(bank_record.cdv_weighting3,  0) +
                nvl(to_number(substr(check_account_number,  4, 1)), 0) * nvl(bank_record.cdv_weighting4,  0) +
                nvl(to_number(substr(check_account_number,  5, 1)), 0) * nvl(bank_record.cdv_weighting5,  0) +
                nvl(to_number(substr(check_account_number,  6, 1)), 0) * nvl(bank_record.cdv_weighting6,  0) +
                nvl(to_number(substr(check_account_number,  7, 1)), 0) * nvl(bank_record.cdv_weighting7,  0) +
                nvl(to_number(substr(check_account_number,  8, 1)), 0) * nvl(bank_record.cdv_weighting8,  0) +
                nvl(to_number(substr(check_account_number,  9, 1)), 0) * nvl(bank_record.cdv_weighting9,  0) +
                nvl(to_number(substr(check_account_number, 10, 1)), 0) * nvl(bank_record.cdv_weighting10, 0) +
                nvl(to_number(substr(check_account_number, 11, 1)), 0) * nvl(bank_record.cdv_weighting11, 0) +
                bank_record.fudge_factor;

   acct_mod := nvl(mod(acct_prod, bank_record.modulus), 0);

   if acct_mod = 0 then
      -- Acct valid. Passed CDV. No exception processing required.
      x_acct_is_valid := 'TRUE';
      return x_acct_is_valid;
   end if;

   -- Exception Code (a) - First National Bank (Current Accounts)
   if bank_record.exception_code = 'A' then

      begin

         if length(x_account_number) < 11 then

            comp_number := x_branch_code || x_account_number;

            wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  2, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  3, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  5, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  6, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  7, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  8, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  9, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number, 12, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number, 13, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number, 14, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number, 15, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number, 16, 1)), 0) * 2;

            acct_mod := nvl(mod(wsum, 10), 0);

            if substr(x_account_number, 1, 1) = '1' and acct_mod = 1 then
               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;
            elsif acct_mod = 0 then
               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;
            end if;

         end if;

         if bank_record.exception_code = 'A' and acct_mod <> 0 then

            if length(x_account_number) = 11 then

               comp_number := x_account_number;

            elsif length(x_account_number) = 13 then

               comp_number := substr(x_account_number, 0, 1) || substr(x_account_number, 4, 13);

            end if;

               wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                       nvl(to_number(substr(comp_number,  2, 1)), 0) * 2 +
                       nvl(to_number(substr(comp_number,  3, 1)), 0) * 1 +
                       nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                       nvl(to_number(substr(comp_number,  5, 1)), 0) * 1 +
                       nvl(to_number(substr(comp_number,  6, 1)), 0) * 2 +
                       nvl(to_number(substr(comp_number,  7, 1)), 0) * 1 +
                       nvl(to_number(substr(comp_number,  8, 1)), 0) * 2 +
                       nvl(to_number(substr(comp_number,  9, 1)), 0) * 1 +
                       nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                       nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

               acct_mod := nvl(mod(wsum, 10), 0);

               if acct_mod = 0 then
                  x_acct_is_valid := 'TRUE';
                  return x_acct_is_valid;
               else
                  wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 13 +
                          nvl(to_number(substr(comp_number,  2, 1)), 0) * 10 +
                          nvl(to_number(substr(comp_number,  3, 1)), 0) * 9  +
                          nvl(to_number(substr(comp_number,  4, 1)), 0) * 8  +
                          nvl(to_number(substr(comp_number,  5, 1)), 0) * 7  +
                          nvl(to_number(substr(comp_number,  6, 1)), 0) * 6  +
                          nvl(to_number(substr(comp_number,  7, 1)), 0) * 5  +
                          nvl(to_number(substr(comp_number,  8, 1)), 0) * 4  +
                          nvl(to_number(substr(comp_number,  9, 1)), 0) * 3  +
                          nvl(to_number(substr(comp_number, 10, 1)), 0) * 2  +
                          nvl(to_number(substr(comp_number, 11, 1)), 0) * 1  + 0;
               end if;

               acct_mod := nvl(mod(wsum, 11), 0);

               if acct_mod = 0 then
                  x_acct_is_valid := 'TRUE';
                  return x_acct_is_valid;
               else
                  x_acct_is_valid := 'FALSE';
                  return x_acct_is_valid;
               end if;

         end if;

      end;

   -- Exception Code (b) - Cape of Good Hope Bank, Banque Indosuez, Bank of Athens, Mercantile Bank
   elsif bank_record.exception_code = 'B' then

      begin

         if (substr(x_account_number, length(x_account_number), 1) = '0'  or
             substr(x_account_number, length(x_account_number), 1) = '1') and
            acct_mod = 1 then

            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;

         else

            x_acct_is_valid := 'FALSE';
            return x_acct_is_valid;

         end if;

      end;

   -- Exception Code (c) - First National Bank (Savings Accounts)
   elsif bank_record.exception_code = 'C' then

      begin

         if length(x_account_number) = 11 and acct_mod <> 0 then

            comp_number := x_account_number;
            wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  2, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  3, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  5, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  6, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  7, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  8, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  9, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

            acct_mod := nvl(mod(wsum, 10), 0);

         end if;

         if acct_mod = 0 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         else
            x_acct_is_valid := 'FALSE';
            return x_acct_is_valid;
         end if;

      end;

   -- Exception Code (d) - Bank of Taiwan
   elsif bank_record.exception_code = 'D' then

      begin

         if (to_number(substr(x_account_number, length(x_account_number), 1)) = acct_mod) or
            (acct_mod = 10 and substr(x_account_number, length(x_account_number), 1) = '0') then

            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;

         else

            x_acct_is_valid := 'FALSE';
            return x_acct_is_valid;

         end if;

      end;

   -- Exception Code (e) - Boland Bank
   elsif bank_record.exception_code = 'E' then

      begin

         if  (to_number(substr(x_account_number, length(x_account_number) - 1, 1) ||
                        substr(x_account_number, length(x_account_number), 1)) > 0)
         and (to_number(substr(x_account_number, length(x_account_number) - 10, 1)) = 0 and
              to_number(substr(x_account_number, length(x_account_number) -  9, 1)) > 0) then

            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;

         else

            x_acct_is_valid := 'FALSE';
            return x_acct_is_valid;

         end if;

      end;

   -- Exception Code (f) - United Bank
   elsif bank_record.exception_code = 'F' then

      begin

         -- ABSA 1
         comp_number := lpad(x_account_number, 11, 0);

         wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                 nvl(to_number(substr(comp_number,  2, 1)), 0) * 7 +
                 nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number,  5, 1)), 0) * 9 +
                 nvl(to_number(substr(comp_number,  6, 1)), 0) * 8 +
                 nvl(to_number(substr(comp_number,  7, 1)), 0) * 7 +
                 nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

         acct_mod := nvl(mod(wsum, 10), 0);
         if acct_mod = 0 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         end if;

         -- ABSA 2
         comp_number := lpad(x_account_number, 11, 0);

         wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                 nvl(to_number(substr(comp_number,  2, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number,  5, 1)), 0) * 7 +
                 nvl(to_number(substr(comp_number,  6, 1)), 0) * 6 +
                 nvl(to_number(substr(comp_number,  7, 1)), 0) * 5 +
                 nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

         acct_mod := nvl(mod(wsum, 11), 0);
         if acct_mod = 0 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         end if;

         -- ABSA 3
         comp_number := lpad(x_account_number, 11, 0);

         wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 5 +
                 nvl(to_number(substr(comp_number,  2, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number,  5, 1)), 0) * 7 +
                 nvl(to_number(substr(comp_number,  6, 1)), 0) * 6 +
                 nvl(to_number(substr(comp_number,  7, 1)), 0) * 5 +
                 nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

         acct_mod := nvl(mod(wsum, 11), 0);
         if acct_mod = 0 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         end if;

         if length(x_account_number) in (10, 11) then

            if substr(comp_number, 11, 1) in (0, 1) and acct_mod = 1 then
               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;
            end if;

         end if;

         -- ABSA 4
         comp_number := lpad(x_account_number, 11, 0);

         wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                 nvl(to_number(substr(comp_number,  2, 1)), 0) * 1 +
                 nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number,  5, 1)), 0) * 7 +
                 nvl(to_number(substr(comp_number,  6, 1)), 0) * 6 +
                 nvl(to_number(substr(comp_number,  7, 1)), 0) * 5 +
                 nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

         acct_mod := nvl(mod(wsum, 11), 0);
         if acct_mod = 0 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         end if;

         if length(x_account_number) < 10 then

            f_acct_1 := substr(x_account_number, 1, (length(x_account_number) - 1));
            f_acct_2 := (substr(x_account_number, length(x_account_number), 1) + 6);
            if f_acct_2 > 9 then
               f_acct_2 := substr((substr(x_account_number, length(x_account_number), 1) + 6), 2, 1);
            else
               f_acct_2 := substr((substr(x_account_number, length(x_account_number), 1) + 6), 1, 1);
            end if;

            comp_number := lpad(f_acct_1 || f_acct_2, 11, 0);

            wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  2, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  5, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number,  6, 1)), 0) * 6 +
                    nvl(to_number(substr(comp_number,  7, 1)), 0) * 5 +
                    nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                    nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

            acct_mod := nvl(mod(wsum, 11), 0);
            if acct_mod = 0 then
               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;
            end if;

         end if;

         -- ABSA 5
         comp_number := lpad(x_account_number, 11, 0);

         wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                 nvl(to_number(substr(comp_number,  2, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number,  5, 1)), 0) * 9 +
                 nvl(to_number(substr(comp_number,  6, 1)), 0) * 8 +
                 nvl(to_number(substr(comp_number,  7, 1)), 0) * 7 +
                 nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

         acct_mod := nvl(mod(wsum, 10), 0);
         if acct_mod = 0 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         end if;

         /*
         if length(x_account_number) < 10 then

            f_acct_1 := substr(x_account_number, 1, (length(x_account_number) - 1));
            f_acct_2 := substr((substr(x_account_number, length(x_account_number), 1) + 6), 2, 1);
            comp_number := lpad(f_acct_1 || f_acct_2, 11, 0);

            wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  2, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  5, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number,  6, 1)), 0) * 6 +
                    nvl(to_number(substr(comp_number,  7, 1)), 0) * 5 +
                    nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                    nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

            acct_mod := nvl(mod(wsum, 11), 0);

            if acct_mod = 0 then

               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;

            else

               wsum := nvl(to_number(substr(check_account_number,  1, 1)), 0) * 1 +
                       nvl(to_number(substr(check_account_number,  2, 1)), 0) * 4 +
                       nvl(to_number(substr(check_account_number,  3, 1)), 0) * 3 +
                       nvl(to_number(substr(check_account_number,  4, 1)), 0) * 2 +
                       nvl(to_number(substr(check_account_number,  5, 1)), 0) * 9 +
                       nvl(to_number(substr(check_account_number,  6, 1)), 0) * 8 +
                       nvl(to_number(substr(check_account_number,  7, 1)), 0) * 7 +
                       nvl(to_number(substr(check_account_number,  8, 1)), 0) * 4 +
                       nvl(to_number(substr(check_account_number,  9, 1)), 0) * 3 +
                       nvl(to_number(substr(check_account_number, 10, 1)), 0) * 2 +
                       nvl(to_number(substr(check_account_number, 11, 1)), 0) * 1 + 0;

               acct_mod := nvl(mod(wsum, 10), 0);

               if acct_mod = 0 then
                  x_acct_is_valid := 'TRUE';
                  return x_acct_is_valid;
               else
                  x_acct_is_valid := 'FALSE';
                  return x_acct_is_valid;
               end if;

            end if;

         elsif length(x_account_number) = 10 then

            comp_number := lpad(x_account_number, 11, 0);

            wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  2, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  5, 1)), 0) * 9 +
                    nvl(to_number(substr(comp_number,  6, 1)), 0) * 8 +
                    nvl(to_number(substr(comp_number,  7, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                    nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

            acct_mod := nvl(mod(wsum, 10), 0);
            if acct_mod = 0 then
               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;
            elsif substr(comp_number, 11, 1) in (0, 1) and acct_mod = 1 then
               x_acct_is_valid := 'TRUE';
            end if;

         end if;

         comp_number := lpad(x_account_number,11,0);

         wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                 nvl(to_number(substr(comp_number,  2, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number,  5, 1)), 0) * 7 +
                 nvl(to_number(substr(comp_number,  6, 1)), 0) * 6 +
                 nvl(to_number(substr(comp_number,  7, 1)), 0) * 5 +
                 nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

         acct_mod := nvl(mod(wsum, 11), 0);
         if acct_mod = 0 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         elsif substr(comp_number, 11, 1) in (0, 1) and acct_mod = 1 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         end if;

         comp_number := lpad(x_account_number, 11, 0);

         wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 5 +
                 nvl(to_number(substr(comp_number,  2, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number,  5, 1)), 0) * 7 +
                 nvl(to_number(substr(comp_number,  6, 1)), 0) * 6 +
                 nvl(to_number(substr(comp_number,  7, 1)), 0) * 5 +
                 nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

         acct_mod := nvl(mod(wsum, 11), 0);
         if acct_mod = 0 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         elsif substr(comp_number, 11, 1) in (0, 1) and acct_mod = 1 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         end if;

         comp_number := lpad(x_account_number, 11, 0);

         wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                 nvl(to_number(substr(comp_number,  2, 1)), 0) * 1 +
                 nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number,  5, 1)), 0) * 7 +
                 nvl(to_number(substr(comp_number,  6, 1)), 0) * 6 +
                 nvl(to_number(substr(comp_number,  7, 1)), 0) * 5 +
                 nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                 nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                 nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

         acct_mod := nvl(mod(wsum, 11), 0);
         if acct_mod = 0 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         elsif substr(comp_number, 11, 1) in (0, 1) and acct_mod = 1 then
            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;
         end if;
         */

      end;

   -- Exception Code (g) - Permanent Bank, Peoples Bank
   elsif bank_record.exception_code = 'G' then

      begin

         comp_number := lpad(substr(x_account_number, 1, 8), 11, 0);

         wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                 nvl(to_number(substr(comp_number,  2, 1)), 0) * 1 +
                 nvl(to_number(substr(comp_number,  3, 1)), 0) * 1 +
                 nvl(to_number(substr(comp_number,  4, 1)), 0) * 29 +
                 nvl(to_number(substr(comp_number,  5, 1)), 0) * 23 +
                 nvl(to_number(substr(comp_number,  6, 1)), 0) * 19 +
                 nvl(to_number(substr(comp_number,  7, 1)), 0) * 17 +
                 nvl(to_number(substr(comp_number,  8, 1)), 0) * 13 +
                 nvl(to_number(substr(comp_number,  9, 1)), 0) * 7 +
                 nvl(to_number(substr(comp_number, 10, 1)), 0) * 3 +
                 nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

         acct_mod := nvl(mod(wsum, 11), 0);

         if acct_mod = 0 then

            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;

         elsif acct_mod <> 0 and substr(x_account_number, 7, 1) = substr(x_account_number, 8, 1) then

            comp_number := lpad(substr(x_account_number, 1, 8), 11, 0);

            wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  2, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  3, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  4, 1)), 0) * 29 +
                    nvl(to_number(substr(comp_number,  5, 1)), 0) * 23 +
                    nvl(to_number(substr(comp_number,  6, 1)), 0) * 19 +
                    nvl(to_number(substr(comp_number,  7, 1)), 0) * 17 +
                    nvl(to_number(substr(comp_number,  8, 1)), 0) * 13 +
                    nvl(to_number(substr(comp_number,  9, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number, 10, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number, 11, 1)), 0) * 0 + 10;

            acct_mod := nvl(mod(wsum, 11), 0);
            if acct_mod = 0 then
               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;
            else
               x_acct_is_valid := 'FALSE';
               return x_acct_is_valid;
            end if;

         else

            x_acct_is_valid := 'FALSE';
            return x_acct_is_valid;

         end if;

      end;

   -- Exception Code (h) - Nedbank Bond Accounts
   elsif bank_record.exception_code = 'H' then

      begin

         comp_number := lpad(substr(x_account_number,1,8),11,0);
         wsum := nvl(to_number(substr(comp_number,1,1)),0)* 1 +
              nvl(to_number(substr(comp_number,2,1)),0)* 1 +
              nvl(to_number(substr(comp_number,3,1)),0)* 1 +
              nvl(to_number(substr(comp_number,4,1)),0)* 29 +
              nvl(to_number(substr(comp_number,5,1)),0)* 23 +
              nvl(to_number(substr(comp_number,6,1)),0)* 19 +
              nvl(to_number(substr(comp_number,7,1)),0)* 17 +
              nvl(to_number(substr(comp_number,8,1)),0)* 13 +
              nvl(to_number(substr(comp_number,9,1)),0)* 7 +
              nvl(to_number(substr(comp_number,10,1)),0)* 3 +
              nvl(to_number(substr(comp_number,11,1)),0)* 1 + 0;

         acct_mod := nvl(mod(wsum, 11), 0);
         if acct_mod = 0 then

            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;

         elsif acct_mod <> 0 and substr(x_account_number, 7, 1) = substr(x_account_number, 8, 1) then

            comp_number := lpad(substr(x_account_number, 1, 8), 11, 0);

            wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  2, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  3, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  4, 1)), 0) * 29 +
                    nvl(to_number(substr(comp_number,  5, 1)), 0) * 23 +
                    nvl(to_number(substr(comp_number,  6, 1)), 0) * 19 +
                    nvl(to_number(substr(comp_number,  7, 1)), 0) * 17 +
                    nvl(to_number(substr(comp_number,  8, 1)), 0) * 13 +
                    nvl(to_number(substr(comp_number,  9, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number, 10, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number, 11, 1)), 0) * 0 + 10;

            acct_mod := nvl(mod(wsum, 11), 0);

            if acct_mod = 0 then
               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;
            else
               x_acct_is_valid := 'FALSE';
               return x_acct_is_valid;
            end if;

         else

            x_acct_is_valid := 'FALSE';
            return x_acct_is_valid;

         end if;

      end;

   elsif bank_record.exception_code = 'I' then

      begin

         if length (x_account_number) < 10 then

            comp_number := x_account_number;
            wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  2, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  5, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number,  6, 1)), 0) * 6 +
                    nvl(to_number(substr(comp_number,  7, 1)), 0) * 5 +
                    nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                    nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

            acct_mod := nvl(mod(wsum, 11), 0);

            if acct_mod = 0 then

               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;

            else

               comp_number := substr(x_account_number, 1, length(x_account_number) - 1) ||
                              substr(to_char(to_number(substr(x_account_number, length(x_account_number), 1)) + 6, 'FM00'), 2, 1);

               wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                       nvl(to_number(substr(comp_number,  2, 1)), 0) * 1 +
                       nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                       nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                       nvl(to_number(substr(comp_number,  5, 1)), 0) * 7 +
                       nvl(to_number(substr(comp_number,  6, 1)), 0) * 6 +
                       nvl(to_number(substr(comp_number,  7, 1)), 0) * 5 +
                       nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                       nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                       nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                       nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

               acct_mod := nvl(mod(wsum, 11), 0);

               if acct_mod = 0 then
                  x_acct_is_valid := 'TRUE';
                  return x_acct_is_valid;
               else
                  x_acct_is_valid := 'FALSE';
                  return x_acct_is_valid;
               end if;

            end if;

         elsif length(x_account_number) = 10 then

            comp_number := x_account_number;

            wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  2, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  5, 1)), 0) * 9 +
                    nvl(to_number(substr(comp_number,  6, 1)), 0) * 8 +
                    nvl(to_number(substr(comp_number,  7, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                    nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

            acct_mod := nvl(mod(wsum, 10), 0);

            if acct_mod = 0 then
               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;
            else
               x_acct_is_valid := 'FALSE';
               return x_acct_is_valid;
            end if;

         else

            x_acct_is_valid := 'FALSE';
            return x_acct_is_valid;

         end if;

      end;

   -- Exception Code (j) - Allied Bank
   elsif bank_record.exception_code = 'J' then

      begin

         if (length(x_account_number) = 10 or length(x_account_number) = 11) and
             acct_mod = 1 and (substr(x_account_number, length(x_account_number) - 1, 1) = '0' or
             substr(x_account_number, length(x_account_number) - 1, 1) = '1') then

            x_acct_is_valid := 'TRUE';
            return x_acct_is_valid;

         elsif length(x_account_number) = 10 then

            comp_number := x_account_number;

            wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  2, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  5, 1)), 0) * 9 +
                    nvl(to_number(substr(comp_number,  6, 1)), 0) * 8 +
                    nvl(to_number(substr(comp_number,  7, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                    nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

            acct_mod := nvl(mod(wsum, 10), 0);

            if acct_mod = 0 then
               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;
            else
               x_acct_is_valid := 'FALSE';
               return x_acct_is_valid;
            end if;

         end if;

      end;

   -- Exception Code (k) - Volkskas Bank
   elsif bank_record.exception_code = 'K' then

      begin

         if length(x_account_number) = 10 then

            comp_number := x_account_number;

            wsum := nvl(to_number(substr(comp_number,  1, 1)), 0) * 1 +
                    nvl(to_number(substr(comp_number,  2, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number,  3, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number,  4, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number,  5, 1)), 0) * 9 +
                    nvl(to_number(substr(comp_number,  6, 1)), 0) * 8 +
                    nvl(to_number(substr(comp_number,  7, 1)), 0) * 7 +
                    nvl(to_number(substr(comp_number,  8, 1)), 0) * 4 +
                    nvl(to_number(substr(comp_number,  9, 1)), 0) * 3 +
                    nvl(to_number(substr(comp_number, 10, 1)), 0) * 2 +
                    nvl(to_number(substr(comp_number, 11, 1)), 0) * 1 + 0;

            acct_mod := nvl(mod(wsum, 10), 0);

            if acct_mod = 0 then
               x_acct_is_valid := 'TRUE';
               return x_acct_is_valid;
            else
               x_acct_is_valid := 'FALSE';
               return x_acct_is_valid;
            end if;

         end if;

      end;

    -- Exception Code (m) - Standard Bank of S.A
   elsif bank_record.exception_code = 'M' then
      begin
         IF length(x_account_number) = 11
         then
              IF x_branch_code <> '051001' then
                  x_acct_is_valid := 'FALSE';
                  RETURN x_acct_is_valid;
              ELSE
                 IF substr(x_account_number,-1)='1' then
                    comp_number := x_account_number;
                    wsum := nvl(to_number(substr(comp_number,1,1)),0)* 13 +
                          nvl(to_number(substr(comp_number,2,1)),0)* 12 +
                          nvl(to_number(substr(comp_number,3,1)),0)* 9 +
                          nvl(to_number(substr(comp_number,4,1)),0)* 8 +
                          nvl(to_number(substr(comp_number,5,1)),0)* 7 +
                          nvl(to_number(substr(comp_number,6,1)),0)* 6 +
                          nvl(to_number(substr(comp_number,7,1)),0)* 5 +
                          nvl(to_number(substr(comp_number,8,1)),0)* 4 +
                          nvl(to_number(substr(comp_number,9,1)),0)* 3 +
                          nvl(to_number(substr(comp_number,10,1)),0)* 2 +
                          nvl(to_number(substr(comp_number,11,1)),0)* 1 + 0;

                     acct_mod := nvl(mod(wsum, 11), 0);
                     if acct_mod = 0 then
                        x_acct_is_valid := 'TRUE';
                        return x_acct_is_valid;
                     else
                        x_acct_is_valid := 'FALSE';
                        return x_acct_is_valid;
                     END if;
                  END IF;
              END IF;
	  END IF;
      end;

   else

      -- Acct invalid. Failed CDV
      x_acct_is_valid := 'FALSE';
      return x_acct_is_valid;

   end if;

   if x_acct_is_valid is null then
      x_acct_is_valid := 'FALSE';
      return x_acct_is_valid;
   end if;

end common_validation;

end py_za_cdv;

/
