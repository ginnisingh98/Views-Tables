--------------------------------------------------------
--  DDL for Package PQH_GEN_FORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GEN_FORM" AUTHID CURRENT_USER as
/* $Header: pqgnfnf.pkh 120.0.12010000.1 2008/07/28 12:57:22 appldev ship $ */
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< PQH_GEN_FORM >---------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Created by : Sanej Nair (SCNair)
--
-- Description:
--    This handles internal Generic form support functionalities.
--
-- Access Status:
--   Internal Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
--  Version Date        Author         Comment
--  -------+-----------+--------------+----------------------------------------
--  115.1  27-Feb-2000 Sanej Nair     Initial Version
--  115.10 28-jun-2001 Sanej Nair     Added default value to match the package
--                                    body (bug 1857207)
--  115.12 27-Nov-2002 rpasapul       NOCOPY Changes.
--  ==========================================================================
g_count                 number;
g_msg                   varchar2(2000);

--
-- Define record and table
--
type v_type is record
( column_alias            varchar2(80),
  ddf_column_name         varchar2(80),
  changeable_column_name  varchar2(80));
type v_r_type is record
( vset_id         number(15),
  code            varchar2(255),
  meaning         varchar2(255));

type v_tab is table of v_type
index by binary_integer;
--
type v_t_tab is table of v_r_type
index by binary_integer;
--
-- define global PL/SQL table
--
g_attrib_tab    v_tab;
g_vset_tab      v_t_tab;
--
g_start_with            pqh_copy_entity_txns.start_with%type;
g_initial_value         pqh_copy_entity_results.information1%type;
--
g_context               pqh_copy_entity_txns.context%type;
g_gbl_context           pqh_copy_entity_txns.context%type;
g_txn_name              pqh_transaction_categories.short_name%type ;
g_txn_id                pqh_copy_entity_txns.copy_entity_txn_id%type;
--
c_information1          pqh_copy_entity_attribs.information1%type;
c_information2          pqh_copy_entity_attribs.information2%type;
c_information3          pqh_copy_entity_attribs.information3%type;
c_information4          pqh_copy_entity_attribs.information4%type;
c_information5          pqh_copy_entity_attribs.information5%type;
c_information6          pqh_copy_entity_attribs.information6%type;
c_information7          pqh_copy_entity_attribs.information7%type;
c_information8          pqh_copy_entity_attribs.information8%type;
c_information9          pqh_copy_entity_attribs.information9%type;
c_information10         pqh_copy_entity_attribs.information10%type;
c_information11         pqh_copy_entity_attribs.information11%type;
c_information12         pqh_copy_entity_attribs.information12%type;
c_information13         pqh_copy_entity_attribs.information13%type;
c_information14         pqh_copy_entity_attribs.information14%type;
c_information15         pqh_copy_entity_attribs.information15%type;
c_information16         pqh_copy_entity_attribs.information16%type;
c_information17         pqh_copy_entity_attribs.information17%type;
c_information18         pqh_copy_entity_attribs.information18%type;
c_information19         pqh_copy_entity_attribs.information19%type;
c_information20         pqh_copy_entity_attribs.information20%type;
c_information21         pqh_copy_entity_attribs.information21%type;
c_information22         pqh_copy_entity_attribs.information22%type;
c_information23         pqh_copy_entity_attribs.information23%type;
c_information24         pqh_copy_entity_attribs.information24%type;
c_information25         pqh_copy_entity_attribs.information25%type;
c_information26         pqh_copy_entity_attribs.information26%type;
c_information27         pqh_copy_entity_attribs.information27%type;
c_information28         pqh_copy_entity_attribs.information28%type;
c_information29         pqh_copy_entity_attribs.information29%type;
c_information30         pqh_copy_entity_attribs.information30%type;
--
k1_information1          pqh_copy_entity_attribs.information1%type;
k1_information2          pqh_copy_entity_attribs.information2%type;
k1_information3          pqh_copy_entity_attribs.information3%type;
k1_information4          pqh_copy_entity_attribs.information4%type;
k1_information5          pqh_copy_entity_attribs.information5%type;
k1_information6          pqh_copy_entity_attribs.information6%type;
k1_information7          pqh_copy_entity_attribs.information7%type;
k1_information8          pqh_copy_entity_attribs.information8%type;
k1_information9          pqh_copy_entity_attribs.information9%type;
k1_information10         pqh_copy_entity_attribs.information10%type;
k1_information11         pqh_copy_entity_attribs.information11%type;
k1_information12         pqh_copy_entity_attribs.information12%type;
k1_information13         pqh_copy_entity_attribs.information13%type;
k1_information14         pqh_copy_entity_attribs.information14%type;
k1_information15         pqh_copy_entity_attribs.information15%type;
k1_information16         pqh_copy_entity_attribs.information16%type;
k1_information17         pqh_copy_entity_attribs.information17%type;
k1_information18         pqh_copy_entity_attribs.information18%type;
k1_information19         pqh_copy_entity_attribs.information19%type;
k1_information20         pqh_copy_entity_attribs.information20%type;
k1_information21         pqh_copy_entity_attribs.information21%type;
k1_information22         pqh_copy_entity_attribs.information22%type;
k1_information23         pqh_copy_entity_attribs.information23%type;
k1_information24         pqh_copy_entity_attribs.information24%type;
k1_information25         pqh_copy_entity_attribs.information25%type;
k1_information26         pqh_copy_entity_attribs.information26%type;
k1_information27         pqh_copy_entity_attribs.information27%type;
k1_information28         pqh_copy_entity_attribs.information28%type;
k1_information29         pqh_copy_entity_attribs.information29%type;
k1_information30         pqh_copy_entity_attribs.information30%type;
--
k2_information1          pqh_copy_entity_attribs.information1%type;
k2_information2          pqh_copy_entity_attribs.information2%type;
k2_information3          pqh_copy_entity_attribs.information3%type;
k2_information4          pqh_copy_entity_attribs.information4%type;
k2_information5          pqh_copy_entity_attribs.information5%type;
k2_information6          pqh_copy_entity_attribs.information6%type;
k2_information7          pqh_copy_entity_attribs.information7%type;
k2_information8          pqh_copy_entity_attribs.information8%type;
k2_information9          pqh_copy_entity_attribs.information9%type;
k2_information10         pqh_copy_entity_attribs.information10%type;
k2_information11         pqh_copy_entity_attribs.information11%type;
k2_information12         pqh_copy_entity_attribs.information12%type;
k2_information13         pqh_copy_entity_attribs.information13%type;
k2_information14         pqh_copy_entity_attribs.information14%type;
k2_information15         pqh_copy_entity_attribs.information15%type;
k2_information16         pqh_copy_entity_attribs.information16%type;
k2_information17         pqh_copy_entity_attribs.information17%type;
k2_information18         pqh_copy_entity_attribs.information18%type;
k2_information19         pqh_copy_entity_attribs.information19%type;
k2_information20         pqh_copy_entity_attribs.information20%type;
k2_information21         pqh_copy_entity_attribs.information21%type;
k2_information22         pqh_copy_entity_attribs.information22%type;
k2_information23         pqh_copy_entity_attribs.information23%type;
k2_information24         pqh_copy_entity_attribs.information24%type;
k2_information25         pqh_copy_entity_attribs.information25%type;
k2_information26         pqh_copy_entity_attribs.information26%type;
k2_information27         pqh_copy_entity_attribs.information27%type;
k2_information28         pqh_copy_entity_attribs.information28%type;
k2_information29         pqh_copy_entity_attribs.information29%type;
k2_information30         pqh_copy_entity_attribs.information30%type;
--
g_information1          pqh_copy_entity_results.information1%type;
g_information2          pqh_copy_entity_results.information2%type;
g_information3          pqh_copy_entity_results.information3%type;
g_information4          pqh_copy_entity_results.information4%type;
g_information5          pqh_copy_entity_results.information5%type;
g_information6          pqh_copy_entity_results.information6%type;
g_information7          pqh_copy_entity_results.information7%type;
g_information8          pqh_copy_entity_results.information8%type;
g_information9          pqh_copy_entity_results.information9%type;
g_information10         pqh_copy_entity_results.information10%type;
g_information11         pqh_copy_entity_results.information11%type;
g_information12         pqh_copy_entity_results.information12%type;
g_information13         pqh_copy_entity_results.information13%type;
g_information14         pqh_copy_entity_results.information14%type;
g_information15         pqh_copy_entity_results.information15%type;
g_information16         pqh_copy_entity_results.information16%type;
g_information17         pqh_copy_entity_results.information17%type;
g_information18         pqh_copy_entity_results.information18%type;
g_information19         pqh_copy_entity_results.information19%type;
g_information20         pqh_copy_entity_results.information20%type;
g_information21         pqh_copy_entity_results.information21%type;
g_information22         pqh_copy_entity_results.information22%type;
g_information23         pqh_copy_entity_results.information23%type;
g_information24         pqh_copy_entity_results.information24%type;
g_information25         pqh_copy_entity_results.information25%type;
g_information26         pqh_copy_entity_results.information26%type;
g_information27         pqh_copy_entity_results.information27%type;
g_information28         pqh_copy_entity_results.information28%type;
g_information29         pqh_copy_entity_results.information29%type;
g_information30         pqh_copy_entity_results.information30%type;
g_information31         pqh_copy_entity_results.information31%type;
g_information32         pqh_copy_entity_results.information32%type;
g_information33         pqh_copy_entity_results.information33%type;
g_information34         pqh_copy_entity_results.information34%type;
g_information35         pqh_copy_entity_results.information35%type;
g_information36         pqh_copy_entity_results.information36%type;
g_information37         pqh_copy_entity_results.information37%type;
g_information38         pqh_copy_entity_results.information38%type;
g_information39         pqh_copy_entity_results.information39%type;
g_information40         pqh_copy_entity_results.information40%type;
g_information41         pqh_copy_entity_results.information41%type;
g_information42         pqh_copy_entity_results.information42%type;
g_information43         pqh_copy_entity_results.information43%type;
g_information44         pqh_copy_entity_results.information44%type;
g_information45         pqh_copy_entity_results.information46%type;
g_information46         pqh_copy_entity_results.information46%type;
g_information47         pqh_copy_entity_results.information47%type;
g_information48         pqh_copy_entity_results.information48%type;
g_information49         pqh_copy_entity_results.information49%type;
g_information50         pqh_copy_entity_results.information50%type;
g_information51         pqh_copy_entity_results.information51%type;
g_information52         pqh_copy_entity_results.information52%type;
g_information53         pqh_copy_entity_results.information53%type;
g_information54         pqh_copy_entity_results.information54%type;
g_information55         pqh_copy_entity_results.information55%type;
g_information56         pqh_copy_entity_results.information56%type;
g_information57         pqh_copy_entity_results.information57%type;
g_information58         pqh_copy_entity_results.information58%type;
g_information59         pqh_copy_entity_results.information59%type;
g_information60         pqh_copy_entity_results.information60%type;
g_information61         pqh_copy_entity_results.information61%type;
g_information62         pqh_copy_entity_results.information62%type;
g_information63         pqh_copy_entity_results.information63%type;
g_information64         pqh_copy_entity_results.information64%type;
g_information65         pqh_copy_entity_results.information65%type;
g_information66         pqh_copy_entity_results.information66%type;
g_information67         pqh_copy_entity_results.information67%type;
g_information68         pqh_copy_entity_results.information68%type;
g_information69         pqh_copy_entity_results.information69%type;
g_information70         pqh_copy_entity_results.information70%type;
g_information71         pqh_copy_entity_results.information71%type;
g_information72         pqh_copy_entity_results.information72%type;
g_information73         pqh_copy_entity_results.information73%type;
g_information74         pqh_copy_entity_results.information74%type;
g_information75         pqh_copy_entity_results.information75%type;
g_information76         pqh_copy_entity_results.information76%type;
g_information77         pqh_copy_entity_results.information77%type;
g_information78         pqh_copy_entity_results.information78%type;
g_information79         pqh_copy_entity_results.information79%type;
g_information80         pqh_copy_entity_results.information80%type;
g_information81         pqh_copy_entity_results.information81%type;
g_information82         pqh_copy_entity_results.information82%type;
g_information83         pqh_copy_entity_results.information83%type;
g_information84         pqh_copy_entity_results.information84%type;
g_information85         pqh_copy_entity_results.information85%type;
g_information86         pqh_copy_entity_results.information86%type;
g_information87         pqh_copy_entity_results.information87%type;
g_information88         pqh_copy_entity_results.information88%type;
g_information89         pqh_copy_entity_results.information89%type;
g_information90         pqh_copy_entity_results.information90%type;
g_information91         pqh_copy_entity_results.information91%type;
g_information92         pqh_copy_entity_results.information92%type;
g_information93         pqh_copy_entity_results.information93%type;
g_information94         pqh_copy_entity_results.information94%type;
g_information95         pqh_copy_entity_results.information95%type;
g_information96         pqh_copy_entity_results.information96%type;
g_information97         pqh_copy_entity_results.information97%type;
g_information98         pqh_copy_entity_results.information98%type;
g_information99         pqh_copy_entity_results.information99%type;
g_information100        pqh_copy_entity_results.information100%type;
g_information101        pqh_copy_entity_results.information101%type;
g_information102        pqh_copy_entity_results.information102%type;
g_information103        pqh_copy_entity_results.information103%type;
g_information104        pqh_copy_entity_results.information104%type;
g_information105        pqh_copy_entity_results.information105%type;
g_information106        pqh_copy_entity_results.information106%type;
g_information107        pqh_copy_entity_results.information107%type;
g_information108        pqh_copy_entity_results.information108%type;
g_information109        pqh_copy_entity_results.information109%type;
g_information110        pqh_copy_entity_results.information110%type;
g_information111        pqh_copy_entity_results.information111%type;
g_information112        pqh_copy_entity_results.information112%type;
g_information113        pqh_copy_entity_results.information113%type;
g_information114        pqh_copy_entity_results.information114%type;
g_information115        pqh_copy_entity_results.information115%type;
g_information116        pqh_copy_entity_results.information116%type;
g_information117        pqh_copy_entity_results.information117%type;
g_information118        pqh_copy_entity_results.information118%type;
g_information119        pqh_copy_entity_results.information119%type;
g_information120        pqh_copy_entity_results.information120%type;
g_information121        pqh_copy_entity_results.information121%type;
g_information122        pqh_copy_entity_results.information122%type;
g_information123        pqh_copy_entity_results.information123%type;
g_information124        pqh_copy_entity_results.information124%type;
g_information125        pqh_copy_entity_results.information125%type;
g_information126        pqh_copy_entity_results.information126%type;
g_information127        pqh_copy_entity_results.information127%type;
g_information128        pqh_copy_entity_results.information128%type;
g_information129        pqh_copy_entity_results.information129%type;
g_information130        pqh_copy_entity_results.information130%type;
g_information131        pqh_copy_entity_results.information131%type;
g_information132        pqh_copy_entity_results.information132%type;
g_information133        pqh_copy_entity_results.information133%type;
g_information134        pqh_copy_entity_results.information134%type;
g_information135        pqh_copy_entity_results.information135%type;
g_information136        pqh_copy_entity_results.information136%type;
g_information137        pqh_copy_entity_results.information137%type;
g_information138        pqh_copy_entity_results.information138%type;
g_information139        pqh_copy_entity_results.information139%type;
g_information140        pqh_copy_entity_results.information140%type;
g_information141        pqh_copy_entity_results.information141%type;
g_information142        pqh_copy_entity_results.information142%type;
g_information143        pqh_copy_entity_results.information143%type;
g_information144        pqh_copy_entity_results.information144%type;
g_information145        pqh_copy_entity_results.information145%type;
g_information146        pqh_copy_entity_results.information146%type;
g_information147        pqh_copy_entity_results.information147%type;
g_information148        pqh_copy_entity_results.information148%type;
g_information149        pqh_copy_entity_results.information149%type;
g_information150        pqh_copy_entity_results.information150%type;
g_information151        pqh_copy_entity_results.information151%type;
g_information152        pqh_copy_entity_results.information152%type;
g_information153        pqh_copy_entity_results.information153%type;
g_information154        pqh_copy_entity_results.information154%type;
g_information155        pqh_copy_entity_results.information155%type;
g_information156        pqh_copy_entity_results.information156%type;
g_information157        pqh_copy_entity_results.information157%type;
g_information158        pqh_copy_entity_results.information158%type;
g_information159        pqh_copy_entity_results.information159%type;
g_information160        pqh_copy_entity_results.information160%type;
g_information161        pqh_copy_entity_results.information161%type;
g_information162        pqh_copy_entity_results.information162%type;
g_information163        pqh_copy_entity_results.information163%type;
g_information164        pqh_copy_entity_results.information164%type;
g_information165        pqh_copy_entity_results.information165%type;
g_information166        pqh_copy_entity_results.information166%type;
g_information167        pqh_copy_entity_results.information167%type;
g_information168        pqh_copy_entity_results.information168%type;
g_information169        pqh_copy_entity_results.information169%type;
g_information170        pqh_copy_entity_results.information170%type;
g_information171        pqh_copy_entity_results.information171%type;
g_information172        pqh_copy_entity_results.information172%type;
g_information173        pqh_copy_entity_results.information173%type;
g_information174        pqh_copy_entity_results.information174%type;
g_information175        pqh_copy_entity_results.information175%type;
g_information176        pqh_copy_entity_results.information176%type;
g_information177        pqh_copy_entity_results.information177%type;
g_information178        pqh_copy_entity_results.information178%type;
g_information179        pqh_copy_entity_results.information179%type;
g_information180        pqh_copy_entity_results.information180%type;

