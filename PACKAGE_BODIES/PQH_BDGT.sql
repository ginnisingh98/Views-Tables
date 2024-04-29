--------------------------------------------------------
--  DDL for Package Body PQH_BDGT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_BDGT" as
/* $Header: pqbudget.pkb 115.18 2002/11/27 04:43:00 rpasapul ship $ */
   g_package varchar2(100) := 'PQH_BDGT.' ;

function get_bgv_budget( p_budget_version_id in number) return number is
   cursor c1 is select budget_id
                from pqh_budget_versions
                where budget_version_id = p_budget_version_id ;
   l_budget_id number;
begin
   open c1;
   fetch c1 into l_budget_id ;
   close c1;
   return l_budget_id;
end get_bgv_budget;
procedure propagate_version_changes (p_change_mode           in varchar2,
                                     p_budget_version_id     in number,
				     p_budget_style_cd       in varchar2,
                                     p_new_bgv_unit1_value   in number,
                                     p_new_bgv_unit2_value   in number,
                                     p_new_bgv_unit3_value   in number,
                                     p_unit1_precision       in number,
                                     p_unit2_precision       in number,
                                     p_unit3_precision       in number,
				     p_unit1_aggregate       in varchar2,
				     p_unit2_aggregate       in varchar2,
				     p_unit3_aggregate       in varchar2,
                                     p_budget_version_status in out nocopy varchar2,
                                     p_bgv_unit1_available   in out nocopy number,
                                     p_bgv_unit2_available   in out nocopy number,
                                     p_bgv_unit3_available   in out nocopy number
)is
   cursor c1 is select budget_detail_id,budget_unit1_value,budget_unit2_value,budget_unit3_value,
                       budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd,
                       budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                       budget_unit1_available,budget_unit2_available,budget_unit3_available,
                       object_version_number,gl_status
   from pqh_budget_details
   where budget_version_id = p_budget_version_id
   for update of budget_unit1_value,budget_unit2_value,budget_unit3_value,
                 budget_unit1_available,budget_unit2_available,budget_unit3_available,
                 budget_unit1_percent,budget_unit2_percent,budget_unit3_percent ;

   l_budget_unit1_value  number;
   l_budget_unit2_value  number;
   l_budget_unit3_value  number;
   l_budget_unit1_percent  number;
   l_budget_unit2_percent  number;
   l_budget_unit3_percent  number;
   l_budget_unit1_available  number;
   l_budget_unit2_available  number;
   l_budget_unit3_available  number;
   ini_budget_unit1_available number := p_bgv_unit1_available;
   ini_budget_unit2_available  number := p_bgv_unit2_available;
   ini_budget_unit3_available  number := p_bgv_unit3_available;
   l_object_version_number   number;
   l_bgd_status              varchar2(30);
   l_proc varchar2(100) := g_package||'propagate_version_changes' ;
   l_code varchar2(30) := p_change_mode;
