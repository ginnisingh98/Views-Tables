--------------------------------------------------------
--  DDL for Package Body PER_QH_TAX_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QH_TAX_QUERY" as
/* $Header: peqhtaxq.pkb 115.4 2004/02/10 00:36:51 jpthomas noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := '  per_qh_tax_query.';
--
procedure tax_query
(p_rec                 out nocopy taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
) is
  l_proc varchar2(72) := g_package||'tax_query';
--
begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
  if p_legislation_code='UK' then
    hr_utility.set_location('Entering:'|| l_proc, 20);
    --
    -- localizations should make a call to their OWN packages in here, using
    -- the record structure to pass the data. You must not place your own
    -- code in here, to keep the size of the package maneagable.
    --
  elsif p_legislation_code='US' then
    hr_utility.set_location('Entering:'|| l_proc, 30);
  elsif p_legislation_code='IT' then
    hr_utility.set_location('Entering:'|| l_proc, 40);
    per_it_qh_tax.it_tax_query
    			(p_rec              => p_rec
    			,p_person_id        => p_person_id
    			,p_assignment_id    => p_assignment_id
    			,p_legislation_code => p_legislation_code
    			,p_effective_date   => p_effective_date
    			);
  elsif p_legislation_code='NL' then
    hr_utility.set_location('Entering:'|| l_proc, 50);
    per_nl_qh_tax.nl_tax_query
    			(p_rec              => p_rec
    			,p_person_id        => p_person_id
    			,p_assignment_id    => p_assignment_id
    			,p_legislation_code => p_legislation_code
    			,p_effective_date   => p_effective_date
    			);
  end if;
--
  hr_utility.set_location('Leaving:'|| l_proc, 1000);
--
end tax_query;
--
procedure tax_query
(tax_effective_start_date    out nocopy date
,tax_effective_end_date      out nocopy date
,tax_field1            out nocopy VARCHAR2
,tax_field2            out nocopy VARCHAR2
,tax_field3            out nocopy VARCHAR2
,tax_field4            out nocopy VARCHAR2
,tax_field5            out nocopy VARCHAR2
,tax_field6            out nocopy VARCHAR2
,tax_field7            out nocopy VARCHAR2
,tax_field8            out nocopy VARCHAR2
,tax_field9            out nocopy VARCHAR2
,tax_field10           out nocopy VARCHAR2
,tax_field11           out nocopy VARCHAR2
,tax_field12           out nocopy VARCHAR2
,tax_field13           out nocopy VARCHAR2
,tax_field14           out nocopy VARCHAR2
,tax_field15           out nocopy VARCHAR2
,tax_field16           out nocopy VARCHAR2
,tax_field17           out nocopy VARCHAR2
,tax_field18           out nocopy VARCHAR2
,tax_field19           out nocopy VARCHAR2
,tax_field20           out nocopy VARCHAR2
,tax_field21           out nocopy VARCHAR2
,tax_field22           out nocopy VARCHAR2
,tax_field23           out nocopy VARCHAR2
,tax_field24           out nocopy VARCHAR2
,tax_field25           out nocopy VARCHAR2
,tax_field26           out nocopy VARCHAR2
,tax_field27           out nocopy VARCHAR2
,tax_field28           out nocopy VARCHAR2
,tax_field29           out nocopy VARCHAR2
,tax_field30           out nocopy VARCHAR2
,tax_field31           out nocopy VARCHAR2
,tax_field32           out nocopy VARCHAR2
,tax_field33           out nocopy VARCHAR2
,tax_field34           out nocopy VARCHAR2
,tax_field35           out nocopy VARCHAR2
,tax_field36           out nocopy VARCHAR2
,tax_field37           out nocopy VARCHAR2
,tax_field38           out nocopy VARCHAR2
,tax_field39           out nocopy VARCHAR2
,tax_field40           out nocopy VARCHAR2
,tax_field41           out nocopy VARCHAR2
,tax_field42           out nocopy VARCHAR2
,tax_field43           out nocopy VARCHAR2
,tax_field44           out nocopy VARCHAR2
,tax_field45           out nocopy VARCHAR2
,tax_field46           out nocopy VARCHAR2
,tax_field47           out nocopy VARCHAR2
,tax_field48           out nocopy VARCHAR2
,tax_field49           out nocopy VARCHAR2
,tax_field50           out nocopy VARCHAR2
,tax_field51           out nocopy VARCHAR2
,tax_field52           out nocopy VARCHAR2
,tax_field53           out nocopy VARCHAR2
,tax_field54           out nocopy VARCHAR2
,tax_field55           out nocopy VARCHAR2
,tax_field56           out nocopy VARCHAR2
,tax_field57           out nocopy VARCHAR2
,tax_field58           out nocopy VARCHAR2
,tax_field59           out nocopy VARCHAR2
,tax_field60           out nocopy VARCHAR2
,tax_field61           out nocopy VARCHAR2
,tax_field62           out nocopy VARCHAR2
,tax_field63           out nocopy VARCHAR2
,tax_field64           out nocopy VARCHAR2
,tax_field65           out nocopy VARCHAR2
,tax_field66           out nocopy VARCHAR2
,tax_field67           out nocopy VARCHAR2
,tax_field68           out nocopy VARCHAR2
,tax_field69           out nocopy VARCHAR2
,tax_field70           out nocopy VARCHAR2
,tax_field71           out nocopy VARCHAR2
,tax_field72           out nocopy VARCHAR2
,tax_field73           out nocopy VARCHAR2
,tax_field74           out nocopy VARCHAR2
,tax_field75           out nocopy VARCHAR2
,tax_field76           out nocopy VARCHAR2
,tax_field77           out nocopy VARCHAR2
,tax_field78           out nocopy VARCHAR2
,tax_field79           out nocopy VARCHAR2
,tax_field80           out nocopy VARCHAR2
,tax_field81           out nocopy VARCHAR2
,tax_field82           out nocopy VARCHAR2
,tax_field83           out nocopy VARCHAR2
,tax_field84           out nocopy VARCHAR2
,tax_field85           out nocopy VARCHAR2
,tax_field86           out nocopy VARCHAR2
,tax_field87           out nocopy VARCHAR2
,tax_field88           out nocopy VARCHAR2
,tax_field89           out nocopy VARCHAR2
,tax_field90           out nocopy VARCHAR2
,tax_field91           out nocopy VARCHAR2
,tax_field92           out nocopy VARCHAR2
,tax_field93           out nocopy VARCHAR2
,tax_field94           out nocopy VARCHAR2
,tax_field95           out nocopy VARCHAR2
,tax_field96           out nocopy VARCHAR2
,tax_field97           out nocopy VARCHAR2
,tax_field98           out nocopy VARCHAR2
,tax_field99           out nocopy VARCHAR2
,tax_field100          out nocopy VARCHAR2
,tax_field101          out nocopy VARCHAR2
,tax_field102          out nocopy VARCHAR2
,tax_field103          out nocopy VARCHAR2
,tax_field104          out nocopy VARCHAR2
,tax_field105          out nocopy VARCHAR2
,tax_field106          out nocopy VARCHAR2
,tax_field107          out nocopy VARCHAR2
,tax_field108          out nocopy VARCHAR2
,tax_field109          out nocopy VARCHAR2
,tax_field110          out nocopy VARCHAR2
,tax_field111          out nocopy VARCHAR2
,tax_field112          out nocopy VARCHAR2
,tax_field113          out nocopy VARCHAR2
,tax_field114          out nocopy VARCHAR2
,tax_field115          out nocopy VARCHAR2
,tax_field116          out nocopy VARCHAR2
,tax_field117          out nocopy VARCHAR2
,tax_field118          out nocopy VARCHAR2
,tax_field119          out nocopy VARCHAR2
,tax_field120          out nocopy VARCHAR2
,tax_field121          out nocopy VARCHAR2
,tax_field122          out nocopy VARCHAR2
,tax_field123          out nocopy VARCHAR2
,tax_field124          out nocopy VARCHAR2
,tax_field125          out nocopy VARCHAR2
,tax_field126          out nocopy VARCHAR2
,tax_field127          out nocopy VARCHAR2
,tax_field128          out nocopy VARCHAR2
,tax_field129          out nocopy VARCHAR2
,tax_field130          out nocopy VARCHAR2
,tax_field131          out nocopy VARCHAR2
,tax_field132          out nocopy VARCHAR2
,tax_field133          out nocopy VARCHAR2
,tax_field134          out nocopy VARCHAR2
,tax_field135          out nocopy VARCHAR2
,tax_field136          out nocopy VARCHAR2
,tax_field137          out nocopy VARCHAR2
,tax_field138          out nocopy VARCHAR2
,tax_field139          out nocopy VARCHAR2
,tax_field140          out nocopy VARCHAR2
-- Bug 3357807 Start Here
,tax_field141                 OUT NOCOPY DATE
,tax_field142                 OUT NOCOPY DATE
,tax_field143                 OUT NOCOPY DATE
,tax_field144                 OUT NOCOPY DATE
,tax_field145                 OUT NOCOPY DATE
,tax_field146                 OUT NOCOPY DATE
,tax_field147                 OUT NOCOPY DATE
,tax_field148                 OUT NOCOPY DATE
,tax_field149                 OUT NOCOPY DATE
,tax_field150                 OUT NOCOPY DATE
-- Bug 3357807 End Here
,tax_update_allowed    out nocopy varchar2
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
) is
  l_rec taxrec;
  l_proc varchar2(72) := g_package||'tax__query';
--
begin
--
-- this procedure must not be modified by localization teams
--
  hr_utility.set_location('Entering:'|| l_proc, 10);
--
tax_query
(p_rec              => l_rec
,p_person_id        => p_person_id
,p_assignment_id    => p_assignment_id
,p_legislation_code => p_legislation_code
,p_effective_date   => p_effective_date
);
tax_effective_start_date := l_rec.tax_effective_start_date;
tax_effective_end_date   := l_rec.tax_effective_end_date;
tax_field1         := l_rec.tax_field1;
tax_field2         := l_rec.tax_field2;
tax_field3         := l_rec.tax_field3;
tax_field4         := l_rec.tax_field4;
tax_field5         := l_rec.tax_field5;
tax_field6         := l_rec.tax_field6;
tax_field7         := l_rec.tax_field7;
tax_field8         := l_rec.tax_field8;
tax_field9         := l_rec.tax_field9;
tax_field10        := l_rec.tax_field10;
tax_field11        := l_rec.tax_field11;
tax_field12        := l_rec.tax_field12;
tax_field13        := l_rec.tax_field13;
tax_field14        := l_rec.tax_field14;
tax_field15        := l_rec.tax_field15;
tax_field16        := l_rec.tax_field16;
tax_field17        := l_rec.tax_field17;
tax_field18        := l_rec.tax_field18;
tax_field19        := l_rec.tax_field19;
tax_field20        := l_rec.tax_field20;
tax_field21        := l_rec.tax_field21;
tax_field22        := l_rec.tax_field22;
tax_field23        := l_rec.tax_field23;
tax_field24        := l_rec.tax_field24;
tax_field25        := l_rec.tax_field25;
tax_field26        := l_rec.tax_field26;
tax_field27        := l_rec.tax_field27;
tax_field28        := l_rec.tax_field28;
tax_field29        := l_rec.tax_field29;
tax_field30        := l_rec.tax_field30;
tax_field31        := l_rec.tax_field31;
tax_field32        := l_rec.tax_field32;
tax_field33        := l_rec.tax_field33;
tax_field34        := l_rec.tax_field34;
tax_field35        := l_rec.tax_field35;
tax_field36        := l_rec.tax_field36;
tax_field37        := l_rec.tax_field37;
tax_field38        := l_rec.tax_field38;
tax_field39        := l_rec.tax_field39;
tax_field40        := l_rec.tax_field40;
tax_field41        := l_rec.tax_field41;
tax_field42        := l_rec.tax_field42;
tax_field43        := l_rec.tax_field43;
tax_field44        := l_rec.tax_field44;
tax_field45        := l_rec.tax_field45;
tax_field46        := l_rec.tax_field46;
tax_field47        := l_rec.tax_field47;
tax_field48        := l_rec.tax_field48;
tax_field49        := l_rec.tax_field49;
tax_field50        := l_rec.tax_field50;
tax_field51        := l_rec.tax_field51;
tax_field52        := l_rec.tax_field52;
tax_field53        := l_rec.tax_field53;
tax_field54        := l_rec.tax_field54;
tax_field55        := l_rec.tax_field55;
tax_field56        := l_rec.tax_field56;
tax_field57        := l_rec.tax_field57;
tax_field58        := l_rec.tax_field58;
tax_field59        := l_rec.tax_field59;
tax_field60        := l_rec.tax_field60;
tax_field61        := l_rec.tax_field61;
tax_field62        := l_rec.tax_field62;
tax_field63        := l_rec.tax_field63;
tax_field64        := l_rec.tax_field64;
tax_field65        := l_rec.tax_field65;
tax_field66        := l_rec.tax_field66;
tax_field67        := l_rec.tax_field67;
tax_field68        := l_rec.tax_field68;
tax_field69        := l_rec.tax_field69;
tax_field70        := l_rec.tax_field70;
tax_field71        := l_rec.tax_field71;
tax_field72        := l_rec.tax_field72;
tax_field73        := l_rec.tax_field73;
tax_field74        := l_rec.tax_field74;
tax_field75        := l_rec.tax_field75;
tax_field76        := l_rec.tax_field76;
tax_field77        := l_rec.tax_field77;
tax_field78        := l_rec.tax_field78;
tax_field79        := l_rec.tax_field79;
tax_field80        := l_rec.tax_field80;
tax_field81        := l_rec.tax_field81;
tax_field82        := l_rec.tax_field82;
tax_field83        := l_rec.tax_field83;
tax_field84        := l_rec.tax_field84;
tax_field85        := l_rec.tax_field85;
tax_field86        := l_rec.tax_field86;
tax_field87        := l_rec.tax_field87;
tax_field88        := l_rec.tax_field88;
tax_field89        := l_rec.tax_field89;
tax_field90        := l_rec.tax_field90;
tax_field91        := l_rec.tax_field91;
tax_field92        := l_rec.tax_field92;
tax_field93        := l_rec.tax_field93;
tax_field94        := l_rec.tax_field94;
tax_field95        := l_rec.tax_field95;
tax_field96        := l_rec.tax_field96;
tax_field97        := l_rec.tax_field97;
tax_field98        := l_rec.tax_field98;
tax_field99        := l_rec.tax_field99;
tax_field100       := l_rec.tax_field100;
tax_field101       := l_rec.tax_field101;
tax_field102       := l_rec.tax_field102;
tax_field103       := l_rec.tax_field103;
tax_field104       := l_rec.tax_field104;
tax_field105       := l_rec.tax_field105;
tax_field106       := l_rec.tax_field106;
tax_field107       := l_rec.tax_field107;
tax_field108       := l_rec.tax_field108;
tax_field109       := l_rec.tax_field109;
tax_field110       := l_rec.tax_field110;
tax_field111       := l_rec.tax_field111;
tax_field112       := l_rec.tax_field112;
tax_field113       := l_rec.tax_field113;
tax_field114       := l_rec.tax_field114;
tax_field115       := l_rec.tax_field115;
tax_field116       := l_rec.tax_field116;
tax_field117       := l_rec.tax_field117;
tax_field118       := l_rec.tax_field118;
tax_field119       := l_rec.tax_field119;
tax_field120       := l_rec.tax_field120;
tax_field121       := l_rec.tax_field121;
tax_field122       := l_rec.tax_field122;
tax_field123       := l_rec.tax_field123;
tax_field124       := l_rec.tax_field124;
tax_field125       := l_rec.tax_field125;
tax_field126       := l_rec.tax_field126;
tax_field127       := l_rec.tax_field127;
tax_field128       := l_rec.tax_field128;
tax_field129       := l_rec.tax_field129;
tax_field130       := l_rec.tax_field130;
tax_field131       := l_rec.tax_field131;
tax_field132       := l_rec.tax_field132;
tax_field133       := l_rec.tax_field133;
tax_field134       := l_rec.tax_field134;
tax_field135       := l_rec.tax_field135;
tax_field136       := l_rec.tax_field136;
tax_field137       := l_rec.tax_field137;
tax_field138       := l_rec.tax_field138;
tax_field139       := l_rec.tax_field139;
tax_field140       := l_rec.tax_field140;
tax_field141       := l_rec.tax_field141;
tax_field142       := l_rec.tax_field142;
tax_field143       := l_rec.tax_field143;
tax_field144       := l_rec.tax_field144;
tax_field145       := l_rec.tax_field145;
tax_field146       := l_rec.tax_field146;
tax_field147       := l_rec.tax_field147;
tax_field148       := l_rec.tax_field148;
tax_field149       := l_rec.tax_field149;
tax_field150       := l_rec.tax_field150;
tax_update_allowed := l_rec.tax_update_allowed;
--
  hr_utility.set_location('Leaving:'|| l_proc, 20);
--
end tax_query;
--

end per_qh_tax_query;

/