g_v_id                  varchar2(2000);
g_v_value               varchar2(2000);
--
-- Procedure to retrive number of records likey to be retrived / create source records
--
procedure create_source ( p_copy_entity_txn_id     number
                        , p_delimiter              varchar2
                        , p_copies                 number default 1
                        , p_msg                out nocopy varchar2);
--
procedure count_source ( p_copy_entity_txn_id     number
                        , p_delimiter             varchar2
                        , p_count              out nocopy number
                        , p_msg                out nocopy varchar2);
--
procedure recount_source ( p_copy_entity_txn_id     number
                          , p_delimiter             varchar2
                          , p_count              out nocopy number
                          , p_msg                out nocopy varchar2);
--
procedure update_source (p_copy_entity_result_id          number
                         , p_count                        number
                         , p_object_version_number in out nocopy number );
--
Procedure create_target ( p_copy_entity_txn_id  number
                        , p_ld1                 varchar2               --delimiter1
                        , p_lf1                 varchar2 default null  --flex_code1
                        , p_ln1                 varchar2 default null  --flex numb1
                        , p_ld2                 varchar2 default null  --delimiter2
                        , p_lf2                 varchar2 default null  --flex_code2
                        , p_ln2                 varchar2 default null  --flex numb1
                        , p_batch_status    out nocopy varchar2 ) ;
