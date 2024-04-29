--------------------------------------------------------
--  DDL for Package Body BEN_SS_DTCT_PTNL_LER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_SS_DTCT_PTNL_LER" as
/* $Header: beptnldt.pkb 115.2 2003/02/12 10:30:52 rpgupta noship $ */
--
-- ----------------------------------------------------------------------------
--
-- Package Variable

g_package  varchar2(33) := '  ben_ss_dtct_ptnl_ler.';
--
-- ----------------------------------------------------------------------------
-- |------------------------< dtct_ptnl_ler >------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
-- This is a process which can be used by selfservice web pages( By OAB, HR and
-- Others  ) for finding out  about the newly created life events. This procedure will return
-- the appropriate message based on the Potential Life event status Code. This does not
-- necessary means that this potential life event will definitely affect their benefits
-- beacause we don't know unless we run benmngle. The purpose of this procedure is to simply warn.
--
--
-- Prerequisites:
--
--
-- Post Success: This procedure will return messages which are based on the Potential life event
-- status code.
-- This procedure will return null if there is no message approprita for the situation.
--
--



procedure dtct_ptnl_ler
(p_person_id              in number ,
p_business_group_id       in number,
p_effective_date          in date default trunc(sysdate),
p_message                 out nocopy varchar2 ) as


 l_proc varchar2(72) := g_package||'dtct_ptnl_ler';
--
--Declare cursors and variables
--
  cursor c_ptnl_lers is
		select ptn.ptnl_ler_for_per_id,
                    ptn.ptnl_ler_for_per_stat_cd
                    from ben_ptnl_ler_for_per ptn
                    where ptn.person_id = p_person_id
                    and ptn.business_group_id =  p_business_group_id
                    and ptn.lf_evt_ocrd_dt <=  p_effective_date ;

  v_ptnl_lers  c_ptnl_lers%rowtype;
  v_mnl_message varchar2(2000):= null;
  v_ler_message varchar2(2000):= null;

Begin
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
   open c_ptnl_lers ;
   fetch c_ptnl_lers into v_ptnl_lers;
-- if there are no potential life events return null .
	if c_ptnl_lers%notfound then
	p_message := null;
        else
          loop
               if v_ptnl_lers.ptnl_ler_for_per_stat_cd = 'MNL' then
                v_mnl_message := fnd_message.get_string('BEN','BEN_92657_MNL_PLE');
                elsif v_ptnl_lers.ptnl_ler_for_per_stat_cd in ('DTCTD','MNLO','UNPROCD') then
                v_ler_message := fnd_message.get_string('BEN','BEN_92671_OPEN_BENEFIT');
                end if;
                fetch c_ptnl_lers into v_ptnl_lers;
                exit when c_ptnl_lers%notfound;
          end loop;
-- if there is any potential life event which has a status code MNL then throw this message.
          if v_mnl_message is not  null then
          p_message := v_mnl_message;
          elsif v_ler_message is not null then
		p_message := v_ler_message;
	  else
		p_message := null;
	  end if;
        end if;
   close c_ptnl_lers;
--
 hr_utility.set_location('Entering:'|| l_proc, 100);
end dtct_ptnl_ler;
--
end ben_ss_dtct_ptnl_ler;

/