begin
  hr_utility.set_location('entering '||l_proc,10);
  hr_utility.set_location('entering with bgv'||p_budget_version_id||l_proc,11);
  hr_utility.set_location('l_code is'||l_code||l_proc,35);
  for i in c1 loop
    hr_utility.set_location('for each budgeted row '||l_proc,40);
    if l_code = 'RV' then
       hr_utility.set_location('unit1 for RV'||l_proc,45);
       if nvl(p_new_bgv_unit1_value,0) <> 0 then
          l_budget_unit1_percent := round((i.budget_unit1_value * 100)/p_new_bgv_unit1_value,2) ;
       else
	  l_budget_unit1_percent := null;
       end if;
       l_budget_unit1_value     := i.budget_unit1_value;
       l_budget_unit1_available := i.budget_unit1_available;
    elsif l_code = 'RP' then
       hr_utility.set_location('unit1 for RP'||l_proc,50);
       if nvl(p_new_bgv_unit1_value,0) <> 0 then
          l_budget_unit1_value     := round(p_new_bgv_unit1_value * nvl(i.budget_unit1_percent,0)/100,p_unit1_precision) ;
          l_budget_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_budget_unit1_value,0) - nvl(i.budget_unit1_value,0);
          p_bgv_unit1_available    := nvl(p_bgv_unit1_available,0) - nvl(l_budget_unit1_value,0) + nvl(i.budget_unit1_value,0);
       else
	  l_budget_unit1_value     := i.budget_unit1_value;
	  l_budget_unit1_available := i.budget_unit1_available;
       end if;
       l_budget_unit1_percent := i.budget_unit1_percent;
    else
       hr_utility.set_location('unit1 for UE'||l_proc,55);
       if nvl(p_new_bgv_unit1_value,0) <> 0 then
          if i.budget_unit1_value_type_cd = 'P' then
             l_budget_unit1_value     := round(p_new_bgv_unit1_value * nvl(i.budget_unit1_percent,0)/100,p_unit1_precision) ;
             l_budget_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_budget_unit1_value,0) - nvl(i.budget_unit1_value,0);
             p_bgv_unit1_available    := nvl(p_bgv_unit1_available,0) - nvl(l_budget_unit1_value,0) + nvl(i.budget_unit1_value,0);
             l_budget_unit1_percent   := i.budget_unit1_percent;
	  else
	     l_budget_unit1_value     := i.budget_unit1_value;
	     l_budget_unit1_available := i.budget_unit1_available;
             l_budget_unit1_percent   := round((i.budget_unit1_value * 100)/p_new_bgv_unit1_value,2) ;
          end if;
       else
	  l_budget_unit1_value     := i.budget_unit1_value;
	  l_budget_unit1_available := i.budget_unit1_available;
          l_budget_unit1_percent   := null;
       end if;
    end if;

    if l_code ='RV' then
       hr_utility.set_location('unit2 for RV'||l_proc,60);
       if nvl(p_new_bgv_unit2_value,0) <> 0 then
          l_budget_unit2_percent := round((i.budget_unit2_value * 100)/p_new_bgv_unit2_value,2) ;
       else
	  l_budget_unit2_percent := null;
       end if;
       l_budget_unit2_value     := i.budget_unit2_value;
       l_budget_unit2_available := i.budget_unit2_available;
    elsif l_code ='RP' then
       hr_utility.set_location('unit2 for RP'||l_proc,65);
       if nvl(p_new_bgv_unit2_value,0) <> 0 then
          l_budget_unit2_value     := round(p_new_bgv_unit2_value * nvl(i.budget_unit2_percent,0)/100,p_unit2_precision) ;
          l_budget_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_budget_unit2_value,0) - nvl(i.budget_unit2_value,0);
          p_bgv_unit2_available    := nvl(p_bgv_unit2_available,0) - nvl(l_budget_unit2_value,0) + nvl(i.budget_unit2_value,0);
       else
	  l_budget_unit2_value     := i.budget_unit2_value;
	  l_budget_unit2_available := i.budget_unit2_available;
       end if;
       l_budget_unit2_percent := i.budget_unit2_percent;
    else
       hr_utility.set_location('unit2 for UE'||l_proc,70);
       if nvl(p_new_bgv_unit2_value,0) <> 0 then
          if i.budget_unit2_value_type_cd = 'P' then
             l_budget_unit2_value     := round(p_new_bgv_unit2_value * nvl(i.budget_unit2_percent,0)/100,p_unit2_precision) ;
             l_budget_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_budget_unit2_value,0) - nvl(i.budget_unit2_value,0);
             p_bgv_unit2_available    := nvl(p_bgv_unit2_available,0) - nvl(l_budget_unit2_value,0) + nvl(i.budget_unit2_value,0);
             l_budget_unit2_percent   := i.budget_unit2_percent;
	  else
	     l_budget_unit2_value     := i.budget_unit2_value;
	     l_budget_unit2_available := i.budget_unit2_available;
             l_budget_unit2_percent   := round((i.budget_unit2_value * 100)/p_new_bgv_unit2_value,2) ;
          end if;
       else
	  l_budget_unit2_value     := i.budget_unit2_value;
	  l_budget_unit2_available := i.budget_unit2_available;
          l_budget_unit2_percent   := null;
       end if;
    end if;

    if l_code ='RV' then
       hr_utility.set_location('unit3 for RV'||l_proc,75);
       if nvl(p_new_bgv_unit3_value,0) <> 0 then
          l_budget_unit3_percent  := round((i.budget_unit3_value * 100)/p_new_bgv_unit3_value,2) ;
       else
	  l_budget_unit3_percent := null;
       end if;
       l_budget_unit3_value     := i.budget_unit3_value;
       l_budget_unit3_available := i.budget_unit3_available;
    elsif l_code ='RP' then
       hr_utility.set_location('unit3 for RP'||l_proc,80);
       if nvl(p_new_bgv_unit3_value,0) <> 0 then
          l_budget_unit3_value     := round(p_new_bgv_unit3_value * nvl(i.budget_unit3_percent,0)/100,p_unit3_precision) ;
          l_budget_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_budget_unit3_value,0) - nvl(i.budget_unit3_value,0);
          p_bgv_unit3_available    := nvl(p_bgv_unit3_available,0) - nvl(l_budget_unit3_value,0) + nvl(i.budget_unit3_value,0);
       else
	  l_budget_unit3_value     := i.budget_unit3_value;
	  l_budget_unit3_available := i.budget_unit3_available;
       end if;
       l_budget_unit3_percent := i.budget_unit3_percent;
    else
       hr_utility.set_location('unit3 for UE'||l_proc,85);
       if nvl(p_new_bgv_unit3_value,0) <> 0 then
          if i.budget_unit3_value_type_cd = 'P' then
             l_budget_unit3_value     := round(p_new_bgv_unit3_value * nvl(i.budget_unit3_percent,0)/100,p_unit3_precision) ;
             l_budget_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_budget_unit3_value,0) - nvl(i.budget_unit3_value,0);
             p_bgv_unit3_available    := nvl(p_bgv_unit3_available,0) - nvl(l_budget_unit3_value,0) + nvl(i.budget_unit3_value,0);
             l_budget_unit3_percent := i.budget_unit3_percent;
	  else
	     l_budget_unit3_value     := i.budget_unit3_value;
	     l_budget_unit3_available := i.budget_unit3_available;
             l_budget_unit3_percent   := round((i.budget_unit3_value * 100)/p_new_bgv_unit3_value,2) ;
          end if;
       else
	  l_budget_unit3_value     := i.budget_unit3_value;
	  l_budget_unit3_available := i.budget_unit3_available;
          l_budget_unit3_percent   := null;
       end if;
    end if;
    hr_utility.set_location('before calling propagate_budget_changes'||l_proc,90);
    hr_utility.set_location('values passed are'||l_proc,95);
    hr_utility.set_location('unit1_value'||l_budget_unit1_value||l_proc,100);
    hr_utility.set_location('unit2_value'||l_budget_unit2_value||l_proc,101);
    hr_utility.set_location('unit3_value'||l_budget_unit3_value||l_proc,102);
    hr_utility.set_location('unit1_available'||l_budget_unit1_available||l_proc,103);
    hr_utility.set_location('unit2_available'||l_budget_unit2_available||l_proc,104);
    hr_utility.set_location('unit3_available'||l_budget_unit3_available||l_proc,105);
    l_object_version_number := i.object_version_number;
    propagate_budget_changes (p_change_mode           => l_code,
                              p_budget_detail_id      => i.budget_detail_id,
                              p_new_bgt_unit1_value   => l_budget_unit1_value,
                              p_new_bgt_unit2_value   => l_budget_unit2_value,
                              p_new_bgt_unit3_value   => l_budget_unit3_value,
			      p_unit1_precision       => p_unit1_precision,
			      p_unit2_precision       => p_unit2_precision,
			      p_unit3_precision       => p_unit3_precision,
			      p_unit1_aggregate       => p_unit1_aggregate,
			      p_unit2_aggregate       => p_unit2_aggregate,
			      p_unit3_aggregate       => p_unit3_aggregate,
                              p_bgt_unit1_available   => l_budget_unit1_available,
                              p_bgt_unit2_available   => l_budget_unit2_available,
                              p_bgt_unit3_available   => l_budget_unit3_available);
    hr_utility.set_location('values returned are'||l_proc,110);
    hr_utility.set_location('unit1_available'||l_budget_unit1_available||l_proc,113);
    hr_utility.set_location('unit2_available'||l_budget_unit2_available||l_proc,114);
    hr_utility.set_location('unit3_available'||l_budget_unit3_available||l_proc,115);
    if nvl(p_budget_version_status,'X') in ('POST','ERROR') then
       l_bgd_status := 'ERROR';
       p_budget_version_status := 'ERROR';
    else
       l_bgd_status := '';
    end if;
    update_budget_detail
    (
    p_budget_detail_id       => i.budget_detail_id,
    p_budget_unit1_percent   => l_budget_unit1_percent,
    p_budget_unit1_value     => l_budget_unit1_value,
    p_budget_unit2_percent   => l_budget_unit2_percent,
    p_budget_unit2_value     => l_budget_unit2_value,
    p_budget_unit3_percent   => l_budget_unit3_percent,
    p_budget_unit3_value     => l_budget_unit3_value,
    p_budget_unit1_available => l_budget_unit1_available,
    p_budget_unit2_available => l_budget_unit2_available,
    p_budget_unit3_available => l_budget_unit3_available,
    p_gl_status              => l_bgd_status,
    p_object_version_number  => l_object_version_number
    );
    hr_utility.set_location('budget row updated '||l_proc,120);
  end loop;
  hr_utility.set_location('values passed out nocopy are'||l_proc,270);
  p_bgv_unit1_available := round(p_bgv_unit1_available,p_unit1_precision);
  p_bgv_unit2_available := round(p_bgv_unit2_available,p_unit2_precision);
  p_bgv_unit3_available := round(p_bgv_unit3_available,p_unit3_precision);
  hr_utility.set_location('unit1_available'||p_bgv_unit1_available||l_proc,273);
  hr_utility.set_location('unit2_available'||p_bgv_unit2_available||l_proc,274);
  hr_utility.set_location('unit3_available'||p_bgv_unit3_available||l_proc,275);
  hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
