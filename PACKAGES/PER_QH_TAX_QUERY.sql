--------------------------------------------------------
--  DDL for Package PER_QH_TAX_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QH_TAX_QUERY" AUTHID CURRENT_USER as
/* $Header: peqhtaxq.pkh 115.3 2004/02/10 00:36:15 jpthomas noship $ */

type taxrec is RECORD
(tax_effective_start_date      date
,tax_effective_end_date        date
,tax_field1                    VARCHAR2(150)
,tax_field2                    VARCHAR2(150)
,tax_field3                    VARCHAR2(150)
,tax_field4                    VARCHAR2(150)
,tax_field5                    VARCHAR2(150)
,tax_field6                    VARCHAR2(150)
,tax_field7                    VARCHAR2(150)
,tax_field8                    VARCHAR2(150)
,tax_field9                    VARCHAR2(150)
,tax_field10                   VARCHAR2(150)
,tax_field11                   VARCHAR2(150)
,tax_field12                   VARCHAR2(150)
,tax_field13                   VARCHAR2(150)
,tax_field14                   VARCHAR2(150)
,tax_field15                   VARCHAR2(150)
,tax_field16                   VARCHAR2(150)
,tax_field17                   VARCHAR2(150)
,tax_field18                   VARCHAR2(150)
,tax_field19                   VARCHAR2(150)
,tax_field20                   VARCHAR2(150)
,tax_field21                   VARCHAR2(150)
,tax_field22                   VARCHAR2(150)
,tax_field23                   VARCHAR2(150)
,tax_field24                   VARCHAR2(150)
,tax_field25                   VARCHAR2(150)
,tax_field26                   VARCHAR2(150)
,tax_field27                   VARCHAR2(150)
,tax_field28                   VARCHAR2(150)
,tax_field29                   VARCHAR2(150)
,tax_field30                   VARCHAR2(150)
,tax_field31                   VARCHAR2(150)
,tax_field32                   VARCHAR2(150)
,tax_field33                   VARCHAR2(150)
,tax_field34                   VARCHAR2(150)
,tax_field35                   VARCHAR2(150)
,tax_field36                   VARCHAR2(150)
,tax_field37                   VARCHAR2(150)
,tax_field38                   VARCHAR2(150)
,tax_field39                   VARCHAR2(150)
,tax_field40                   VARCHAR2(150)
,tax_field41                   VARCHAR2(150)
,tax_field42                   VARCHAR2(150)
,tax_field43                   VARCHAR2(150)
,tax_field44                   VARCHAR2(150)
,tax_field45                   VARCHAR2(150)
,tax_field46                   VARCHAR2(150)
,tax_field47                   VARCHAR2(150)
,tax_field48                   VARCHAR2(150)
,tax_field49                   VARCHAR2(150)
,tax_field50                   VARCHAR2(150)
,tax_field51                   VARCHAR2(150)
,tax_field52                   VARCHAR2(150)
,tax_field53                   VARCHAR2(150)
,tax_field54                   VARCHAR2(150)
,tax_field55                   VARCHAR2(150)
,tax_field56                   VARCHAR2(150)
,tax_field57                   VARCHAR2(150)
,tax_field58                   VARCHAR2(150)
,tax_field59                   VARCHAR2(150)
,tax_field60                   VARCHAR2(150)
,tax_field61                   VARCHAR2(150)
,tax_field62                   VARCHAR2(150)
,tax_field63                   VARCHAR2(150)
,tax_field64                   VARCHAR2(150)
,tax_field65                   VARCHAR2(150)
,tax_field66                   VARCHAR2(150)
,tax_field67                   VARCHAR2(150)
,tax_field68                   VARCHAR2(150)
,tax_field69                   VARCHAR2(150)
,tax_field70                   VARCHAR2(150)
,tax_field71                   VARCHAR2(150)
,tax_field72                   VARCHAR2(150)
,tax_field73                   VARCHAR2(150)
,tax_field74                   VARCHAR2(150)
,tax_field75                   VARCHAR2(150)
,tax_field76                   VARCHAR2(150)
,tax_field77                   VARCHAR2(150)
,tax_field78                   VARCHAR2(150)
,tax_field79                   VARCHAR2(150)
,tax_field80                   VARCHAR2(150)
,tax_field81                   VARCHAR2(150)
,tax_field82                   VARCHAR2(150)
,tax_field83                   VARCHAR2(150)
,tax_field84                   VARCHAR2(150)
,tax_field85                   VARCHAR2(150)
,tax_field86                   VARCHAR2(150)
,tax_field87                   VARCHAR2(150)
,tax_field88                   VARCHAR2(150)
,tax_field89                   VARCHAR2(150)
,tax_field90                   VARCHAR2(150)
,tax_field91                   VARCHAR2(150)
,tax_field92                   VARCHAR2(150)
,tax_field93                   VARCHAR2(150)
,tax_field94                   VARCHAR2(150)
,tax_field95                   VARCHAR2(150)
,tax_field96                   VARCHAR2(150)
,tax_field97                   VARCHAR2(150)
,tax_field98                   VARCHAR2(150)
,tax_field99                   VARCHAR2(150)
,tax_field100                  VARCHAR2(150)
,tax_field101                  VARCHAR2(150)
,tax_field102                  VARCHAR2(150)
,tax_field103                  VARCHAR2(150)
,tax_field104                  VARCHAR2(150)
,tax_field105                  VARCHAR2(150)
,tax_field106                  VARCHAR2(150)
,tax_field107                  VARCHAR2(150)
,tax_field108                  VARCHAR2(150)
,tax_field109                  VARCHAR2(150)
,tax_field110                  VARCHAR2(150)
,tax_field111                  VARCHAR2(150)
,tax_field112                  VARCHAR2(150)
,tax_field113                  VARCHAR2(150)
,tax_field114                  VARCHAR2(150)
,tax_field115                  VARCHAR2(150)
,tax_field116                  VARCHAR2(150)
,tax_field117                  VARCHAR2(150)
,tax_field118                  VARCHAR2(150)
,tax_field119                  VARCHAR2(150)
,tax_field120                  VARCHAR2(150)
,tax_field121                  VARCHAR2(150)
,tax_field122                  VARCHAR2(150)
,tax_field123                  VARCHAR2(150)
,tax_field124                  VARCHAR2(150)
,tax_field125                  VARCHAR2(150)
,tax_field126                  VARCHAR2(150)
,tax_field127                  VARCHAR2(150)
,tax_field128                  VARCHAR2(150)
,tax_field129                  VARCHAR2(150)
,tax_field130                  VARCHAR2(150)
,tax_field131                  VARCHAR2(150)
,tax_field132                  VARCHAR2(150)
,tax_field133                  VARCHAR2(150)
,tax_field134                  VARCHAR2(150)
,tax_field135                  VARCHAR2(150)
,tax_field136                  VARCHAR2(150)
,tax_field137                  VARCHAR2(150)
,tax_field138                  VARCHAR2(150)
,tax_field139                  VARCHAR2(150)
,tax_field140                  VARCHAR2(150)
-- Bug 3357807 Start Here
,tax_field141                  DATE
,tax_field142                  DATE
,tax_field143                  DATE
,tax_field144                  DATE
,tax_field145                  DATE
,tax_field146                  DATE
,tax_field147                  DATE
,tax_field148                  DATE
,tax_field149                  DATE
,tax_field150                  DATE
-- Bug 3357807 End Here
,tax_update_allowed            varchar2(5)
);

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
);

procedure tax_query
(p_rec                 out nocopy taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
);

end per_qh_tax_query;

 

/
