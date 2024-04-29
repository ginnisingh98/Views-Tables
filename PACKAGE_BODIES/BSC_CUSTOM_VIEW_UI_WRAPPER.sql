--------------------------------------------------------
--  DDL for Package Body BSC_CUSTOM_VIEW_UI_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_CUSTOM_VIEW_UI_WRAPPER" AS
 /* $Header: BSCCVDPB.pls 120.13 2007/03/15 10:42:34 ashankar ship $ */

PROCEDURE add_or_update_kpi_trend(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_kpi_id            IN NUMBER
 ,p_function_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
);


FUNCTION Is_More
( p_list_ids    IN  OUT NOCOPY  VARCHAR2
 ,p_id          OUT NOCOPY  VARCHAR2
) RETURN BOOLEAN
IS
    l_pos_ids               NUMBER;
    l_pos_rel_types         NUMBER;
    l_pos_rel_columns       NUMBER;
BEGIN
    IF (p_list_ids IS NOT NULL) THEN
        l_pos_ids           := INSTR(p_list_ids, ',');
        IF (l_pos_ids > 0) THEN
            p_id            :=  TRIM(SUBSTR(p_list_ids, 1, l_pos_ids - 1));
            p_list_ids      :=  TRIM(SUBSTR(p_list_ids, l_pos_ids + 1));
        ELSE
            p_id            :=  TRIM(p_list_ids);
            p_list_ids      :=  NULL;
        END IF;
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END Is_More;

