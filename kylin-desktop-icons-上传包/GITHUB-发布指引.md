# GitHub 发布指引（照抄即可 / Copy & paste）

## 第 1 步：新建仓库

打开 https://github.com/new ，填写：

- **Repository name（仓库名）**：`kylin-desktop-icons`
- **Description（描述）**：粘贴下面这一行

```text
一键隐藏/恢复银河麒麟V10桌面的计算机/回收站/主文件夹三个内置系统图标（UKUI+peony），双击操作、即时生效、可回滚 | One-click hide/restore of Kylin V10 desktop built-in icons (Computer/Trash/Home), UKUI+peony, instant effect, reversible
```

- 选 **Public**（公开，造福更多用户）
- **不要**勾选 "Add a README file"（我们自带 README）
- 点 **Create repository**

## 第 2 步：上传文件

在新仓库页面点 **Add file → Upload files**，把 `kylin-desktop-icons-v1.0.0.zip` 解压后的整个 `kylin-desktop-icons` 文件夹里的**全部内容**拖进去：

```text
README.md
LICENSE
RELEASE-NOTES.md
hide-desktop-icons.sh
install-desktop.sh
assets/
  ├── hide.png
  ├── hide.svg
  ├── restore.png
  └── restore.svg
```

（注意：拖的是文件夹**里面**的这些文件，连同 `assets` 文件夹；不是把最外层文件夹整个拖进去。）

拉到页面底部点 **Commit changes**。

## 第 3 步：加 Topics（让中文用户搜得到）

仓库首页右侧 **About** 区点 ⚙ 齿轮，在 Topics 框里**逐个输入、每输一个按一次回车**：

```text
kylin
galaxy-kylin
ukui
linux
bash
desktop
peony
aarch64
performance
```

（Topics 只能用英文小写字母/数字/连字符，中文放不进去；中文检索靠上面的描述覆盖。）

点 **Save changes**。

## 第 4 步：发 Release（可选）

仓库右侧 **Releases → Create a new release**：

- Tag：`v1.0.0`
- Title：`v1.0.0 麒麟桌面系统图标管理`
- 描述：粘贴 `RELEASE-NOTES.md` 的内容
- 把 `kylin-desktop-icons-v1.0.0.zip` 拖进附件区
- 点 **Publish release**

---

## English quick version

1. New repo at https://github.com/new named `kylin-desktop-icons`, Public, no README (we ship one). Paste the bilingual description above into Description.
2. Add file → Upload files → drag in ALL files from the `kylin-desktop-icons/` folder (including the `assets/` folder) → Commit changes.
3. About → ⚙ → add topics listed above (press Enter after each) → Save changes.
4. (Optional) Releases → Create a new release, tag `v1.0.0`, attach the zip, paste RELEASE-NOTES.md.
