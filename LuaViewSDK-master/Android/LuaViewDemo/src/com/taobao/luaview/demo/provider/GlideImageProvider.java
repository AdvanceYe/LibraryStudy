/*
 * Created by LuaView.
 * Copyright (c) 2017, Alibaba Group. All rights reserved.
 *
 * This source code is licensed under the MIT.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

package com.taobao.luaview.demo.provider;

import android.app.Activity;
import android.content.Context;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.load.resource.bitmap.GlideBitmapDrawable;
import com.bumptech.glide.load.resource.drawable.GlideDrawable;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.taobao.luaview.provider.ImageProvider;
import com.taobao.luaview.view.imageview.BaseImageView;
import com.taobao.luaview.view.imageview.DrawableLoadCallback;

import java.lang.ref.WeakReference;

/**
 * XXX
 *
 * @author song
 * @date 16/4/11
 * 主要功能描述
 * 修改描述
 * 下午5:42 song XXX
 */
public class GlideImageProvider implements ImageProvider {

    @Override
    public void pauseRequests(final ViewGroup view, Context context) {
        Glide.with(context).pauseRequests();
    }

    @Override
    public void resumeRequests(final ViewGroup view, Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            if (context instanceof Activity && (((Activity) context).isFinishing() || ((Activity) context).isDestroyed())) {
                return;
            }
        } else {
            if (context instanceof Activity && (((Activity) context).isFinishing())) {
                return;
            }
        }
        if (Glide.with(context).isPaused()) {
            Glide.with(context).resumeRequests();
        }
    }

    /**
     * load url
     *
     * @param referImageView
     * @param url
     * @param callback
     */
    public void load(final Context context, final WeakReference<BaseImageView> referImageView, final String url, final WeakReference<DrawableLoadCallback> callback) {
        if (referImageView != null) {
            ImageView imageView = referImageView.get();
            if (imageView != null) {
                if (callback != null) {
                    Glide.with(context).load(url).listener(new RequestListener<String, GlideDrawable>() {
                        @Override
                        public boolean onException(Exception e, String model, Target<GlideDrawable> target, boolean isFirstResource) {
                            if (callback != null && callback.get() != null) {
                                callback.get().onLoadResult(null);
                            }
                            return false;
                        }

                        @Override
                        public boolean onResourceReady(GlideDrawable resource, String model, Target<GlideDrawable> target, boolean isFromMemoryCache, boolean isFirstResource) {
                            if (callback != null && callback.get() != null) {
                                callback.get().onLoadResult(resource.getCurrent());
                            }
                            return false;
                        }
                    }).into(imageView);
                } else {
                    Glide.with(context).load(url).into(imageView);
                }
            }
        }
    }

    @Override
    public void preload(final Context context, String url, final DrawableLoadCallback callback) {
        if (callback != null) {
            Glide.with(context).load(url).listener(new RequestListener<String, GlideDrawable>() {
                @Override
                public boolean onException(Exception e, String model, Target<GlideDrawable> target, boolean isFirstResource) {
                    if (callback != null) {
                        callback.onLoadResult(null);
                    }
                    return false;
                }

                @Override
                public boolean onResourceReady(GlideDrawable resource, String model, Target<GlideDrawable> target, boolean isFromMemoryCache, boolean isFirstResource) {
                    if (callback != null) {
                        Drawable r = resource instanceof GlideBitmapDrawable ? new BitmapDrawable(context.getResources(), ((GlideBitmapDrawable) resource).getBitmap()) : resource;
                        callback.onLoadResult(r);
                    }
                    return false;
                }
            }).preload();
        } else {
            Glide.with(context).load(url).preload();
        }
    }
}