p_bgv_unit1_available   := ini_budget_unit1_available;
p_bgv_unit2_available   := ini_budget_unit2_available;
p_bgv_unit3_available   := ini_budget_unit3_available;
raise;
end propagate_version_changes;

procedure propagate_budget_changes (p_change_mode           in varchar2,
                                    p_budget_detail_id      in number,
                                    p_new_bgt_unit1_value   in number,
                                    p_new_bgt_unit2_value   in number,
                                    p_new_bgt_unit3_value   in number,
                                    p_unit1_precision       in number,
                                    p_unit2_precision       in number,
                                    p_unit3_precision       in number,
				    p_unit1_aggregate       in varchar2,
				    p_unit2_aggregate       in varchar2,
				    p_unit3_aggregate       in varchar2,
                                    p_bgt_unit1_available   in out nocopy number,
                                    p_bgt_unit2_available   in out nocopy number,
                                    p_bgt_unit3_available   in out nocopy number
)is
   cursor c1 is select budget_period_id,budget_unit1_value,budget_unit2_value,budget_unit3_value,
                       budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd,
                       budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                       budget_unit1_available,budget_unit2_available,budget_unit3_available
   from pqh_budget_periods
   where budget_detail_id = p_budget_detail_id
   for update of budget_unit1_value,budget_unit2_value,budget_unit3_value,
                 budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                 budget_unit1_available,budget_unit2_available,budget_unit3_available ;

   l_period_unit1_value  number;
   l_period_unit2_value  number;
   l_period_unit3_value  number;
   l_period_unit1_percent  number;
   l_period_unit2_percent  number;
   l_period_unit3_percent  number;
   l_period_unit1_available  number;
   l_period_unit2_available  number;
   l_period_unit3_available  number;
   ini_budget_unit1_available   number := p_bgt_unit1_available;
   ini_budget_unit2_available   number := p_bgt_unit2_available;
   ini_budget_unit3_available   number := p_bgt_unit3_available;
   x_unit1_max number;
   x_unit2_max number;
   x_unit3_max number;
   x_unit1_avg number;
   x_unit2_avg number;
   x_unit3_avg number;
   x_unit1_sum number;
   x_unit2_sum number;
   x_unit3_sum number;
   l_proc varchar2(100) := g_package||'propagate_budget_changes' ;
