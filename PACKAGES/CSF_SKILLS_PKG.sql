--------------------------------------------------------
--  DDL for Package CSF_SKILLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_SKILLS_PKG" AUTHID CURRENT_USER AS
/* $Header: CSFPSKLS.pls 120.1 2006/03/01 01:59:01 ipananil noship $ */


  PROCEDURE load_skill_type
  ( p_skill_type_id         in number
  , p_rating_scale_id       in number
  , p_start_date_active     in date
  , p_end_date_active       in date
  , p_last_update_date      in date
  , p_seeded_flag           in varchar2
  , p_key_column            in varchar2
  , p_data_column           in varchar2
  , p_name_number_column    in varchar2
  , p_from_clause           in varchar2
  , p_where_clause          in varchar2
  , p_order_by_clause       in varchar2
  , p_object_version_number in number
  , p_attribute1            in varchar2
  , p_attribute2            in varchar2
  , p_attribute3            in varchar2
  , p_attribute4            in varchar2
  , p_attribute5            in varchar2
  , p_attribute6            in varchar2
  , p_attribute7            in varchar2
  , p_attribute8            in varchar2
  , p_attribute9            in varchar2
  , p_attribute10           in varchar2
  , p_attribute11           in varchar2
  , p_attribute12           in varchar2
  , p_attribute13           in varchar2
  , p_attribute14           in varchar2
  , p_attribute15           in varchar2
  , p_attribute_category    in varchar2
  , p_name                  in varchar2
  , p_description           in varchar2 );

  PROCEDURE create_skill_type
  ( x_rowid                 in out nocopy varchar2
  , x_skill_type_id         in out nocopy number
  , x_rating_scale_id       in number
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_seeded_flag           in varchar2 default null
  , x_key_column            in varchar2 default null
  , x_data_column           in varchar2 default null
  , x_name_number_column    in varchar2 default null
  , x_from_clause           in varchar2 default null
  , x_where_clause          in varchar2 default null
  , x_order_by_clause       in varchar2 default null
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null
  , x_name                  in varchar2
  , x_description           in varchar2 );

  PROCEDURE lock_skill_type
  ( x_skill_type_id        in number
  , x_object_version_number in number
  , x_name                  in varchar2
  , x_description           in varchar2 );

  PROCEDURE update_skill_type
  ( x_skill_type_id      in number
  , x_object_version_number in out nocopy number
  , x_rating_scale_id    in number
  , x_start_date_active  in date
  , x_end_date_active    in date
  , x_seeded_flag        in varchar2 default null
  , x_attribute1         in varchar2 default null
  , x_attribute2         in varchar2 default null
  , x_attribute3         in varchar2 default null
  , x_attribute4         in varchar2 default null
  , x_attribute5         in varchar2 default null
  , x_attribute6         in varchar2 default null
  , x_attribute7         in varchar2 default null
  , x_attribute8         in varchar2 default null
  , x_attribute9         in varchar2 default null
  , x_attribute10        in varchar2 default null
  , x_attribute11        in varchar2 default null
  , x_attribute12        in varchar2 default null
  , x_attribute13        in varchar2 default null
  , x_attribute14        in varchar2 default null
  , x_attribute15        in varchar2 default null
  , x_attribute_category in varchar2 default null
  , x_name               in varchar2
  , x_description        in varchar2 );

  PROCEDURE delete_skill_type ( x_skill_type_id in number );

  PROCEDURE add_skill_type_language;

  PROCEDURE create_skill
  ( x_rowid                 in out nocopy varchar2
  , x_skill_id              in out nocopy number
  , x_skill_type_id         in number
  , x_skill_alias           in varchar2
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_seeded_flag           in varchar2 default null
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null
  , x_name                  in varchar2
  , x_description           in varchar2 );

  PROCEDURE lock_skill
  ( x_skill_id              in number
  , x_object_version_number in number
  , x_name                  in varchar2
  , x_description           in varchar2 );

  PROCEDURE update_skill
  ( x_skill_id           in number
  , x_object_version_number in out nocopy number
  , x_skill_type_id      in number
  , x_skill_alias        in varchar2
  , x_start_date_active  in date
  , x_end_date_active    in date
  , x_attribute1         in varchar2 default null
  , x_attribute2         in varchar2 default null
  , x_attribute3         in varchar2 default null
  , x_attribute4         in varchar2 default null
  , x_attribute5         in varchar2 default null
  , x_attribute6         in varchar2 default null
  , x_attribute7         in varchar2 default null
  , x_attribute8         in varchar2 default null
  , x_attribute9         in varchar2 default null
  , x_attribute10        in varchar2 default null
  , x_attribute11        in varchar2 default null
  , x_attribute12        in varchar2 default null
  , x_attribute13        in varchar2 default null
  , x_attribute14        in varchar2 default null
  , x_attribute15        in varchar2 default null
  , x_attribute_category in varchar2 default null
  , x_name               in varchar2
  , x_description        in varchar2 );

  PROCEDURE delete_skill ( x_skill_id in number );

  PROCEDURE add_skill_language;

  PROCEDURE create_rating_scale
  ( x_rowid                 in out nocopy varchar2
  , x_rating_scale_id       in out nocopy number
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_seeded_flag           in varchar2 default null
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null
  , x_name                  in varchar2
  , x_description           in varchar2 );

  PROCEDURE lock_rating_scale
  ( x_rating_scale_id       in number
  , x_object_version_number in number
  , x_name                  in varchar2
  , x_description           in varchar2 );

  PROCEDURE update_rating_scale
  ( x_rating_scale_id    in number
  , x_object_version_number in out nocopy number
  , x_start_date_active  in date
  , x_end_date_active    in date
  , x_seeded_flag        in varchar2 default null
  , x_attribute1         in varchar2 default null
  , x_attribute2         in varchar2 default null
  , x_attribute3         in varchar2 default null
  , x_attribute4         in varchar2 default null
  , x_attribute5         in varchar2 default null
  , x_attribute6         in varchar2 default null
  , x_attribute7         in varchar2 default null
  , x_attribute8         in varchar2 default null
  , x_attribute9         in varchar2 default null
  , x_attribute10        in varchar2 default null
  , x_attribute11        in varchar2 default null
  , x_attribute12        in varchar2 default null
  , x_attribute13        in varchar2 default null
  , x_attribute14        in varchar2 default null
  , x_attribute15        in varchar2 default null
  , x_attribute_category in varchar2 default null
  , x_name               in varchar2
  , x_description        in varchar2 );

  PROCEDURE delete_rating_scale ( x_rating_scale_id in number );

  PROCEDURE add_rating_scale_language;

  PROCEDURE create_skill_level
  ( x_rowid                 in out nocopy varchar2
  , x_skill_level_id        in out nocopy number
  , x_rating_scale_id       in number
  , x_step_value            in number
  , x_correction_factor     in number
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_seeded_flag           in varchar2 default null
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null
  , x_name                  in varchar2
  , x_description           in varchar2 );

  PROCEDURE lock_skill_level
  ( x_skill_level_id        in number
  , x_object_version_number in number
  , x_name                  in varchar2
  , x_description           in varchar2 );

  PROCEDURE update_skill_level
  ( x_skill_level_id     in number
  , x_object_version_number in out nocopy number
  , x_rating_scale_id    in number
  , x_step_value         in number
  , x_correction_factor  in number
  , x_start_date_active  in date
  , x_end_date_active    in date
  , x_seeded_flag        in varchar2 default null
  , x_attribute1         in varchar2 default null
  , x_attribute2         in varchar2 default null
  , x_attribute3         in varchar2 default null
  , x_attribute4         in varchar2 default null
  , x_attribute5         in varchar2 default null
  , x_attribute6         in varchar2 default null
  , x_attribute7         in varchar2 default null
  , x_attribute8         in varchar2 default null
  , x_attribute9         in varchar2 default null
  , x_attribute10        in varchar2 default null
  , x_attribute11        in varchar2 default null
  , x_attribute12        in varchar2 default null
  , x_attribute13        in varchar2 default null
  , x_attribute14        in varchar2 default null
  , x_attribute15        in varchar2 default null
  , x_attribute_category in varchar2 default null
  , x_name               in varchar2
  , x_description        in varchar2 );

  PROCEDURE delete_skill_level ( x_skill_level_id in number );

  PROCEDURE add_skill_level_language;

  PROCEDURE create_resource_skill
  ( x_rowid                 in out nocopy varchar2
  , x_resource_skill_id     in out nocopy number
  , x_skill_type_id         in number
  , x_skill_id              in number
  , x_resource_type         in varchar2
  , x_resource_id           in number
  , x_skill_level_id        in number
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null );

  PROCEDURE lock_resource_skill
  ( x_resource_skill_id   in number
  , x_object_version_number in number );

  PROCEDURE update_resource_skill
  ( x_resource_skill_id  in number
  , x_object_version_number in out nocopy number
  , x_skill_type_id      in number
  , x_skill_id           in number
  , x_resource_type      in varchar2
  , x_resource_id        in number
  , x_skill_level_id     in number
  , x_start_date_active  in date
  , x_end_date_active    in date
  , x_attribute1         in varchar2 default null
  , x_attribute2         in varchar2 default null
  , x_attribute3         in varchar2 default null
  , x_attribute4         in varchar2 default null
  , x_attribute5         in varchar2 default null
  , x_attribute6         in varchar2 default null
  , x_attribute7         in varchar2 default null
  , x_attribute8         in varchar2 default null
  , x_attribute9         in varchar2 default null
  , x_attribute10        in varchar2 default null
  , x_attribute11        in varchar2 default null
  , x_attribute12        in varchar2 default null
  , x_attribute13        in varchar2 default null
  , x_attribute14        in varchar2 default null
  , x_attribute15        in varchar2 default null
  , x_attribute_category in varchar2 default null );

  PROCEDURE delete_resource_skill ( x_resource_skill_id in number );

  PROCEDURE create_required_skill
  ( x_rowid                 in out nocopy varchar2
  , x_required_skill_id     in out nocopy number
  , x_skill_type_id         in number
  , x_skill_id              in number
  , x_has_skill_type        in varchar2
  , x_has_skill_id          in number
  , x_skill_level_id        in number
  , x_skill_required_flag   in varchar2
  , x_level_required_flag   in varchar2
  , x_disabled_flag         in varchar2
  , x_start_date_active     in date
  , x_end_date_active       in date
  , x_object_version_number in out nocopy number
  , x_attribute1            in varchar2 default null
  , x_attribute2            in varchar2 default null
  , x_attribute3            in varchar2 default null
  , x_attribute4            in varchar2 default null
  , x_attribute5            in varchar2 default null
  , x_attribute6            in varchar2 default null
  , x_attribute7            in varchar2 default null
  , x_attribute8            in varchar2 default null
  , x_attribute9            in varchar2 default null
  , x_attribute10           in varchar2 default null
  , x_attribute11           in varchar2 default null
  , x_attribute12           in varchar2 default null
  , x_attribute13           in varchar2 default null
  , x_attribute14           in varchar2 default null
  , x_attribute15           in varchar2 default null
  , x_attribute_category    in varchar2 default null );

  PROCEDURE lock_required_skill
  ( x_required_skill_id   in number
  , x_object_version_number in number );

  PROCEDURE update_required_skill
  ( x_required_skill_id   in number
  , x_object_version_number in out nocopy number
  , x_skill_type_id       in number
  , x_skill_id            in number
  , x_has_skill_type      in varchar2
  , x_has_skill_id        in number
  , x_skill_level_id      in number
  , x_skill_required_flag in varchar2
  , x_level_required_flag in varchar2
  , x_disabled_flag       in varchar2
  , x_start_date_active   in date
  , x_end_date_active     in date
  , x_attribute1          in varchar2 default null
  , x_attribute2          in varchar2 default null
  , x_attribute3          in varchar2 default null
  , x_attribute4          in varchar2 default null
  , x_attribute5          in varchar2 default null
  , x_attribute6          in varchar2 default null
  , x_attribute7          in varchar2 default null
  , x_attribute8          in varchar2 default null
  , x_attribute9          in varchar2 default null
  , x_attribute10         in varchar2 default null
  , x_attribute11         in varchar2 default null
  , x_attribute12         in varchar2 default null
  , x_attribute13         in varchar2 default null
  , x_attribute14         in varchar2 default null
  , x_attribute15         in varchar2 default null
  , x_attribute_category  in varchar2 default null );

  PROCEDURE delete_required_skill ( x_required_skill_id in number );

--==============================================================
-- PUBLIC Procedures for translation
--==============================================================
  PROCEDURE translate_rating_scale
  ( p_rating_scale_id       in varchar2
  , p_owner                 in varchar2
  , p_name                  in varchar2
  , p_description           in varchar2) ;
  PROCEDURE translate_skill
  ( p_skill_id              in varchar2
  , p_owner                 in varchar2
  , p_name                  in varchar2
  , p_description           in varchar2) ;
  PROCEDURE translate_skill_level
  ( p_skill_level_id        in varchar2
  , p_owner                 in varchar2
  , p_name                  in varchar2
  , p_description           in varchar2) ;
  PROCEDURE translate_skill_type
  ( p_skill_type_id         in varchar2
  , p_owner                 in varchar2
  , p_name                  in varchar2
  , p_description           in varchar2) ;


END csf_skills_pkg;

 

/
