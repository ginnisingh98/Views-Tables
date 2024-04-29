--------------------------------------------------------
--  DDL for Package HR_ORD_INS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORD_INS" AUTHID CURRENT_USER as
/* $Header: hrordrhi.pkh 120.0 2005/05/31 01:49:22 appldev noship $ */
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the record interface for the insert process
--   for the specified entity. The role of this process is to insert a fully
--   validated row, into the HR schema passing back to  the calling process,
--   any system generated values (e.g. primary and object version number
--   attributes). This process is the main backbone of the ins
--   process. The processing of this procedure is as follows:
--   1) The controlling validation process insert_validate is executed
--      which will execute all private and public validation business rule
--      processes.
--   2) The pre_insert business process is then executed which enables any
--      logic to be processed before the insert dml process is executed.
--   3) The insert_dml process will physical perform the insert dml into the
--      specified entity.
--   4) The post_insert business process is then executed which enables any
--      logic to be processed after the insert dml process.
--
-- Prerequisites:
--   The main parameters to the this process have to be in the record
--   format.
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted into the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in date
  ,p_rec                          in out nocopy hr_ord_shd.g_rec_type
  );
--
-- ----------------------------------------------------------------------------
-- |---------------------------------< ins >----------------------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   This procedure is the attribute interface for the insert
--   process for the specified entity and is the outermost layer. The role
--   of this process is to insert a fully validated row into the HR schema
--   passing back to the calling process, any system generated values
--   (e.g. object version number attributes).The processing of this
--   procedure is as follows:
--   1) The attributes are converted into a local record structure by
--      calling the convert_args function.
--   2) After the conversion has taken place, the corresponding record ins
--      interface process is executed.
--   3) OUT parameters are then set to their corresponding record attributes.
--
-- Prerequisites:
--
-- In Parameters:
--
-- Post Success:
--   A fully validated row will be inserted for the specified entity
--   without being committed.
--
-- Post Failure:
--   If an error has occurred, an error message will be raised.
--
-- Developer Implementation Notes:
--   None.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
-- ----------------------------------------------------------------------------
Procedure ins
  (p_effective_date               in     date
  ,p_parent_organization_id         in     number
  ,p_child_organization_id          in     number
  ,p_business_group_id              in     number
  ,p_org_link_type                  in     varchar2
  ,p_org_link_information_categor   in     varchar2 default null
  ,p_org_link_information1          in     varchar2 default null
  ,p_org_link_information2          in     varchar2 default null
  ,p_org_link_information3          in     varchar2 default null
  ,p_org_link_information4          in     varchar2 default null
  ,p_org_link_information5          in     varchar2 default null
  ,p_org_link_information6          in     varchar2 default null
  ,p_org_link_information7          in     varchar2 default null
  ,p_org_link_information8          in     varchar2 default null
  ,p_org_link_information9          in     varchar2 default null
  ,p_org_link_information10         in     varchar2 default null
  ,p_org_link_information11         in     varchar2 default null
  ,p_org_link_information12         in     varchar2 default null
  ,p_org_link_information13         in     varchar2 default null
  ,p_org_link_information14         in     varchar2 default null
  ,p_org_link_information15         in     varchar2 default null
  ,p_org_link_information16         in     varchar2 default null
  ,p_org_link_information17         in     varchar2 default null
  ,p_org_link_information18         in     varchar2 default null
  ,p_org_link_information19         in     varchar2 default null
  ,p_org_link_information20         in     varchar2 default null
  ,p_org_link_information21         in     varchar2 default null
  ,p_org_link_information22         in     varchar2 default null
  ,p_org_link_information23         in     varchar2 default null
  ,p_org_link_information24         in     varchar2 default null
  ,p_org_link_information25         in     varchar2 default null
  ,p_org_link_information26         in     varchar2 default null
  ,p_org_link_information27         in     varchar2 default null
  ,p_org_link_information28         in     varchar2 default null
  ,p_org_link_information29         in     varchar2 default null
  ,p_org_link_information30         in     varchar2 default null
  ,p_attribute_category             in     varchar2 default null
  ,p_attribute1                     in     varchar2 default null
  ,p_attribute2                     in     varchar2 default null
  ,p_attribute3                     in     varchar2 default null
  ,p_attribute4                     in     varchar2 default null
  ,p_attribute5                     in     varchar2 default null
  ,p_attribute6                     in     varchar2 default null
  ,p_attribute7                     in     varchar2 default null
  ,p_attribute8                     in     varchar2 default null
  ,p_attribute9                     in     varchar2 default null
  ,p_attribute10                    in     varchar2 default null
  ,p_attribute11                    in     varchar2 default null
  ,p_attribute12                    in     varchar2 default null
  ,p_attribute13                    in     varchar2 default null
  ,p_attribute14                    in     varchar2 default null
  ,p_attribute15                    in     varchar2 default null
  ,p_attribute16                    in     varchar2 default null
  ,p_attribute17                    in     varchar2 default null
  ,p_attribute18                    in     varchar2 default null
  ,p_attribute19                    in     varchar2 default null
  ,p_attribute20                    in     varchar2 default null
  ,p_attribute21                    in     varchar2 default null
  ,p_attribute22                    in     varchar2 default null
  ,p_attribute23                    in     varchar2 default null
  ,p_attribute24                    in     varchar2 default null
  ,p_attribute25                    in     varchar2 default null
  ,p_attribute26                    in     varchar2 default null
  ,p_attribute27                    in     varchar2 default null
  ,p_attribute28                    in     varchar2 default null
  ,p_attribute29                    in     varchar2 default null
  ,p_attribute30                    in     varchar2 default null
  ,p_organization_link_id              out nocopy number
  ,p_object_version_number             out nocopy number
  );
--
end hr_ord_ins;

 

/