begin
  hr_utility.set_location('entering '||l_proc,10);
  if p_change_mode not in ('RP','RV','UE') then
      hr_utility.set_message(8302,'PQH_WKS_PROPAGATION_METHOD_ERR');
      hr_utility.raise_error;
  end if;

  /* make a call to sub_budgetrow to subtract the all period info. from the table*/
  pqh_budget.sub_budgetrow(p_budget_detail_id    => p_budget_detail_id,
                           p_unit1_aggregate     => p_unit1_aggregate,
                           p_unit2_aggregate     => p_unit2_aggregate,
                           p_unit3_aggregate     => p_unit3_aggregate);

  for i in c1 loop
    hr_utility.set_location('for each period '||l_proc,20);
    if p_change_mode ='RV' then
       hr_utility.set_location('unit1 for RV '||l_proc,30);
       if nvl(p_new_bgt_unit1_value,0) <> 0 then
          l_period_unit1_percent  := round((i.budget_unit1_value * 100)/p_new_bgt_unit1_value,2) ;
       else
          l_period_unit1_percent := null;
       end if;
       l_period_unit1_value     := i.budget_unit1_value;
       l_period_unit1_available := i.budget_unit1_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit1 for RP '||l_proc,35);
       if nvl(p_new_bgt_unit1_value,0) <> 0 then
          l_period_unit1_value  := round(p_new_bgt_unit1_value * nvl(i.budget_unit1_percent,0)/100,2) ;
          l_period_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_period_unit1_value,0) - nvl(i.budget_unit1_value,0);
          p_bgt_unit1_available := nvl(p_bgt_unit1_available,0) - nvl(l_period_unit1_value,0) + nvl(i.budget_unit1_value,0);
       else
	  l_period_unit1_value := i.budget_unit1_value;
	  l_period_unit1_available := i.budget_unit1_available;
       end if;
       l_period_unit1_percent := i.budget_unit1_percent;
    else
       hr_utility.set_location('unit1 for UE '||l_proc,40);
       if nvl(p_new_bgt_unit1_value,0) <> 0 then
          if i.budget_unit1_value_type_cd = 'P' then
             l_period_unit1_value  := round(p_new_bgt_unit1_value * nvl(i.budget_unit1_percent,0)/100,2) ;
             l_period_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_period_unit1_value,0) - nvl(i.budget_unit1_value,0);
             p_bgt_unit1_available := nvl(p_bgt_unit1_available,0) - nvl(l_period_unit1_value,0) + nvl(i.budget_unit1_value,0);
             l_period_unit1_percent := i.budget_unit1_percent;
	  else
	     l_period_unit1_value     := i.budget_unit1_value;
	     l_period_unit1_available := i.budget_unit1_available;
             l_period_unit1_percent   := round((i.budget_unit1_value * 100)/p_new_bgt_unit1_value,2) ;
          end if;
       else
	  l_period_unit1_value     := i.budget_unit1_value;
	  l_period_unit1_available := i.budget_unit1_available;
          l_period_unit1_percent   := null;
       end if;
    end if;

    if p_change_mode ='RV' then
       hr_utility.set_location('unit2 for RV '||l_proc,50);
       if nvl(p_new_bgt_unit2_value,0) <> 0 then
          l_period_unit2_percent  := round((i.budget_unit2_value * 100)/p_new_bgt_unit2_value,2) ;
       else
          l_period_unit2_percent := null;
       end if;
       l_period_unit2_value     := i.budget_unit2_value;
       l_period_unit2_available := i.budget_unit2_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit2 for RP '||l_proc,60);
       if nvl(p_new_bgt_unit2_value,0) <> 0 then
          l_period_unit2_value  := round(p_new_bgt_unit2_value * nvl(i.budget_unit2_percent,0)/100,2) ;
          l_period_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_period_unit2_value,0) - nvl(i.budget_unit2_value,0);
          p_bgt_unit2_available := nvl(p_bgt_unit2_available,0) - nvl(l_period_unit2_value,0) + nvl(i.budget_unit2_value,0);
       else
	  l_period_unit2_value := i.budget_unit2_value;
	  l_period_unit2_available := i.budget_unit2_available;
       end if;
       l_period_unit2_percent := i.budget_unit2_percent;
    else
       hr_utility.set_location('unit2 for UE '||l_proc,70);
       if nvl(p_new_bgt_unit2_value,0) <> 0 then
          if i.budget_unit2_value_type_cd = 'P' then
             l_period_unit2_value  := round(p_new_bgt_unit2_value * nvl(i.budget_unit2_percent,0)/100,2) ;
             l_period_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_period_unit2_value,0) - nvl(i.budget_unit2_value,0);
             p_bgt_unit2_available := nvl(p_bgt_unit2_available,0) - nvl(l_period_unit2_value,0) + nvl(i.budget_unit2_value,0);
             l_period_unit2_percent := i.budget_unit2_percent;
	  else
	     l_period_unit2_value := i.budget_unit2_value;
	     l_period_unit2_available := i.budget_unit2_available;
             l_period_unit2_percent  := round((i.budget_unit2_value * 100)/p_new_bgt_unit2_value,2) ;
          end if;
       else
	  l_period_unit2_value := i.budget_unit2_value;
	  l_period_unit2_available := i.budget_unit2_available;
          l_period_unit2_percent := null;
       end if;
    end if;

    if p_change_mode ='RV' then
       hr_utility.set_location('unit3 for RV '||l_proc,80);
       if nvl(p_new_bgt_unit3_value,0) <> 0 then
          l_period_unit3_percent  := round((i.budget_unit3_value * 100)/p_new_bgt_unit3_value,2) ;
       else
          l_period_unit3_percent := null;
       end if;
       l_period_unit3_value     := i.budget_unit3_value;
       l_period_unit3_available := i.budget_unit3_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit3 for RP '||l_proc,90);
       if nvl(p_new_bgt_unit3_value,0) <> 0 then
          l_period_unit3_value  := round(p_new_bgt_unit3_value * nvl(i.budget_unit3_percent,0)/100,2) ;
          l_period_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_period_unit3_value,0) - nvl(i.budget_unit3_value,0);
          p_bgt_unit3_available := nvl(p_bgt_unit3_available,0) - nvl(l_period_unit3_value,0) + nvl(i.budget_unit3_value,0);
       else
	  l_period_unit3_value := i.budget_unit3_value;
	  l_period_unit3_available := i.budget_unit3_available;
       end if;
       l_period_unit3_percent := i.budget_unit3_percent;
    else
       hr_utility.set_location('unit3 for UE '||l_proc,100);
       if nvl(p_new_bgt_unit3_value,0) <> 0 then
          if i.budget_unit3_value_type_cd = 'P' then
             l_period_unit3_value  := round(p_new_bgt_unit3_value * nvl(i.budget_unit3_percent,0)/100,2) ;
             l_period_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_period_unit3_value,0) - nvl(i.budget_unit3_value,0);
             p_bgt_unit3_available := nvl(p_bgt_unit3_available,0) - nvl(l_period_unit3_value,0) + nvl(i.budget_unit3_value,0);
             l_period_unit3_percent := i.budget_unit3_percent;
	  else
	     l_period_unit3_value := i.budget_unit3_value;
	     l_period_unit3_available := i.budget_unit3_available;
             l_period_unit3_percent  := round((i.budget_unit3_value * 100)/p_new_bgt_unit3_value,2) ;
          end if;
       else
	  l_period_unit3_value := i.budget_unit3_value;
	  l_period_unit3_available := i.budget_unit3_available;
          l_period_unit3_percent := null;
       end if;
    end if;
    hr_utility.set_location('calling period changes with values '||l_proc,110);
    hr_utility.set_location('unit1_value is '||l_period_unit1_value||l_proc,120);
    hr_utility.set_location('unit2_value is '||l_period_unit2_value||l_proc,121);
    hr_utility.set_location('unit3_value is '||l_period_unit3_value||l_proc,122);
    hr_utility.set_location('unit1_available is '||l_period_unit1_available||l_proc,123);
    hr_utility.set_location('unit2_available is '||l_period_unit2_available||l_proc,124);
    hr_utility.set_location('unit3_available is '||l_period_unit3_available||l_proc,125);
    propagate_period_changes (p_change_mode          => p_change_mode,
                              p_budget_period_id     => i.budget_period_id,
                              p_new_prd_unit1_value  => l_period_unit1_value,
                              p_new_prd_unit2_value  => l_period_unit2_value,
                              p_new_prd_unit3_value  => l_period_unit3_value,
                              p_unit1_precision      => p_unit1_precision,
                              p_unit2_precision      => p_unit2_precision,
                              p_unit3_precision      => p_unit3_precision,
                              p_prd_unit1_available  => l_period_unit1_available,
                              p_prd_unit2_available  => l_period_unit2_available,
                              p_prd_unit3_available  => l_period_unit3_available);
    hr_utility.set_location('after period changes values '||l_proc,130);
    hr_utility.set_location('unit1_available is '||l_period_unit1_available||l_proc,133);
    hr_utility.set_location('unit2_available is '||l_period_unit2_available||l_proc,134);
    hr_utility.set_location('unit3_available is '||l_period_unit3_available||l_proc,135);
    update pqh_budget_periods
    set budget_unit1_value = l_period_unit1_value,
        budget_unit2_value = l_period_unit2_value,
        budget_unit3_value = l_period_unit3_value,
        budget_unit1_percent = l_period_unit1_percent,
        budget_unit2_percent = l_period_unit2_percent,
        budget_unit3_percent = l_period_unit3_percent,
        budget_unit1_available = l_period_unit1_available,
        budget_unit2_available = l_period_unit2_available,
        budget_unit3_available = l_period_unit3_available
    where current of c1;
    hr_utility.set_location('after period updated '||l_proc,140);
  end loop;

  /* make a call to add_budgetrow to add the all period info. from the table
     and then get the available figures using each unit to be passed on to budget*/

  pqh_budget.add_budgetrow(p_budget_detail_id    => p_budget_detail_id,
                           p_unit1_aggregate     => p_unit1_aggregate,
                           p_unit2_aggregate     => p_unit2_aggregate,
                           p_unit3_aggregate     => p_unit3_aggregate);
  pqh_budget.chk_unit_sum(p_unit1_sum_value     => x_unit1_sum,
	                  p_unit2_sum_value     => x_unit2_sum,
	                  p_unit3_sum_value     => x_unit3_sum);
  pqh_budget.chk_unit_max(p_unit1_max_value     => x_unit1_max,
	                  p_unit2_max_value     => x_unit2_max,
	                  p_unit3_max_value     => x_unit3_max);
  pqh_budget.chk_unit_avg(p_unit1_avg_value     => x_unit1_avg,
	                  p_unit2_avg_value     => x_unit2_avg,
	                  p_unit3_avg_value     => x_unit3_avg);
  if p_unit1_aggregate ='ACCUMULATE' then
     p_bgt_unit1_available := nvl(p_new_bgt_unit1_value,0) - nvl(x_unit1_sum,0);
  elsif p_unit1_aggregate='MAXIMUM' then
     p_bgt_unit1_available := nvl(p_new_bgt_unit1_value,0) - nvl(x_unit1_max,0);
  elsif p_unit1_aggregate='AVERAGE' then
     p_bgt_unit1_available := nvl(p_new_bgt_unit1_value,0) - nvl(x_unit1_avg,0);
  end if;
  if p_unit2_aggregate ='ACCUMULATE' then
     p_bgt_unit2_available := nvl(p_new_bgt_unit2_value,0) - nvl(x_unit2_sum,0);
  elsif p_unit2_aggregate='MAXIMUM' then
     p_bgt_unit2_available := nvl(p_new_bgt_unit2_value,0) - nvl(x_unit2_max,0);
  elsif p_unit2_aggregate='AVERAGE' then
     p_bgt_unit2_available := nvl(p_new_bgt_unit2_value,0) - nvl(x_unit2_avg,0);
  end if;
  if p_unit3_aggregate ='ACCUMULATE' then
     p_bgt_unit3_available := nvl(p_new_bgt_unit3_value,0) - nvl(x_unit3_sum,0);
  elsif p_unit3_aggregate='MAXIMUM' then
     p_bgt_unit3_available := nvl(p_new_bgt_unit3_value,0) - nvl(x_unit3_max,0);
  elsif p_unit3_aggregate='AVERAGE' then
     p_bgt_unit3_available := nvl(p_new_bgt_unit3_value,0) - nvl(x_unit3_avg,0);
  end if;
  hr_utility.set_location('values passed out nocopy are'||l_proc,150);
  p_bgt_unit1_available := round(p_bgt_unit1_available,p_unit1_precision);
  p_bgt_unit2_available := round(p_bgt_unit2_available,p_unit2_precision);
  p_bgt_unit3_available := round(p_bgt_unit3_available,p_unit3_precision);
  hr_utility.set_location('unit1_available is '||p_bgt_unit1_available||l_proc,153);
  hr_utility.set_location('unit2_available is '||p_bgt_unit2_available||l_proc,154);
  hr_utility.set_location('unit3_available is '||p_bgt_unit3_available||l_proc,155);
  hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