--
function get_sql_from_vset_id(p_vset_id            in number,
                              p_add_where_clause   in varchar2 default null,
                              p_where_on_id        in boolean  default false ) return varchar2;
--
function get_value_from_id(p_id      in varchar2,
                           p_vset_id in varchar2) return varchar2 ;
--
function get_id_from_value(p_value   in varchar2,
                           p_vset_id in varchar2) return varchar2 ;
--
function populate_prefs(p_copy_entity_txn_id       in number
                       , p_transaction_category_id in number ) return boolean;
--
function get_legislation_code (p_business_group_id in varchar2) return varchar2;
--
function get_alr(p_application_id          in  number
                ,p_responsibility_id       in  number
                ,p_business_group_id       in  varchar2
                ,p_transaction_short_name  in  varchar2
                ,p_application_short_name  out nocopy varchar2
                ,p_legislation_code        out nocopy varchar2
                ,p_responsibility_key      out nocopy varchar2
                ,p_gbl_context             out nocopy varchar2 ) return varchar2 ;
--
procedure populate_context(p_copy_entity_txn_id in number);
--
procedure chk_transaction_category (p_short_name              in out nocopy varchar2,
                                    p_transaction_category_id in out nocopy varchar2,
                                    p_transaction_id          in     varchar2,
                                    p_member_cd                  out nocopy varchar2,
                                    p_name                       out nocopy varchar2);
--
function get_transaction_type (p_transaction_category_id in number
                              , p_context                in varchar2) return varchar2;
--
function my_con return varchar2;
--
function get_look (p_code in varchar2) return varchar2;
--
function  kf(p_string    in varchar2 ,
             p_delimiter in varchar2 ) return varchar2;
--
procedure delete_source (p_validate                in boolean
				    , p_copy_entity_result_id  in number
				    , p_object_version_number  in number
				    , p_effective_date         in date);
--
procedure flip_selection (p_mode                  in varchar2,
					 p_copy_entity_txn_id    in number  ,
					 p_copy_entity_result_id in number   default null ,
					 p_block                 in varchar2 default 'SOURCE',
					 p_select_value          in varchar2  ) ;
--
function check_id_flex_struct ( p_id_flex_code in varchar2,
						  p_id_flex_num  in number ) return boolean ;
--
function context_bg return varchar2;
--
procedure set_txn_id (p_txn_id in number);
--
procedure set_dt (p_dt_mode in varchar2, p_dt_desc in varchar2);
--
function check_valueset_type (p_valueset_id in varchar2) return varchar2 ;
--
function get_segment(p_col in varchar2) return varchar2;
--
END PQH_GEN_FORM;

/
