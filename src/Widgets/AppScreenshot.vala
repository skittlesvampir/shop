// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2014-2016 elementary LLC. (https://elementary.io)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authored by: Ian Santopietro <ian@system76.com>
 */
 public class AppCenter.Widgets.AppScreenshot : Gtk.DrawingArea {
    private string file_path;
    private Gdk.Pixbuf? pixbuf;
    private Cairo.Surface? surface;
    private int pixbuf_width {
    get { return pixbuf != null ? pixbuf.width : 1; }
    }
    private int pixbuf_height {
    get { return pixbuf != null ? pixbuf.height : 1; }
    }

    public void set_path (string path_text) {
        file_path = path_text;
        try {
            pixbuf = new Gdk.Pixbuf.from_file (file_path);
        }
        catch (Error e) {
            critical ("Couldn't load pixbuf: %s", e.message);
            pixbuf = null;
        }
    }

    public void get_cairo_surface () {
        if (pixbuf != null) {
            surface = Gdk.cairo_surface_create_from_pixbuf (pixbuf, 1, null);
        }
    }

    private int get_useful_height () {
        var alloc_width = get_allocated_width ();
        return alloc_width / pixbuf_width * pixbuf_height;
    }

    private double get_scale_factor () {
        return get_allocated_width () / pixbuf_width;
    }

    protected override bool draw (Cairo.Context cr) {
        get_cairo_surface ();
        if (pixbuf == null && surface != null)
            return Gdk.EVENT_PROPAGATE;
        var scale = get_scale_factor ();
        cr.scale (scale, scale);
        cr.set_source_surface (surface, 0, 0);
        cr.paint ();
        var widget_height = get_useful_height ();
        set_size_request (-1, widget_height);
        return Gdk.EVENT_PROPAGATE;
    }

    protected override Gtk.SizeRequestMode get_request_mode () {
        return Gtk.SizeRequestMode.HEIGHT_FOR_WIDTH;
    }

    protected override void get_preferred_width (out int min, out int nat) {
    min = 0;
    nat = pixbuf_width;
    }

    protected override void get_preferred_height (out int min, out int nat) {
    min = 0;
    nat = pixbuf_height;
    }

    protected override void get_preferred_height_for_width (int width, out int min, out int nat) {
        min = width * (pixbuf_height / pixbuf_width);
        min = min.clamp(0, 1000);
    nat = min;
    }

    protected override void get_preferred_width_for_height (int height, out int min, out int nat) {
        min = height * (pixbuf_width / pixbuf_height);
        min = min.clamp(0, 800);
    nat = min;
    }
}