p_bgt_unit1_available := ini_budget_unit1_available;
p_bgt_unit2_available := ini_budget_unit2_available;
p_bgt_unit3_available := ini_budget_unit3_available;
raise;
end propagate_budget_changes;

procedure propagate_period_changes (p_change_mode          in varchar2,
                                    p_budget_period_id     in number,
                                    p_new_prd_unit1_value  in number,
                                    p_new_prd_unit2_value  in number,
                                    p_new_prd_unit3_value  in number,
                                    p_unit1_precision      in number,
                                    p_unit2_precision      in number,
                                    p_unit3_precision      in number,
                                    p_prd_unit1_available  in out nocopy number,
                                    p_prd_unit2_available  in out nocopy number,
                                    p_prd_unit3_available  in out nocopy number
)is
   cursor c1 is select budget_unit1_value,budget_unit2_value,budget_unit3_value,
                       budget_unit1_value_type_cd,budget_unit2_value_type_cd,budget_unit3_value_type_cd,
                       budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                       budget_unit1_available,budget_unit2_available,budget_unit3_available
   from pqh_budget_sets
   where budget_period_id = p_budget_period_id
   for update of budget_unit1_value,budget_unit2_value,budget_unit3_value,
                 budget_unit1_percent,budget_unit2_percent,budget_unit3_percent,
                 budget_unit1_available,budget_unit2_available,budget_unit3_available ;

   l_budgetset_unit1_value  number;
   l_budgetset_unit2_value  number;
   l_budgetset_unit3_value  number;
   l_budgetset_unit1_available  number;
   l_budgetset_unit2_available  number;
   l_budgetset_unit3_available  number;
   l_prd_unit1_available number := p_prd_unit1_available;
   l_prd_unit2_available number := p_prd_unit2_available;
   l_prd_unit3_available number := p_prd_unit3_available;
   l_budgetset_unit1_percent  number;
   l_budgetset_unit2_percent  number;
   l_budgetset_unit3_percent  number;

   l_proc varchar2(100) := g_package||'propagate_period_changes' ;
