--------------------------------------------------------
--  DDL for Package Body PQH_ATTRIBUTE_RANGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_ATTRIBUTE_RANGES_PKG" as
/* $Header: pqrngchk.pkb 115.16 2002/12/12 22:47:59 rpasapul noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33)	:= '  pqh_rng_chk.';  -- Global package name
--
------------------------------------------------------------------------------
-- |                     Procedure Specifications
------------------------------------------------------------------------------
--
PROCEDURE select_other_routing_rules
                            (p_transaction_category_id IN   number,
                             p_attribute_range_id_list in  varchar2,
                             p_routing_type            in  varchar2,
                             p_db_ranges               OUT NOCOPY  other_ranges_tab,
                             p_db_rows                 OUT NOCOPY  number);
--
--
PROCEDURE select_other_member_rules(
                             p_transaction_category_id in  number,
                             p_routing_category_id     in number,
                             p_routing_type            in varchar2,
                             p_member_id               in number,
                             p_attribute_range_id_list in  varchar2,
                             p_db_ranges               out nocopy other_ranges_tab,
                             p_db_rows                 out nocopy number);
--
FUNCTION form_db_table(p_form_table           IN  rule_attr_tab,
                       p_db_table             IN  rule_attr_tab,
                       p_db_ranges            IN  other_ranges_tab,
                       p_no_attr              IN  number,
                       p_db_rows              IN  number,
                       p_error_routing_cat_id OUT NOCOPY number,
                       p_error_range_name     OUT NOCOPY varchar2)
                       RETURN number;
--
FUNCTION  check_unique_rules(p_table1        IN  rule_attr_tab ,
                             p_table2        IN  rule_attr_tab,
                             p_no_attributes IN  number)
                             RETURN number ;
--
PROCEDURE assign_right_values(p_dest_from_char    OUT NOCOPY varchar2,
                              p_dest_to_char      OUT NOCOPY varchar2,
                              p_dest_from_number  OUT NOCOPY number,
                              p_dest_to_number    OUT NOCOPY number,
                              p_dest_from_date    OUT NOCOPY date,
                              p_dest_to_date      OUT NOCOPY date,
                              p_src_from_char     IN varchar2,
                              p_src_to_char       IN varchar2,
                              p_src_from_number   IN number,
                              p_src_to_number     IN number,
                              p_src_from_date     IN date,
                              p_src_to_date       IN date);

PROCEDURE chk_unique_range_name(p_routing_category_id     IN number,
                                p_range_name              IN varchar2,
                                p_attribute_id_list       IN varchar2,
                                p_primary_flag            IN varchar2);
--
-- ----------------------------------------------------------------------------
-- |     fetch_attributes                                                     |
-- ----------------------------------------------------------------------------
--
-- Description : This procedure returns the List / member identifying
--               attributes for a transaction_category_id.
--
PROCEDURE fetch_attributes(p_transaction_category_id IN     number,
                           p_att_tab                 IN OUT NOCOPY att_tab,
                           no_attr                   OUT NOCOPY    number,
                           primary_flag              IN     varchar2) is
--
Cursor c1 is
  select att.attribute_name,tca.attribute_id,
         att.column_type,tca.value_style_cd,tca.value_set_id
    from pqh_txn_category_attributes tca,pqh_attributes_vl att
   where tca.transaction_category_id = p_transaction_category_id
     and tca.attribute_id            = att.attribute_id
     and tca.list_identifying_flag='Y'
   order by tca.attribute_id;
--
Cursor c2 is
  select att.attribute_name,tca.attribute_id,
         att.column_type,tca.value_style_cd,tca.value_set_id
    from pqh_txn_category_attributes tca,pqh_attributes_vl att
   where tca.transaction_category_id = p_transaction_category_id
     and tca.attribute_id            = att.attribute_id
     and tca.member_identifying_flag='Y'
   order by tca.attribute_id;
--
  l_proc  varchar2(72) := g_package||'fetch_attributes';
  l_att_tab att_tab := p_att_tab;
--
Begin
   --
   hr_utility.set_location('Entering:'||l_proc, 5);
   --
   -- If primary flag is 'Y' , return list identifiers
   --
   if primary_flag = 'Y' then
      --
      open c1;
      --
      no_attr := 1;
      loop
            --
            fetch c1 into p_att_tab(no_attr).attribute_name,
                          p_att_tab(no_attr).attribute_id,
                          p_att_tab(no_attr).column_type,
                          p_att_tab(no_attr).value_style_cd,
                          p_att_tab(no_attr).value_set_id;
            --
            exit when c1%notfound;
            --
            no_attr := no_attr + 1;
            --
      End loop;
      --
      Close c1;
      --
   else -- Return member identifiers
      --
      open c2;
      --
      no_attr := 1;
      --
      loop
            --
            fetch c2 into p_att_tab(no_attr).attribute_name,
                          p_att_tab(no_attr).attribute_id,
                          p_att_tab(no_attr).column_type,
                          p_att_tab(no_attr).value_style_cd,
                          p_att_tab(no_attr).value_set_id;
            --
            exit when c2%notfound;
            --
            no_attr := no_attr + 1;
            --
      End loop;
      --
      Close c2;
      --
   end if;
   --
   -- Decrement no_attr by 1 to account for the last fetch that failed.
   --
   no_attr := no_attr - 1;
   --
   hr_utility.set_location('Leaving:'||l_proc, 10);
   --
exception when others then
p_att_tab := l_att_tab;
no_attr := null;
raise;
end fetch_attributes;
--
--
-- ----------------------------------------------------------------------------
-- | Fetches the list and member ranges for a transaction category       |
-- ----------------------------------------------------------------------------
-- This procedure cannot be recoded with outer join as it is not possible to
-- use the outer join while using OR operand.
--
PROCEDURE fetch_ranges(p_routing_category_id in     number,
                       p_range_name          in     varchar2,
                       p_att_ranges_tab      in out nocopy att_ranges,
                       p_no_attributes       in     number,
                       p_primary_flag        in varchar2) is
 --
  type cur_type IS REF CURSOR;
  ranges_cur cur_type;
  sql_stmt varchar2(1000);
 --
  temp_rec att_ranges_rec;
  cnt number;
  l_att_ranges_tab att_ranges := p_att_ranges_tab;
 --
 l_proc   varchar2(72) := g_package||'fetch_ranges';
 --
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
    sql_stmt := 'select attribute_range_id,attribute_id,from_char,to_char,from_date,to_date,from_number,to_number,object_version_number from pqh_attribute_ranges where routing_category_id = :p and range_name = :r and ';

 if p_primary_flag = 'Y' then
    sql_stmt := sql_stmt || ' attribute_id IS NOT NULL and routing_list_member_id IS NULL and position_id IS NULL and assignment_id IS NULL order by attribute_id';

 else
    sql_stmt := sql_stmt || ' attribute_id IS NOT NULL and (routing_list_member_id IS NOT NULL OR position_id IS NOT NULL OR assignment_id IS NOT NULL) order by attribute_id';
 end if;
   --
   open ranges_cur for sql_stmt using p_routing_category_id,p_range_name;
   --
   loop
       --
       fetch ranges_cur into temp_rec.attribute_range_id,temp_rec.attribute_id,
                             temp_rec.from_char,temp_rec.to_char,
                             temp_rec.from_date,temp_rec.to_date,
                             temp_rec.from_number,temp_rec.to_number,
                             temp_rec.ovn;
       --
       exit when ranges_cur%notfound;
       --
       for cnt in 1..p_no_attributes loop
           --
           if  p_att_ranges_tab(cnt).attribute_id = temp_rec.attribute_id then
               p_att_ranges_tab(cnt).attribute_range_id := temp_rec.attribute_range_id;
               p_att_ranges_tab(cnt).from_date   := temp_rec.from_date;
               p_att_ranges_tab(cnt).to_date     := temp_rec.to_date;
               p_att_ranges_tab(cnt).from_char   := temp_rec.from_char;
               p_att_ranges_tab(cnt).to_char     := temp_rec.to_char;
               p_att_ranges_tab(cnt).from_number := temp_rec.from_number;
               p_att_ranges_tab(cnt).to_number   := temp_rec.to_number;
               p_att_ranges_tab(cnt).ovn         := temp_rec.ovn;
               exit;
           end if;
           --
       end loop;
       --
   end loop;
   --
   close ranges_cur;
 --
 cnt := cnt - 1;
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 exception when others then
p_att_ranges_tab := l_att_ranges_tab;
 raise;
end fetch_ranges;
--
--
-------------------------------------------------------------------------------
--  The following procedures are used to validate that attribute ranges
--  entered for a routing rule are unique.
--
-- ----------------------------------------------------------------------------
-- |              chk_routing_range_overlap                                  |
-- ----------------------------------------------------------------------------
--
PROCEDURE chk_routing_range_overlap
                (tab1                      in rule_attr_tab,
                 tab2                      in rule_attr_tab,
                 p_routing_type            in varchar2,
                 p_transaction_category_id in number,
                 p_attribute_range_id_list in varchar2,
                 p_no_attributes           in number,
                 p_error_code             out nocopy number,
                 p_error_routing_category out nocopy varchar2,
                 p_error_range_name       out nocopy varchar2) is

p_attr_tab1     rule_attr_tab;
p_attr_tab2     rule_attr_tab;
--
exist_db_ranges other_ranges_tab;
no_db_rows      number;
--
err_rcat        number := NULL;
ret_val         number := NULL;
--
--
  l_proc  varchar2(72) := g_package||'chk_routing_range_overlap';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
    p_attr_tab1 := tab1;
    p_attr_tab2 := tab2;
    --
    p_error_code := NULL;
    p_error_routing_category := NULL;
    p_error_range_name := NULL;
    --
    -- Select all other rules in the transaction category except the
    -- current one.
    --
    select_other_routing_rules
                      (p_transaction_category_id  => p_transaction_category_id,
                       p_attribute_range_id_list  => p_attribute_range_id_list,
                       p_routing_type             => p_routing_type,
                       p_db_ranges                => exist_db_ranges,
                       p_db_rows                  => no_db_rows);
    --
    -- If there are other rules existing , then check for overlap.
    --
    if no_db_rows > 0 then
        --
        --
        ret_val := form_db_table
                      (p_form_table           => p_attr_tab1,
                       p_db_table             => p_attr_tab2,
                       p_db_ranges            => exist_db_ranges,
                       p_no_attr              => p_no_attributes,
                       p_db_rows              => no_db_rows,
                       p_error_routing_cat_id => err_rcat,
                       p_error_range_name     => p_error_range_name);
        --
        if ret_val = 1 then
            --
            pqh_tct_bus.get_routing_category_name
                       (p_routing_category_id   => err_rcat,
                        p_routing_category_name => p_error_routing_category);
            --
            p_error_code := 1;
            --
        End if;
        --
    End if;
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End chk_routing_range_overlap;
--
--
------------------------------------------------------------------------------
--                        chk_member_range_overlap
------------------------------------------------------------------------------
--
FUNCTION chk_member_range_overlap
                (tab1                      in rule_attr_tab,
                 tab2                      in rule_attr_tab,
                 p_transaction_category_id in number,
                 p_routing_category_id     in number,
                 p_range_name              in varchar2,
                 p_routing_type            in varchar2,
                 p_member_id               in number,
                 p_attribute_range_id_list in varchar2,
                 p_no_attributes           in number,
                 p_error_range            out nocopy varchar2)
RETURN number is

p_attr_tab1     rule_attr_tab;
p_attr_tab2     rule_attr_tab;
exist_db_ranges other_ranges_tab;
no_db_rows      number;
i               number;
ret_value       number;
err_rcat        number;
--
  l_proc  varchar2(72) := g_package||'chk_member_range_overlap';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
    p_attr_tab1 := tab1;
    p_attr_tab2 := tab2;
    --
    -- Select all other rules in the transaction category except the
    -- current one.
    --
    select_other_member_rules
                      (p_transaction_category_id  => p_transaction_category_id,
                       p_attribute_range_id_list  => p_attribute_range_id_list,
                       p_routing_category_id      => p_routing_category_id,
                       p_routing_type             => p_routing_type,
                       p_member_id                => p_member_id,
                       p_db_ranges                => exist_db_ranges,
                       p_db_rows                  => no_db_rows);
    --
    -- There can be only one another rule existing . If there is another rule
    -- existing for the same member , then check for overlap.
    --
    if no_db_rows > 0 then
        --
        --
        ret_value := form_db_table
                      (p_form_table           => p_attr_tab1,
                       p_db_table             => p_attr_tab2,
                       p_db_ranges            => exist_db_ranges,
                       p_no_attr              => p_no_attributes,
                       p_db_rows              => no_db_rows,
                       p_error_routing_cat_id => err_rcat,
                       p_error_range_name     => p_error_range);
        --
        --
        if ret_value = 1 then
           RETURN 1;
        End if;
        --
    End if;
    --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 RETURN 0;
 --
End chk_member_range_overlap;
--
--
-- ----------------------------------------------------------------------------
-- |                    select_other_member_rules
-- ----------------------------------------------------------------------------
--
PROCEDURE select_other_member_rules
                            (p_transaction_category_id in  number,
                             p_routing_category_id     in number,
                             p_routing_type            in varchar2,
                             p_member_id               in number,
                             p_attribute_range_id_list in  varchar2,
                             p_db_ranges               out nocopy other_ranges_tab,
                             p_db_rows                 out nocopy number) is
--
--
TYPE cur_type        IS REF CURSOR;
other_ranges_cur     cur_type;
sql_stmt             varchar2(1000);
l_db_ranges		other_ranges_tab;

--
--
l_proc  varchar2(72) := g_package||'select_other_member_rules';
--
--
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 sql_stmt := 'Select a.routing_category_id,a.range_name,a.attribute_id,a.from_char,a.to_char,a.from_number,a.to_number,a.from_date,a.to_date '
             ||' from pqh_attribute_ranges a,pqh_routing_categories b '
             ||' where a.routing_category_id = :p_routing_category_id AND a.routing_category_id = b.routing_category_id AND b.transaction_category_id = :p_transaction_category_id and a.attribute_id IS NOT NULL'
             ||' AND a.enable_flag ='
             ||''''
             ||'Y'
             ||''''
             ||' and nvl(a.delete_flag,'||''''||'N'||''''||') <> '
             ||''''
             ||'Y'
             ||''''
             ||' AND a.attribute_range_id not in ('
             ||p_attribute_range_id_list
             ||') AND decode(:p_routing_type,'
             ||''''
             ||'R'
             ||''''
             ||',a.routing_list_member_id,'
             ||''''
             ||'P'
             ||''''
             ||',a.position_id,a.assignment_id) = :p_member_id order by 1,2,3';
  --
  --
  open other_ranges_cur for sql_stmt using p_routing_category_id,p_transaction_category_id,p_routing_type,p_member_id;
  --

  p_db_rows := 1;

  loop

   fetch other_ranges_cur into p_db_ranges(p_db_rows).routing_category_id,
                               p_db_ranges(p_db_rows).range_name,
                               p_db_ranges(p_db_rows).attribute_id,
                               p_db_ranges(p_db_rows).from_char,
                               p_db_ranges(p_db_rows).to_char,
                               p_db_ranges(p_db_rows).from_number,
                               p_db_ranges(p_db_rows).to_number,
                               p_db_ranges(p_db_rows).from_date,
                               p_db_ranges(p_db_rows).to_date;

    Exit when other_ranges_cur%notfound;
    --
    p_db_rows := p_db_rows + 1;
    --
  End loop;
  --
  p_db_rows := p_db_rows - 1;
  --
  close other_ranges_cur;
  --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 exception when others then
 p_db_ranges := l_db_ranges;
 p_db_rows   := null;
 raise;
End select_other_member_rules;
--
--
-- ----------------------------------------------------------------------------
-- |                    select_other_routing_rules
-- ----------------------------------------------------------------------------
--
PROCEDURE select_other_routing_rules
                            (p_transaction_category_id in  number,
                             p_attribute_range_id_list in  varchar2,
                             p_routing_type            in  varchar2,
                             p_db_ranges               out nocopy other_ranges_tab,
                             p_db_rows                 out nocopy number) is
--
TYPE cur_type        IS REF CURSOR;
other_ranges_cur     cur_type;
sql_stmt             varchar2(1000);
l_db_ranges 		other_ranges_tab;
--
l_proc  varchar2(72) := g_package||'select_other_routing_rules';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
 -- The foll cursor selects all other routing rules under the transcation
 -- category against which the current rule will be checked for overlap.
 --
 sql_stmt := 'Select rng.routing_category_id,rng.range_name,rng.attribute_id,rng.from_char,rng.to_char,rng.from_number,rng.to_number,rng.from_date,rng.to_date '
             ||' from pqh_attribute_ranges rng,pqh_routing_categories rct ';

 If p_routing_type = 'R' then
   sql_stmt := sql_stmt || ' Where rct.routing_list_id is not null ';
 Elsif p_routing_type = 'P' then
   sql_stmt := sql_stmt || ' Where rct.position_structure_id is not null ';
 Else
   sql_stmt := sql_stmt || ' Where rct.routing_list_id is null and rct.position_structure_id is null ';
 End if;

 sql_stmt:= sql_stmt ||' and rct.enable_flag = :enable_flag '
                     ||' and nvl(rct.delete_flag,:null_value1) <> :delete_flag'
                     ||' and nvl(rct.default_flag,:null_value2) <> :default_flag '
                     ||' and rct.routing_category_id = rng.routing_category_id'
                     ||' AND rct.transaction_category_id = :t '
                     ||' and rng.attribute_range_id not in ('
                     ||p_attribute_range_id_list
                     ||') and rng.enable_flag = :rule_enable '
                     ||' and nvl(rng.delete_flag,:null_value2) <> :delete_rule'
                     ||' and rng.routing_list_member_id is null and rng.position_id is null and rng.assignment_id is null order by 1,2,3';

  --
  --
  open other_ranges_cur for sql_stmt using 'Y','N','Y','N','Y',
                                           p_transaction_category_id,
                                           'Y','N','Y';
  --
  --
  p_db_rows := 1;
  --
  loop
   --
   fetch other_ranges_cur into p_db_ranges(p_db_rows).routing_category_id,
                               p_db_ranges(p_db_rows).range_name,
                               p_db_ranges(p_db_rows).attribute_id,
                               p_db_ranges(p_db_rows).from_char,
                               p_db_ranges(p_db_rows).to_char,
                               p_db_ranges(p_db_rows).from_number,
                               p_db_ranges(p_db_rows).to_number,
                               p_db_ranges(p_db_rows).from_date,
                               p_db_ranges(p_db_rows).to_date;

    Exit when other_ranges_cur%notfound;
    --
    hr_utility.set_location('Other rcat :'||to_char( p_db_ranges(p_db_rows).routing_category_id),9);
    hr_utility.set_location('Other Rule :'||p_db_ranges(p_db_rows).range_name,9);
    p_db_rows := p_db_rows + 1;
    --
  End loop;
  --
  p_db_rows := p_db_rows - 1;
  --
  close other_ranges_cur;
  --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
  exception when others then
 p_db_ranges := l_db_ranges;
 p_db_rows   := null;
 raise;
End select_other_routing_rules;
--
-- ----------------------------------------------------------------------------
-- |     form_db_table                                                     |
-- ----------------------------------------------------------------------------
--
FUNCTION form_db_table(p_form_table           IN  rule_attr_tab,
                       p_db_table             IN  rule_attr_tab,
                       p_db_ranges            IN  other_ranges_tab,
                       p_no_attr              IN  number,
                       p_db_rows              IN  number,
                       p_error_routing_cat_id OUT NOCOPY number,
                       p_error_range_name     OUT NOCOPY varchar2)
                       RETURN number is

wrk_db_table      rule_attr_tab;
prev_rcat_id      number(15);
prev_range_name   varchar2(30);
ret_value         number;
i number;
j number;
--
  l_proc  varchar2(72) := g_package||'form_db_table';
--
begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
   prev_rcat_id := p_db_ranges(1).routing_category_id;
   prev_range_name := p_db_ranges(1).range_name;

   wrk_db_table := p_db_table;

   For i in 1..p_db_rows loop
       --
       -- Check if we are in the same routing category and range name.
       --
       if (prev_rcat_id  = p_db_ranges(i).routing_category_id AND
           prev_range_name = p_db_ranges(i).range_name) then
           --
           --
           for j in 1..p_no_attr loop
              --
              -- copy the existing attribute range for the right attribute
              -- under the routing category and range name in the work table.
              --
              if wrk_db_table(j).attribute_id = p_db_ranges(i).attribute_id then
                  --
                  assign_right_values
                   (p_dest_from_char    => wrk_db_table(j).from_char,
                    p_dest_to_char      => wrk_db_table(j).to_char ,
                    p_dest_from_number  => wrk_db_table(j).from_number,
                    p_dest_to_number    => wrk_db_table(j).to_number ,
                    p_dest_from_date    => wrk_db_table(j).from_date,
                    p_dest_to_date      => wrk_db_table(j).to_date ,
                    p_src_from_char     => p_db_ranges(i).from_char,
                    p_src_to_char       => p_db_ranges(i).to_char,
                    p_src_from_number   => p_db_ranges(i).from_number,
                    p_src_to_number     => p_db_ranges(i).to_number,
                    p_src_from_date     => p_db_ranges(i).from_date ,
                    p_src_to_date       => p_db_ranges(i).to_date);
                  --
               End if;
               --
             End loop;
             --
         Else
             --
             -- Compare a rule in the work table against the rule from the
             -- form.
             --
             ret_value := check_unique_rules(p_table1        => p_form_table,
                                             p_table2        => wrk_db_table,
                                             p_no_attributes => p_no_attr);
             --
             -- If there was range overlap , Return error
             --
             if ret_value = 1 then
                 p_error_routing_cat_id := prev_rcat_id;
                 p_error_range_name := prev_range_name;
                 return 1;
             end if;

             --
             -- Else process next rule
             --
             prev_rcat_id    := p_db_ranges(i).routing_category_id;
             prev_range_name := p_db_ranges(i).range_name;
             wrk_db_table    := p_db_table;
             --
             for j in 1..p_no_attr loop
             --
              if wrk_db_table(j).attribute_id = p_db_ranges(i).attribute_id then
                  assign_right_values
                   (p_dest_from_char    => wrk_db_table(j).from_char,
                    p_dest_to_char      => wrk_db_table(j).to_char ,
                    p_dest_from_number  => wrk_db_table(j).from_number,
                    p_dest_to_number    => wrk_db_table(j).to_number ,
                    p_dest_from_date    => wrk_db_table(j).from_date,
                    p_dest_to_date      => wrk_db_table(j).to_date ,
                    p_src_from_char     => p_db_ranges(i).from_char,
                    p_src_to_char       => p_db_ranges(i).to_char,
                    p_src_from_number   => p_db_ranges(i).from_number,
                    p_src_to_number     => p_db_ranges(i).to_number,
                    p_src_from_date     => p_db_ranges(i).from_date ,
                    p_src_to_date       => p_db_ranges(i).to_date);
                End if;
             --
             End loop;
             --
          End if;
          --
   End loop;

   ret_value := check_unique_rules(p_table1        => p_form_table,
                                   p_table2        => wrk_db_table,
                                   p_no_attributes => p_no_attr);
   if ret_value = 1 then
      p_error_routing_cat_id := prev_rcat_id;
      p_error_range_name := prev_range_name;
      return 1;
   end if;

 hr_utility.set_location('Leaving:'||l_proc,10);
 --
 Return 0;
End form_db_table;
--
-- ----------------------------------------------------------------------------
-- |     check_unique_rules                                                  |
-- ----------------------------------------------------------------------------
--
FUNCTION  check_unique_rules(p_table1 in rule_attr_tab,
                             p_table2 in rule_attr_tab,
                             p_no_attributes in number)
                             RETURN number is
unique_flag number;
ctr         number;
tab1        rule_attr_tab;
tab2        rule_attr_tab;
--
  l_proc  varchar2(72) := g_package||'check_unique_rules';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
   tab1 := p_table1;
   tab2 := p_table2;

   unique_flag := 0;
   for ctr in 1..p_no_attributes loop

     if tab1(ctr).datatype = 'N' then

        if tab1(ctr).from_number = tab2(ctr).from_number AND
           tab1(ctr).to_number = tab2(ctr).to_number then
           unique_flag := unique_flag + 1;
        else
           if tab1(ctr).to_number < tab2(ctr).from_number OR
              tab1(ctr).from_number > tab2(ctr).to_number then
                null;
           else
                unique_flag := unique_flag + 1;
           End if;
        End if;
     elsif tab1(ctr).datatype = 'V' then
        if tab1(ctr).from_char = tab2(ctr).from_char AND
           tab1(ctr).to_char = tab2(ctr).to_char then
           unique_flag := unique_flag + 1;
        else
           if tab1(ctr).to_char < tab2(ctr).from_char OR
              tab1(ctr).from_char > tab2(ctr).to_char then
                null;
           else
                unique_flag := unique_flag + 1;
           End if;
        End if;
     elsif tab1(ctr).datatype = 'D' then
        if tab1(ctr).from_date = tab2(ctr).from_date AND
           tab1(ctr).to_date = tab2(ctr).to_date then
           unique_flag := unique_flag + 1;
        else
           if tab1(ctr).to_date < tab2(ctr).from_date OR
              tab1(ctr).from_date > tab2(ctr).to_date then
                null;
           else
                unique_flag := unique_flag + 1;
           End if;
        End if;
     End if;

    End loop;

    If unique_flag = p_no_attributes then
       return 1;
    End if;
return 0;
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End check_unique_rules;
--
-- ----------------------------------------------------------------------------
-- |     assign_right_values                                                 |
-- ----------------------------------------------------------------------------
--
PROCEDURE assign_right_values(p_dest_from_char    OUT NOCOPY varchar2,
                              p_dest_to_char      OUT NOCOPY varchar2,
                              p_dest_from_number  OUT NOCOPY number,
                              p_dest_to_number    OUT NOCOPY number,
                              p_dest_from_date    OUT NOCOPY date,
                              p_dest_to_date      OUT NOCOPY date,
                              p_src_from_char     IN varchar2,
                              p_src_to_char       IN varchar2,
                              p_src_from_number   IN number,
                              p_src_to_number     IN number,
                              p_src_from_date     IN date,
                              p_src_to_date       IN date) is
--
  l_proc  varchar2(72) := g_package||'assign_right_values';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
   p_dest_from_char   := p_src_from_char;
   p_dest_to_char     := p_src_to_char;
   p_dest_from_number := p_src_from_number;
   p_dest_to_number   := p_src_to_number;
   p_dest_from_date   := p_src_from_date;
   p_dest_to_date     := p_src_to_date ;
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End assign_right_values;
-- ----------------------------------------------------------------------------
-- |                Delete_attribute_ranges
-- ----------------------------------------------------------------------------
--Description : Function to Delete attribute ranges for invalid list/member
--              flags .
--              This procedure is called from row handler for pqh_attributes.
--              When a list or member identifier is unmarked this procedure is
--              called .
--
Procedure Delete_attribute_ranges(p_attribute_id            IN number,
                                  p_delete_attr_ranges_flag IN varchar2,
                                  p_primary_flag            IN varchar2) is
--
l_dummy                 varchar2(1);
l_attribute_range_id    pqh_attribute_ranges.attribute_range_id%type;
l_object_version_number pqh_attribute_ranges.object_version_number%type;
--
Cursor c1 is
  Select attribute_range_id , object_version_number
    from pqh_attribute_ranges
   where attribute_id IS NOT NULL
     AND attribute_id = p_attribute_id
     AND routing_list_member_id is null
     AND position_id is null
     AND assignment_id is null;
--
Cursor c2 is
  Select attribute_range_id , object_version_number
    from pqh_attribute_ranges
   where attribute_id IS NOT NULL
     AND attribute_id = p_attribute_id
     AND (routing_list_member_id is not null
      OR  position_id is not null
      OR  assignment_id is not null);
--
  l_proc  varchar2(72) := g_package||'Delete_atrribute_ranges';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
   if p_primary_flag = 'Y' then
      --
      Open c1;
      --
      loop
      --
         Fetch c1 into l_attribute_range_id , l_object_version_number;
         --
         if c1%notfound then
            exit;
         Else
           --
           -- Delete ranges from pqh_attribute_ranges for the unchecked
           -- list  identifier
           --
           If p_delete_attr_ranges_flag = 'Y' then
             --
             pqh_ATTRIBUTE_RANGES_api.delete_ATTRIBUTE_RANGE
             (p_validate              => false
             ,p_attribute_range_id    => l_attribute_range_id
             ,p_object_version_number => l_object_version_number
             ,p_effective_date        => sysdate);
             --
           Elsif p_delete_attr_ranges_flag = 'N' then
             --
             Close c1;
             hr_utility.set_message(8302,'PQH_CANNOT_UNCHECK_LIST_IDENT');
             hr_utility.raise_error;
             --
           Elsif p_delete_attr_ranges_flag = 'I' then
             --
             -- Ignore.
             --
             null;
             --
           End if;
           --
         End if;
         --
       End loop;
       --
       Close c1;
   Else
      Open c2 ;
      --
      loop
      --
         Fetch c2 into l_attribute_range_id , l_object_version_number;
         --
         if c2%notfound then
            exit;
         Else
           --
           -- Delete ranges from pqh_attribute_ranges for the unchecked
           -- member identifier ,
           --
           If p_delete_attr_ranges_flag = 'Y' then
             --
             pqh_ATTRIBUTE_RANGES_api.delete_ATTRIBUTE_RANGE
             (p_validate              => false
             ,p_attribute_range_id    => l_attribute_range_id
             ,p_object_version_number => l_object_version_number
             ,p_effective_date        => sysdate);
             --
           Elsif p_delete_attr_ranges_flag = 'N' then
             --
             Close c2;
             hr_utility.set_message(8302,'PQH_CANNOT_UNCHECK_MEM_IDENT');
             hr_utility.raise_error;
             --
           Elsif p_delete_attr_ranges_flag = 'I' then
             --
             -- Ignore.
             --
             null;
             --
           End if;
           --
         End if;
         --
       End loop;
       --
       Close c2;
       --
   End if;
   --
   --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
----------Wrapper for DML's for  PQH_ATTRIBUTE_RANGES--------------------------
--
-- The following procedures are coded because a  Range name created in the
-- form has to be inserted into the database as 1 record per attribute id
-- The form displays ranges for all the list / member identifiers  in a
-- range name as 1 row
--
--
-- ----------------------------------------------------------------------------
-- |     on_insert_attribute_ranges                                           |
-- ----------------------------------------------------------------------------
--
PROCEDURE on_insert_attribute_ranges(
                                   p_routing_category_id     IN     number,
                                   p_range_name              IN     varchar2,
                                   p_primary_flag            IN     varchar2,
                                   p_routing_list_member_id  IN     number,
                                   p_position_id             IN     number,
                                   p_assignment_id           IN     number,
                                   p_approver_flag           IN     varchar2,
                                   p_enable_flag             IN     varchar2,
                                   ins_attr_ranges_table     IN OUT NOCOPY att_ranges,
                                   p_no_attributes           IN     number) is
ctr number;
attribute_range_id_list varchar2(2000);
l_ins_attr_ranges_table att_ranges := ins_attr_ranges_table;
--
  l_proc  varchar2(72) := g_package||'on_insert_atrribute_ranges';
--
Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
   --
   -- Concatenate all attribute_range_id 's in ins_attr_ranges_table
   -- into attribute_range_id_list;
   --
   for ctr in 1..p_no_attributes loop
     if ctr = 1 then
         attribute_range_id_list := '(';
     end if;

     if ins_attr_ranges_table(ctr).attribute_range_id IS NOT NULL then
         attribute_range_id_list := attribute_range_id_list ||to_char(ins_attr_ranges_table(ctr).attribute_range_id);
     else
         attribute_range_id_list := attribute_range_id_list ||'-1';
     end if;

     if ctr < p_no_attributes then
         attribute_range_id_list := attribute_range_id_list ||',';
     else
         attribute_range_id_list := attribute_range_id_list ||')';
     end if;

   end loop;
   --
   -- The unique range name check is still there because creating a
   -- unique constraint to enforce this ,is greatly affecting performance
   --
   chk_unique_range_name(p_routing_category_id     => p_routing_category_id,
                         p_range_name              => p_range_name,
                         p_attribute_id_list       => attribute_range_id_list,
                         p_primary_flag            => p_primary_flag);

   --
   for ctr in 1..p_no_attributes loop
   --
       pqh_ATTRIBUTE_RANGES_api.create_ATTRIBUTE_RANGE
       (p_validate              => false
       ,p_attribute_range_id    => ins_attr_ranges_table(ctr).attribute_range_id
       ,p_approver_flag         => p_approver_flag
       ,p_enable_flag         => p_enable_flag
       ,p_assignment_id         => p_assignment_id
       ,p_attribute_id          => ins_attr_ranges_table(ctr).attribute_id
       ,p_from_char             => ins_attr_ranges_table(ctr).from_char
       ,p_to_char               => ins_attr_ranges_table(ctr).to_char
       ,p_from_date             => ins_attr_ranges_table(ctr).from_date
       ,p_to_date               => ins_attr_ranges_table(ctr).to_date
       ,p_from_number           => ins_attr_ranges_table(ctr).from_number
       ,p_to_number             => ins_attr_ranges_table(ctr).to_number
       ,p_position_id           => p_position_id
       ,p_range_name            => p_range_name
       ,p_routing_category_id   => p_routing_category_id
       ,p_routing_list_member_id=> p_routing_list_member_id
       ,p_object_version_number => ins_attr_ranges_table(ctr).ovn
       ,p_effective_date        => sysdate
       );
    --
    End loop;
    --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
 exception when others then
 ins_attr_ranges_table := l_ins_attr_ranges_table;
 raise;
End on_insert_attribute_ranges;
--
-- ----------------------------------------------------------------------------
-- |      insert_update_delete_ranges                                         |
-- ----------------------------------------------------------------------------
--
PROCEDURE insert_update_delete_ranges (
                                   p_routing_category_id     IN number,
                                   p_range_name              IN varchar2,
                                   p_primary_flag            IN varchar2,
                                   p_routing_list_member_id  IN number,
                                   p_position_id             IN number,
                                   p_assignment_id           IN number,
                                   p_approver_flag           IN varchar2,
                                   p_enable_flag           IN varchar2,
                                   p_attr_ranges_table       IN OUT NOCOPY att_ranges,
                                   p_no_attributes           IN number) is
ctr number;
attribute_id_list varchar2(2000);
l_attr_ranges_table	att_ranges := p_attr_ranges_table;
--
  l_proc  varchar2(72) := g_package||'insert_update_delete_ranges';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);

   for ctr in 1..p_no_attributes loop
     if ctr = 1 then
         attribute_id_list := '(';
     end if;

     if p_attr_ranges_table(ctr).attribute_range_id IS NOT NULL then
         attribute_id_list := attribute_id_list ||to_char(p_attr_ranges_table(ctr).attribute_range_id);
     else
         attribute_id_list := attribute_id_list ||'-1';
     end if;

     if ctr < p_no_attributes then
         attribute_id_list := attribute_id_list ||',';
     else
         attribute_id_list := attribute_id_list ||')';
     end if;

   end loop;
   --
   -- The unique range name check is still there because creating a
   -- unique constraint to enforce this ,is greatly affecting performance
   --
   chk_unique_range_name(p_routing_category_id     => p_routing_category_id,
                         p_range_name              => p_range_name,
                         p_attribute_id_list       => attribute_id_list,
                         p_primary_flag            => p_primary_flag);

   for ctr in 1..p_no_attributes loop
     --
     if p_attr_ranges_table(ctr).attribute_range_id IS NOT NULL then
        --
       pqh_ATTRIBUTE_RANGES_api.update_ATTRIBUTE_RANGE
       (p_validate              => false
       ,p_attribute_range_id    => p_attr_ranges_table(ctr).attribute_range_id
       ,p_approver_flag         => p_approver_flag
       ,p_enable_flag         => p_enable_flag
       ,p_assignment_id         => p_assignment_id
       ,p_attribute_id          => p_attr_ranges_table(ctr).attribute_id
       ,p_from_char             => p_attr_ranges_table(ctr).from_char
       ,p_to_char               => p_attr_ranges_table(ctr).to_char
       ,p_from_date             => p_attr_ranges_table(ctr).from_date
       ,p_to_date               => p_attr_ranges_table(ctr).to_date
       ,p_from_number           => p_attr_ranges_table(ctr).from_number
       ,p_to_number             => p_attr_ranges_table(ctr).to_number
       ,p_position_id           => p_position_id
       ,p_range_name            => p_range_name
       ,p_routing_category_id   => p_routing_category_id
       ,p_routing_list_member_id=> p_routing_list_member_id
       ,p_object_version_number => p_attr_ranges_table(ctr).ovn
       ,p_effective_date        => sysdate
       );
        --
        --
        p_attr_ranges_table(ctr).operation := 'U';
        --
    else
        --
        --
       pqh_ATTRIBUTE_RANGES_api.create_ATTRIBUTE_RANGE
       (p_validate              => false
       ,p_attribute_range_id    => p_attr_ranges_table(ctr).attribute_range_id
       ,p_approver_flag         => p_approver_flag
       ,p_enable_flag         => p_enable_flag
       ,p_assignment_id         => p_assignment_id
       ,p_attribute_id          => p_attr_ranges_table(ctr).attribute_id
       ,p_from_char             => p_attr_ranges_table(ctr).from_char
       ,p_to_char               => p_attr_ranges_table(ctr).to_char
       ,p_from_date             => p_attr_ranges_table(ctr).from_date
       ,p_to_date               => p_attr_ranges_table(ctr).to_date
       ,p_from_number           => p_attr_ranges_table(ctr).from_number
       ,p_to_number             => p_attr_ranges_table(ctr).to_number
       ,p_position_id           => p_position_id
       ,p_range_name            => p_range_name
       ,p_routing_category_id   => p_routing_category_id
       ,p_routing_list_member_id=> p_routing_list_member_id
       ,p_object_version_number => p_attr_ranges_table(ctr).ovn
       ,p_effective_date        => sysdate
       );
       --
       p_attr_ranges_table(ctr).operation := 'I';
       --
     End if;
     --
    End loop;
    --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 exception when others then
p_attr_ranges_table := l_attr_ranges_table;
 raise;
 --
End insert_update_delete_ranges;
--
-- ----------------------------------------------------------------------------
-- |      on_delete_attribute_ranges                                          |
-- ----------------------------------------------------------------------------
--
PROCEDURE on_delete_attribute_ranges (p_validate              IN  boolean,
                                      del_attr_ranges_table   IN OUT NOCOPY att_ranges,
                                      p_no_attributes         IN  number) is
--
ctr number;
l_del_attr_ranges_table	att_ranges := del_attr_ranges_table;
--
  l_proc  varchar2(72) := g_package||'on_delete_attribute_ranges';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  for ctr in 1..p_no_attributes loop

    if del_attr_ranges_table(ctr).attribute_range_id IS NOT NULL then
      --
      pqh_ATTRIBUTE_RANGES_api.delete_ATTRIBUTE_RANGE
      (p_validate              => p_validate
      ,p_attribute_range_id    => del_attr_ranges_table(ctr).attribute_range_id
      ,p_object_version_number => del_attr_ranges_table(ctr).ovn
      ,p_effective_date        => sysdate);
      --
    End if;

  End loop;
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
  --
  exception when others then
  del_attr_ranges_table := l_del_attr_ranges_table;
  raise;
End on_delete_attribute_ranges;
--
--
-------------------------------------------------------------------------------
-- |  function to ensure that unique range names are entered within a         |
-- |  routing category id                                                     |
-------------------------------------------------------------------------------
--
-- Not making any changes to this procedure as it is yet undecided if
-- this procedure is going to be replaced by an unique constraint
--
PROCEDURE chk_unique_range_name (p_routing_category_id  in number,
                                 p_range_name           in varchar2,
                                 p_attribute_id_list    in varchar2,
                                 p_primary_flag         in varchar2) is
--
l_proc             varchar2(72) := g_package||'chk_unique_range_name';
--
type cur_type   IS REF CURSOR;
range_name_cur     cur_type;
sql_stmt           varchar2(1000);
exist_range_name   pqh_attribute_ranges.range_name%type;

Begin
 --
 hr_utility.set_location('Entering:'||l_proc, 5);
 --
       sql_stmt := 'Select distinct range_name from pqh_attribute_ranges where routing_category_id = :r AND attribute_id IS NOT NULL AND attribute_range_id not in '||p_attribute_id_list;

 if p_primary_flag  = 'Y' then
       sql_stmt := sql_stmt ||' AND routing_list_member_id is NULL AND position_id is NULL AND assignment_id is NULL';
 else
       sql_stmt := sql_stmt ||' AND (routing_list_member_id is NOT NULL  OR position_id is NOT NULL OR assignment_id is NOT NULL)';
 end if;

open range_name_cur for sql_stmt using p_routing_category_id;

 Loop
   Fetch range_name_cur into exist_range_name;
   exit when range_name_cur%notfound;
   if exist_range_name = p_range_name then
        hr_utility.set_message(8302, 'PQH_DUPLICATE_RANGE_NAME');
        hr_utility.raise_error;
   end if;
 End loop;
 --
 hr_utility.set_location('Leaving:'||l_proc, 10);
 --
End;
--
-----------------------------------------------------------------------------
--
-- The following procedure ensures that when enabling a disable routing
-- category , its routing rules do not overlap with other routing rules in
-- transaction category.
--
FUNCTION chk_enable_routing_category( p_routing_category_id     in number,
                                      p_transaction_category_id in number,
                                      p_overlap_range_name     out nocopy varchar2,
                                      p_error_routing_category out nocopy varchar2,
                                      p_error_range_name       out nocopy varchar2
                                      ) RETURN NUMBER is
--
  l_prev_range_name       pqh_attribute_ranges.range_name%type;
  cnt                     number(10);
  l_attribute_range_id_list  varchar2(2000);
  l_no_list_identifiers    number(10);
  l_routing_type          pqh_transaction_categories.member_cd%type;
--
  l_routing_category_id  pqh_routing_categories.routing_category_id%type;
  l_range_name       pqh_attribute_ranges.range_name%type;
  l_attribute_range_id pqh_attribute_ranges.attribute_range_id %type;
  l_attribute_id     pqh_attribute_ranges.attribute_id%type;
  l_column_type      pqh_attributes.column_type%type;
  l_from_char        pqh_attribute_ranges.from_char%type;
  l_to_char          pqh_attribute_ranges.to_char%type;
  l_from_date        pqh_attribute_ranges.from_date%type;
  l_to_date          pqh_attribute_ranges.to_date%type;
  l_from_number      pqh_attribute_ranges.from_number%type;
  l_to_number        pqh_attribute_ranges.to_number%type;
--
l_error_code    number(10) := NULL;
--
type cur_type   IS REF CURSOR;
csr_enable_routing     cur_type;
sql_stmt           varchar2(2000);
--
all_routing_rules  rule_attr_tab;
all_attributes_tab  rule_attr_tab;
--
--
Cursor csr_routing_type is
  Select member_Cd
    From pqh_transaction_categories
  Where transaction_category_id = p_transaction_category_id;
--
Cursor csr_list_ident_cnt is
  Select count(*)
    from pqh_txn_category_attributes
  Where transaction_category_id = p_transaction_category_id
    AND list_identifying_flag = 'Y';
--
l_proc             varchar2(72) := g_package||'chk_enable_routing_category';
--
Begin
--
 hr_utility.set_location('Entering:'||l_proc, 5);
--
Open csr_list_ident_cnt;
Fetch csr_list_ident_cnt into l_no_list_identifiers;
Close csr_list_ident_cnt;
--
-- Obtain the routing type of the transaction category
--
open csr_routing_type;
Fetch csr_routing_type into l_routing_type;
Close csr_routing_type;
--
sql_stmt := 'Select rct.routing_category_id, rng.range_name , rng.attribute_range_id, rng.attribute_id, att.column_type, rng.from_char, rng.to_char, rng.from_number, rng.to_number, rng.from_date, rng.to_date ';
--
sql_stmt := sql_stmt ||' From pqh_routing_categories rct,pqh_attribute_ranges rng,pqh_attributes att ';
--
sql_stmt := sql_stmt ||' Where rct.routing_category_id = :p_routing_category_id  and rng.routing_category_id = rct.routing_category_id and rng.attribute_id IS NOT NULL and rng.attribute_id = att.attribute_id';
--
If l_routing_type = 'R' then
   --
   sql_stmt := sql_stmt || ' and rct.routing_list_id is not null';
   --
Elsif l_routing_type = 'P' then
   --
   sql_stmt := sql_stmt || ' and rct.position_structure_id is not null';
   --
Else
   --
   sql_stmt := sql_stmt || ' and rct.routing_list_id is null and rct.position_structure_id is null';
   --
End if;

sql_stmt := sql_stmt || ' and rng.enable_flag = :enable_rule and nvl(rng.delete_flag,:null2) <> :delete_rule and rng.routing_list_member_id IS NULL and rng.position_id IS NULL and rng.assignment_id IS NULL ';

sql_stmt := sql_stmt || ' order by rng.range_name,rng.attribute_id';
--
--
-- We have the sql_stmt that we can execute.
--
Open csr_enable_routing for sql_stmt using p_routing_category_id,'Y','N','Y';
--
cnt := 0;
l_prev_range_name := NULL;
--

loop
  --
  Fetch csr_enable_routing into  l_routing_category_id, l_range_name,
                                 l_attribute_range_id,l_attribute_id,
                                 l_column_type,
                                 l_from_char,l_to_char,
                                 l_from_number,l_to_number,
                                 l_from_date,l_to_date;
  If csr_enable_routing%notfound then
     hr_utility.set_location('Closing cursor',100);
     Close csr_enable_routing;
     exit;
  End if;
  --
   --
   -- Check if there is a change in rule name
   --
   If  nvl(l_range_name,'xXx') <> nvl(l_prev_range_name,hr_api.g_varchar2)  then
     hr_utility.set_location('New rule:'||l_range_name ||l_proc, 6);
        --
        If  cnt > 0  then
     hr_utility.set_location('Rules exist '||l_proc, 6);
            --
            -- call chk_routing_range_overlap procedure to check if this rule
            -- overlaps with any other routing rules under that
            -- transaction category.
            --
     hr_utility.set_location('Calling chk_routing_range_overlap:'||to_char(l_no_list_identifiers), 100);
            chk_routing_range_overlap
                (tab1                      => all_routing_rules ,
                 tab2                      => all_attributes_tab,
                 p_routing_type            => l_routing_type,
                 p_transaction_category_id => p_transaction_category_id,
                 p_attribute_range_id_list => l_attribute_range_id_list,
                 p_no_attributes           => l_no_list_identifiers,
                 p_error_code              => l_error_code,
                 p_error_routing_category  => p_error_routing_category,
                 p_error_range_name        => p_error_range_name);
            --
            If l_error_code = 1 then
               --
               p_overlap_range_name := l_prev_range_name;
               RETURN 1;
            End if;
            --
        End if;
        -- Reset counters
        hr_utility.set_location('Reset counter'||l_proc, 6);
        --
        cnt := 1;
        l_prev_range_name := l_range_name;
        --
        l_error_code := NULL;
        p_error_routing_category := NULL;
        p_error_range_name := NULL;
        l_attribute_range_id_list := NULL;
        --
  Else
     hr_utility.set_location('Increment counter'||l_proc, 6);
         -- If we are processing same rule , increment counter
         cnt := cnt + 1;
         l_attribute_range_id_list := l_attribute_range_id_list || ',';

  End if;
  --
  all_routing_rules(cnt).attribute_id := l_attribute_id;
  all_routing_rules(cnt).datatype := l_column_type;
  all_routing_rules(cnt).from_char := l_from_char;
  all_routing_rules(cnt).to_char := l_to_char;
  all_routing_rules(cnt).from_number := l_from_number;
  all_routing_rules(cnt).to_number := l_to_number;
  all_routing_rules(cnt).from_date := l_from_date;
  all_routing_rules(cnt).to_date := l_to_date;
  --
  all_attributes_tab(cnt).attribute_id := l_attribute_id;
  all_attributes_tab(cnt).datatype := l_column_type;
  --
  l_attribute_range_id_list := l_attribute_range_id_list || to_char(l_attribute_range_id);
  --
End loop;
--
If  cnt > 0  then
--
  hr_utility.set_location('Rules exist '||l_proc, 6);
  --
  -- call chk_routing_range_overlap procedure to check if this rule
  -- overlaps with any other routing rules under that
  -- transaction category.
  --
  hr_utility.set_location('Calling chk_routing_range_overlap:'||to_char(l_no_list_identifiers), 100);
  --
  chk_routing_range_overlap
                  (tab1                      => all_routing_rules ,
                   tab2                      => all_attributes_tab,
                   p_routing_type            => l_routing_type,
                   p_transaction_category_id => p_transaction_category_id,
                   p_attribute_range_id_list => l_attribute_range_id_list,
                   p_no_attributes           => l_no_list_identifiers,
                   p_error_code              => l_error_code,
                   p_error_routing_category  => p_error_routing_category,
                   p_error_range_name        => p_error_range_name);
  --
  If l_error_code = 1 then
  --
     p_overlap_range_name := l_prev_range_name;
     RETURN 1;
   --
  End if;
  --
End if;
--
hr_utility.set_location('Leaving'||l_proc, 10);
--
RETURN 0;
--
End;
--
---------------------------------------------------------------------------
--
-- The following procedure ensures that when  Freezing a transaction
-- category , its routing rules do not overlap with each other
--
Procedure chk_rout_overlap_on_freeze(p_transaction_category_id in number
                                    ) is
--
l_routing_type             pqh_transaction_categories.member_cd%type;
--
l_routing_category_id  pqh_routing_categories.routing_category_id%type;
--
type cur_type   IS REF CURSOR;
csr_chk_rule_overlap     cur_type;
sql_stmt           varchar2(2000);
--
l_error_code               number(10);
--
l_overlap_routing_category varchar2(200);
l_overlap_range_name       pqh_attribute_ranges.range_name%type;
l_error_routing_category   varchar2(200);
l_error_range_name         pqh_attribute_ranges.range_name%type;
--
Cursor csr_routing_type is
  Select member_Cd
    From pqh_transaction_categories
  Where transaction_category_id = p_transaction_category_id;
--
l_proc             varchar2(72) := g_package||'chk_overlap_on_freeze_cat';
--
Begin
--
hr_utility.set_location('Entering:'||l_proc, 5);
--
-- Obtain the routing type of the transaction category
--
open csr_routing_type;
Fetch csr_routing_type into l_routing_type;
Close csr_routing_type;
--
--
-- Select all routing categories under the transaction category that
-- belong to the current routing type
--
sql_stmt := 'Select rct.routing_category_id From pqh_routing_categories rct ';
--
sql_stmt := sql_stmt ||' Where rct.transaction_category_id = :p_transaction_category_id and rct.enable_flag = :p_enable_flag  and nvl(rct.default_flag,:null_value1) <> :default_flag and nvl(rct.delete_flag,:null_value2) <> :delete_flag';
--
If l_routing_type = 'R' then
   --
   sql_stmt := sql_stmt || ' and rct.routing_list_id is not null';
   --
Elsif l_routing_type = 'P' then
   --
   sql_stmt := sql_stmt || ' and rct.position_structure_id is not null';
   --
Else
   --
   sql_stmt := sql_stmt || ' and rct.routing_list_id is null and rct.position_structure_id is null';
   --
End if;

sql_stmt := sql_stmt || ' order by rct.routing_category_id ';
--
--
-- We have the sql_stmt that we can execute.
--
Open csr_chk_rule_overlap for sql_stmt using p_transaction_category_id,
                                             'Y','N','Y','N','Y';
--
loop
  --
  l_error_code := 0;
  --
  Fetch csr_chk_rule_overlap into  l_routing_category_id ;
  --
  If csr_chk_rule_overlap%notfound then
     Close csr_chk_rule_overlap;
     exit;
  End if;
  --
  l_error_code := chk_enable_routing_category
       (p_routing_category_id      => l_routing_category_id,
        p_transaction_category_id  => p_transaction_category_id,
        p_overlap_range_name       => l_overlap_range_name,
        p_error_routing_category   => l_error_routing_category,
        p_error_range_name         => l_error_range_name);
  --
  If l_error_code = 1 then
     --
     pqh_tct_bus.get_routing_category_name
                (p_routing_category_id   => l_routing_category_id,
                 p_routing_category_name => l_overlap_routing_category);
     --
     hr_utility.set_message(8302,'PQH_ROUT_OVERLAP_ON_CAT_FREEZE');
     hr_utility.set_message_token('ROUT1',l_overlap_routing_category);
     hr_utility.set_message_token('RULE1',l_overlap_range_name);
     hr_utility.set_message_token('ROUT2',l_error_routing_category);
     hr_utility.set_message_token('RULE2',l_error_range_name);
     hr_utility.raise_error;
     --
  End if;
  --
End loop;
--
hr_utility.set_location('Leaving:'||l_proc, 10);
--
End;
--
----------------------------------------------------------------------------
PROCEDURE get_member_name(p_member_id    in  number,
                          p_routing_type in  varchar2,
                          p_member_name out nocopy  varchar2) is
--
type cur_type   IS REF CURSOR;
csr_mem_name    cur_type;
sql_stmt        varchar2(2000);
--
--
l_proc             varchar2(72) := g_package||'get_member_name';
--
Begin
--
 hr_utility.set_location('Entering:'||l_proc, 5);
--
 If p_routing_type = 'R' then
    --
    sql_stmt := 'Select decode(RLM.user_id,NULL,RLM.role_name,RLM.user_name'
              ||'||'||''''||'-'||''''||'||' ||' RLM.role_name) routing_member_name from pqh_routing_list_members_v RLM where RLM.routing_list_member_id = :p_member_id';
    --
 Elsif p_routing_type = 'P' then
    --
    sql_stmt := 'Select substr(POS.name,1,240) from hr_all_positions pos where pos.position_id = :p_member_id';
    --
 End if;
--
 --
 If p_routing_type = 'R' or p_routing_type = 'P' then

    Open csr_mem_name for sql_stmt using p_member_id;
    --
    Fetch csr_mem_name into p_member_name;
    --
    Close csr_mem_name;
 Else
    --
    p_member_name := pqh_utility.decode_assignment_name( p_member_id);
    --
 End if;
--
 hr_utility.set_location('Leaving:'||l_proc, 10);
 exception when others then
 p_member_name := null;
 raise;
--
End;
--
--
--
----------------------------------------------------------------------------
--
-- The following procedure ensures that when  Freezing a transaction
-- category , its authorization rules of a member do not overlap with
-- other authorization rules for the same member.
--
PROCEDURE chk_mem_overlap_on_freeze( p_transaction_category_id in number
                                  )is
--
  l_overlap_range_name       pqh_attribute_ranges.range_name%type;
  l_error_range_name         pqh_attribute_ranges.range_name%type;
  l_error_routing_category varchar2(200);
  l_member_name              varchar2(300);
--
  l_prev_range_name       pqh_attribute_ranges.range_name%type;
  l_prev_routing_category_id  pqh_routing_categories.routing_category_id%type;
  l_prev_member_id        number(30);
--
  cnt                     number(10);
  l_attribute_range_id_list  varchar2(2000);
  l_no_mem_identifiers    number(10);
  l_routing_type          pqh_transaction_categories.member_cd%type;
--
  l_routing_category_id  pqh_routing_categories.routing_category_id%type;
  l_range_name       pqh_attribute_ranges.range_name%type;
  l_member_id        number(30);
  l_attribute_range_id pqh_attribute_ranges.attribute_range_id %type;
  l_attribute_id     pqh_attribute_ranges.attribute_id%type;
  l_column_type      pqh_attributes.column_type%type;
  l_from_char        pqh_attribute_ranges.from_char%type;
  l_to_char          pqh_attribute_ranges.to_char%type;
  l_from_date        pqh_attribute_ranges.from_date%type;
  l_to_date          pqh_attribute_ranges.to_date%type;
  l_from_number      pqh_attribute_ranges.from_number%type;
  l_to_number        pqh_attribute_ranges.to_number%type;
--
l_error_code    number(10) := NULL;
--
type cur_type   IS REF CURSOR;
csr_mem_overlap     cur_type;
sql_stmt           varchar2(2000);
--
all_routing_rules  rule_attr_tab;
all_attributes_tab  rule_attr_tab;
--
Cursor csr_routing_type is
  Select member_Cd
    From pqh_transaction_categories
  Where transaction_category_id = p_transaction_category_id;
--
Cursor csr_mem_ident_cnt is
  Select count(*)
    from pqh_txn_category_attributes
  Where transaction_category_id = p_transaction_category_id
    AND member_identifying_flag = 'Y';
--
l_proc             varchar2(72) := g_package||'chk_mem_overlap_on_freeze';
--
Begin
--
 hr_utility.set_location('Entering:'||l_proc, 5);
--
Open csr_mem_ident_cnt;
Fetch csr_mem_ident_cnt into l_no_mem_identifiers;
Close csr_mem_ident_cnt;
--
-- Obtain the routing type of the transaction category
--
open csr_routing_type;
Fetch csr_routing_type into l_routing_type;
Close csr_routing_type;
--
sql_stmt := 'Select rct.routing_category_id, rng.range_name ,';
--
If l_routing_type = 'R' then
   --
   sql_stmt := sql_stmt || ' rng.routing_list_member_id,';
   --
Elsif l_routing_type = 'P' then
   --
   sql_stmt := sql_stmt || ' rng.position_id,';
   --
Else
   --
   sql_stmt := sql_stmt || ' rng.assignment_id,';
   --
End if;
--
sql_stmt := sql_stmt ||' rng.attribute_range_id, rng.attribute_id, att.column_type, rng.from_char, rng.to_char, rng.from_number, rng.to_number, rng.from_date, rng.to_date ';
--
sql_stmt := sql_stmt ||' From pqh_routing_categories rct,pqh_attribute_ranges rng,pqh_attributes att ';
--
sql_stmt := sql_stmt ||' Where rct.transaction_category_id = :p_transaction_category_id  and nvl(rct.default_flag,:null_value) <> :default_flag '
                     ||' and nvl(rct.delete_flag,:null2) <> :delete_flag and rng.routing_category_id = rct.routing_category_id and rng.attribute_id = att.attribute_id';
--
If l_routing_type = 'R' then
   --
   sql_stmt := sql_stmt || ' and rct.routing_list_id is not null';
   --
Elsif l_routing_type = 'P' then
   --
   sql_stmt := sql_stmt || ' and rct.position_structure_id is not null';
   --
Else
   --
   sql_stmt := sql_stmt || ' and rct.routing_list_id is null and rct.position_structure_id is null';
   --
End if;
--
sql_stmt := sql_stmt || ' and nvl(rng.delete_flag,:null3) <> :delete_rule';
--
If l_routing_type = 'R' then
   --
   sql_stmt := sql_stmt || ' and rng.routing_list_member_id is not null';
   --
Elsif l_routing_type = 'P' then
   --
   sql_stmt := sql_stmt || ' and rng.position_id is not null';
   --
Else
   --
   sql_stmt := sql_stmt || ' and rng.assignment_id is not null ';
   --
End if;
--
sql_stmt := sql_stmt || ' order by rct.routing_category_id,rng.range_name,rng.attribute_id';
--
--
-- We have the sql_stmt that we can execute.
--
Open csr_mem_overlap for sql_stmt using p_transaction_category_id,'N','Y','N','Y','N','Y';
--
cnt := 0;
l_prev_range_name := NULL;
l_prev_routing_category_id := NULL;
l_prev_member_id := NULL;
--

loop
  --
  Fetch csr_mem_overlap into  l_routing_category_id, l_range_name,
                                 l_member_id,
                                 l_attribute_range_id,l_attribute_id,
                                 l_column_type,
                                 l_from_char,l_to_char,
                                 l_from_number,l_to_number,
                                 l_from_date,l_to_date;
  If csr_mem_overlap%notfound then
     hr_utility.set_location('Closing cursor',100);
     Close csr_mem_overlap;
     exit;
  End if;
  --
   --
   -- Check if there is a change in rule name
   --
   If  l_routing_category_id <> l_prev_routing_category_id OR
       nvl(l_range_name,'xXx') <> nvl(l_prev_range_name,hr_api.g_varchar2)  then
       --
        hr_utility.set_location('New rule:'||l_range_name ||l_proc, 6);
        --
        If  cnt > 0  then
            hr_utility.set_location('Rules exist '||l_proc, 6);
            --
            -- call chk_routing_range_overlap procedure to check if this rule
            -- overlaps with any other routing rules under that
            -- transaction category.
            --
            hr_utility.set_location('Calling chk_member_range_overlap:'||l_proc, 6);
            l_error_code := chk_member_range_overlap
                (tab1                      => all_routing_rules ,
                 tab2                      => all_attributes_tab,
                 p_transaction_category_id => p_transaction_category_id,
                 p_routing_category_id     => l_prev_routing_category_id,
                 p_range_name              => l_prev_range_name,
                 p_routing_type            => l_routing_type,
                 p_member_id               => l_prev_member_id,
                 p_attribute_range_id_list => l_attribute_range_id_list,
                 p_no_attributes           => l_no_mem_identifiers,
                 p_error_range             => l_error_range_name);
            --
            If l_error_code = 1 then
               --
               -- Get the name of the routing category and member for
               -- whom there is a overlap.
               --
               l_overlap_range_name := l_prev_range_name;
               --
               pqh_tct_bus.get_routing_category_name(
                           p_routing_category_id  => l_prev_routing_category_id,
                           p_routing_category_name => l_error_routing_category);
               --
               get_member_name(p_member_id               => l_prev_member_id,
                               p_routing_type            => l_routing_type,
                               p_member_name             => l_member_name);
               --
               hr_utility.set_message(8302,'PQH_MEM_OVERLAP_ON_CAT_FREEZE');
               hr_utility.set_message_token('ROUT1',l_error_routing_category);
               hr_utility.set_message_token('RULE1',l_overlap_range_name);
               hr_utility.set_message_token('RULE2',l_error_range_name);
               hr_utility.set_message_token('MEMBER_NAME',l_member_name);
               hr_utility.raise_error;
               --
            End if;
            --
        End if;
        -- Reset counters
        hr_utility.set_location('Reset counter'||l_proc, 6);
        --
        cnt := 1;
        l_prev_routing_category_id := l_routing_category_id;
        l_prev_range_name := l_range_name;
        l_prev_member_id  := l_member_id;
        --
        l_error_code := NULL;
        l_error_routing_category := NULL;
        l_error_range_name := NULL;
        l_attribute_range_id_list := NULL;
        --
  Else
     hr_utility.set_location('Increment counter'||l_proc, 6);
         -- If we are processing same rule , increment counter
         cnt := cnt + 1;
         l_attribute_range_id_list := l_attribute_range_id_list || ',';

  End if;
  --
  all_routing_rules(cnt).attribute_id := l_attribute_id;
  all_attributes_tab(cnt).attribute_id := l_attribute_id;
  all_routing_rules(cnt).datatype := l_column_type;
  all_attributes_tab(cnt).datatype := l_column_type;
  all_routing_rules(cnt).from_char := l_from_char;
  all_routing_rules(cnt).to_char := l_to_char;
  all_routing_rules(cnt).from_number := l_from_number;
  all_routing_rules(cnt).to_number := l_to_number;
  all_routing_rules(cnt).from_date := l_from_date;
  all_routing_rules(cnt).to_date := l_to_date;
  --
  l_attribute_range_id_list := l_attribute_range_id_list || to_char(l_attribute_range_id);
  --
End loop;
--
If  cnt > 0  then
--
  hr_utility.set_location('Rules exist '||l_proc, 6);
  --
  -- call chk_routing_range_overlap procedure to check if this rule
  -- overlaps with any other routing rules under that
  -- transaction category.
  --
  hr_utility.set_location('Calling chk_routing_range_overlap:'||l_proc, 6);
  --
  l_error_code := chk_member_range_overlap
                (tab1                      => all_routing_rules ,
                 tab2                      => all_attributes_tab,
                 p_transaction_category_id => p_transaction_category_id,
                 p_routing_category_id     => l_prev_routing_category_id,
                 p_range_name              => l_prev_range_name,
                 p_routing_type            => l_routing_type,
                 p_member_id               => l_prev_member_id,
                 p_attribute_range_id_list => l_attribute_range_id_list,
                 p_no_attributes           => l_no_mem_identifiers,
                 p_error_range             => l_error_range_name);
  --
  If l_error_code = 1 then
  --
     --
     -- Get the name of the routing category and member for
     -- whom there is a overlap.
     --
     l_overlap_range_name := l_prev_range_name;
     --
     pqh_tct_bus.get_routing_category_name(
                 p_routing_category_id  => l_prev_routing_category_id,
                 p_routing_category_name => l_error_routing_category);
     --
     get_member_name(p_member_id               => l_prev_member_id,
                     p_routing_type            => l_routing_type,
                     p_member_name             => l_member_name);
     --
     --
     hr_utility.set_message(8302,'PQH_MEM_OVERLAP_ON_CAT_FREEZE');
     hr_utility.set_message_token('ROUT1',l_error_routing_category);
     hr_utility.set_message_token('RULE1',l_overlap_range_name);
     hr_utility.set_message_token('RULE2',l_error_range_name);
     hr_utility.set_message_token('MEMBER_NAME',l_member_name);
     hr_utility.raise_error;
     --
  End if;
  --
End if;
--
hr_utility.set_location('Leaving'||l_proc, 10);
--
--
End;
--
--

End pqh_ATTRIBUTE_RANGES_pkg;

/