--Compact all label ids in BSC_TAB_VIEW_LABELS_TL and BSC_TAB_VIEW_LABELS_B to be in consecutive order
PROCEDURE compact_custom_view_labels(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
 l_count              NUMBER;

 CURSOR LABEL_CUR IS
   SELECT label_id
   FROM BSC_TAB_VIEW_LABELS_B
   WHERE tab_id = p_tab_id
   AND tab_view_id = p_tab_view_id
   ORDER BY label_id;
 l_label_cur   LABEL_CUR%ROWTYPE;

BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_count := 0;

  FOR l_label_cur IN LABEL_CUR LOOP
    UPDATE BSC_TAB_VIEW_LABELS_B
    SET label_id = l_count
    WHERE tab_id = p_tab_id
    AND tab_view_id = p_tab_view_id
    AND label_id = l_label_cur.label_id;

    UPDATE BSC_TAB_VIEW_LABELS_TL
    SET label_id = l_count
    WHERE tab_id = p_tab_id
    AND tab_view_id = p_tab_view_id
    AND label_id = l_label_cur.label_id;

    l_count := l_count + 1;
  END LOOP;

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END compact_custom_view_labels;

-- Clear BSC_TAB_VIEW_LABELS_TL, BSC_TAB_VIEW_LABELS_B and BSC_TAB_VIEW_KPI_TL with given tab_id and tab_view_id
PROCEDURE clear_custom_view_canvas(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  DELETE FROM BSC_TAB_VIEW_LABELS_TL
  WHERE TAB_ID = p_tab_id
  AND TAB_VIEW_ID = p_tab_view_id;

  DELETE FROM BSC_TAB_VIEW_LABELS_B
  WHERE TAB_ID = p_tab_id
  AND TAB_VIEW_ID = p_tab_view_id;

  DELETE FROM BSC_TAB_VIEW_KPI_TL
  WHERE TAB_ID = p_tab_id
  AND TAB_VIEW_ID = p_tab_view_id;

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END clear_custom_view_canvas;

--Remove all items specified in removedKPIs and removedLabels
--Format of removedKPIs and removedLabels are id1,id2,id3,...,idN
PROCEDURE remove_custom_view_items(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_kpis              IN VARCHAR2
 ,p_labels            IN VARCHAR2
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
 TYPE index_table_type IS TABLE OF NUMBER INDEX BY binary_integer;
 l_kpis_table     index_table_type;
 l_lables_table   index_table_type;
 l_id             NUMBER;
 l_kpis           VARCHAR2(5000);
 l_labels         VARCHAR2(5000);

 CURSOR kpi_cur IS
   SELECT indicator
   FROM bsc_tab_view_kpi_vl
   WHERE tab_id = p_tab_id
   AND tab_view_id = p_tab_view_id;
 l_kpi_cur  kpi_cur%ROWTYPE;

 CURSOR label_cur IS
   SELECT label_id
   FROM bsc_tab_view_labels_vl
   WHERE tab_id = p_tab_id
   AND tab_view_id = p_tab_view_id;
 l_label_cur  label_cur%ROWTYPE;

BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --convert string of IDs to table lookup
  l_kpis := p_kpis;
  WHILE (Is_More(p_list_ids => l_kpis, p_id => l_id))
  LOOP
    l_kpis_table(l_id) := 1;
  END LOOP;

  l_labels := p_labels;
  WHILE (Is_More(p_list_ids => l_labels, p_id => l_id))
  LOOP
    l_lables_table(l_id) := 1;
  END LOOP;

  --loop for all existing KPIs and remove all those that are not in the l_kpis
  FOR l_kpi_cur IN kpi_cur
  LOOP
    IF (l_kpis_table.exists(l_kpi_cur.indicator) = FALSE) THEN
      BSC_TAB_VIEW_KPI_PKG.DELETE_ROW (
        X_TAB_ID => p_tab_id,
        X_TAB_VIEW_ID => p_tab_view_id,
        X_INDICATOR => l_kpi_cur.indicator
      );
    END IF;
  END LOOP;

  --loop for all existing labels and remove all those that are not in the l_labels
  FOR l_label_cur IN label_cur
  LOOP
    IF (l_lables_table.exists(l_label_cur.label_id) = FALSE) THEN
      BSC_TAB_VIEW_LABELS_PKG.DELETE_ROW (
        X_TAB_ID => p_tab_id,
        X_TAB_VIEW_ID => p_tab_view_id,
        X_LABEL_ID => l_label_cur.label_id
      );
    END IF;
  END LOOP;

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END remove_custom_view_items;

-- Add specified label to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_kpi_actual(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_kpi_id            IN NUMBER
 ,p_function_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_object_id
   ,p_object_type => c_type_kpi_actual
   ,p_label_text => p_label_text
   ,p_text_flag => p_text_flag
   ,p_font_color => p_font_color
   ,p_font_size => p_font_size
   ,p_font_style => p_font_style
   ,p_left => p_left
   ,p_top => p_top
   ,p_width => p_width
   ,p_height => p_height
   ,p_note_text => NULL
   ,p_link_id => p_kpi_id
   ,p_function_id => p_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END add_or_update_kpi_actual;

-- Add specified label to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_kpi_change(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_kpi_id            IN NUMBER
 ,p_function_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_object_id
   ,p_object_type => c_type_kpi_change
   ,p_label_text => p_label_text
   ,p_text_flag => p_text_flag
   ,p_font_color => p_font_color
   ,p_font_size => p_font_size
   ,p_font_style => p_font_style
   ,p_left => p_left
   ,p_top => p_top
   ,p_width => p_width
   ,p_height => p_height
   ,p_note_text => NULL
   ,p_link_id => p_kpi_id
   ,p_function_id => p_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END add_or_update_kpi_change;

-- Add specified label to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_kpi_label(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_kpi_id            IN NUMBER
 ,p_function_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_object_id
   ,p_object_type => c_type_kpi
   ,p_label_text => p_label_text
   ,p_text_flag => p_text_flag
   ,p_font_color => p_font_color
   ,p_font_size => p_font_size
   ,p_font_style => p_font_style
   ,p_left => p_left
   ,p_top => p_top
   ,p_width => p_width
   ,p_height => p_height
   ,p_note_text => NULL
   ,p_link_id => p_kpi_id
   ,p_function_id => p_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END add_or_update_kpi_label;

-- insert to the following tables:
-- BSC_TAB_VIEW_KPI_TL (1 row for kpi)
-- BSC_TAB_VIEW_LABELS_B (1 row for kpi, 1 row for actual, 1 row for change)
-- BSC_TAB_VIEW_LABELS_TL (1 row for kpi, 1 row for actual, 1 row for change)
PROCEDURE add_or_update_kpi(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_kpi_id            IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_hotspot_left      IN NUMBER
 ,p_hotspot_top       IN NUMBER
 ,p_hotspot_width     IN NUMBER
 ,p_hotspot_height    IN NUMBER
 ,p_alarm_left        IN NUMBER
 ,p_alarm_top         IN NUMBER
 ,p_alarm_width       IN NUMBER
 ,p_alarm_height      IN NUMBER
 ,p_actual_object_id  IN NUMBER
 ,p_actual_flag       IN NUMBER
 ,p_actual_left       IN NUMBER
 ,p_actual_top        IN NUMBER
 ,p_actual_width      IN NUMBER
 ,p_actual_height     IN NUMBER
 ,p_change_object_id  IN NUMBER
 ,p_change_flag       IN NUMBER
 ,p_change_left       IN NUMBER
 ,p_change_top        IN NUMBER
 ,p_change_width      IN NUMBER
 ,p_change_height     IN NUMBER
 ,p_link_function_id  IN NUMBER
 ,p_trend_object_id   IN NUMBER
 ,p_trend_flag        IN NUMBER
 ,p_trend_left        IN NUMBER
 ,p_trend_top         IN NUMBER
 ,p_trend_width       IN NUMBER
 ,p_trend_height      IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Add specified entry for objectives to BSC_TAB_VIEW_LABELS_PKG
  -- position and color info is stored in BSC_TAB_VIEW_KPI_TL entries
  add_or_update_kpi_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_object_id
   ,p_text_flag => p_text_flag
   ,p_label_text => c_kpi
   ,p_font_size => p_font_size
   ,p_font_color => p_font_color
   ,p_font_style => p_font_style
   ,p_left => p_hotspot_left
   ,p_top => p_hotspot_top
   ,p_width => p_hotspot_width
   ,p_height => p_hotspot_height
   ,p_kpi_id => p_kpi_id
   ,p_function_id => p_link_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

  -- Add specified kpi to BSC_TAB_VIEW_KPI_TL
  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_kpi(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_kpi_id => p_kpi_id
   ,p_text_flag => p_text_flag
   ,p_font_size => p_font_size
   ,p_font_style => p_font_style
   ,p_font_color => p_font_color
   ,p_hotspot_left => p_hotspot_left
   ,p_hotspot_top => p_hotspot_top
   ,p_hotspot_width => p_hotspot_width
   ,p_hotspot_height => p_hotspot_height
   ,p_alarm_left => p_alarm_left
   ,p_alarm_top => p_alarm_top
   ,p_alarm_width => p_alarm_width
   ,p_alarm_height => p_alarm_height
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

  -- Add specified entry for actual to BSC_TAB_VIEW_LABELS_PKG
  add_or_update_kpi_actual(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_actual_object_id
   ,p_text_flag => p_actual_flag
   ,p_label_text => c_kpi_actual
   ,p_font_size => p_font_size
   ,p_font_color => p_font_color
   ,p_font_style => p_font_style
   ,p_left => p_actual_left
   ,p_top => p_actual_top
   ,p_width => p_actual_width
   ,p_height => p_actual_height
   ,p_kpi_id => p_kpi_id
   ,p_function_id => p_link_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

  -- Add specified entry for change to BSC_TAB_VIEW_LABELS_PKG
  add_or_update_kpi_change(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_change_object_id
   ,p_text_flag => p_change_flag
   ,p_label_text => c_kpi_change
   ,p_font_size => p_font_size
   ,p_font_color => p_font_color
   ,p_font_style => p_font_style
   ,p_left => p_change_left
   ,p_top => p_change_top
   ,p_width => p_change_width
   ,p_height => p_change_height
   ,p_kpi_id => p_kpi_id
   ,p_function_id=> p_link_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

 -- Add Specified entry for trend to BSC_TAB_VIEW_LABELS_PKG

 add_or_update_kpi_trend(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_trend_object_id
   ,p_text_flag => p_trend_flag
   ,p_label_text => c_kpi_trend
   ,p_font_size => p_font_size
   ,p_font_color => p_font_color
   ,p_font_style => p_font_style
   ,p_left => p_trend_left
   ,p_top => p_trend_top
   ,p_width => p_trend_width
   ,p_height => p_trend_height
   ,p_kpi_id => p_kpi_id
   ,p_function_id=> p_link_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );


EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END add_or_update_kpi;


-- Add specified label to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_label(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_object_id
   ,p_object_type => c_type_label
   ,p_label_text => p_label_text
   ,p_text_flag => 1
   ,p_font_color => p_font_color
   ,p_font_size => p_font_size
   ,p_font_style => p_font_style
   ,p_left => p_left
   ,p_top => p_top
   ,p_width => p_width
   ,p_height => p_height
   ,p_note_text => NULL
   ,p_link_id => NULL
   ,p_function_id => NULL
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END add_or_update_label;

-- Add specified hotspot to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_hotspot(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_object_id
   ,p_object_type => c_type_hotspot
   ,p_label_text => p_label_text
   ,p_text_flag => 0
   ,p_font_color => 1
   ,p_font_size => 1
   ,p_font_style => 1
   ,p_left => p_left
   ,p_top => p_top
   ,p_width => p_width
   ,p_height => p_height
   ,p_note_text => NULL
   ,p_link_id => NULL
   ,p_function_id => NULL
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END add_or_update_hotspot;

-- Add specified custom view link to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_custom_view_link(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_link_tab_view_id  IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_object_id
   ,p_object_type => c_type_link
   ,p_label_text => p_label_text
   ,p_text_flag => p_text_flag
   ,p_font_color => p_font_color
   ,p_font_size => p_font_size
   ,p_font_style => p_font_style
   ,p_left => p_left
   ,p_top => p_top
   ,p_width => p_width
   ,p_height => p_height
   ,p_note_text => NULL
   ,p_link_id => p_link_tab_view_id
   ,p_function_id => NULL
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;
END add_or_update_custom_view_link;

-- Add specified launchpad to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_launch_pad(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_note_text         IN VARCHAR2
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_menu_id           IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_object_id
   ,p_object_type => c_type_launch_pad
   ,p_label_text => p_label_text
   ,p_text_flag => 0
   ,p_font_color => -16777216
   ,p_font_size => 1
   ,p_font_style => 0
   ,p_left => p_left
   ,p_top => p_top
   ,p_width => p_width
   ,p_height => p_height
   ,p_note_text => p_note_text
   ,p_link_id => p_menu_id
   ,p_function_id => NULL
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END add_or_update_launch_pad;

-- Add specified measure (existing kpi) to BSC_TAB_VIEW_LABELS_PKG
PROCEDURE add_or_update_measure(
  p_tab_id             IN NUMBER
 ,p_tab_view_id        IN NUMBER
 ,p_text_object_id     IN NUMBER
 ,p_text_flag          IN NUMBER
 ,p_font_size          IN NUMBER
 ,p_font_style         IN NUMBER
 ,p_font_color         IN NUMBER
 ,p_text_left          IN NUMBER
 ,p_text_top           IN NUMBER
 ,p_text_width         IN NUMBER
 ,p_text_height        IN NUMBER
 ,p_slider_object_id   IN NUMBER
 ,p_slider_flag        IN NUMBER
 ,p_slider_left        IN NUMBER
 ,p_slider_top         IN NUMBER
 ,p_slider_width       IN NUMBER
 ,p_slider_height      IN NUMBER
 ,p_actual_object_id   IN NUMBER
 ,p_actual_flag        IN NUMBER
 ,p_actual_left        IN NUMBER
 ,p_actual_top         IN NUMBER
 ,p_actual_width       IN NUMBER
 ,p_actual_height      IN NUMBER
 ,p_change_object_id   IN NUMBER
 ,p_change_flag        IN NUMBER
 ,p_change_left        IN NUMBER
 ,p_change_top         IN NUMBER
 ,p_change_width       IN NUMBER
 ,p_change_height      IN NUMBER
 ,p_indicator_id       IN NUMBER
 ,p_function_id        IN NUMBER
 ,x_return_status      OUT NOCOPY VARCHAR2
 ,x_msg_count          OUT NOCOPY NUMBER
 ,x_msg_data           OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --add name/hotspot
  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_text_object_id
   ,p_object_type => c_type_measure
   ,p_label_text => c_measure
   ,p_text_flag => p_text_flag
   ,p_font_color => p_font_color
   ,p_font_size => p_font_size
   ,p_font_style => p_font_style
   ,p_left => p_text_left
   ,p_top => p_text_top
   ,p_width => p_text_width
   ,p_height => p_text_height
   ,p_note_text => NULL
   ,p_link_id => p_indicator_id
   ,p_function_id => p_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

  --add actual
  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_actual_object_id
   ,p_object_type => c_type_measure_actual
   ,p_label_text => c_measure_actual
   ,p_text_flag => p_actual_flag
   ,p_font_color => p_font_color
   ,p_font_size => p_font_size
   ,p_font_style => p_font_style
   ,p_left => p_actual_left
   ,p_top => p_actual_top
   ,p_width => p_actual_width
   ,p_height => p_actual_height
   ,p_note_text => NULL
   ,p_link_id => p_indicator_id
   ,p_function_id => p_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

  --add change
  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_change_object_id
   ,p_object_type => c_type_measure_change
   ,p_label_text => c_measure_change
   ,p_text_flag => p_change_flag
   ,p_font_color => p_font_color
   ,p_font_size => p_font_size
   ,p_font_style => p_font_style
   ,p_left => p_change_left
   ,p_top => p_change_top
   ,p_width => p_change_width
   ,p_height => p_change_height
   ,p_note_text => NULL
   ,p_link_id => p_indicator_id
   ,p_function_id => p_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

  --add slider
  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_slider_object_id
   ,p_object_type => c_type_measure_slider
   ,p_label_text => c_measure_slider
   ,p_text_flag => p_slider_flag
   ,p_font_color => p_font_color
   ,p_font_size => p_font_size
   ,p_font_style => p_font_style
   ,p_left => p_slider_left
   ,p_top => p_slider_top
   ,p_width => p_slider_width
   ,p_height => p_slider_height
   ,p_note_text => NULL
   ,p_link_id => p_indicator_id
   ,p_function_id => p_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END add_or_update_measure;

-- Wrapper for calling BSC_TAB_VIEW_LABELS_PKG procedures
PROCEDURE add_or_update_tab_view_label(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_object_type       IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_text_flag         IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_note_text         IN VARCHAR2
 ,p_link_id           IN NUMBER
 ,p_function_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
 l_str                VARCHAR2(100);
 l_count              NUMBER;
 l_object_id          BSC_TAB_VIEW_LABELS_B.LABEL_ID%TYPE;
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT count(1) INTO l_count
  FROM bsc_tab_view_labels_vl
  WHERE tab_id = p_tab_id
  AND tab_view_id = p_tab_view_id
  AND label_id = p_object_id;

  IF (l_count = 0) THEN
    --create

    --find the next label_id
    SELECT max(label_id)+1 INTO l_object_id
    FROM bsc_tab_view_labels_vl
    WHERE tab_id = p_tab_id
    AND tab_view_id = p_tab_view_id;

    IF (l_object_id IS NULL) THEN
      l_object_id := 0;
    END IF;

  BSC_TAB_VIEW_LABELS_PKG.INSERT_ROW (
    X_ROWID => l_str,
    X_TAB_ID => p_tab_id,
    X_TAB_VIEW_ID => p_tab_view_id,
      X_LABEL_ID => l_object_id,
      X_LABEL_TYPE => p_object_type,
      X_LINK_ID => p_link_id,
      X_NAME => p_label_text,
      X_NOTE => p_note_text,
      X_TEXT_FLAG => p_text_flag,
      X_LEFT_POSITION => p_left,
      X_TOP_POSITION => p_top,
      X_WIDTH => p_width,
      X_HEIGHT => p_height,
      X_FONT_SIZE => p_font_size,
      X_FONT_STYLE => p_font_style,
      X_FONT_COLOR => p_font_color,
      X_URL => null,
      X_FUNCTION_ID => p_function_id,
      X_CREATION_DATE => SYSDATE,
      X_CREATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_DATE => SYSDATE,
      X_LAST_UPDATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN => fnd_global.login_id
    );
  ELSE
    --update
    BSC_TAB_VIEW_LABELS_PKG.UPDATE_ROW (
      X_TAB_ID => p_tab_id,
      X_TAB_VIEW_ID => p_tab_view_id,
    X_LABEL_ID => p_object_id,
    X_LABEL_TYPE => p_object_type,
    X_LINK_ID => p_link_id,
    X_NAME => p_label_text,
    X_NOTE => p_note_text,
    X_TEXT_FLAG => p_text_flag,
    X_LEFT_POSITION => p_left,
    X_TOP_POSITION => p_top,
    X_WIDTH => p_width,
    X_HEIGHT => p_height,
    X_FONT_SIZE => p_font_size,
    X_FONT_STYLE => p_font_style,
    X_FONT_COLOR => p_font_color,
    X_URL => null,
    X_FUNCTION_ID => p_function_id,
    X_CREATION_DATE => SYSDATE,
    X_CREATED_BY => fnd_global.user_id,
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => fnd_global.user_id,
    X_LAST_UPDATE_LOGIN => fnd_global.login_id
  );
  END IF;

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data := SQLERRM;
END add_or_update_tab_view_label;

-- Wrappers for calling BSC_TAB_VIEW_KPI_PKG
PROCEDURE add_or_update_tab_view_kpi(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_kpi_id            IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_hotspot_left      IN NUMBER
 ,p_hotspot_top       IN NUMBER
 ,p_hotspot_width     IN NUMBER
 ,p_hotspot_height    IN NUMBER
 ,p_alarm_left        IN NUMBER
 ,p_alarm_top         IN NUMBER
 ,p_alarm_width       IN NUMBER
 ,p_alarm_height      IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
  l_count             NUMBER;
  l_str               VARCHAR2(100);
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT count(1) INTO l_count
  FROM BSC_TAB_VIEW_KPI_VL
  WHERE TAB_ID = p_tab_id
  AND TAB_VIEW_ID = p_tab_view_id
  AND INDICATOR = p_kpi_id;

  IF (l_count = 0) THEN
    --create
  BSC_TAB_VIEW_KPI_PKG.INSERT_ROW (
    X_ROWID => l_str,
    X_TAB_ID => p_tab_id,
    X_TAB_VIEW_ID => p_tab_view_id,
    X_INDICATOR => p_kpi_id,
    X_TEXT_FLAG => p_text_flag,
    X_LEFT_POSITION => p_hotspot_left,
    X_TOP_POSITION => p_hotspot_top,
    X_WIDTH => p_hotspot_width,
    X_HEIGHT => p_hotspot_height,
    X_FONT_SIZE => p_font_size,
    X_FONT_STYLE => p_font_style,
    X_FONT_COLOR => p_font_color,
    X_COLOR_LEFT_POSITION => p_alarm_left,
    X_COLOR_TOP_POSITION => p_alarm_top,
    X_COLOR_WIDTH => p_alarm_width,
    X_COLOR_HEIGHT => p_alarm_height,
    X_COLOR_SIZE => 0,
    X_CREATION_DATE => SYSDATE,
    X_CREATED_BY => fnd_global.user_id,
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => fnd_global.user_id,
    X_LAST_UPDATE_LOGIN => fnd_global.login_id
  );
  ELSE
    --update
    BSC_TAB_VIEW_KPI_PKG.UPDATE_ROW(
      X_TAB_ID => p_tab_id,
      X_TAB_VIEW_ID => p_tab_view_id,
      X_INDICATOR => p_kpi_id,
      X_TEXT_FLAG => p_text_flag,
      X_LEFT_POSITION => p_hotspot_left,
      X_TOP_POSITION => p_hotspot_top,
      X_WIDTH => p_hotspot_width,
      X_HEIGHT => p_hotspot_height,
      X_FONT_SIZE => p_font_size,
      X_FONT_STYLE => p_font_style,
      X_FONT_COLOR => p_font_color,
      X_COLOR_LEFT_POSITION => p_alarm_left,
      X_COLOR_TOP_POSITION => p_alarm_top,
      X_COLOR_WIDTH => p_alarm_width,
      X_COLOR_HEIGHT => p_alarm_height,
      X_COLOR_SIZE => 0,
      X_CREATION_DATE => SYSDATE,
      X_CREATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_DATE => SYSDATE,
      X_LAST_UPDATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN => fnd_global.login_id
    );
  END IF;

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END add_or_update_tab_view_kpi;

--Create a new image for the specified p_tab_id and p_tab_view_id
PROCEDURE create_tab_view_bg (
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_file_name         IN VARCHAR2
 ,p_description       IN VARCHAR2
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_mime_type         IN VARCHAR2
 ,x_image_id          OUT NOCOPY NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
 l_next_image_id      NUMBER;
 l_str                VARCHAR2(100);
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT BSC_SYS_IMAGE_ID_S.NEXTVAL INTO l_next_image_id FROM dual;
  x_image_id := l_next_image_id;

  BEGIN
    BSC_SYS_IMAGES_PKG.INSERT_ROW (
      X_IMAGE_ID => l_next_image_id,
      X_FILE_NAME => p_file_name,
      X_DESCRIPTION => p_description,
      X_WIDTH => p_width,
      X_HEIGHT => p_height,
      X_MIME_TYPE => p_mime_type,
      X_CREATED_BY => fnd_global.user_id,
      X_LAST_UPDATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN => fnd_global.login_id
    );

  EXCEPTION
    WHEN others THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := 'Insertion to BSC_SYS_IMAGES_PKG failed' || SQLERRM;
      RAISE;
  END;

  BSC_SYS_IMAGES_MAP_PKG.INSERT_ROW (
    X_ROWID => l_str,
    X_SOURCE_TYPE => 1,
    X_SOURCE_CODE => p_tab_id,
    X_TYPE => p_tab_view_id,
    X_IMAGE_ID => l_next_image_id,
    X_CREATION_DATE => SYSDATE,
    X_CREATED_BY => fnd_global.user_id,
    X_LAST_UPDATE_DATE => SYSDATE,
    X_LAST_UPDATED_BY => fnd_global.user_id,
    X_LAST_UPDATE_LOGIN => fnd_global.login_id
  );
EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
    RAISE;
END create_tab_view_bg;


-- Create or udpate tab view's background in BSC_SYS_IMAGES and BSC_SYS_IMAGES_MAP_PKG
PROCEDURE add_or_update_tab_view_bg (
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_image_id          IN NUMBER
 ,p_file_name         IN VARCHAR2
 ,p_description       IN VARCHAR2
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_mime_type         IN VARCHAR2
 ,x_image_id          OUT NOCOPY NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
 l_count              NUMBER;
 l_next_image_id      NUMBER;
 l_str                VARCHAR2(100);
 l_temp               VARCHAR2(100);
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT count(1) INTO l_count
  FROM BSC_SYS_IMAGES bsi, BSC_SYS_IMAGES_MAP_VL bsim
  WHERE bsim.source_code = p_tab_id
  AND bsim.type = p_tab_view_id
  AND bsim.image_id = p_image_id
  AND bsim.image_id = bsi.image_id;

  if (l_count > 0)
  THEN
    --check if the image is owned by current NLS session
    SELECT count(1) INTO l_count
    FROM BSC_SYS_IMAGES_MAP_TL
    WHERE source_code = p_tab_id
    AND type = p_tab_view_id
    AND image_id = p_image_id
    AND source_lang = userenv('LANG');

    IF (l_count > 0) THEN
      --image owned by this NLS session, just simply update the same image
    x_image_id := p_image_id;

    BEGIN
      UPDATE  BSC_SYS_IMAGES
      SET     FILE_NAME              =   p_file_name,
              DESCRIPTION            =   p_description,
              WIDTH                  =   p_width,
              HEIGHT                 =   p_height,
              MIME_TYPE              =   p_mime_type,
              LAST_UPDATE_DATE       =   SYSDATE,
              LAST_UPDATED_BY        =   fnd_global.user_id,
              LAST_UPDATE_LOGIN      =   fnd_global.login_id,
              FILE_BODY              =   EMPTY_BLOB()
      WHERE   IMAGE_ID               =   p_image_id
      AND     LAST_UPDATE_DATE      <=   SYSDATE;
    EXCEPTION
      WHEN others THEN
        ROLLBACK TO RollBackPt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := 'Update to BSC_SYS_IMAGES failed' || SQLERRM;
        RETURN;
    END;

    BSC_SYS_IMAGES_MAP_PKG.UPDATE_ROW (
      X_SOURCE_TYPE => 1,
      X_SOURCE_CODE => p_tab_id,
      X_TYPE => p_tab_view_id,
      X_IMAGE_ID => p_image_id,
      X_CREATION_DATE => SYSDATE,
      X_CREATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_DATE => SYSDATE,
      X_LAST_UPDATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN => fnd_global.login_id
    );

  ELSE
      --image not owned by this NLS session, need to create a new image and update the image map
    SELECT BSC_SYS_IMAGE_ID_S.NEXTVAL INTO l_next_image_id FROM dual;
    x_image_id := l_next_image_id;

    BEGIN
      BSC_SYS_IMAGES_PKG.INSERT_ROW (
        X_IMAGE_ID => l_next_image_id,
        X_FILE_NAME => p_file_name,
        X_DESCRIPTION => p_description,
        X_WIDTH => p_width,
        X_HEIGHT => p_height,
        X_MIME_TYPE => p_mime_type,
        X_CREATED_BY => fnd_global.user_id,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.login_id
      );

    EXCEPTION
      WHEN others THEN
        ROLLBACK TO RollBackPt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := 'Insertion to BSC_SYS_IMAGES_PKG failed' || SQLERRM;
        RETURN;
    END;

      BSC_SYS_IMAGES_MAP_PKG.UPDATE_ROW (
      X_SOURCE_TYPE => 1,
      X_SOURCE_CODE => p_tab_id,
      X_TYPE => p_tab_view_id,
      X_IMAGE_ID => l_next_image_id,
      X_CREATION_DATE => SYSDATE,
      X_CREATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_DATE => SYSDATE,
      X_LAST_UPDATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN => fnd_global.login_id
    );
    END IF;

  ELSE
    --create a new image for this custom view
    create_tab_view_bg (
      p_tab_id            => p_tab_id
     ,p_tab_view_id       => p_tab_view_id
     ,p_file_name         => p_file_name
     ,p_description       => p_description
     ,p_width             => p_width
     ,p_height            => p_height
     ,p_mime_type         => p_mime_type
     ,x_image_id          => x_image_id
     ,x_return_status     => x_return_status
     ,x_msg_count         => x_msg_count
     ,x_msg_data          => x_msg_data
    );
  END IF;

EXCEPTION
  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END add_or_update_tab_view_bg;

-- Create or update tab view properties in BSC_TAB_VIEWS_PKG
PROCEDURE add_or_update_tab_view (
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_name              IN VARCHAR2
 ,p_func_area_short_name IN VARCHAR2
 ,p_internal_name     IN VARCHAR2
 ,p_description       IN VARCHAR2
 ,p_enable_flag       IN NUMBER
 ,p_create_form_func  IN VARCHAR2
 ,p_last_update_date  IN VARCHAR2
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
 l_count              NUMBER;
 l_str                VARCHAR2(100);
 l_flag               NUMBER;
 l_function_id        NUMBER;
 l_enabled_flag       BSC_TAB_VIEWS_B.enabled_flag%TYPE;
BEGIN
  SAVEPOINT RollBackPt;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_flag := 0;

  IF (is_tab_view_exist(p_tab_id, p_tab_view_id) = 'Y')
  THEN
    /********************************************
     Because tab_view id already exists then first get
     the enbaled flag for this custom view.
    /*******************************************/
    SELECT NVL(ENABLED_FLAG,1)
    INTO  l_enabled_flag
    FROM  BSC_TAB_VIEWS_VL
    WHERE tab_id = p_tab_id
    AND   tab_view_id = p_tab_view_id;


    BSC_TAB_VIEWS_PKG.UPDATE_ROW(
      X_TAB_ID => p_tab_id,
      X_TAB_VIEW_ID => p_tab_view_id,
      X_ENABLED_FLAG => l_enabled_flag,
      X_NAME => p_name,
      X_HELP => p_description,
      X_LAST_UPDATE_DATE => SYSDATE,
      X_LAST_UPDATED_BY => fnd_global.user_id,
      X_LAST_UPDATE_LOGIN => fnd_global.login_id
    );
  ELSE
    BEGIN
      BSC_TAB_VIEWS_PKG.INSERT_ROW(
        X_ROWID => l_str,
        X_TAB_ID => p_tab_id,
        X_TAB_VIEW_ID => p_tab_view_id,
        X_ENABLED_FLAG => p_enable_flag,
        X_NAME => p_name,
        X_HELP => p_description,
        X_CREATION_DATE => SYSDATE,
        X_CREATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_DATE => SYSDATE,
        X_LAST_UPDATED_BY => fnd_global.user_id,
        X_LAST_UPDATE_LOGIN => fnd_global.login_id
      );

    EXCEPTION
      WHEN others THEN
        ROLLBACK TO RollBackPt;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := 'Insertion to BSC_TAB_VIEWS_PKG failed' || SQLERRM;
        RETURN;
    END;

    UPDATE  BSC_TABS_B
    SET     LAST_UPDATE_DATE        =   SYSDATE,
            LAST_UPDATED_BY         =   fnd_global.user_id,
            LAST_UPDATE_LOGIN       =   fnd_global.login_id
    WHERE   TAB_ID                  =   p_tab_id;
  END IF;

  -- Enh 3934298, for each new custom view will create/update a form function to use in DBI
  /*****************************************************************
    For custom view simulation Enhancement,following are the requirements.
    1.Making CVD an Independent Entity,so that it can be called from Report Designer also.
    2.When called from Report Designer we don't need to create the form function
      p_create_form_Func is added to check if we need to create the form fucntion or not.
      If (p_create_form_Func = FND_API.G_FALSE)Then we will not create the form function
      and when it is set to  FND_API.G_TRUE then we will create the form fucntion
  /*****************************************************************/
  IF (p_create_form_func = FND_API.G_TRUE) THEN
    -- Enh 3934298, for each new custom view will create/update a form function to use in DBI
    BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_function
      (p_tab_id => p_tab_id,
       p_tab_view_id => p_tab_view_id,
       p_name => p_name,
       p_internal_name => p_internal_name,
       p_description => p_description,
       x_function_id => l_function_id,
       x_return_status => x_return_status ,
       x_msg_count => x_msg_count,
       x_msg_data => x_msg_data
      );

    IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
      --DBMS_OUTPUT.PUT_LINE('BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view Failed: at BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_function');
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Maps Functional area short name.
    IF (p_Func_Area_Short_Name IS NOT NULL) THEN
      BIS_OBJECT_EXTENSIONS_PUB.Object_Funct_Area_Map
        (p_Api_Version => 1.0,
         p_Commit => FND_API.G_FALSE,
         p_Obj_Type => BSC_UTILITY.BSC_CUSTOM_VIEW,
         p_Obj_Name => p_internal_name,
         p_App_Id => BSC_UTILITY.BSC_APP_ID,
         p_Func_Area_Sht_Name =>p_func_area_short_name,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
        );

      IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    if (l_flag = 1)
    THEN
     x_msg_data := 'INVALID_TIMESTAMP';
    ELSE
     x_msg_data :=  SQLERRM;
    END IF;

  WHEN others THEN
    ROLLBACK TO RollBackPt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;

END add_or_update_tab_view;

-- Create or update tab view properties in BSC_TAB_VIEWS_PKG
-- Called from UI for the extra original Name
PROCEDURE add_or_update_tab_view (
  p_tab_id                IN NUMBER
 ,p_tab_view_id           IN NUMBER
 ,p_name                  IN VARCHAR2
 ,p_func_area_short_name  IN VARCHAR2
 ,p_internal_name         IN VARCHAR2
 ,p_description           IN VARCHAR2
 ,p_enable_flag           IN NUMBER
 ,p_is_default_int_name   IN VARCHAR2
 ,p_create_form_func      IN VARCHAR2
 ,p_last_update_date      IN VARCHAR2
 ,x_return_status         OUT NOCOPY VARCHAR2
 ,x_msg_count             OUT NOCOPY NUMBER
 ,x_msg_data              OUT NOCOPY VARCHAR2
) IS
l_count         NUMBER;
l_internal_name FND_FORM_FUNCTIONS_VL.FUNCTION_NAME%TYPE;
BEGIN

  l_internal_name := p_internal_name;
  -- for the new view check if the internal name already exists
  IF (is_tab_view_exist(p_tab_id, p_tab_view_id) = 'N') THEN
    SELECT COUNT(0)
    INTO l_count
    FROM FND_FORM_FUNCTIONS_VL
    WHERE FUNCTION_NAME = p_internal_name;

    IF (l_count <> 0) THEN
      -- If the user has not changed the default internal name then insert the next available
      IF (p_is_default_int_name = FND_API.G_TRUE) THEN
        l_internal_name := 'BSC_PORTLET_CUSTOM_VIEW_'||p_tab_id||'_'||next_custom_view_id(p_tab_id);
      ELSE
        -- If the user has changed the internal name and it already exists then will show warning
        x_msg_data := BSC_UTILITY.INVALID_CUST_VIEW_NAME;
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    END IF;
  END IF;
  add_or_update_tab_view (
  p_tab_id          => p_tab_id
 ,p_tab_view_id     => p_tab_view_id
 ,p_name            => p_name
 ,p_func_area_short_name => p_func_area_short_name
 ,p_internal_name   => l_internal_name
 ,p_description     => p_description
 ,p_enable_flag     => p_enable_flag
 ,p_create_form_func => p_create_form_func
 ,p_last_update_date => p_last_update_date
 ,x_return_status   => x_return_status
 ,x_msg_count       => x_msg_count
 ,x_msg_data        => x_msg_data
);

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN others THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END add_or_update_tab_view;

-- Check if the given tab view exists, return 'Y' if it exists, 'N' otherwise
FUNCTION is_tab_view_exist (
  p_tab_id             IN NUMBER
 ,p_tab_view_id        IN NUMBER
) RETURN VARCHAR2 IS
  l_count              NUMBER;
BEGIN

  SELECT count(tab_id) INTO l_count
  FROM bsc_tab_views_vl
  WHERE tab_id = p_tab_id AND tab_view_id = p_tab_view_id;

  IF (l_count > 0)
  THEN
   RETURN 'Y';
  ELSE
   RETURN 'N';
  END IF;

END is_tab_view_exist;

-- Compare given tab view timestamp with that in DB. Return 0 if it is the
-- same, 1 otherwise.
FUNCTION compare_tab_view_timestamp  (
  p_tab_id             IN NUMBER
 ,p_tab_view_id        IN NUMBER
 ,p_last_update_date   IN VARCHAR2
) RETURN NUMBER IS
  l_last_update_date   VARCHAR2(100);
BEGIN

  SELECT to_char(last_update_date,'YY/MM/DD-HH24:MM:SS') into l_last_update_date
  FROM bsc_tab_views_vl
  WHERE tab_id = p_tab_id AND tab_view_id = p_tab_view_id;

  IF (p_last_update_date <> l_last_update_date)
  THEN
   RETURN 1;
  ELSE
   RETURN 0;
  END IF;

END compare_tab_view_timestamp;

FUNCTION get_function_name_string  (
  p_tab_id             IN NUMBER
 ,p_tab_view_id        IN NUMBER
) RETURN VARCHAR2 IS

  x_function_name      VARCHAR(30);

BEGIN
     x_function_name := 'BSC_PORTLET_CUSTOM_VIEW_' || p_tab_id || '_' || p_tab_view_id;
     return x_function_name;

end get_function_name_string;

FUNCTION get_function_params_string  (
  p_tab_id             IN NUMBER
 ,p_tab_view_id        IN NUMBER
) RETURN VARCHAR2 IS

  x_parameters      VARCHAR(2000);

BEGIN
     x_parameters := 'pRequestType=C&pTabId=' || p_tab_id || '&pViewId=' || p_tab_view_id;
     return x_parameters;

end get_function_params_string;

-- Returns the Parameter String
FUNCTION get_param_search_string  (
  p_tab_id             IN NUMBER
 ,p_tab_view_id        IN NUMBER
) RETURN VARCHAR2 IS

  x_parameters      VARCHAR(2000);

BEGIN
     x_parameters := '%pTabId=' || p_tab_id || '&pViewId=' || p_tab_view_id||'%';
     return x_parameters;

end get_param_search_string;

procedure add_or_update_function (
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_name              IN VARCHAR2
 ,p_internal_name     IN VARCHAR2 := NULL
 ,p_description       IN VARCHAR2
 ,x_function_id       OUT NOCOPY NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) is

l_rowid               VARCHAR2(30);
l_new_function_id     NUMBER;
l_parameters          VARCHAR2(2000);
l_function_name       VARCHAR2(30);
l_count               NUMBER;

begin

    l_parameters := get_function_params_string(p_tab_id,p_tab_view_id);

    -- assign default function name if internal name is null
    IF (p_internal_name IS NULL) THEN
      l_function_name := get_function_name_string(p_tab_id, p_tab_view_id);
    ELSE
      l_function_name := p_internal_name;
    END IF;

    select count(FUNCTION_ID) into l_count
    from FND_FORM_FUNCTIONS
    where FUNCTION_NAME = l_function_name;

    -- check if function has already been created
    IF (l_count =0) THEN
        select FND_FORM_FUNCTIONS_S.NEXTVAL into l_new_function_id from dual;

        FND_FORM_FUNCTIONS_PKG.INSERT_ROW(
            X_ROWID                  => l_ROWID,
            X_FUNCTION_ID            => l_new_function_id,
            X_WEB_HOST_NAME          => null,
            X_WEB_AGENT_NAME         => null,
            X_WEB_HTML_CALL          => C_FUNC_WEB_HTML_CALL,
            X_WEB_ENCRYPT_PARAMETERS => 'N',
            X_WEB_SECURED            => 'N',
            X_WEB_ICON               => null,
            X_OBJECT_ID              => null,
            X_REGION_APPLICATION_ID  => C_FUNC_REGION_APPLICATION_ID,
            X_REGION_CODE            => C_FUNC_REGION_CODE,
            X_FUNCTION_NAME          => l_function_name,
            X_APPLICATION_ID         => null,
            X_FORM_ID                => null,
            X_PARAMETERS             => l_parameters,
            X_TYPE                   => C_FUNC_TYPE,
            X_USER_FUNCTION_NAME     => p_name,
            X_DESCRIPTION            => p_description,
            X_CREATION_DATE          => sysdate,
            X_CREATED_BY             => fnd_global.user_id,
            X_LAST_UPDATE_DATE       => sysdate,
            X_LAST_UPDATED_BY        => fnd_global.user_id,
            X_LAST_UPDATE_LOGIN      => fnd_global.user_id,
            X_MAINTENANCE_MODE_SUPPORT => NULL,
            X_CONTEXT_DEPENDENCE       => NULL);

        if l_ROWID is not null then
            x_function_id := l_new_function_id;
        end if;
     ELSE
        select FUNCTION_ID into x_function_id from FND_FORM_FUNCTIONS where FUNCTION_NAME = l_function_name;

        FND_FORM_FUNCTIONS_PKG.UPDATE_ROW
        (
           X_FUNCTION_ID            => x_function_id
          ,X_WEB_HOST_NAME          => NULL
          ,X_WEB_AGENT_NAME         => NULL
          ,X_WEB_HTML_CALL          => C_FUNC_WEB_HTML_CALL
          ,X_WEB_ENCRYPT_PARAMETERS => 'N'
          ,X_WEB_SECURED            => 'N'
          ,X_WEB_ICON               => NULL
          ,X_OBJECT_ID              => NULL
          ,X_REGION_APPLICATION_ID  => C_FUNC_REGION_APPLICATION_ID
          ,X_REGION_CODE            => C_FUNC_REGION_CODE
          ,X_FUNCTION_NAME          => l_function_name
          ,X_APPLICATION_ID         => NULL
          ,X_FORM_ID                => NULL
          ,X_PARAMETERS             => l_parameters
          ,X_TYPE                   => C_FUNC_TYPE
          ,X_USER_FUNCTION_NAME     => p_name
          ,X_DESCRIPTION            => p_description
          ,X_LAST_UPDATE_DATE       => SYSDATE
          ,X_LAST_UPDATED_BY        => FND_GLOBAL.USER_ID
          ,X_LAST_UPDATE_LOGIN      => FND_GLOBAL.LOGIN_ID
        );
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BSC_CUSTOM_VIEW_UI_WRAPPER.create_function' || SQLERRM;
    end if;

end add_or_update_function;

procedure delete_function (
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) is

 l_function_id          NUMBER;
 l_param_search_string  FND_FORM_FUNCTIONS_VL.PARAMETERS%TYPE;
 l_object_name          FND_FORM_FUNCTIONS_VL.FUNCTION_NAME%TYPE;
 l_count                NUMBER;

 CURSOR c_verify_function IS
 SELECT FUNCTION_ID, FUNCTION_NAME
 FROM   FND_FORM_FUNCTIONS
 WHERE  PARAMETERS LIKE l_param_search_string;

BEGIN
    fnd_msg_pub.initialize;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Constracts the PARAMETER to find out FUNCTION_NAME
    l_param_search_string := get_param_search_string(p_tab_id,p_tab_view_id);

    FOR cd IN c_verify_function LOOP
      l_function_id := cd.function_id;
      l_object_name := cd.function_name;

      FND_FORM_FUNCTIONS_PKG.DELETE_ROW(l_function_id);
        -- Checks if the functional_area alredy exists.
      SELECT COUNT(0)
      INTO   l_count
      FROM   bis_form_function_extension_vl
      WHERE  object_name= l_object_name;

      IF(l_count > 0) THEN
        BIS_OBJECT_EXTENSIONS_PUB.Object_Funct_Area_Map( p_Api_Version => 1.0,
                               p_Commit => FND_API.G_FALSE,
                               p_Obj_Type => BSC_UTILITY.BSC_CUSTOM_VIEW,
                               p_Obj_Name => l_object_name,
                               p_App_Id => BSC_UTILITY.BSC_APP_ID,
                               p_Func_Area_Sht_Name =>NULL,
                               x_return_status => x_return_status,
                               x_msg_count => x_msg_count,
                               x_msg_data => x_msg_data);

        IF (x_return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;
    END LOOP;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BSC_CUSTOM_VIEW_UI_WRAPPER.delete_function: no Row Found: ' || SQLERRM;
    end if;

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
        x_msg_data := 'BSC_CUSTOM_VIEW_UI_WRAPPER.delete_function' || SQLERRM;
    end if;

end delete_function;

-- Returns the next_custom_view_id
FUNCTION next_custom_view_id (
  p_tab_id             IN NUMBER
 ) RETURN NUMBER IS
l_view_id    BSC_TAB_VIEWS_VL.tab_view_id%TYPE;
l_internal_name FND_FORM_FUNCTIONS_VL.function_name%TYPE;

BEGIN
  SELECT NVL(MAX(tab_view_id),1)
  INTO   l_view_id
  FROM   BSC_TAB_VIEWS_B
  WHERE tab_id =  p_tab_id;

  RETURN l_view_id;
END next_custom_view_id;

/**********************************************************
 Name   : Get_Or_CreateNew_Scorecard
 Description    : This API Checks if the scorecard was created for the report or not.
                  If not then it it will create a new scorecard and return the tab_id
 Input Parameters : p_report_sht_name  --> Report short name
                    p_resp_Id          --> Reposibility
                    x_tab_Id           --> tab id of the scorecard.

 Created By     : ashankar
/*********************************************************/

PROCEDURE Get_Or_CreateNew_Scorecard
(
    p_report_sht_name   IN          VARCHAR
 ,  p_resp_Id           IN          NUMBER
 ,  p_time_stamp        IN          VARCHAR2
 ,  p_Application_Id    IN          NUMBER
 ,  x_time_stamp        OUT NOCOPY  VARCHAR2
 ,  x_tab_Id            OUT NOCOPY  NUMBER
 ,  x_return_status     OUT NOCOPY  VARCHAR2
 ,  x_msg_count         OUT NOCOPY  NUMBER
 ,  x_msg_data          OUT NOCOPY  VARCHAR2
)IS
    l_count         NUMBER;
    l_tabId         BSC_TABS_B.tab_Id%TYPE;
    l_tab_name      BSC_TABS_VL.name%TYPE;
    l_Time_Stamp    DATE;
    l_last_update_date DATE;
    -- Date Format used in Report Designer.
    l_last_upd_format  VARCHAR2(25):= 'YYYY/MM/DD-HH24:MI:SS';
BEGIN
    FND_MSG_PUB.INITIALIZE;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_time_stamp IS NOT NULL) THEN
        SELECT LAST_UPDATE_DATE
        INTO l_last_update_date
        FROM AK_REGIONS
        WHERE REGION_CODE = p_report_sht_name
        AND REGION_APPLICATION_ID = p_Application_Id;

        IF(p_time_stamp <> TO_CHAR(l_last_update_date, l_last_upd_format)) THEN
            FND_MSG_PUB.Initialize;
            FND_MESSAGE.SET_NAME('BSC', 'BSC_INVALID_RPT_TIMESTAMP');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_data := 'BSC_INVALID_RPT_TIMESTAMP';
            RAISE FND_API.G_EXC_ERROR;
        END IF;
    END IF;

    l_Time_Stamp := SYSDATE;
    --DBMS_OUTPUT.PUT_LINE('latest timestamp = ' || TO_CHAR(l_Time_Stamp, l_last_upd_format));

    UPDATE AK_REGIONS A
    SET    A.LAST_UPDATE_DATE = l_Time_Stamp
    WHERE  A.REGION_CODE = p_report_sht_name
    AND REGION_APPLICATION_ID = p_Application_Id;


    SELECT COUNT(0)
    INTO   l_count
    FROM   BSC_TABS_B
    WHERE  SHORT_NAME = p_report_sht_name;

    IF(l_count=0)THEN

        SELECT Name
        INTO   l_tab_name
        FROM   AK_REGIONS_VL
        WHERE  REGION_CODE = p_report_sht_name;

        l_tab_name := BSC_BIS_CUSTOM_KPI_UTIL_PUB.Get_Unqiue_Tab_Name(l_tab_name);
        BSC_PMF_UI_WRAPPER.Create_Tab
        (
                p_Commit            => FND_API.G_FALSE
              , p_Responsibility_Id => p_resp_Id
              , p_Parent_Tab_Id     => NULL
              , p_Owner_Id          => NULL
              , p_Short_Name        => p_report_sht_name
              , x_Tab_Id            => l_tabId
              , x_Return_Status     => x_return_status
              , x_Msg_Count         => x_msg_count
              , x_Msg_Data          => x_msg_data
              , p_Tab_Name          => l_tab_name
              , p_Tab_Help          => NULL
              , p_Tab_Info          => NULL
         );
         IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
           RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
    ELSE
        SELECT  tab_Id
        INTO    l_tabId
        FROM    BSC_TABS_B
        WHERE   SHORT_NAME = p_report_sht_name;
    END IF;

    x_tab_Id := l_tabId;
    x_time_stamp := TO_CHAR(l_Time_Stamp, l_last_upd_format);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
           FND_MSG_PUB.Count_And_Get
           (      p_encoded   =>  FND_API.G_FALSE
              ,   p_count     =>  x_msg_count
              ,   p_data      =>  x_msg_data
           );
           --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_ERROR '||x_msg_data);
           x_return_status :=  FND_API.G_RET_STS_ERROR;
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
           FND_MSG_PUB.Count_And_Get
           (      p_encoded   =>  FND_API.G_FALSE
              ,   p_count     =>  x_msg_count
              ,   p_data      =>  x_msg_data
           );
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           --DBMS_OUTPUT.PUT_LINE('EXCEPTION FND_API.G_EXC_UNEXPECTED_ERROR '||x_msg_data);
       WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF (x_msg_data IS NOT NULL) THEN
               x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_UI_WRAPPER.Get_Or_CreateNew_Scorecard ';
           ELSE
               x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_UI_WRAPPER.Get_Or_CreateNew_Scorecard ';
           END IF;
           --DBMS_OUTPUT.PUT_LINE('EXCEPTION NO_DATA_FOUND '||x_msg_data);
       WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           IF (x_msg_data IS NOT NULL) THEN
               x_msg_data      :=  x_msg_data||' -> BSC_CUSTOM_VIEW_UI_WRAPPER.Get_Or_CreateNew_Scorecard ';
           ELSE
               x_msg_data      :=  SQLERRM||' at BSC_CUSTOM_VIEW_UI_WRAPPER.Get_Or_CreateNew_Scorecard ';
           END IF;
           --DBMS_OUTPUT.PUT_LINE('EXCEPTION OTHERS '||x_msg_data);
END Get_Or_CreateNew_Scorecard;

/*************************************************************
Name    : Get_Measure_Display_Name
Description : This API is used to get the measure display name
Input       : p_region_code   --> Region code
              p_dataset_id    --> dataset id
Output      : x_meas_disp_name --> measure display name
Created By  : ashankar 09-JUN-2005
/************************************************************/

PROCEDURE  Get_Measure_Display_Name
(
    p_region_code       IN          VARCHAR
   ,p_dataset_id        IN          NUMBER
   ,x_meas_disp_name    OUT NOCOPY  VARCHAR
) IS
 l_display_name    AK_REGION_ITEMS_VL.attribute_label_long%TYPE;
 l_measure_type    BIS_INDICATORS_VL.MEASURE_TYPE%TYPE;
 l_source          BSC_SYS_DATASETS_B.SOURCE%TYPE;
 l_item_type       AK_REGION_ITEMS_VL.ATTRIBUTE1%TYPE;
BEGIN
    Get_Measure_Prop(p_region_code, p_dataset_id, l_display_name, l_measure_type, l_source, l_item_type);
    x_meas_disp_name := l_display_name;

END Get_Measure_Display_Name;

/*************************************************************
Name    : Get_Measure_Prop
Description : This API is used to get the measure properties.
If p_region_code is null, it retrieves information from bis_display_measures_v.
Input       : p_region_code   --> Region code
              p_dataset_id    --> dataset id
Output      : x_meas_disp_name --> measure display name
            : x_measure_type   --> measure type in bis_indicators_vl
            : x_source        --> data source in bsc_sys_datasets_b
            : x_item_type     --> attribute1 in ak_region_items
Created By  : sawu 30-JUN-2005
Modified By : ashankar 07-JUL-05 Filtering Weighted KPIs
/************************************************************/

PROCEDURE  Get_Measure_Prop
(
    p_region_code       IN          VARCHAR
   ,p_dataset_id        IN          NUMBER
   ,x_meas_disp_name    OUT NOCOPY  AK_REGION_ITEMS_VL.ATTRIBUTE_LABEL_LONG%TYPE
   ,x_measure_type      OUT NOCOPY  BIS_INDICATORS_VL.MEASURE_TYPE%TYPE
   ,x_source            OUT NOCOPY  BSC_SYS_DATASETS_B.SOURCE%TYPE
   ,x_item_type         OUT NOCOPY  AK_REGION_ITEMS_VL.ATTRIBUTE1%TYPE
) IS
  l_display_name    AK_REGION_ITEMS_VL.attribute_label_long%TYPE;

  CURSOR measure_cur IS
    SELECT DISTINCT NVL(V.ATTRIBUTE_LABEL_LONG,B.NAME) NAME,
           B.MEASURE_TYPE,
           D.SOURCE,
           v.attribute1 ITEM_TYPE
    FROM   BIS_INDICATORS_VL B,
           BSC_SYS_DATASETS_B D,
           AK_REGION_ITEMS_VL V,
           AK_REGIONS C
    WHERE C.REGION_CODE = V.REGION_CODE
    AND   V.ATTRIBUTE_CATEGORY ='BIS PM Viewer'
    AND   V.ATTRIBUTE1 LIKE '%MEASURE%'
    AND   V.ATTRIBUTE1 NOT IN ('COMPARE_TO_MEASURE_NO_TARGET','CHANGE_MEASURE_NO_TARGET')
    AND   NVL(B.MEASURE_TYPE,D.SOURCE) <>'CDS_SCORE'
    AND   V.ATTRIBUTE2 = B.SHORT_NAME
    AND   B.DATASET_ID = D.DATASET_ID
    AND   B.DATASET_ID = p_dataset_id
    AND   C.REGION_CODE = p_region_code;
  l_measure_cur measure_cur%ROWTYPE;

  CURSOR dataset_cur IS
    SELECT V.NAME, V.MEASURE_TYPE, D.SOURCE
    FROM BIS_DISPLAY_MEASURES_V V,
         BIS_INDICATORS B,
         BSC_SYS_DATASETS_B D
    WHERE D.DATASET_ID = p_dataset_id
    AND D.DATASET_ID = B.DATASET_ID
    AND B.SHORT_NAME = V.SHORT_NAME;
  l_dataset_cur dataset_cur%ROWTYPE;

BEGIN
  IF (p_region_code IS NOT NULL) THEN
    OPEN measure_cur;
    FETCH measure_cur INTO l_measure_cur;
    IF measure_cur%FOUND THEN
      x_meas_disp_name := l_measure_cur.name;
      x_measure_type := l_measure_cur.measure_type;
      x_source := l_measure_cur.source;
      x_item_type := l_measure_cur.item_type;
    END IF;
    CLOSE measure_cur;
  ELSE
    OPEN dataset_cur;
    FETCH dataset_cur INTO l_dataset_cur;
    IF dataset_cur%FOUND THEN
      x_meas_disp_name := l_dataset_cur.name;
      x_measure_type := l_dataset_cur.measure_type;
      x_source := l_dataset_cur.source;
      x_item_type := '';
    END IF;
    CLOSE dataset_cur;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF measure_cur%ISOPEN THEN
      CLOSE measure_cur;
    END IF;
    IF dataset_cur%ISOPEN THEN
      CLOSE dataset_cur;
    END IF;
END Get_Measure_Prop;

/**************************************************
 NAME        : Get_Functional_Area_Code
 DESCRIPTION : This API will return the Functional Area code
               This is being used in CustomViewCanvasSessionManager.java
 /**************************************************/
FUNCTION Get_Functional_Area_Code
RETURN VARCHAR2 IS
BEGIN
   RETURN BSC_CUSTOM_VIEW_UI_WRAPPER.C_FUNCTIONAL_AREA;
END Get_Functional_Area_Code;

/**************************************************
 NAME        : Get_Form_Function_Code
 DESCRIPTION : This API will return the Form Function Code
               This is being used in CustomViewCanvasSessionManager.java
/**************************************************/
FUNCTION Get_Form_Function_Code
RETURN VARCHAR2 IS
BEGIN
   RETURN BSC_CUSTOM_VIEW_UI_WRAPPER.C_FORM_FUNCTION;
END Get_Form_Function_Code;

/**************************************************
 NAME        : Get_Tab_Fun_Fa_Prop
 DESCRIPTION : This API returns the Function name and Functional Area shortName
               based on the p_type value.
               If the value of p_type is C_FUNCTIONAL_AREA then it returns the
               Functional Area shortname.
               If the value of p_type is C_FORM_FUNCTION then it returns the
               Form Functio name.
               This is being used in CustomViewCanvasSessionManager.java
 INPUT       : p_tab_id
             : p_tab_view_id
             : p_type
/**************************************************/

FUNCTION Get_Tab_Fun_Fa_Prop
(
      p_tab_id      IN  NUMBER
    , p_tab_view_id IN  NUMBER
    , p_type        IN  VARCHAR
) RETURN VARCHAR2 IS

  l_fun_name        FND_FORM_FUNCTIONS_VL.function_name%TYPE;
  l_short_name      BIS_FUNCTIONAL_AREAS_VL.short_name%TYPE;
  l_name            VARCHAR2(100);

BEGIN
    SELECT ff.function_name,fa.short_name
    INTO   l_fun_name,l_short_name
    FROM   bis_form_function_extension ext,
           bis_functional_areas_vl fa,
           fnd_form_functions_vl ff
    WHERE
           ff.parameters LIKE '%pTabId_'||p_tab_id|| '&pViewId_'||p_tab_view_id||'%'
    AND    ext.functional_area_id = fa.functional_area_id (+)
    AND    ff.function_name = ext.object_name (+);

    IF(BSC_CUSTOM_VIEW_UI_WRAPPER.C_FUNCTIONAL_AREA=p_type) THEN
        l_name:=l_short_name;
    ELSIF(BSC_CUSTOM_VIEW_UI_WRAPPER.C_FORM_FUNCTION=p_type)THEN
        l_name:=l_fun_name;
    END IF;

  RETURN l_name;
END Get_Tab_Fun_Fa_Prop;

/**************************************************
 NAME        : add_or_update_kpi_trend
 DESCRIPTION : This api inserts trend information into BSC_TAB_VIEW_LABELS table for objectives.
/**************************************************/

PROCEDURE add_or_update_kpi_trend(
  p_tab_id            IN NUMBER
 ,p_tab_view_id       IN NUMBER
 ,p_object_id         IN NUMBER
 ,p_text_flag         IN NUMBER
 ,p_label_text        IN VARCHAR2
 ,p_font_size         IN NUMBER
 ,p_font_style        IN NUMBER
 ,p_font_color        IN NUMBER
 ,p_left              IN NUMBER
 ,p_top               IN NUMBER
 ,p_width             IN NUMBER
 ,p_height            IN NUMBER
 ,p_kpi_id            IN NUMBER
 ,p_function_id       IN NUMBER
 ,x_return_status     OUT NOCOPY VARCHAR2
 ,x_msg_count         OUT NOCOPY NUMBER
 ,x_msg_data          OUT NOCOPY VARCHAR2
) IS
BEGIN
  SAVEPOINT addorupdatekpitrend;
  fnd_msg_pub.initialize;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BSC_CUSTOM_VIEW_UI_WRAPPER.add_or_update_tab_view_label(
    p_tab_id => p_tab_id
   ,p_tab_view_id => p_tab_view_id
   ,p_object_id => p_object_id
   ,p_object_type => c_type_kpi_trend
   ,p_label_text => p_label_text
   ,p_text_flag => p_text_flag
   ,p_font_color => p_font_color
   ,p_font_size => p_font_size
   ,p_font_style => p_font_style
   ,p_left => p_left
   ,p_top => p_top
   ,p_width => p_width
   ,p_height => p_height
   ,p_note_text => NULL
   ,p_link_id => p_kpi_id
   ,p_function_id => p_function_id
   ,x_return_status => x_return_status
   ,x_msg_count => x_msg_count
   ,x_msg_data => x_msg_data
  );

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO addorupdatekpitrend;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_data      :=  SQLERRM;
END add_or_update_kpi_trend;


END BSC_CUSTOM_VIEW_UI_WRAPPER;

/