begin
  hr_utility.set_location('entering '||l_proc,10);
  if p_change_mode not in ('RP','RV','UE') then
      hr_utility.set_message(8302,'PQH_WKS_PROPAGATION_METHOD_ERR');
      hr_utility.raise_error;
  end if;
  for i in c1 loop
    if p_change_mode ='RV' then
       hr_utility.set_location('unit1 for RV '||l_proc,20);
       if nvl(p_new_prd_unit1_value,0) <> 0 then
          l_budgetset_unit1_percent  := round((i.budget_unit1_value * 100)/p_new_prd_unit1_value,2) ;
       else
          l_budgetset_unit1_percent := null;
       end if;
       l_budgetset_unit1_value     := i.budget_unit1_value;
       l_budgetset_unit1_available := i.budget_unit1_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit1 for RP '||l_proc,30);
       if nvl(p_new_prd_unit1_value,0) <> 0 then
          l_budgetset_unit1_value  := round(p_new_prd_unit1_value * nvl(i.budget_unit1_percent,0)/100,p_unit1_precision) ;
          l_budgetset_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_budgetset_unit1_value,0) - nvl(i.budget_unit1_value,0);
          p_prd_unit1_available := nvl(p_prd_unit1_available,0) - nvl(l_budgetset_unit1_value,0) + nvl(i.budget_unit1_value,0);
       else
          l_budgetset_unit1_value := i.budget_unit1_value;
          l_budgetset_unit1_available := i.budget_unit1_available;
       end if;
       l_budgetset_unit1_percent := i.budget_unit1_percent;
    else
       hr_utility.set_location('unit1 for UE '||l_proc,40);
       if nvl(p_new_prd_unit1_value,0) <> 0 then
          if i.budget_unit1_value_type_cd = 'P' then
             l_budgetset_unit1_value  := round(p_new_prd_unit1_value * nvl(i.budget_unit1_percent,0)/100,p_unit1_precision) ;
             l_budgetset_unit1_available := nvl(i.budget_unit1_available,0) + nvl(l_budgetset_unit1_value,0) - nvl(i.budget_unit1_value,0);
             p_prd_unit1_available := nvl(p_prd_unit1_available,0) - nvl(l_budgetset_unit1_value,0) + nvl(i.budget_unit1_value,0);
             l_budgetset_unit1_percent := i.budget_unit1_percent;
	  else
             l_budgetset_unit1_percent  := round((i.budget_unit1_value * 100)/p_new_prd_unit1_value,2) ;
             l_budgetset_unit1_value := i.budget_unit1_value;
             l_budgetset_unit1_available := i.budget_unit1_available;
          end if;
       else
          l_budgetset_unit1_value := i.budget_unit1_value;
          l_budgetset_unit1_available := i.budget_unit1_available;
          l_budgetset_unit1_percent := null;
       end if;
    end if;

    if p_change_mode ='RV' then
       hr_utility.set_location('unit2 for RV '||l_proc,50);
       if nvl(p_new_prd_unit2_value,0) <> 0 then
          l_budgetset_unit2_percent  := round((i.budget_unit2_value * 100)/p_new_prd_unit2_value,2) ;
       else
          l_budgetset_unit2_percent := null;
       end if;
       l_budgetset_unit2_value     := i.budget_unit2_value;
       l_budgetset_unit2_available := i.budget_unit2_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit2 for RP '||l_proc,60);
       if nvl(p_new_prd_unit2_value,0) <> 0 then
          l_budgetset_unit2_value  := round(p_new_prd_unit2_value * nvl(i.budget_unit2_percent,0)/100,p_unit2_precision) ;
          l_budgetset_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_budgetset_unit2_value,0) - nvl(i.budget_unit2_value,0);
          p_prd_unit2_available := nvl(p_prd_unit2_available,0) - nvl(l_budgetset_unit2_value,0) + nvl(i.budget_unit2_value,0);
       else
          l_budgetset_unit2_value := i.budget_unit2_value;
          l_budgetset_unit2_available := i.budget_unit2_available;
       end if;
       l_budgetset_unit2_percent := i.budget_unit2_percent;
    else
       hr_utility.set_location('unit2 for UE '||l_proc,70);
       if nvl(p_new_prd_unit2_value,0) <> 0 then
          if i.budget_unit2_value_type_cd = 'P' then
             l_budgetset_unit2_value  := round(p_new_prd_unit2_value * nvl(i.budget_unit2_percent,0)/100,p_unit2_precision) ;
             l_budgetset_unit2_available := nvl(i.budget_unit2_available,0) + nvl(l_budgetset_unit2_value,0) - nvl(i.budget_unit2_value,0);
             p_prd_unit2_available := nvl(p_prd_unit2_available,0) - nvl(l_budgetset_unit2_value,0) + nvl(i.budget_unit2_value,0);
             l_budgetset_unit2_percent := i.budget_unit2_percent;
	  else
             l_budgetset_unit2_value := i.budget_unit2_value;
             l_budgetset_unit2_available := i.budget_unit2_available;
             l_budgetset_unit2_percent  := round((i.budget_unit2_value * 100)/p_new_prd_unit2_value,2) ;
          end if;
       else
          l_budgetset_unit2_value := i.budget_unit2_value;
          l_budgetset_unit2_available := i.budget_unit2_available;
          l_budgetset_unit2_percent := null;
       end if;
    end if;

    if p_change_mode ='RV' then
       hr_utility.set_location('unit3 for RV '||l_proc,80);
       if nvl(p_new_prd_unit3_value,0) <> 0 then
          l_budgetset_unit3_percent  := round((i.budget_unit3_value * 100)/p_new_prd_unit3_value,2) ;
       else
          l_budgetset_unit3_percent := null;
       end if;
       l_budgetset_unit3_value     := i.budget_unit3_value;
       l_budgetset_unit3_available := i.budget_unit3_available;
    elsif p_change_mode ='RP' then
       hr_utility.set_location('unit3 for RP '||l_proc,90);
       if nvl(p_new_prd_unit3_value,0) <> 0 then
          l_budgetset_unit3_value  := round(p_new_prd_unit3_value * nvl(i.budget_unit3_percent,0)/100,p_unit3_precision) ;
          l_budgetset_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_budgetset_unit3_value,0) - nvl(i.budget_unit3_value,0);
          p_prd_unit3_available := nvl(p_prd_unit3_available,0) - nvl(l_budgetset_unit3_value,0) + nvl(i.budget_unit3_value,0);
       else
          l_budgetset_unit3_value := i.budget_unit3_value;
          l_budgetset_unit3_available := i.budget_unit3_available;
       end if;
       l_budgetset_unit3_percent := i.budget_unit3_percent;
    else
       hr_utility.set_location('unit3 for UE '||l_proc,100);
       if nvl(p_new_prd_unit3_value,0) <> 0 then
          if i.budget_unit3_value_type_cd = 'P' then
             l_budgetset_unit3_value  := round(p_new_prd_unit3_value * nvl(i.budget_unit3_percent,0)/100,p_unit3_precision) ;
             l_budgetset_unit3_available := nvl(i.budget_unit3_available,0) + nvl(l_budgetset_unit3_value,0) - nvl(i.budget_unit3_value,0);
             p_prd_unit3_available := nvl(p_prd_unit3_available,0) - nvl(l_budgetset_unit3_value,0) + nvl(i.budget_unit3_value,0);
             l_budgetset_unit3_percent := i.budget_unit3_percent;
	  else
             l_budgetset_unit3_value := i.budget_unit3_value;
             l_budgetset_unit3_available := i.budget_unit3_available;
             l_budgetset_unit3_percent  := round((i.budget_unit3_value * 100)/p_new_prd_unit3_value,2) ;
          end if;
       else
          l_budgetset_unit3_value := i.budget_unit3_value;
          l_budgetset_unit3_available := i.budget_unit3_available;
          l_budgetset_unit3_percent := null;
       end if;
    end if;
    hr_utility.set_location('before update values passed are '||l_proc,110);
    hr_utility.set_location('unit1_value '||l_budgetset_unit1_value||l_proc,120);
    hr_utility.set_location('unit2_value '||l_budgetset_unit2_value||l_proc,121);
    hr_utility.set_location('unit3_value '||l_budgetset_unit3_value||l_proc,122);
    hr_utility.set_location('unit1_percent '||l_budgetset_unit1_percent||l_proc,123);
    hr_utility.set_location('unit2_percent '||l_budgetset_unit2_percent||l_proc,124);
    hr_utility.set_location('unit3_percent '||l_budgetset_unit3_percent||l_proc,125);
    hr_utility.set_location('unit1_available '||l_budgetset_unit1_available||l_proc,126);
    hr_utility.set_location('unit2_available '||l_budgetset_unit2_available||l_proc,127);
    hr_utility.set_location('unit3_available '||l_budgetset_unit3_available||l_proc,128);
    update pqh_budget_sets
    set budget_unit1_value = l_budgetset_unit1_value,
        budget_unit2_value = l_budgetset_unit2_value,
        budget_unit3_value = l_budgetset_unit3_value,
        budget_unit1_percent = l_budgetset_unit1_percent,
        budget_unit2_percent = l_budgetset_unit2_percent,
        budget_unit3_percent = l_budgetset_unit3_percent,
        budget_unit1_available = l_budgetset_unit1_available,
        budget_unit2_available = l_budgetset_unit2_available,
        budget_unit3_available = l_budgetset_unit3_available
    where current of c1;
  end loop;
  hr_utility.set_location('after update out nocopy values passed are '||l_proc,130);
  p_prd_unit1_available := round(p_prd_unit1_available,p_unit1_precision);
  p_prd_unit2_available := round(p_prd_unit2_available,p_unit2_precision);
  p_prd_unit3_available := round(p_prd_unit3_available,p_unit3_precision);
  hr_utility.set_location('unit1_available '||p_prd_unit1_available||l_proc,136);
  hr_utility.set_location('unit2_available '||p_prd_unit2_available||l_proc,137);
  hr_utility.set_location('unit3_available '||p_prd_unit3_available||l_proc,138);
  hr_utility.set_location('exiting '||l_proc,1000);
exception when others then
p_prd_unit1_available := l_prd_unit1_available;
p_prd_unit2_available := l_prd_unit2_available;
p_prd_unit3_available := l_prd_unit3_available;
raise;
end propagate_period_changes;

procedure insert_budget_detail(
  p_budget_version_id           in number,
  p_organization_id             in number           default null,
  p_job_id                      in number           default null,
  p_position_id                 in number           default null,
  p_grade_id                    in number           default null,
  p_budget_unit1_percent        in number           default null,
  p_budget_unit1_value          in number           default null,
  p_budget_unit2_percent        in number           default null,
  p_budget_unit2_value          in number           default null,
  p_budget_unit3_percent        in number           default null,
  p_budget_unit3_value          in number           default null,
  p_budget_unit1_value_type_cd  in varchar2         default null,
  p_budget_unit2_value_type_cd  in varchar2         default null,
  p_budget_unit3_value_type_cd  in varchar2         default null,
  p_gl_status                   in varchar2         default null,
  p_budget_unit1_available      in number           default null,
  p_budget_unit2_available      in number           default null,
  p_budget_unit3_available      in number           default null,
  p_budget_detail_id               out nocopy number
) is
l_object_version_number number;
begin
   pqh_budget_details_api.create_budget_detail(
       p_validate                   => FALSE
      ,p_budget_detail_id           => p_budget_detail_id
      ,p_budget_version_id          => p_budget_version_id
      ,p_organization_id            => p_organization_id
      ,p_position_id                => p_position_id
      ,p_job_id                     => p_job_id
      ,p_grade_id                   => p_grade_id
      ,p_gl_status                  => p_gl_status
      ,p_budget_unit1_value         => p_budget_unit1_value
      ,p_budget_unit1_percent       => p_budget_unit1_percent
      ,p_budget_unit1_available     => p_budget_unit1_available
      ,p_budget_unit1_value_type_cd => p_budget_unit1_value_type_cd
      ,p_budget_unit2_value         => p_budget_unit2_value
      ,p_budget_unit2_percent       => p_budget_unit2_percent
      ,p_budget_unit2_available     => p_budget_unit2_available
      ,p_budget_unit2_value_type_cd => p_budget_unit2_value_type_cd
      ,p_budget_unit3_value         => p_budget_unit3_value
      ,p_budget_unit3_percent       => p_budget_unit3_percent
      ,p_budget_unit3_available     => p_budget_unit3_available
      ,p_budget_unit3_value_type_cd => p_budget_unit3_value_type_cd
      ,p_object_version_number      => l_object_version_number
    );
exception when others then
p_budget_detail_id := null;
raise;
end insert_budget_detail;

Procedure update_budget_detail
  (
  p_budget_detail_id             in number,
  p_budget_version_id            in number           default hr_api.g_number,
  p_organization_id              in number           default hr_api.g_number,
  p_job_id                       in number           default hr_api.g_number,
  p_position_id                  in number           default hr_api.g_number,
  p_grade_id                     in number           default hr_api.g_number,
  p_budget_unit1_percent         in number           default hr_api.g_number,
  p_budget_unit1_value           in number           default hr_api.g_number,
  p_budget_unit2_percent         in number           default hr_api.g_number,
  p_budget_unit2_value           in number           default hr_api.g_number,
  p_budget_unit3_percent         in number           default hr_api.g_number,
  p_budget_unit3_value           in number           default hr_api.g_number,
  p_object_version_number        in out nocopy number,
  p_budget_unit1_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_budget_unit2_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_budget_unit3_value_type_cd   in varchar2         default hr_api.g_varchar2,
  p_gl_status                    in varchar2         default hr_api.g_varchar2,
  p_budget_unit1_available       in number           default hr_api.g_number,
  p_budget_unit2_available       in number           default hr_api.g_number,
  p_budget_unit3_available       in number           default hr_api.g_number
  ) is
  l_proc varchar2(61) := g_package||'Update_bgd';
  l_object_version_number number := p_object_version_number;
begin
   hr_utility.set_location('entering'||l_proc,10);
   hr_utility.set_location('bgd id is'||p_budget_detail_id||l_proc,11);
   hr_utility.set_location('ovn is'||p_object_version_number||l_proc,12);
   pqh_budget_details_api.update_budget_detail(
      p_validate                    => FALSE
      ,p_budget_detail_id           => p_budget_detail_id
      ,p_budget_version_id          => p_budget_version_id
      ,p_organization_id            => p_organization_id
      ,p_position_id                => p_position_id
      ,p_job_id                     => p_job_id
      ,p_grade_id                   => p_grade_id
      ,p_budget_unit1_value         => p_budget_unit1_value
      ,p_budget_unit1_percent       => p_budget_unit1_percent
      ,p_budget_unit1_available     => p_budget_unit1_available
      ,p_budget_unit1_value_type_cd => p_budget_unit1_value_type_cd
      ,p_budget_unit2_value         => p_budget_unit2_value
      ,p_budget_unit2_percent       => p_budget_unit2_percent
      ,p_budget_unit2_available     => p_budget_unit2_available
      ,p_budget_unit2_value_type_cd => p_budget_unit2_value_type_cd
      ,p_budget_unit3_value         => p_budget_unit3_value
      ,p_budget_unit3_percent       => p_budget_unit3_percent
      ,p_budget_unit3_available     => p_budget_unit3_available
      ,p_budget_unit3_value_type_cd => p_budget_unit3_value_type_cd
      ,p_gl_status                  => p_gl_status
      ,p_object_version_number      => p_object_version_number
    );
   hr_utility.set_location('wkd id is'||p_budget_detail_id||l_proc,20);
   hr_utility.set_location('ovn is'||p_object_version_number||l_proc,30);
   hr_utility.set_location('exiting'||l_proc,100);
   exception when others then
   p_object_version_number := l_object_version_number;
   raise;
end update_budget_detail;
procedure bgv_date_validation( p_budget_id      in number,
			       p_version_number in number ,
			       p_date_from      in date,
			       p_date_to        in date,
			       p_bgv_ll_date    out nocopy date,
			       p_bgv_ul_date    out nocopy date,
			       p_status         out nocopy varchar2) is
   l_max_version    number;
   l_min_version    number;
   cursor c0 is select max(version_number) from pqh_budget_versions
		where budget_id = p_budget_id ;
   cursor c1 is select min(version_number) from pqh_budget_versions
		where budget_id = p_budget_id ;
-- cursor to fetch the end_date of the last_version
   cursor c2 is select date_to from pqh_budget_versions
		where version_number = l_max_version
		and budget_id = p_budget_id;
-- cursor to fetch next version from the current version
   cursor c5 is select date_from from pqh_budget_versions
                where budget_id = p_budget_id
                and version_number = (select min(version_number)
                                      from pqh_budget_versions
                                      where budget_id = p_budget_id
                                      and version_number > p_version_number) ;
-- cursor to fetch previous version from the current version
   cursor c6 is select date_to from pqh_budget_versions
                where budget_id = p_budget_id
                and version_number = (select max(version_number)
                                      from pqh_budget_versions
                                      where budget_id = p_budget_id
                                      and version_number < p_version_number) ;
   l_max_end_date   date;
   l_min_start_date date;
   l_ver_end_date   date;
   l_next_ver_start_date date;
   l_prev_ver_end_date date;
   l_ver_chk        varchar2(15);
   l_ver_start_date date;
   l_proc           varchar2(61) := g_package ||'bgv_date_validation' ;
begin
   hr_utility.set_location('entering '||l_proc,10);
   hr_utility.set_location('ver # entered is '||p_version_number||l_proc,10);
   hr_utility.set_location('start_date is '||p_date_from||l_proc,10);
   hr_utility.set_location('end_date is '||p_date_to||l_proc,10);
   if p_budget_id is null then
      hr_utility.set_message(8302,'PQH_INVALID_BUDGET');
      hr_utility.raise_error;
   elsif p_version_number is null then
      hr_utility.set_message(8302,'PQH_INVALID_VERSION_FOR_BDGT');
      hr_utility.raise_error;
   elsif p_date_from is null then
      hr_utility.set_message(8302,'PQH_START_DT_NULL');
      hr_utility.raise_error;
   elsif p_date_to is null then
      hr_utility.set_message(8302,'PQH_END_DT_NULL');
      hr_utility.raise_error;
   elsif p_date_from > p_date_to then
      hr_utility.set_message(8302,'PQH_INVALID_END_DT');
      hr_utility.set_message_token('STARTDATE',fnd_date.date_to_chardate(p_date_from));
      hr_utility.set_message_token('ENDDATE',fnd_date.date_to_chardate(p_date_to));
      hr_utility.raise_error;
   end if;
   -- we are here to correct a existing version or checking for the new version to be entered.
   open c0;
   fetch c0 into l_max_version;
   close c0;
   hr_utility.set_location('max_version is'||l_max_version||l_proc,70);
   open c1;
   fetch c1 into l_min_version;
   close c1;
   hr_utility.set_location('min_version is'||l_min_version||l_proc,80);
   hr_utility.set_location('max_end_date is'||l_max_end_date||l_proc,90);
   hr_utility.set_location('min_start_date is'||l_min_start_date||l_proc,100);
   if p_version_number = l_max_version then
      open c6;
      fetch c6 into l_prev_ver_end_date;
      close c6;
      hr_utility.set_location('version_number = max_version'||l_proc,140);
      -- last version is getting corrected
      if p_version_number = l_min_version then
         hr_utility.set_location('version_number = min version'||l_proc,142);
         -- There is only one version and we are working on it.so any date user enters is okay.
         p_status := 'SUCCESS' ;
      else
         hr_utility.set_location('Lower limit should be > '||l_prev_ver_end_date||l_proc,162);
         if p_date_from > l_prev_ver_end_date then
            hr_utility.set_location('between valid dates '||l_proc,145);
            p_status := 'SUCCESS' ;
         else
            hr_utility.set_location('not between valid dates '||l_proc,148);
            p_bgv_ll_date := l_prev_ver_end_date;
            p_status := 'ERROR' ;
         end if;
      end if;
   elsif p_version_number > l_max_version then
      -- new version is getting added
      open c2;
      fetch c2 into l_max_end_date;
      close c2;
      hr_utility.set_location('version_number > max_version'||l_proc,150);
      hr_utility.set_location('Lower limit should be > '||l_max_end_date||l_proc,162);
      if p_date_from > l_max_end_date then
         hr_utility.set_location('between valid dates '||l_proc,155);
         p_status := 'SUCCESS' ;
      else
         hr_utility.set_location('not between valid dates '||l_proc,158);
         p_bgv_ll_date := l_max_end_date;
         p_status := 'ERROR' ;
      end if;
   elsif p_version_number = l_min_version then
      open c5;
      fetch c5 into l_next_ver_start_date;
      close c5;
      -- first version is getting corrected
      -- but end date should be equal to ver_end_date
      hr_utility.set_location('version_number = min_version'||l_proc,160);
      hr_utility.set_location('Upper limit should be < '||l_next_ver_start_date||l_proc,162);
      if p_date_to < l_next_ver_start_date then
         hr_utility.set_location('between valid dates '||l_proc,165);
         p_status := 'SUCCESS' ;
      else
         hr_utility.set_location('not between valid dates '||l_proc,168);
         p_bgv_ul_date := l_next_ver_start_date;
         p_status := 'ERROR' ;
      end if;
   else
      open c5;
      fetch c5 into l_next_ver_start_date;
      close c5;
      open c6;
      fetch c6 into l_prev_ver_end_date;
      close c6;
      hr_utility.set_location('version_number in middle '||l_proc,170);
      -- a version in middle is getting corrected
      -- in this case start date of the worksheet should be less than or equal to start date
      -- of the version and worksheet end date should be greater than or equal to version
      -- and also version start date should be between last_ver_end_date and next_ver_start_date
      -- and also version_end_date should be between last_ver_end date and next_ver_start_date
      if p_date_from between l_prev_ver_end_date+1 and l_next_ver_start_date-1
         and p_date_to between l_prev_ver_end_date+1 and l_next_ver_start_date-1 then
            hr_utility.set_location('between valid dates '||l_proc,175);
            p_status := 'SUCCESS' ;
      else
            hr_utility.set_location('not between valid dates '||l_proc,178);
            p_bgv_ll_date := l_prev_ver_end_date+1;
            p_bgv_ul_date := l_next_ver_start_date-1;
            p_status := 'ERROR' ;
      end if;
   end if;
   hr_utility.set_location('end of validation with status'||p_status||l_proc,270);
exception when others then
p_bgv_ll_date    := null;
p_bgv_ul_date    := null;
p_status         := null;
raise;
end bgv_date_validation;

function gl_post(p_budget_version_id in number) return number is
l_req number := -1;
begin
   l_req := fnd_request.submit_request(application => 'PQH',
                                       program     => 'PQHGLPOST',
                                       argument1   => p_budget_version_id);
   return l_req;
end gl_post;

end pqh_bdgt;

/
